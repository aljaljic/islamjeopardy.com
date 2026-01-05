<script lang="ts">
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Button } from '$lib/components/ui/button';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();
</script>

<div class="container mx-auto px-4 py-8">
	<div class="mb-8 text-center">
		<h1 class="mb-2 text-4xl font-bold">Islamic Jeopardy</h1>
		<p class="text-lg text-muted-foreground">
			Test your knowledge of Islam through fun and engaging Jeopardy-style games
		</p>
		<p class="mt-2 text-sm text-muted-foreground">
			No account needed to play! Sign in only if you want to create your own games.
		</p>
		{#if !data.dbError && data.games.length > 0}
			<div class="mt-6">
				<a href="/play-now">
					<Button size="lg" class="min-h-[56px] px-8 text-lg">
						🎮 Play Now
					</Button>
				</a>
			</div>
		{/if}
	</div>

	{#if data.dbError}
		<div class="flex min-h-[400px] items-center justify-center">
			<Card class="max-w-md">
				<CardHeader>
					<CardTitle>Database Setup Required</CardTitle>
					<CardDescription>
						The database tables haven't been created yet. Please run the schema in your Supabase SQL Editor.
					</CardDescription>
				</CardHeader>
				<CardContent>
					<p class="text-sm text-muted-foreground">
						1. Go to your Supabase project<br />
						2. Open SQL Editor<br />
						3. Run the contents of <code class="bg-muted px-1 rounded">supabase/schema.sql</code>
					</p>
				</CardContent>
			</Card>
		</div>
	{:else if data.games.length === 0}
		<div class="flex min-h-[400px] items-center justify-center">
			<Card class="max-w-md">
				<CardHeader>
					<CardTitle>No Games Available</CardTitle>
					<CardDescription>
						Run the seed data to add sample games, or create your own!
					</CardDescription>
				</CardHeader>
				<CardContent class="space-y-3">
					<p class="text-sm text-muted-foreground">
						Run <code class="rounded bg-muted px-1">supabase/seed.sql</code> in your Supabase SQL Editor to add sample games.
					</p>
					{#if data.session}
						<a href="/games/new">
							<Button class="w-full">Or Create Your Own Game</Button>
						</a>
					{:else}
						<a href="/auth/signup">
							<Button variant="outline" class="w-full">Sign Up to Create Games</Button>
						</a>
					{/if}
				</CardContent>
			</Card>
		</div>
	{:else}
		<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
			{#each data.games as game}
				<Card class="transition-shadow hover:shadow-lg">
					<CardHeader>
						<div class="mb-2 flex items-center justify-between">
							<span class="rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
								{game.difficulty}
							</span>
							{#if game.average_rating}
								<span class="text-sm text-muted-foreground">
									⭐ {game.average_rating.toFixed(1)} ({game.rating_count})
								</span>
							{/if}
						</div>
						<CardTitle>{game.title}</CardTitle>
						<CardDescription>
							{game.description || 'No description provided'}
						</CardDescription>
					</CardHeader>
					<CardContent>
						<div class="flex items-center justify-between">
							<div class="text-sm text-muted-foreground">
								<p>By {game.profiles?.display_name || game.profiles?.username}</p>
								<p>{game.total_plays} plays</p>
							</div>
							<a href="/games/{game.id}/play">
								<Button size="sm">Play</Button>
							</a>
						</div>
					</CardContent>
				</Card>
			{/each}
		</div>
	{/if}
</div>
