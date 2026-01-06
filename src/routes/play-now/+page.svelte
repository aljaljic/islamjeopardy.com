<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Select } from '$lib/components/ui/select';
	import { Switch } from '$lib/components/ui/switch';
	import { goto } from '$app/navigation';
	import { Gamepad2, Star, Users, TrendingUp, User, Database, AlertCircle, ArrowRight } from 'lucide-svelte';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let teamCount = $state(2);
	// Use game ID from URL param if provided, otherwise default to first game
	let selectedGameId = $state<string | null>(
		data.selectedGameId && data.games.some(g => g.id === data.selectedGameId)
			? data.selectedGameId
			: data.games.length > 0 ? data.games[0].id : null
	);
	let doubleJeopardyEnabled = $state(true);

	// Difficulty badge colors
	const difficultyColors: Record<string, string> = {
		kids: 'from-green-500 to-emerald-600',
		beginner: 'from-blue-500 to-indigo-600',
		intermediate: 'from-amber-500 to-orange-600',
		advanced: 'from-purple-500 to-violet-600'
	};

	function startPlaying() {
		if (selectedGameId && teamCount >= 1 && teamCount <= 8) {
			goto(`/games/${selectedGameId}/play?teams=${teamCount}&dj=${doubleJeopardyEnabled ? '1' : '0'}`);
		}
	}
</script>

<svelte:head>
	<title>Play Now - Islamic Jeopardy</title>
</svelte:head>

<div class="container mx-auto px-4 py-8">
	<div class="mx-auto max-w-2xl">
		<!-- Header -->
		<div class="mb-8 text-center">
			<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl gradient-primary shadow-lg shadow-primary/25">
				<Gamepad2 class="h-8 w-8 text-white" />
			</div>
			<h1 class="mb-2 text-3xl font-bold sm:text-4xl">Play Now</h1>
			<p class="text-lg text-muted-foreground">
				Select the number of players and start playing immediately!
			</p>
		</div>

		{#if data.dbError}
			<Card class="max-w-md mx-auto border-2 border-destructive/20 shadow-lg">
				<CardHeader class="text-center">
					<div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-destructive/10">
						<Database class="h-7 w-7 text-destructive" />
					</div>
					<CardTitle>Database Setup Required</CardTitle>
					<CardDescription>
						The database tables haven't been created yet. Please run the schema in your Supabase SQL Editor.
					</CardDescription>
				</CardHeader>
			</Card>
		{:else if data.games.length === 0}
			<Card class="max-w-md mx-auto border-2 border-primary/20 shadow-lg">
				<CardHeader class="text-center">
					<div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10">
						<AlertCircle class="h-7 w-7 text-primary" />
					</div>
					<CardTitle>No Games Available</CardTitle>
					<CardDescription>
						Run the seed data to add sample games, or create your own!
					</CardDescription>
				</CardHeader>
				<CardContent>
					<p class="text-sm text-muted-foreground mb-4 text-center">
						Run <code class="rounded bg-muted px-1.5 py-0.5 font-mono text-xs">supabase/seed.sql</code> in your Supabase SQL Editor to add sample games.
					</p>
					<a href="/">
						<Button variant="outline" class="w-full touch-target">Back to Home</Button>
					</a>
				</CardContent>
			</Card>
		{:else}
			<Card class="mb-6 border-2 shadow-lg">
				<CardHeader>
					<CardTitle>Quick Setup</CardTitle>
					<CardDescription>
						Choose your game and number of players to start playing
					</CardDescription>
				</CardHeader>
				<CardContent class="space-y-6">
					<!-- Game Selection -->
					<div class="space-y-2">
						<label for="game-select" class="text-sm font-medium flex items-center gap-2">
							<Gamepad2 class="h-4 w-4 text-primary" />
							Select Game
						</label>
						<Select id="game-select" bind:value={selectedGameId} class="w-full touch-target">
							{#each data.games as game}
								<option value={game.id}>
									{game.title} ({game.difficulty})
									{#if game.average_rating}
										- {game.average_rating.toFixed(1)}★
									{/if}
								</option>
							{/each}
						</Select>
						{#if selectedGameId}
							{@const selectedGame = data.games.find((g) => g.id === selectedGameId)}
							{#if selectedGame}
								<p class="text-sm text-muted-foreground">
									{selectedGame.description || 'No description provided'}
								</p>
							{/if}
						{/if}
					</div>

					<!-- Player Count Selection -->
					<div class="space-y-2">
						<label for="player-count" class="text-sm font-medium flex items-center gap-2">
							<Users class="h-4 w-4 text-primary" />
							Number of Players
						</label>
						<Select id="player-count" bind:value={teamCount} class="w-full touch-target">
							{#each [1, 2, 3, 4, 5, 6, 7, 8] as num}
								<option value={num}>{num} Player{num > 1 ? 's' : ''}</option>
							{/each}
						</Select>
						<p class="text-xs text-muted-foreground">
							Select how many players will compete.
						</p>
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
									<Switch bind:checked={doubleJeopardyEnabled} aria-label="Enable Double Jeopardy Mode" class="scale-110" />
								</div>
								<span class="text-xs font-medium {doubleJeopardyEnabled ? 'text-green-600 font-bold' : 'text-muted-foreground'}">ON</span>
							</div>
						</div>
					</div>

					<Button
						class="w-full min-h-[56px] text-lg font-bold gradient-primary border-0 text-white shadow-lg shadow-primary/25 active:shadow-primary/15 active:scale-[0.98] transition-all touch-target"
						onclick={startPlaying}
					>
						Start Playing
						<ArrowRight class="ml-2 h-5 w-5" />
					</Button>
				</CardContent>
			</Card>

			<!-- Game Preview -->
			{#if selectedGameId}
				{@const selectedGame = data.games.find((g) => g.id === selectedGameId)}
				{#if selectedGame}
					<Card class="border-2 shadow-lg">
						<CardHeader>
							<CardTitle>{selectedGame.title}</CardTitle>
							<CardDescription>{selectedGame.description || 'No description provided'}</CardDescription>
						</CardHeader>
						<CardContent>
							<div class="flex flex-wrap items-center gap-3 text-sm">
								<span class="rounded-full bg-gradient-to-r {difficultyColors[selectedGame.difficulty.toLowerCase()] || 'from-gray-500 to-gray-600'} px-3 py-1 font-semibold text-white shadow-sm">
									{selectedGame.difficulty}
								</span>
								{#if selectedGame.average_rating}
									<span class="flex items-center gap-1 text-muted-foreground">
										<Star class="h-4 w-4 fill-amber-400 text-amber-400" />
										<span class="font-medium">{selectedGame.average_rating.toFixed(1)}</span>
										<span class="text-xs">({selectedGame.rating_count} ratings)</span>
									</span>
								{/if}
								<span class="flex items-center gap-1 text-muted-foreground">
									<TrendingUp class="h-4 w-4" />
									{selectedGame.total_plays} plays
								</span>
								<span class="flex items-center gap-1 text-muted-foreground">
									<User class="h-4 w-4" />
									{selectedGame.profiles?.display_name || selectedGame.profiles?.username}
								</span>
							</div>
						</CardContent>
					</Card>
				{/if}
			{/if}
		{/if}
	</div>
</div>

<style>
	/* Make Switch toggle red/green */
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
