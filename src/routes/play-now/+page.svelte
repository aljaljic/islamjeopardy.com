<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Select } from '$lib/components/ui/select';
	import { goto } from '$app/navigation';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let teamCount = $state(2);
	let selectedGameId = $state<string | null>(data.games.length > 0 ? data.games[0].id : null);

	function startPlaying() {
		if (selectedGameId && teamCount >= 1 && teamCount <= 8) {
			goto(`/games/${selectedGameId}/play?teams=${teamCount}`);
		}
	}
</script>

<svelte:head>
	<title>Play Now - Islamic Jeopardy</title>
</svelte:head>

<div class="container mx-auto px-4 py-8">
	<div class="mx-auto max-w-2xl">
		<div class="mb-8 text-center">
			<h1 class="mb-2 text-4xl font-bold">Play Now</h1>
			<p class="text-lg text-muted-foreground">
				Select the number of teams and start playing immediately!
			</p>
		</div>

		{#if data.dbError}
			<Card class="max-w-md mx-auto">
				<CardHeader>
					<CardTitle>Database Setup Required</CardTitle>
					<CardDescription>
						The database tables haven't been created yet. Please run the schema in your Supabase SQL Editor.
					</CardDescription>
				</CardHeader>
			</Card>
		{:else if data.games.length === 0}
			<Card class="max-w-md mx-auto">
				<CardHeader>
					<CardTitle>No Games Available</CardTitle>
					<CardDescription>
						Run the seed data to add sample games, or create your own!
					</CardDescription>
				</CardHeader>
				<CardContent>
					<p class="text-sm text-muted-foreground mb-4">
						Run <code class="rounded bg-muted px-1">supabase/seed.sql</code> in your Supabase SQL Editor to add sample games.
					</p>
					<a href="/">
						<Button variant="outline" class="w-full">Back to Home</Button>
					</a>
				</CardContent>
			</Card>
		{:else}
			<Card class="mb-6">
				<CardHeader>
					<CardTitle>Quick Setup</CardTitle>
					<CardDescription>
						Choose your game and number of teams to start playing
					</CardDescription>
				</CardHeader>
				<CardContent class="space-y-6">
					<!-- Game Selection -->
					<div class="space-y-2">
						<label for="game-select" class="text-sm font-medium">Select Game</label>
						<Select id="game-select" bind:value={selectedGameId} class="w-full">
							{#each data.games as game}
								<option value={game.id}>
									{game.title} ({game.difficulty})
									{#if game.average_rating}
										- ⭐ {game.average_rating.toFixed(1)}
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

					<!-- Team Count Selection -->
					<div class="space-y-2">
						<label for="team-count" class="text-sm font-medium">Number of Teams</label>
						<Select id="team-count" bind:value={teamCount} class="w-full">
							{#each [1, 2, 3, 4, 5, 6, 7, 8] as num}
								<option value={num}>{num} Team{num > 1 ? 's' : ''}</option>
							{/each}
						</Select>
						<p class="text-xs text-muted-foreground">
							Each team can have multiple players. Select how many teams will compete.
						</p>
					</div>

					<Button class="w-full min-h-[56px] text-lg" onclick={startPlaying}>
						Start Playing →
					</Button>
				</CardContent>
			</Card>

			<!-- Game Preview -->
			{#if selectedGameId}
				{@const selectedGame = data.games.find((g) => g.id === selectedGameId)}
				{#if selectedGame}
					<Card>
						<CardHeader>
							<CardTitle>{selectedGame.title}</CardTitle>
							<CardDescription>{selectedGame.description || 'No description provided'}</CardDescription>
						</CardHeader>
						<CardContent>
							<div class="flex flex-wrap items-center gap-4 text-sm">
								<span class="rounded-full bg-primary/10 px-3 py-1 font-medium text-primary">
									{selectedGame.difficulty}
								</span>
								{#if selectedGame.average_rating}
									<span class="text-muted-foreground">
										⭐ {selectedGame.average_rating.toFixed(1)} ({selectedGame.rating_count} ratings)
									</span>
								{/if}
								<span class="text-muted-foreground">
									{selectedGame.total_plays} plays
								</span>
								<span class="text-muted-foreground">
									By {selectedGame.profiles?.display_name || selectedGame.profiles?.username}
								</span>
							</div>
						</CardContent>
					</Card>
				{/if}
			{/if}
		{/if}
	</div>
</div>

