<script lang="ts">
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { leaderboard, familyName } from '$lib/stores/leaderboard.svelte';
	import { Trophy, Medal, Clock, Trash2, Users, TrendingUp, Calendar, Edit2, Check, X } from 'lucide-svelte';
	import { onMount } from 'svelte';

	let editingFamilyName = $state(false);
	let tempFamilyName = $state('');
	let mounted = $state(false);

	onMount(() => {
		leaderboard.reload();
		familyName.reload();
		mounted = true;
	});

	function startEditingFamily() {
		tempFamilyName = familyName.value;
		editingFamilyName = true;
	}

	function saveFamilyName() {
		familyName.set(tempFamilyName.trim());
		editingFamilyName = false;
	}

	function cancelEditingFamily() {
		editingFamilyName = false;
	}

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
	<title>Family Leaderboard - Islamic Jeopardy</title>
</svelte:head>

<div class="container mx-auto px-4 py-8">
	<!-- Header -->
	<div class="mb-8 text-center">
		<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl gradient-accent shadow-lg shadow-accent/25">
			<Trophy class="h-8 w-8 text-white" />
		</div>
		<h1 class="mb-2 text-3xl font-bold sm:text-4xl">Family Leaderboard</h1>
		<p class="text-lg text-muted-foreground">
			Track your family's trivia champions
		</p>
	</div>

	<!-- Family Name Section -->
	<Card class="mb-8 max-w-md mx-auto border-2 shadow-lg">
		<CardHeader class="pb-3">
			<CardTitle class="flex items-center gap-2">
				<Users class="h-5 w-5 text-primary" />
				Your Family
			</CardTitle>
		</CardHeader>
		<CardContent>
			{#if editingFamilyName}
				<div class="flex gap-2">
					<Input
						bind:value={tempFamilyName}
						placeholder="Enter family name"
						class="touch-target"
						onkeydown={(e) => e.key === 'Enter' && saveFamilyName()}
					/>
					<Button size="icon" onclick={saveFamilyName} class="touch-target shrink-0">
						<Check class="h-4 w-4" />
					</Button>
					<Button size="icon" variant="ghost" onclick={cancelEditingFamily} class="touch-target shrink-0">
						<X class="h-4 w-4" />
					</Button>
				</div>
			{:else}
				<div class="flex items-center justify-between">
					<span class="text-lg font-semibold">
						{familyName.value || 'Not set'}
					</span>
					<Button variant="ghost" size="sm" onclick={startEditingFamily} class="gap-2 touch-target">
						<Edit2 class="h-4 w-4" />
						{familyName.value ? 'Edit' : 'Set Name'}
					</Button>
				</div>
			{/if}
			<p class="text-xs text-muted-foreground mt-2">
				Set your family name to track scores together
			</p>
		</CardContent>
	</Card>

	{#if !mounted}
		<div class="text-center text-muted-foreground py-12">
			Loading...
		</div>
	{:else if entries.length === 0}
		<Card class="max-w-md mx-auto border-2 shadow-lg text-center">
			<CardHeader>
				<div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-muted">
					<Trophy class="h-7 w-7 text-muted-foreground" />
				</div>
				<CardTitle>No Games Yet</CardTitle>
				<CardDescription>
					Play some games to see your family's scores here!
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
								<div class="flex items-center justify-between p-4 {i === 0 ? 'bg-gradient-to-r from-yellow-50 to-amber-50 dark:from-yellow-900/20 dark:to-amber-900/20' : ''}">
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
											{#if entry.familyName}
												<p class="text-xs text-muted-foreground">{entry.familyName} family</p>
											{/if}
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
											{#if game.familyName}
												· {game.familyName}
											{/if}
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
									{#each [...game.teams].sort((a, b) => b.score - a.score) as team, i}
										<div class="flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium
											{team.isWinner ? 'bg-gradient-to-r from-yellow-100 to-amber-100 text-amber-800 dark:from-yellow-900/30 dark:to-amber-900/30 dark:text-amber-300' : 'bg-muted text-muted-foreground'}">
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
