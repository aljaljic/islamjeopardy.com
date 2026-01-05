<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import {
		Card,
		CardContent,
		CardDescription,
		CardHeader,
		CardTitle
	} from '$lib/components/ui/card';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	let confirmDelete = $state<string | null>(null);

	const difficultyColors: Record<string, string> = {
		kids: 'bg-green-500/10 text-green-600',
		beginner: 'bg-blue-500/10 text-blue-600',
		advanced: 'bg-purple-500/10 text-purple-600'
	};

	function formatDate(dateString: string) {
		return new Date(dateString).toLocaleDateString('en-US', {
			month: 'short',
			day: 'numeric',
			year: 'numeric'
		});
	}
</script>

<svelte:head>
	<title>My Games | Islamic Jeopardy</title>
</svelte:head>

<div class="container mx-auto px-4 py-8">
	<div class="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
		<div>
			<h1 class="text-3xl font-bold">My Games</h1>
			<p class="text-muted-foreground">Manage your created games</p>
		</div>
		<a href="/games/new">
			<Button>Create New Game</Button>
		</a>
	</div>

	{#if data.games.length === 0}
		<Card class="mx-auto max-w-md">
			<CardHeader>
				<CardTitle>No Games Yet</CardTitle>
				<CardDescription>
					You haven't created any games yet. Get started by creating your first game!
				</CardDescription>
			</CardHeader>
			<CardContent>
				<a href="/games/new">
					<Button class="w-full">Create Your First Game</Button>
				</a>
			</CardContent>
		</Card>
	{:else}
		<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
			{#each data.games as game}
				<Card class="relative">
					<CardHeader>
						<div class="mb-2 flex items-center justify-between">
							<span
								class="rounded-full px-3 py-1 text-xs font-medium {difficultyColors[
									game.difficulty
								]}"
							>
								{game.difficulty}
							</span>
							<span class="text-xs text-muted-foreground">
								{game.is_public ? 'Public' : 'Private'}
							</span>
						</div>
						<CardTitle class="line-clamp-1">{game.title}</CardTitle>
						<CardDescription class="line-clamp-2">
							{game.description || 'No description'}
						</CardDescription>
					</CardHeader>
					<CardContent>
						<div class="mb-4 text-sm text-muted-foreground">
							<p>Created {formatDate(game.created_at)}</p>
							<p>
								{game.total_plays} play{game.total_plays !== 1 ? 's' : ''} ·
								{game.rating_count} rating{game.rating_count !== 1 ? 's' : ''}
							</p>
						</div>

						<div class="flex flex-wrap gap-2">
							<a href="/games/{game.id}/play">
								<Button size="sm">Play</Button>
							</a>
							<a href="/games/{game.id}">
								<Button size="sm" variant="outline">View</Button>
							</a>

							<!-- Toggle Visibility -->
							<form method="POST" action="?/toggleVisibility">
								<input type="hidden" name="gameId" value={game.id} />
								<input type="hidden" name="isPublic" value={game.is_public.toString()} />
								<Button size="sm" variant="ghost" type="submit">
									{game.is_public ? 'Make Private' : 'Make Public'}
								</Button>
							</form>
						</div>

						<!-- Delete Confirmation -->
						{#if confirmDelete === game.id}
							<div class="mt-4 rounded-lg border border-destructive bg-destructive/10 p-3">
								<p class="mb-2 text-sm text-destructive">
									Delete this game? This cannot be undone.
								</p>
								<div class="flex gap-2">
									<form method="POST" action="?/delete">
										<input type="hidden" name="gameId" value={game.id} />
										<Button size="sm" variant="destructive" type="submit">Confirm Delete</Button>
									</form>
									<Button size="sm" variant="outline" onclick={() => (confirmDelete = null)}>
										Cancel
									</Button>
								</div>
							</div>
						{:else}
							<Button
								size="sm"
								variant="ghost"
								class="mt-2 text-destructive hover:text-destructive"
								onclick={() => (confirmDelete = game.id)}
							>
								Delete
							</Button>
						{/if}
					</CardContent>
				</Card>
			{/each}
		</div>
	{/if}
</div>
