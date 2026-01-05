<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Input } from '$lib/components/ui/input';
	import { Select } from '$lib/components/ui/select';
	import { untrack } from 'svelte';
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

	// Setup state - initialize from query param if available
	let playerCount = $state(data.initialTeamCount ?? 1);
	let playerNames = $state<string[]>(
		data.initialTeamCount
			? Array.from({ length: data.initialTeamCount }, (_, i) => `Team ${i + 1}`)
			: ['Team 1']
	);
	
	// Track previous count with non-reactive variable to avoid infinite loops
	let previousCount = playerCount;

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

	// Update team names array when count changes
	// Only react to playerCount changes, using untrack to avoid infinite loops
	$effect(() => {
		const currentCount = playerCount;
		if (previousCount !== currentCount) {
			// Use untrack to read playerNames without making it a dependency
			const currentNames = untrack(() => playerNames);
			const newNames = [...currentNames];
			// Add new teams if count increased
			while (newNames.length < currentCount) {
				newNames.push(`Team ${newNames.length + 1}`);
			}
			// Trim if count decreased
			playerNames = newNames.slice(0, currentCount);
			previousCount = currentCount;
		}
	});

	function startGame() {
		players = playerNames.map((name, i) => ({
			id: `player-${i}`,
			name: name || `Team ${i + 1}`,
			score: 0
		}));
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

		if (addPoints) {
			players[currentPlayerIndex].score += currentQuestion.points;
		} else {
			players[currentPlayerIndex].score -= currentQuestion.points;
			// Ensure score doesn't go below 0
			if (players[currentPlayerIndex].score < 0) {
				players[currentPlayerIndex].score = 0;
			}
		}
		players = [...players];

		// Store last answered question for +/- buttons
		lastAnsweredQuestion = {
			points: currentQuestion.points
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
		gamePhase = 'setup';
	}

	const currentTheme = $derived(themes[theme]);
</script>

<svelte:head>
	<title>{data.game.title} - Play | Islamic Jeopardy</title>
</svelte:head>

<div class="min-h-screen {currentTheme.board} p-2 md:p-4">
	<!-- Header -->
	<div class="container mx-auto mb-4">
		<div class="flex items-center justify-between gap-2">
			<h1 class="truncate text-lg font-bold md:text-xl {currentTheme.header}">
				{data.game.title}
			</h1>
			{#if gamePhase !== 'setup'}
				<div class="flex shrink-0 gap-2">
					<Select bind:value={theme} class="w-32 bg-background text-foreground text-sm">
						<option value="modern">Modern</option>
						<option value="islamic">Islamic</option>
					</Select>
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
						<label for="player-count" class="text-sm font-medium">Number of Teams</label>
						<Select id="player-count" bind:value={playerCount} class="w-full">
							{#each [1, 2, 3, 4, 5, 6, 7, 8] as num}
								<option value={num}>{num} Team{num > 1 ? 's' : ''}</option>
							{/each}
						</Select>
						<p class="text-xs text-muted-foreground">
							Each team can have multiple players. Select how many teams will compete.
						</p>
					</div>

					<!-- Team Names -->
					<div class="space-y-2">
						<span class="text-sm font-medium">Team Names</span>
						{#each { length: playerCount } as _, i}
							<Input bind:value={playerNames[i]} placeholder={`Team ${i + 1}`} aria-label={`Team ${i + 1} name`} />
						{/each}
					</div>

					<Button class="w-full" onclick={startGame}>Start Game</Button>
				</CardContent>
			</Card>
		</div>
	{/if}

	<!-- Playing Phase - Game Board -->
	{#if gamePhase === 'playing'}
		<!-- Last Card Points Adjustment -->
		{#if lastAnsweredQuestion}
			<div class="container mx-auto mb-4 px-2">
				<div class="mx-auto max-w-4xl rounded-xl bg-gradient-to-r from-primary/10 to-purple-500/10 border-2 border-primary/30 p-3 md:p-4 shadow-md">
					<div class="flex flex-col md:flex-row items-center justify-between gap-3 md:gap-4">
						<div class="flex-1 text-center md:text-left">
							<p class="text-xs md:text-sm font-semibold text-muted-foreground mb-1">Last Card Value</p>
							<p class="text-xl md:text-2xl font-bold text-primary">{lastAnsweredQuestion.points} Points</p>
						</div>
						<div class="flex flex-wrap justify-center gap-2 md:gap-3 w-full md:w-auto">
							{#each players as player, i}
								<div class="flex flex-col items-center gap-1">
									<p class="text-xs font-medium text-muted-foreground truncate max-w-[80px]">{player.name}</p>
									<div class="flex gap-1">
										<Button
											size="sm"
											variant="outline"
											onclick={() => adjustPoints(i, false)}
											class="h-9 w-9 p-0 text-red-600 hover:bg-red-50 hover:border-red-400 font-bold text-lg shadow-sm hover:shadow-md transition-all"
											title={`Subtract ${lastAnsweredQuestion.points} points from ${player.name}`}
										>
											-
										</Button>
										<Button
											size="sm"
											onclick={() => adjustPoints(i, true)}
											class="h-9 w-9 p-0 font-bold text-lg shadow-sm hover:shadow-md transition-all"
											title={`Add ${lastAnsweredQuestion.points} points to ${player.name}`}
										>
											+
										</Button>
									</div>
								</div>
							{/each}
						</div>
					</div>
				</div>
			</div>
		{/if}

		<!-- Score Display -->
		<div class="container mx-auto mb-6">
			<div class="flex flex-wrap justify-center gap-3 md:gap-4">
				{#each players as player, i}
					<div
						class="rounded-xl border-2 px-4 py-3 text-center shadow-lg transition-all transform hover:scale-105 {currentTheme.scoreCard}
							{i === currentPlayerIndex ? 'ring-4 ring-yellow-400 ring-offset-2 scale-110 shadow-2xl' : 'hover:shadow-xl'}"
					>
						<p class="text-sm font-bold md:text-base mb-1">{player.name}</p>
						<p class="text-2xl font-extrabold md:text-3xl">{player.score}</p>
					</div>
				{/each}
			</div>
		</div>

		<!-- Game Board Grid -->
		<div class="container mx-auto overflow-x-auto pb-4">
			<div class="grid min-w-[320px] grid-cols-5 gap-1 md:gap-2">
				<!-- Category Headers -->
				{#each data.categories as category}
					<div
						class="border-b-2 p-1 text-center text-[10px] font-bold uppercase md:p-3 md:text-xs lg:text-sm {currentTheme.category}"
					>
						<span class="line-clamp-2">{category.name}</span>
					</div>
				{/each}

				<!-- Question Cells (5 rows of 5) -->
				{#each [0, 1, 2, 3, 4] as rowIndex}
					{#each data.categories as category, colIndex}
						{@const question = category.questions[rowIndex]}
						{@const isAnswered = answeredQuestions.has(question.id)}
						<button
							onclick={() => selectQuestion(colIndex, rowIndex)}
							disabled={isAnswered}
							class="jeopardy-card aspect-square min-h-[48px] border text-lg font-bold md:min-h-[70px] md:text-2xl lg:min-h-[90px] lg:text-3xl
								{isAnswered ? currentTheme.cellAnswered + ' cursor-default opacity-50' : currentTheme.cell + ' cursor-pointer'}"
						>
							{question.points}
						</button>
					{/each}
				{/each}
			</div>
		</div>
	{/if}

	<!-- Question Phase -->
	{#if gamePhase === 'question' && currentQuestion}
		<div class="container mx-auto flex min-h-[60vh] items-center justify-center px-4">
			<Card class="w-full max-w-2xl shadow-2xl border-2 border-primary/30 bg-gradient-to-br from-white to-primary/5">
				<CardHeader class="pb-4">
					<div class="mb-3 flex items-center justify-between">
						<span class="rounded-full bg-primary/10 px-3 py-1 text-sm font-semibold text-primary">{currentQuestion.categoryName}</span>
						<span class="rounded-full bg-gradient-to-r from-blue-600 to-purple-600 px-4 py-2 text-lg font-bold text-white shadow-md border-2 border-blue-500/50">{currentQuestion.points} Points</span>
					</div>
					<CardTitle class="text-2xl md:text-3xl leading-tight text-foreground">{currentQuestion.question_text}</CardTitle>
				</CardHeader>
				<CardContent class="pt-2">
					<p class="mb-6 text-center text-lg font-medium text-muted-foreground">
						{players[currentPlayerIndex].name}'s turn
					</p>
					<Button class="min-h-[64px] w-full text-lg font-bold shadow-lg hover:shadow-xl transition-all" onclick={showAnswer}>Show Answer</Button>
				</CardContent>
			</Card>
		</div>
	{/if}

	<!-- Answer Phase -->
	{#if gamePhase === 'answer' && currentQuestion}
		<div class="container mx-auto flex min-h-[60vh] items-center justify-center px-4">
			<Card class="w-full max-w-2xl shadow-2xl border-2 border-primary/30 bg-gradient-to-br from-white to-primary/5">
				<CardHeader class="pb-4">
					<CardTitle class="text-xl md:text-2xl leading-tight">{currentQuestion.question_text}</CardTitle>
				</CardHeader>
				<CardContent class="space-y-6">
					<div class="rounded-xl bg-gradient-to-br from-primary/20 to-primary/10 border-2 border-primary/30 p-6 md:p-8 shadow-lg">
						<p class="text-center text-xl md:text-2xl font-bold text-primary">
							{currentQuestion.answer_text}
						</p>
					</div>

					{#if currentQuestion.explanation}
						<div class="rounded-lg bg-blue-50 border-2 border-blue-200 p-4 md:p-5">
							<p class="text-sm font-semibold text-blue-900 mb-2">💡 Did you know?</p>
							<p class="text-sm md:text-base text-blue-800 leading-relaxed">
								{currentQuestion.explanation}
							</p>
						</div>
					{/if}

					<p class="text-center text-lg font-semibold text-muted-foreground">
						{players[currentPlayerIndex].name}'s answer
					</p>

					<div class="grid grid-cols-2 gap-4">
						<Button
							size="lg"
							onclick={() => handleAnswer(false)}
							variant="outline"
							class="min-h-[64px] text-lg font-bold border-2 hover:bg-red-50 hover:border-red-400 hover:text-red-600 transition-all shadow-md hover:shadow-lg"
						>
							Subtract Points<br />
							<span class="text-sm">(-{currentQuestion.points})</span>
						</Button>
						<Button 
							size="lg" 
							onclick={() => handleAnswer(true)} 
							variant="outline"
							class="min-h-[64px] text-lg font-bold border-2 hover:bg-green-50 hover:border-green-400 hover:text-green-600 transition-all shadow-md hover:shadow-lg"
						>
							Add Points<br />
							<span class="text-sm">(+{currentQuestion.points})</span>
						</Button>
					</div>
				</CardContent>
			</Card>
		</div>
	{/if}

	<!-- Finished Phase -->
	{#if gamePhase === 'finished'}
		<div class="container mx-auto flex min-h-[60vh] items-center justify-center px-4">
			<Card class="w-full max-w-md shadow-2xl border-2 border-primary/30 bg-gradient-to-br from-white to-primary/5">
				<CardHeader>
					<CardTitle class="text-center text-3xl font-bold bg-gradient-to-r from-primary to-purple-600 bg-clip-text text-transparent">
						🎉 Game Over! 🎉
					</CardTitle>
				</CardHeader>
				<CardContent class="space-y-6">
					<div class="space-y-3">
						{#each [...players].sort((a, b) => b.score - a.score) as player, i}
							<div
								class="flex items-center justify-between rounded-xl p-4 shadow-md transition-all
									{i === 0 ? 'bg-gradient-to-r from-yellow-400 to-yellow-500 text-white border-2 border-yellow-300 scale-105' : 
									 i === 1 ? 'bg-gradient-to-r from-gray-300 to-gray-400 text-white border-2 border-gray-200' :
									 i === 2 ? 'bg-gradient-to-r from-amber-600 to-amber-700 text-white border-2 border-amber-500' :
									 'bg-muted border-2 border-border'}"
							>
								<span class="font-bold text-lg">
									{i === 0 ? '🥇 1st ' : i === 1 ? '🥈 2nd ' : i === 2 ? '🥉 3rd ' : `${i + 1}th `}{player.name}
								</span>
								<span class="text-2xl font-bold">{player.score}</span>
							</div>
						{/each}
					</div>

					<div class="grid grid-cols-2 gap-4 pt-2">
						<Button variant="outline" onclick={resetGame} class="font-bold shadow-md hover:shadow-lg transition-all">
							Play Again
						</Button>
						<a href="/games/{data.game.id}">
							<Button class="w-full font-bold shadow-md hover:shadow-lg transition-all">Back to Game</Button>
						</a>
					</div>
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
</style>
