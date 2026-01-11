<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import {
		Card,
		CardContent,
		CardDescription,
		CardHeader,
		CardTitle
	} from '$lib/components/ui/card';
	import { enhance } from '$app/forms';
	import { invalidateAll } from '$app/navigation';
	import type { PageData } from './$types';

	let { data }: { data: PageData } = $props();
	
	// Local state for user rating to update UI immediately
	let userRating = $state(data.userRating?.rating ?? null);
	let isFavorited = $state(data.isFavorited);
	
	// Update local state when data changes
	$effect(() => {
		userRating = data.userRating?.rating ?? null;
		isFavorited = data.isFavorited;
	});

	const difficultyColors: Record<string, string> = {
		kids: 'bg-green-500/10 text-green-600',
		beginner: 'bg-blue-500/10 text-blue-600',
		advanced: 'bg-purple-500/10 text-purple-600'
	};

	function formatDate(dateString: string) {
		return new Date(dateString).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'long',
			day: 'numeric'
		});
	}
</script>

<div class="container mx-auto px-4 py-8">
	<div class="grid gap-8 lg:grid-cols-3">
		<!-- Main Content -->
		<div class="lg:col-span-2">
			<Card>
				<CardHeader>
					<div class="mb-2 flex flex-wrap items-center gap-2">
						<span
							class="rounded-full px-3 py-1 text-xs font-medium {difficultyColors[
								data.game.difficulty
							]}"
						>
							{data.game.difficulty}
						</span>
						{#if !data.game.is_public}
							<span class="rounded-full bg-muted px-3 py-1 text-xs font-medium">Private</span>
						{/if}
					</div>
					<CardTitle class="text-3xl">{data.game.title}</CardTitle>
					<CardDescription>
						{data.game.description || 'No description provided'}
					</CardDescription>
				</CardHeader>
				<CardContent>
					<!-- Categories -->
					<div class="mb-6">
						<h3 class="mb-2 text-sm font-medium text-muted-foreground">Categories</h3>
						<div class="flex flex-wrap gap-2">
							{#each data.categories as category}
								<span class="rounded-lg bg-primary/10 px-3 py-1 text-sm font-medium text-primary">
									{category}
								</span>
							{/each}
						</div>
					</div>

					<!-- Stats -->
					<div class="grid grid-cols-3 gap-4 rounded-lg bg-muted p-4">
						<div class="text-center">
							<p class="text-2xl font-bold">{data.game.total_plays}</p>
							<p class="text-xs text-muted-foreground">Plays</p>
						</div>
						<div class="text-center">
							<p class="text-2xl font-bold">
								{data.game.average_rating ? data.game.average_rating.toFixed(1) : '-'}
							</p>
							<p class="text-xs text-muted-foreground">Rating</p>
						</div>
						<div class="text-center">
							<p class="text-2xl font-bold">{data.game.rating_count}</p>
							<p class="text-xs text-muted-foreground">Reviews</p>
						</div>
					</div>

					<!-- Play Button -->
					<div class="mt-6">
						<a href="/games/{data.game.id}/play">
							<Button size="lg" class="min-h-[56px] w-full text-lg">Play Game</Button>
						</a>
					</div>
				</CardContent>
			</Card>
		</div>

		<!-- Sidebar -->
		<div class="space-y-6">
			<!-- Creator Card -->
			<Card>
				<CardHeader>
					<CardTitle class="text-lg">Created by</CardTitle>
				</CardHeader>
				<CardContent>
					<div class="flex items-center gap-3">
						<div
							class="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-lg font-bold text-primary"
						>
							{(data.game.creator.display_name || data.game.creator.username)
								.charAt(0)
								.toUpperCase()}
						</div>
						<div>
							<p class="font-medium">
								{data.game.creator.display_name || data.game.creator.username}
							</p>
							<p class="text-sm text-muted-foreground">
								{formatDate(data.game.created_at)}
							</p>
						</div>
					</div>
				</CardContent>
			</Card>

			<!-- Actions Card (for logged in users) -->
			{#if data.session}
				<Card>
					<CardHeader>
						<CardTitle class="text-lg">Actions</CardTitle>
					</CardHeader>
					<CardContent class="space-y-4">
						<!-- Favorite Button -->
						<form 
							method="POST" 
							action="?/toggleFavorite"
							use:enhance={() => {
								return async ({ result, update }) => {
									if (result.type === 'success') {
										// Toggle local state immediately
										isFavorited = !isFavorited;
									}
									await update();
									await invalidateAll();
								};
							}}
						>
							<Button variant="outline" class="w-full" type="submit">
								{isFavorited ? 'Favorited' : 'Add to Favorites'}
							</Button>
						</form>

						<!-- Rating -->
						<div>
							<p class="mb-2 text-sm font-medium">Rate this game</p>
							<form 
								method="POST" 
								action="?/rate" 
								class="flex gap-1"
								use:enhance={({ formData }) => {
									// Get the rating value from the form submission
									const rating = parseInt(formData.get('rating') as string);
									if (!isNaN(rating)) {
										userRating = rating;
									}
									
									return async ({ result, update }) => {
										await update();
										// Invalidate all data to refresh the page data (average rating, count, etc.)
										await invalidateAll();
									};
								}}
							>
								{#each [1, 2, 3, 4, 5] as star}
									<button
										type="submit"
										name="rating"
										value={star}
										class="text-2xl transition-transform hover:scale-110
											{userRating && userRating >= star
											? 'text-yellow-500'
											: 'text-muted'}"
										aria-label="Rate {star} star{star !== 1 ? 's' : ''}"
									>
										★
									</button>
								{/each}
							</form>
						</div>

						<!-- Owner Actions -->
						{#if data.isOwner}
							<div class="border-t pt-4">
								<a href="/games/{data.game.id}/edit">
									<Button variant="outline" class="w-full">Edit Game</Button>
								</a>
							</div>
						{/if}
					</CardContent>
				</Card>
			{:else}
				<Card>
					<CardContent class="pt-6">
						<p class="mb-4 text-sm text-muted-foreground">Sign in to rate and favorite games</p>
						<a href="/auth/login">
							<Button variant="outline" class="w-full">Sign In</Button>
						</a>
					</CardContent>
				</Card>
			{/if}
		</div>
	</div>
</div>
