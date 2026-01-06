<script lang="ts">
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Button } from '$lib/components/ui/button';
	import { Gamepad2, Star, TrendingUp, Database, AlertCircle, User } from 'lucide-svelte';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();

	// Difficulty badge colors
	const difficultyColors: Record<string, string> = {
		kids: 'from-green-500 to-emerald-600',
		beginner: 'from-blue-500 to-indigo-600',
		intermediate: 'from-amber-500 to-orange-600',
		advanced: 'from-purple-500 to-violet-600'
	};
</script>

<div class="container mx-auto px-4 py-8">
	<!-- Hero Section -->
	<div class="mb-12 text-center">
		<h1 class="mb-4 text-4xl font-extrabold tracking-tight text-gradient sm:text-5xl md:text-6xl">
			Islamic Jeopardy
		</h1>
		<p class="mx-auto max-w-2xl text-lg text-muted-foreground sm:text-xl">
			Test your knowledge of Islam through fun and engaging trivia games
		</p>
		<p class="mt-3 text-sm text-muted-foreground">
			No account needed to play! Sign in only if you want to create your own games.
		</p>
		{#if !data.dbError && data.games.length > 0}
			<div class="mt-8">
				<a href="/play-now">
					<Button
						size="lg"
						class="min-h-[56px] px-10 text-lg font-bold gradient-primary border-0 text-white shadow-xl shadow-primary/30 active:shadow-primary/20 active:scale-[0.98] transition-all touch-target"
					>
						<Gamepad2 class="mr-2 h-6 w-6" />
						Play Now
					</Button>
				</a>
			</div>
		{/if}
	</div>

	<!-- Content based on state -->
	{#if data.dbError}
		<div class="flex min-h-[400px] items-center justify-center">
			<Card class="max-w-md border-2 border-destructive/20 shadow-lg">
				<CardHeader class="text-center">
					<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-destructive/10">
						<Database class="h-8 w-8 text-destructive" />
					</div>
					<CardTitle>Database Setup Required</CardTitle>
					<CardDescription>
						The database tables haven't been created yet.
					</CardDescription>
				</CardHeader>
				<CardContent>
					<p class="text-sm text-muted-foreground">
						1. Go to your Supabase project<br />
						2. Open SQL Editor<br />
						3. Run the contents of <code class="bg-muted px-1.5 py-0.5 rounded font-mono text-xs">supabase/schema.sql</code>
					</p>
				</CardContent>
			</Card>
		</div>
	{:else if data.games.length === 0}
		<div class="flex min-h-[400px] items-center justify-center">
			<Card class="max-w-md border-2 border-primary/20 shadow-lg">
				<CardHeader class="text-center">
					<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10">
						<AlertCircle class="h-8 w-8 text-primary" />
					</div>
					<CardTitle>No Games Available</CardTitle>
					<CardDescription>
						Run the seed data to add sample games, or create your own!
					</CardDescription>
				</CardHeader>
				<CardContent class="space-y-3">
					<p class="text-sm text-muted-foreground text-center">
						Run <code class="rounded bg-muted px-1.5 py-0.5 font-mono text-xs">supabase/seed.sql</code> in your Supabase SQL Editor.
					</p>
					{#if data.session}
						<a href="/games/new">
							<Button class="w-full gradient-primary border-0 text-white touch-target">Or Create Your Own Game</Button>
						</a>
					{:else}
						<a href="/auth/signup">
							<Button variant="outline" class="w-full touch-target">Sign Up to Create Games</Button>
						</a>
					{/if}
				</CardContent>
			</Card>
		</div>
	{:else}
		<!-- Games Grid -->
		<div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
			{#each data.games as game, i}
				<div
					class="animate-card-in"
					style="animation-delay: {i * 80}ms"
				>
					<Card class="group h-full border-2 border-transparent hover:border-primary/20 hover-lift overflow-hidden">
						<CardHeader class="pb-3">
							<div class="mb-3 flex items-center justify-between">
								<span class="rounded-full bg-gradient-to-r {difficultyColors[game.difficulty.toLowerCase()] || 'from-gray-500 to-gray-600'} px-3 py-1 text-xs font-semibold text-white shadow-sm">
									{game.difficulty}
								</span>
								{#if game.average_rating}
									<span class="flex items-center gap-1 text-sm text-muted-foreground">
										<Star class="h-4 w-4 fill-amber-400 text-amber-400" />
										<span class="font-medium">{game.average_rating.toFixed(1)}</span>
										<span class="text-xs">({game.rating_count})</span>
									</span>
								{/if}
							</div>
							<CardTitle class="group-hover:text-primary transition-colors line-clamp-1">
								{game.title}
							</CardTitle>
							<CardDescription class="line-clamp-2">
								{game.description || 'No description provided'}
							</CardDescription>
						</CardHeader>
						<CardContent>
							<div class="flex items-center justify-between">
								<div class="space-y-1 text-sm text-muted-foreground">
									<p class="flex items-center gap-1.5">
										<User class="h-3.5 w-3.5" />
										<span class="truncate max-w-[120px]">{game.profiles?.display_name || game.profiles?.username || 'Anonymous'}</span>
									</p>
									<p class="flex items-center gap-1.5">
										<TrendingUp class="h-3.5 w-3.5" />
										<span>{game.total_plays} plays</span>
									</p>
								</div>
								<a href="/games/{game.id}/play">
									<Button size="sm" class="shadow-md active:scale-95 transition-transform touch-target">
										Play
									</Button>
								</a>
							</div>
						</CardContent>
					</Card>
				</div>
			{/each}
		</div>
	{/if}
</div>
