<script lang="ts">
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Button } from '$lib/components/ui/button';
	import { leaderboard } from '$lib/stores/leaderboard.svelte';
	import { Trophy, Medal, Clock, Trash2, TrendingUp, Calendar, X } from 'lucide-svelte';

	function clearAllResults() {
		if (confirm('Are you sure you want to clear all game history? This cannot be undone.')) {
			leaderboard.clearAll();
		}
	}

	function deleteGame(id: string) {
		leaderboard.deleteResult(id);
	}

	function formatDate(isoString: string): string {
		const date = new Date(isoString);
		return date.toLocaleDateString(undefined, {
			month: 'short',
			day: 'numeric',
			hour: 'numeric',
			minute: '2-digit'
		});
	}

	function getRankIcon(index: number) {
		if (index === 0) return { icon: Trophy, class: 'text-yellow-500' };
		if (index === 1) return { icon: Medal, class: 'text-gray-400' };
		if (index === 2) return { icon: Medal, class: 'text-amber-600' };
		return null;
	}

	// Reactive derived values
	let entries = $derived(leaderboard.entries);
	let recentGames = $derived(leaderboard.getRecentGames(10));
</script>

<svelte:head>
	<title>Leaderboard - Islamic Jeopardy</title>
</svelte:head>

<div class="container mx-auto px-4 py-8 min-h-[calc(100vh-80px)]">
	<!-- Header -->
	<div class="mb-8 text-center">
		<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl gradient-accent shadow-lg shadow-accent/25">
			<Trophy class="h-8 w-8 text-white" />
		</div>
		<h1 class="mb-2 text-3xl font-bold sm:text-4xl">Leaderboard</h1>
		<p class="text-lg text-muted-foreground">
			Track your trivia champions
		</p>
	</div>

	{#if entries.length === 0}
		<Card class="max-w-md mx-auto border-2 shadow-lg text-center">
			<CardHeader>
				<div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-muted">
					<Trophy class="h-7 w-7 text-muted-foreground" />
				</div>
				<CardTitle>No Games Yet</CardTitle>
				<CardDescription>
					Play some games to see your scores here!
				</CardDescription>
			</CardHeader>
			<CardContent>
				<a href="/play-now">
					<Button class="gradient-primary border-0 text-white touch-target">
						Start Playing
					</Button>
				</a>
			</CardContent>
		</Card>
	{:else}
		<div class="grid gap-8 lg:grid-cols-2">
			<!-- Leaderboard Rankings -->
			<div>
				<h2 class="text-xl font-bold mb-4 flex items-center gap-2">
					<TrendingUp class="h-5 w-5 text-primary" />
					Player Rankings
				</h2>
				<Card class="border-2 shadow-lg">
					<CardContent class="p-0">
						<div class="divide-y">
							{#each entries.slice(0, 10) as entry, i}
								{@const rankInfo = getRankIcon(i)}
								<div class="flex items-center justify-between p-4 {i === 0 ? 'bg-gradient-to-r from-yellow-50 to-amber-50 dark:from-yellow-900/20 dark:to-amber-900/20 rounded-t-lg' : ''}">
									<div class="flex items-center gap-3">
										<div class="flex items-center justify-center w-8 h-8 rounded-full {i < 3 ? 'bg-primary/10' : 'bg-muted'}">
											{#if rankInfo}
												{@const Icon = rankInfo.icon}
												<Icon class="h-4 w-4 {rankInfo.class}" />
											{:else}
												<span class="text-sm font-bold text-muted-foreground">{i + 1}</span>
											{/if}
										</div>
										<div>
											<p class="font-semibold">{entry.playerName}</p>
										</div>
									</div>
									<div class="text-right">
										<p class="font-bold text-lg">{entry.totalWins} <span class="text-sm font-normal text-muted-foreground">wins</span></p>
										<p class="text-xs text-muted-foreground">
											High: {entry.highestScore} · Avg: {entry.averageScore}
										</p>
									</div>
								</div>
							{/each}
						</div>
					</CardContent>
				</Card>
			</div>

			<!-- Recent Games -->
			<div>
				<div class="flex items-center justify-between mb-4">
					<h2 class="text-xl font-bold flex items-center gap-2">
						<Clock class="h-5 w-5 text-primary" />
						Recent Games
					</h2>
					{#if recentGames.length > 0}
						<Button variant="ghost" size="sm" onclick={clearAllResults} class="text-destructive hover:text-destructive hover:bg-destructive/10 touch-target">
							<Trash2 class="h-4 w-4 mr-1" />
							Clear All
						</Button>
					{/if}
				</div>
				<div class="space-y-3">
					{#each recentGames as game}
						<Card class="border shadow-sm">
							<CardContent class="p-4">
								<div class="flex items-start justify-between mb-2">
									<div>
										<p class="font-semibold line-clamp-1">{game.gameTitle}</p>
										<p class="text-xs text-muted-foreground flex items-center gap-1">
											<Calendar class="h-3 w-3" />
											{formatDate(game.playedAt)}
										</p>
									</div>
									<Button
										variant="ghost"
										size="icon"
										class="h-8 w-8 text-muted-foreground hover:text-destructive"
										onclick={() => deleteGame(game.id)}
									>
										<X class="h-4 w-4" />
									</Button>
								</div>
								<div class="flex flex-wrap gap-2">
									{#each [...game.teams].sort((a, b) => b.score - a.score) as team}
										<div class="flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium
											{team.isWinner ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300' : 'bg-muted text-muted-foreground'}">
											{#if team.isWinner}
												<Trophy class="h-3 w-3" />
											{/if}
											{team.name}: {team.score}
										</div>
									{/each}
								</div>
							</CardContent>
						</Card>
					{/each}
				</div>
			</div>
		</div>
	{/if}
</div>
