<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Input } from '$lib/components/ui/input';
	import { Select } from '$lib/components/ui/select';
	import { Switch } from '$lib/components/ui/switch';
	import { Trophy, Medal, Lightbulb, AlertTriangle, PartyPopper, Share2, Maximize2, Minimize2 } from 'lucide-svelte';
	import { toast } from '$lib/stores/toast';
	import { untrack } from 'svelte';
	import { scale } from 'svelte/transition';
	import { leaderboard, familyName } from '$lib/stores/leaderboard.svelte';
	import { page } from '$app/stores';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	// Game state types
	type GameTheme = 'modern' | 'islamic';
	type Player = { id: string; name: string; score: number };
	type GamePhase = 'setup' | 'playing' | 'question' | 'answer' | 'finished';

	// Game state
	let theme = $state<GameTheme>('modern');
	let gamePhase = $state<GamePhase>('setup');
	let players = $state<Player[]>([]);
	let currentPlayerIndex = $state(0);
	let answeredQuestions = $state<Set<string>>(new Set());
	
	// Double Jeopardy mode - default to initialDoubleJeopardy if coming from quick setup
	let doubleJeopardyEnabled = $state(data.initialDoubleJeopardy ?? false);
	let doubleJeopardyQuestions = $state<Set<string>>(new Set());

	// Current question state
	let currentQuestion = $state<{
		id: string;
		question_text: string;
		answer_text: string;
		explanation: string | null;
		points: number;
		categoryName: string;
	} | null>(null);

	// Last answered question for +/- buttons
	let lastAnsweredQuestion = $state<{
		points: number;
	} | null>(null);

	// Player name editing state
	let editingTeamIndex = $state<number | null>(null);
	let editingTeamName = $state('');

	// Setup state - initialize from query param if available
	let playerCount = $state(data.initialTeamCount ?? 1);
	let playerNames = $state<string[]>(
		data.initialTeamCount
			? Array.from({ length: data.initialTeamCount }, (_, i) => `Player ${i + 1}`)
			: ['Player 1']
	);
	
	// Track previous count with non-reactive variable to avoid infinite loops
	let previousCount = playerCount;

	// Track if user manually exited to prevent auto-restart
	let userExited = $state(false);

	// Fullscreen mode for TV display
	let isFullscreen = $state(false);

	function toggleFullscreen() {
		if (!document.fullscreenElement) {
			document.documentElement.requestFullscreen().then(() => {
				isFullscreen = true;
			}).catch(() => {
				toast.error('Could not enter fullscreen');
			});
		} else {
			document.exitFullscreen().then(() => {
				isFullscreen = false;
			});
		}
	}

	// Listen for fullscreen changes (e.g., user presses Escape)
	$effect(() => {
		function handleFullscreenChange() {
			isFullscreen = !!document.fullscreenElement;
		}
		document.addEventListener('fullscreenchange', handleFullscreenChange);
		return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
	});

	// Theme styles - Family-friendly with vibrant colors
	const themes = {
		modern: {
			board: 'bg-gradient-to-br from-blue-50 to-purple-50',
			category: 'bg-gradient-to-br from-blue-500 to-purple-600 text-white border-2 border-blue-400 shadow-lg',
			cell: 'bg-white text-blue-600 border-2 border-blue-300 hover:bg-blue-50 hover:border-blue-500 hover:shadow-md transition-all font-bold',
			cellAnswered: 'bg-gray-200 border-2 border-gray-300 opacity-50',
			header: 'text-blue-700',
			scoreCard: 'bg-gradient-to-br from-blue-500 to-purple-600 text-white border-2 border-blue-400 shadow-lg'
		},
		islamic: {
			board: 'bg-gradient-to-br from-green-50 to-emerald-50',
			category: 'bg-gradient-to-br from-green-600 to-emerald-700 text-white border-2 border-green-400 shadow-lg',
			cell: 'bg-white text-green-700 border-2 border-green-300 hover:bg-green-50 hover:border-green-500 hover:shadow-md transition-all font-bold',
			cellAnswered: 'bg-gray-200 border-2 border-gray-300 opacity-50',
			header: 'text-green-700',
			scoreCard: 'bg-gradient-to-br from-green-600 to-emerald-700 text-white border-2 border-green-400 shadow-lg'
		}
	};

	// Update player names array when count changes
	// Only react to playerCount changes, using untrack to avoid infinite loops
	$effect(() => {
		const currentCount = playerCount;
		if (previousCount !== currentCount) {
			// Use untrack to read playerNames without making it a dependency
			const currentNames = untrack(() => playerNames);
			const newNames = [...currentNames];
			// Add new players if count increased
			while (newNames.length < currentCount) {
				newNames.push(`Player ${newNames.length + 1}`);
			}
			// Trim if count decreased
			playerNames = newNames.slice(0, currentCount);
			previousCount = currentCount;
		}
	});

	// Auto-start game when coming from quick setup (has initialTeamCount)
	$effect(() => {
		if (data.initialTeamCount && gamePhase === 'setup' && !userExited) {
			startGame();
		}
	});

	function startGame() {
		players = playerNames.map((name, i) => ({
			id: `player-${i}`,
			name: name || `Player ${i + 1}`,
			score: 0
		}));
		
		// If double jeopardy is enabled, randomly select 5-8 questions as double jeopardy
		if (doubleJeopardyEnabled) {
			const allQuestionIds: string[] = [];
			data.categories.forEach((category: { questions: { id: string }[] }) => {
				category.questions.forEach((question: { id: string }) => {
					allQuestionIds.push(question.id);
				});
			});
			
			// Randomly select 5-8 questions (20-32% of questions)
			const numDoubleJeopardy = Math.floor(Math.random() * 4) + 5; // 5-8 questions
			const shuffled = [...allQuestionIds].sort(() => Math.random() - 0.5);
			doubleJeopardyQuestions = new Set(shuffled.slice(0, numDoubleJeopardy));
		} else {
			doubleJeopardyQuestions = new Set();
		}
		
		gamePhase = 'playing';
	}

	function selectQuestion(categoryIndex: number, questionIndex: number) {
		const category = data.categories[categoryIndex];
		const question = category.questions[questionIndex];

		if (answeredQuestions.has(question.id)) return;

		currentQuestion = {
			...question,
			categoryName: category.name
		};
		gamePhase = 'question';
	}

	function showAnswer() {
		gamePhase = 'answer';
	}

	function handleAnswer(addPoints: boolean) {
		if (!currentQuestion) return;

		const isDoubleJeopardy = doubleJeopardyQuestions.has(currentQuestion.id);
		const basePoints = currentQuestion.points;
		const pointsToAward = isDoubleJeopardy ? basePoints * 2 : basePoints;

		if (addPoints) {
			players[currentPlayerIndex].score += pointsToAward;
		} else {
			// For double jeopardy cards, wrong answers always deduct points
			// For normal cards, deduct if explicitly subtracting
			if (isDoubleJeopardy) {
				// Double jeopardy: wrong answer deducts 2x points
				players[currentPlayerIndex].score -= pointsToAward;
			} else {
				// Normal card: deduct if subtracting
				players[currentPlayerIndex].score -= basePoints;
			}
			// Ensure score doesn't go below 0
			if (players[currentPlayerIndex].score < 0) {
				players[currentPlayerIndex].score = 0;
			}
		}
		players = [...players];

		// Store last answered question for +/- buttons (use actual points awarded)
		lastAnsweredQuestion = {
			points: isDoubleJeopardy ? pointsToAward : basePoints
		};

		answeredQuestions.add(currentQuestion.id);
		answeredQuestions = new Set(answeredQuestions);

		// Check if game is over
		if (answeredQuestions.size === 25) {
			gamePhase = 'finished';
		} else {
			// Move to next player
			currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
			currentQuestion = null;
			gamePhase = 'playing';
		}
	}

	function skipAnswer() {
		if (!currentQuestion) return;

		// Mark question as answered (grey it out) but don't award points
		answeredQuestions.add(currentQuestion.id);
		answeredQuestions = new Set(answeredQuestions);

		// Store last answered question so points can still be adjusted manually
		const isDoubleJeopardy = doubleJeopardyQuestions.has(currentQuestion.id);
		const pointsValue = isDoubleJeopardy ? currentQuestion.points * 2 : currentQuestion.points;
		lastAnsweredQuestion = {
			points: pointsValue
		};

		// Check if game is over
		if (answeredQuestions.size === 25) {
			gamePhase = 'finished';
		} else {
			// Move to next player
			currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
			currentQuestion = null;
			gamePhase = 'playing';
		}
	}

	function adjustPoints(playerIndex: number, addPoints: boolean) {
		if (!lastAnsweredQuestion) return;

		if (addPoints) {
			players[playerIndex].score += lastAnsweredQuestion.points;
		} else {
			players[playerIndex].score -= lastAnsweredQuestion.points;
			// Ensure score doesn't go below 0
			if (players[playerIndex].score < 0) {
				players[playerIndex].score = 0;
			}
		}
		players = [...players];
	}

	function resetGame() {
		answeredQuestions = new Set();
		players = players.map((p) => ({ ...p, score: 0 }));
		currentPlayerIndex = 0;
		currentQuestion = null;
		lastAnsweredQuestion = null;
		gamePhase = 'playing';
	}

	function backToSetup() {
		answeredQuestions = new Set();
		players = [];
		currentPlayerIndex = 0;
		currentQuestion = null;
		lastAnsweredQuestion = null;
		userExited = true;
		gamePhase = 'setup';
	}

	// Player name editing functions
	function startEditingTeam(index: number) {
		editingTeamIndex = index;
		editingTeamName = players[index].name;
	}

	function saveTeamName() {
		if (editingTeamIndex !== null && editingTeamName.trim()) {
			players[editingTeamIndex].name = editingTeamName.trim();
			players = [...players];
		}
		editingTeamIndex = null;
		editingTeamName = '';
	}

	function cancelEditingTeam() {
		editingTeamIndex = null;
		editingTeamName = '';
	}

	function handleTeamNameKeydown(event: KeyboardEvent) {
		if (event.key === 'Enter') {
			saveTeamName();
		} else if (event.key === 'Escape') {
			cancelEditingTeam();
		}
	}

	// Track if we've saved results for this game
	let resultsSaved = $state(false);

	// Save game results to leaderboard when game finishes
	async function saveGameResults() {
		if (resultsSaved || players.length === 0) return;

		const sortedPlayers = [...players].sort((a, b) => b.score - a.score);
		const highestScore = sortedPlayers[0]?.score ?? 0;

		// Save to local leaderboard
		leaderboard.addResult({
			gameTitle: data.game.title,
			gameId: data.game.id,
			familyName: familyName.value,
			teams: players.map((p) => ({
				name: p.name,
				score: p.score,
				isWinner: p.score === highestScore && highestScore > 0
			})),
			totalQuestions: 25
		});

		// Increment play count in database
		const supabase = $page.data.supabase;
		if (supabase) {
			// Get current play count and increment
			const { data: gameData } = await supabase
				.from('games')
				.select('total_plays')
				.eq('id', data.game.id)
				.single();

			if (gameData) {
				await supabase
					.from('games')
					.update({ total_plays: (gameData.total_plays || 0) + 1 })
					.eq('id', data.game.id);
			}
		}

		resultsSaved = true;
	}

	// Share game results using Web Share API
	async function shareResults() {
		const sortedPlayers = [...players].sort((a, b) => b.score - a.score);
		const winner = sortedPlayers[0];

		// Build results text with medals
		const resultsText = sortedPlayers
			.map((p, i) => {
				const medal = i === 0 ? '🥇' : i === 1 ? '🥈' : i === 2 ? '🥉' : `${i + 1}.`;
				return `${medal} ${p.name}: ${p.score} pts`;
			})
			.join('\n');

		const shareText = `🎉 We played Islamic Jeopardy!\n\n🎮 Game: ${data.game.title}\n\n${resultsText}\n\n🏆 Winner: ${winner.name} with ${winner.score} points!\n\n🕌 Play at islamjeopardy.com`;

		// Try Web Share API first
		if (navigator.share) {
			try {
				await navigator.share({
					title: `Islamic Jeopardy - ${data.game.title}`,
					text: shareText,
					url: `https://islamjeopardy.com/games/${data.game.id}`
				});
				toast.success('Shared successfully!');
			} catch (err) {
				// User cancelled - don't show error
				if ((err as Error).name !== 'AbortError') {
					await copyToClipboard(shareText);
				}
			}
		} else {
			// Fallback to clipboard
			await copyToClipboard(shareText);
		}
	}

	async function copyToClipboard(text: string) {
		try {
			await navigator.clipboard.writeText(text);
			toast.success('Results copied to clipboard!');
		} catch {
			toast.error('Could not copy to clipboard');
		}
	}

	// Effect to save results when game finishes
	$effect(() => {
		if (gamePhase === 'finished' && !resultsSaved) {
			saveGameResults();
		}
	});

	const currentTheme = $derived(themes[theme]);
</script>

<svelte:head>
	<title>{data.game.title} - Play | Islamic Jeopardy</title>
</svelte:head>

<div class="h-dvh {currentTheme.board} p-2 md:p-3 flex flex-col overflow-hidden">
	<!-- Header -->
	<div class="container mx-auto mb-2 md:mb-4 shrink-0">
		<div class="flex items-center justify-between gap-2">
			<h1 class="truncate text-base font-bold md:text-xl {currentTheme.header}">
				{data.game.title}
			</h1>
			{#if gamePhase !== 'setup'}
				<div class="flex shrink-0 gap-2">
					<Select bind:value={theme} class="w-28 lg:w-32 bg-background text-foreground text-sm">
						<option value="modern">Modern</option>
						<option value="islamic">Islamic</option>
					</Select>
					<Button
						variant="outline"
						size="sm"
						onclick={toggleFullscreen}
						title={isFullscreen ? 'Exit fullscreen' : 'Fullscreen (TV mode)'}
						class="hidden sm:flex"
					>
						{#if isFullscreen}
							<Minimize2 class="h-4 w-4" />
						{:else}
							<Maximize2 class="h-4 w-4" />
						{/if}
					</Button>
					<Button variant="outline" size="sm" onclick={backToSetup}>Exit</Button>
				</div>
			{/if}
		</div>
	</div>

	<!-- Setup Phase -->
	{#if gamePhase === 'setup'}
		<div class="container mx-auto flex items-center justify-center py-8 md:py-12">
			<Card class="w-full max-w-md shadow-2xl border-2 border-primary/20">
				<CardHeader>
					<CardTitle class="text-2xl">Game Setup</CardTitle>
				</CardHeader>
				<CardContent class="space-y-6">
					<!-- Theme Selection -->
					<div class="space-y-2">
						<label for="theme-select" class="text-sm font-medium">Board Theme</label>
						<Select id="theme-select" bind:value={theme} class="w-full">
							<option value="modern">Modern (Blue/Purple)</option>
							<option value="islamic">Islamic (Green/Emerald)</option>
						</Select>
					</div>

					<!-- Player Count -->
					<div class="space-y-2">
						<label for="player-count" class="text-sm font-medium">Number of Players</label>
						<Select id="player-count" bind:value={playerCount} class="w-full">
							{#each [1, 2, 3, 4, 5, 6, 7, 8] as num}
								<option value={num}>{num} Player{num > 1 ? 's' : ''}</option>
							{/each}
						</Select>
						<p class="text-xs text-muted-foreground">
							Select how many players will compete.
						</p>
					</div>

					<!-- Player Names -->
					<div class="space-y-2">
						<span class="text-sm font-medium">Player Names</span>
						{#each { length: playerCount } as _, i}
							<Input bind:value={playerNames[i]} placeholder={`Player ${i + 1}`} aria-label={`Player ${i + 1} name`} />
						{/each}
					</div>

					<!-- Double Jeopardy Toggle -->
					<div class="rounded-lg border-2 border-primary/30 bg-background p-4">
						<div class="flex items-center justify-between gap-4">
							<div class="flex-1">
								<p class="text-sm font-semibold mb-1 text-foreground">
									Double Jeopardy Mode
								</p>
								<p class="text-xs text-muted-foreground">
									Random cards worth 2x points. Wrong answers deduct points.
								</p>
							</div>
							<div class="shrink-0 flex items-center gap-2">
								<span class="text-xs font-medium {doubleJeopardyEnabled ? 'text-muted-foreground' : 'text-red-600 font-bold'}">OFF</span>
								<div class="double-jeopardy-switch-wrapper">
									<Switch bind:checked={doubleJeopardyEnabled} aria-label="Enable Double Jeopardy Mode" class="scale-110 double-jeopardy-switch" />
								</div>
								<span class="text-xs font-medium {doubleJeopardyEnabled ? 'text-green-600 font-bold' : 'text-muted-foreground'}">ON</span>
							</div>
						</div>
					</div>

					<Button class="w-full" onclick={startGame}>Start Game</Button>
				</CardContent>
			</Card>
		</div>
	{/if}

	<!-- Playing Phase - Game Board -->
	{#if gamePhase === 'playing'}
		<div class="flex-1 flex flex-col min-h-0">
		<!-- Last Card Points Adjustment -->
		{#if lastAnsweredQuestion}
			<div class="container mx-auto mb-2 px-1 shrink-0">
				<div class="mx-auto max-w-4xl rounded-lg bg-gradient-to-r from-primary/10 to-purple-500/10 border border-primary/30 p-2 md:p-3 shadow-sm">
					<div class="flex items-center justify-center gap-2 md:gap-4 flex-wrap">
						<div class="text-center">
							<span class="text-xs font-semibold text-muted-foreground">Last: </span>
							<span class="text-sm md:text-base font-bold text-primary">{lastAnsweredQuestion.points} pts</span>
						</div>
						<div class="flex flex-wrap justify-center gap-1 md:gap-2">
							{#each players as player, i}
								<div class="flex items-center gap-0.5">
									<span class="text-[10px] md:text-xs font-medium text-muted-foreground truncate max-w-[50px] md:max-w-[70px]">{player.name}</span>
									<Button
										size="sm"
										variant="outline"
										onclick={() => adjustPoints(i, false)}
										class="h-6 w-6 md:h-7 md:w-7 p-0 text-red-600 hover:bg-red-50 hover:border-red-400 font-bold text-sm"
										title={`-${lastAnsweredQuestion.points}`}
									>
										-
									</Button>
									<Button
										size="sm"
										onclick={() => adjustPoints(i, true)}
										class="h-6 w-6 md:h-7 md:w-7 p-0 font-bold text-sm"
										title={`+${lastAnsweredQuestion.points}`}
									>
										+
									</Button>
								</div>
							{/each}
						</div>
					</div>
				</div>
			</div>
		{/if}

		<!-- Score Display -->
		<div class="container mx-auto mb-2 md:mb-3 shrink-0">
			<div class="flex flex-wrap justify-center gap-2 md:gap-3 xl:gap-4">
				{#each players as player, i}
					<div
						class="rounded-lg md:rounded-xl border-2 px-2 py-1 md:px-4 md:py-2 xl:px-5 xl:py-3 text-center shadow-lg transition-all transform hover:scale-105 {currentTheme.scoreCard}
							{i === currentPlayerIndex ? 'ring-2 md:ring-4 ring-yellow-400 ring-offset-1 md:ring-offset-2 scale-105 md:scale-110 shadow-2xl' : 'hover:shadow-xl'}"
					>
						{#if editingTeamIndex === i}
							<input
								type="text"
								bind:value={editingTeamName}
								onkeydown={handleTeamNameKeydown}
								onblur={saveTeamName}
								class="w-full min-w-[60px] max-w-[100px] md:min-w-[80px] md:max-w-[120px] rounded border-2 border-white/50 bg-white/20 px-1 py-0.5 text-center text-xs font-bold text-white placeholder-white/70 focus:border-white focus:outline-none md:text-sm xl:text-base"
								placeholder="Player name"
								autofocus
							/>
						{:else}
							<button
								onclick={() => startEditingTeam(i)}
								class="text-xs font-bold md:text-sm xl:text-base 2xl:text-lg hover:underline cursor-pointer focus:outline-none focus:underline"
								title="Click to rename player"
							>
								{player.name}
							</button>
						{/if}
						<p class="text-lg font-extrabold md:text-2xl xl:text-3xl 2xl:text-4xl">{player.score}</p>
					</div>
				{/each}
			</div>
		</div>

		<!-- Game Board Grid - Fills remaining viewport -->
		<div class="flex-1 container mx-auto flex flex-col min-h-0 pb-2">
			<div class="flex-1 grid grid-cols-5 grid-rows-[auto_repeat(5,1fr)] gap-0.5 md:gap-1 xl:gap-2 min-h-0">
				<!-- Category Headers -->
				{#each data.categories as category}
					<div
						class="border-b-2 p-1 md:p-2 xl:p-3 text-center text-[8px] font-bold uppercase md:text-[10px] lg:text-xs xl:text-sm 2xl:text-base flex items-center justify-center {currentTheme.category}"
					>
						<span class="line-clamp-2">{category.name}</span>
					</div>
				{/each}

				<!-- Question Cells (5 rows of 5) -->
				{#each [0, 1, 2, 3, 4] as rowIndex}
					{#each data.categories as category, colIndex}
						{@const question = category.questions[rowIndex]}
						{@const isAnswered = answeredQuestions.has(question.id)}
						{@const isDoubleJeopardy = doubleJeopardyQuestions.has(question.id)}
						<button
							onclick={() => selectQuestion(colIndex, rowIndex)}
							disabled={isAnswered}
							class="jeopardy-card border text-base font-bold relative md:text-xl lg:text-2xl xl:text-3xl 2xl:text-4xl flex items-center justify-center
								{isAnswered ? currentTheme.cellAnswered + ' cursor-default opacity-50' : currentTheme.cell + ' cursor-pointer'}"
						>
							{question.points}
						</button>
					{/each}
				{/each}
			</div>
		</div>
		</div>
	{/if}

	<!-- Question Phase -->
	{#if gamePhase === 'question' && currentQuestion}
		<div class="container mx-auto flex min-h-[60vh] items-center justify-center px-4">
			<div in:scale={{ start: 0.3, duration: 400, easing: (t) => t * (2 - t) }}>
				<Card class="w-full max-w-2xl xl:max-w-4xl 2xl:max-w-5xl shadow-2xl border-2 border-primary/30 bg-gradient-to-br from-white to-primary/5">
				<CardHeader class="pb-4 xl:pb-6">
					<div class="mb-3 xl:mb-4 flex items-center justify-between">
						<span class="rounded-full bg-primary/10 px-3 py-1 xl:px-4 xl:py-2 text-sm xl:text-base 2xl:text-lg font-semibold text-primary">{currentQuestion.categoryName}</span>
						<span class="rounded-full bg-gradient-to-r from-blue-600 to-purple-600 px-4 py-2 xl:px-6 xl:py-3 text-lg xl:text-xl 2xl:text-2xl font-bold text-white shadow-md border-2 border-blue-500/50">{currentQuestion.points} Points</span>
					</div>
					<CardTitle class="text-2xl md:text-3xl xl:text-4xl 2xl:text-5xl leading-tight text-foreground">{currentQuestion.question_text}</CardTitle>
				</CardHeader>
				<CardContent class="pt-2 xl:pt-4">
					<p class="mb-6 xl:mb-8 text-center text-lg xl:text-xl 2xl:text-2xl font-medium text-muted-foreground">
						{players[currentPlayerIndex].name}'s turn
					</p>
					<Button class="min-h-[64px] xl:min-h-[80px] 2xl:min-h-[96px] w-full text-lg xl:text-xl 2xl:text-2xl font-bold shadow-lg hover:shadow-xl transition-all" onclick={showAnswer}>Show Answer</Button>
				</CardContent>
			</Card>
			</div>
		</div>
	{/if}

	<!-- Answer Phase -->
	{#if gamePhase === 'answer' && currentQuestion}
		{@const isDoubleJeopardy = doubleJeopardyQuestions.has(currentQuestion.id)}
		{@const displayPoints = isDoubleJeopardy ? currentQuestion.points * 2 : currentQuestion.points}
		<div class="container mx-auto flex min-h-[60vh] items-center justify-center px-4">
			<Card class="w-full max-w-2xl xl:max-w-4xl 2xl:max-w-5xl shadow-2xl border-2 border-primary/30 bg-gradient-to-br from-white to-primary/5">
				<CardHeader class="pb-4 xl:pb-6">
					<div class="mb-2 xl:mb-4 flex items-center justify-between gap-4">
						<CardTitle class="text-xl md:text-2xl xl:text-3xl 2xl:text-4xl leading-tight">{currentQuestion.question_text}</CardTitle>
						{#if isDoubleJeopardy}
							<span class="rounded-full bg-yellow-400 px-3 py-1 xl:px-4 xl:py-2 text-sm xl:text-base font-bold text-yellow-900 shrink-0">2x Double Jeopardy</span>
						{/if}
					</div>
				</CardHeader>
				<CardContent class="space-y-6 xl:space-y-8">
					<div class="rounded-xl bg-gradient-to-br from-primary/20 to-primary/10 border-2 border-primary/30 p-6 md:p-8 xl:p-10 2xl:p-12 shadow-lg">
						<p class="text-center text-xl md:text-2xl xl:text-3xl 2xl:text-4xl font-bold text-primary">
							{currentQuestion.answer_text}
						</p>
					</div>

					{#if currentQuestion.explanation}
						<div class="rounded-lg bg-blue-50 border-2 border-blue-200 p-4 md:p-5 xl:p-6">
							<p class="text-sm xl:text-base font-semibold text-blue-900 mb-2 flex items-center gap-2">
								<Lightbulb class="h-4 w-4 xl:h-5 xl:w-5" />
								Did you know?
							</p>
							<p class="text-sm md:text-base xl:text-lg 2xl:text-xl text-blue-800 leading-relaxed">
								{currentQuestion.explanation}
							</p>
						</div>
					{/if}

					<p class="text-center text-lg xl:text-xl 2xl:text-2xl font-semibold text-muted-foreground">
						{players[currentPlayerIndex].name}'s answer
					</p>

					{#if isDoubleJeopardy}
						<div class="rounded-lg bg-yellow-50 border-2 border-yellow-300 p-3 xl:p-4">
							<p class="text-sm xl:text-base font-semibold text-yellow-900 text-center">
								<AlertTriangle class="inline h-4 w-4 xl:h-5 xl:w-5 mr-1" />
							Double Jeopardy: Wrong answer will deduct {displayPoints} points!
							</p>
						</div>
					{/if}

					<div class="flex flex-col md:grid md:grid-cols-2 gap-3 md:gap-4 xl:gap-6 w-full">
						<Button
							size="lg"
							onclick={() => handleAnswer(false)}
							variant="outline"
							class="w-full min-h-[56px] md:min-h-[64px] xl:min-h-[80px] 2xl:min-h-[96px] text-sm md:text-lg xl:text-xl 2xl:text-2xl font-bold border-2 hover:bg-red-50 hover:border-red-400 hover:text-red-600 transition-all shadow-md hover:shadow-lg"
						>
							<div class="flex flex-col items-center justify-center">
								<span>Subtract Points</span>
								<span class="text-xs md:text-sm xl:text-base">(-{displayPoints})</span>
							</div>
						</Button>
						<Button
							size="lg"
							onclick={() => handleAnswer(true)}
							variant="outline"
							class="w-full min-h-[56px] md:min-h-[64px] xl:min-h-[80px] 2xl:min-h-[96px] text-sm md:text-lg xl:text-xl 2xl:text-2xl font-bold border-2 hover:bg-green-50 hover:border-green-400 hover:text-green-600 transition-all shadow-md hover:shadow-lg"
						>
							<div class="flex flex-col items-center justify-center">
								<span>Add Points</span>
								<span class="text-xs md:text-sm xl:text-base">(+{displayPoints})</span>
							</div>
						</Button>
					</div>

					<div class="pt-2 xl:pt-4">
						<Button
							size="lg"
							onclick={skipAnswer}
							variant="ghost"
							class="w-full min-h-[56px] xl:min-h-[64px] text-base xl:text-lg font-semibold text-muted-foreground hover:text-foreground hover:bg-muted transition-all"
						>
							← Back (Skip - No Points)
						</Button>
					</div>
				</CardContent>
			</Card>
		</div>
	{/if}

	<!-- Finished Phase -->
	{#if gamePhase === 'finished'}
		<div class="container mx-auto flex flex-col items-center justify-center px-2 sm:px-4 py-4 sm:py-8 gap-4 sm:gap-6">
			<!-- Award Card -->
			<div class="award-card w-full max-w-sm sm:max-w-md rounded-xl sm:rounded-2xl overflow-hidden shadow-2xl">
				<!-- Header with logo and site -->
				<div class="bg-gradient-to-r from-emerald-600 to-teal-600 px-4 sm:px-6 py-3 sm:py-4 text-center">
					<div class="flex items-center justify-center gap-2 mb-0.5 sm:mb-1">
						<div class="flex items-center justify-center w-8 h-8 sm:w-10 sm:h-10 rounded-xl bg-white/20 shadow-lg">
							<svg class="h-4 w-4 sm:h-5 sm:w-5 text-white" viewBox="0 0 64 64" fill="currentColor" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
								<rect x="16" y="38" width="32" height="14" fill="currentColor" rx="1"/>
								<path d="M32 38 Q 18 38, 18 30 Q 18 24, 24 22 Q 28 20, 32 20 Q 36 20, 40 22 Q 46 24, 46 30 Q 46 38, 32 38" fill="currentColor"/>
								<rect x="10" y="32" width="3" height="20" fill="currentColor" rx="0.5"/>
								<circle cx="11.5" cy="32" r="2" fill="currentColor"/>
								<rect x="51" y="32" width="3" height="20" fill="currentColor" rx="0.5"/>
								<circle cx="52.5" cy="32" r="2" fill="currentColor"/>
								<rect x="28" y="46" width="8" height="6" fill="none" stroke="currentColor" stroke-width="2"/>
								<path d="M32 18 C 30 18, 28.5 18.8, 28.5 20 C 28.5 21.2, 30 22, 32 22 C 34 22, 35.5 21.2, 35.5 20 C 35.5 18.8, 34 18, 32 18" fill="currentColor"/>
							</svg>
						</div>
						<span class="text-lg sm:text-xl font-bold text-white">Islamic Jeopardy</span>
					</div>
					<p class="text-emerald-100 text-xs sm:text-sm">islamjeopardy.com</p>
				</div>

				<!-- Game title -->
				<div class="bg-gradient-to-b from-slate-800 to-slate-900 px-4 sm:px-6 py-3 sm:py-4 text-center border-b border-slate-700">
					<p class="text-slate-400 text-xs sm:text-sm uppercase tracking-wider mb-0.5 sm:mb-1">Game Completed</p>
					<h2 class="text-base sm:text-xl font-bold text-white leading-tight">{data.game.title}</h2>
				</div>

				<!-- Results -->
				<div class="bg-slate-900 px-3 sm:px-6 py-3 sm:py-5 space-y-2 sm:space-y-3">
					{#each [...players].sort((a, b) => b.score - a.score) as player, i}
						<div
							class="flex items-center justify-between rounded-lg sm:rounded-xl p-2.5 sm:p-3 transition-all
								{i === 0 ? 'bg-gradient-to-r from-yellow-500/20 to-amber-500/20 border-2 border-yellow-500/50' :
								 i === 1 ? 'bg-gradient-to-r from-slate-400/10 to-slate-300/10 border border-slate-500/30' :
								 i === 2 ? 'bg-gradient-to-r from-amber-700/20 to-orange-700/20 border border-amber-600/30' :
								 'bg-slate-800/50 border border-slate-700/50'}"
						>
							<span class="font-bold text-sm sm:text-base flex items-center gap-1.5 sm:gap-2 truncate max-w-[60%]">
								{#if i === 0}
									<span class="text-lg sm:text-xl shrink-0">🥇</span>
									<span class="text-yellow-400 truncate">{player.name}</span>
								{:else if i === 1}
									<span class="text-lg sm:text-xl shrink-0">🥈</span>
									<span class="text-slate-300 truncate">{player.name}</span>
								{:else if i === 2}
									<span class="text-lg sm:text-xl shrink-0">🥉</span>
									<span class="text-amber-400 truncate">{player.name}</span>
								{:else}
									<span class="text-slate-400 ml-1 shrink-0">{i + 1}.</span>
									<span class="text-slate-300 truncate">{player.name}</span>
								{/if}
							</span>
							<span class="text-lg sm:text-xl font-bold shrink-0 {i === 0 ? 'text-yellow-400' : i === 1 ? 'text-slate-300' : i === 2 ? 'text-amber-400' : 'text-slate-400'}">{player.score}</span>
						</div>
					{/each}
				</div>

				<!-- Footer -->
				<div class="bg-gradient-to-r from-emerald-600 to-teal-600 px-4 sm:px-6 py-2 sm:py-3 text-center">
					<p class="text-emerald-100 text-[10px] sm:text-xs">Play Islamic trivia with family and friends!</p>
				</div>
			</div>

			<!-- Action Buttons (not included in screenshot) -->
			<Card class="w-full max-w-sm sm:max-w-md shadow-xl border-2 border-primary/20">
				<CardContent class="pt-4 sm:pt-6 space-y-3 sm:space-y-4">
					<!-- Share Button -->
					<Button
						onclick={shareResults}
						class="w-full min-h-[48px] sm:min-h-[52px] text-sm sm:text-base font-bold bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white border-0 shadow-lg hover:shadow-xl transition-all touch-target"
					>
						<Share2 class="h-4 w-4 sm:h-5 sm:w-5 mr-2" />
						Share Results
					</Button>

					<div class="grid grid-cols-2 gap-2 sm:gap-3">
						<Button variant="outline" onclick={resetGame} class="font-bold shadow-md hover:shadow-lg transition-all text-sm sm:text-base touch-target">
							Play Again
						</Button>
						<a href="/games/{data.game.id}">
							<Button class="w-full font-bold shadow-md hover:shadow-lg transition-all text-sm sm:text-base touch-target">Back to Game</Button>
						</a>
					</div>

					<a href="/leaderboard" class="block">
						<Button variant="ghost" class="w-full text-muted-foreground hover:text-primary text-sm sm:text-base">
							<Trophy class="h-4 w-4 mr-2" />
							View Leaderboard
						</Button>
					</a>
				</CardContent>
			</Card>
		</div>
	{/if}
</div>

<style>
	/* JeopardyLabs-style zoom-in animation */
	.jeopardy-card:not(:disabled) {
		position: relative;
		transform-origin: center center;
		transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1),
		            box-shadow 0.25s ease,
		            filter 0.25s ease,
		            z-index 0.25s step-end;
		will-change: transform;
	}

	.jeopardy-card:not(:disabled):hover {
		transform: scale(1.05);
		box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
		filter: brightness(1.1);
		z-index: 10;
	}

	.jeopardy-card:not(:disabled):active {
		transform: scale(1.2);
		box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
		filter: brightness(1.15);
		transition: transform 0.15s cubic-bezier(0.4, 0, 0.2, 1),
		            box-shadow 0.15s ease,
		            filter 0.15s ease;
		z-index: 20;
	}

	/* Smooth return animation after click */
	.jeopardy-card:not(:disabled) {
		animation: none;
	}

	@keyframes zoomIn {
		0% {
			transform: scale(1);
		}
		50% {
			transform: scale(1.25);
		}
		100% {
			transform: scale(1);
		}
	}

	/* Make Switch toggle red/green like points buttons with black border */
	.double-jeopardy-switch-wrapper :global(button[role="switch"]) {
		border: 3px solid #000000 !important;
		background-color: #ef4444 !important;
	}

	.double-jeopardy-switch-wrapper :global(button[role="switch"][aria-checked="true"]) {
		border: 3px solid #000000 !important;
		background-color: #22c55e !important;
	}

	.double-jeopardy-switch-wrapper :global(button[role="switch"] span) {
		background-color: white !important;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3) !important;
	}
</style>
