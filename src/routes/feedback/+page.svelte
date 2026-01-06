<script lang="ts">
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { Textarea } from '$lib/components/ui/textarea';
	import { MessageSquare, Send } from 'lucide-svelte';
	import { enhance } from '$app/forms';
	import type { PageData } from './$types';

	let { data, form }: { data: PageData; form: any } = $props();

	let name = $state('');
	let email = $state('');
	let subject = $state('');
	let message = $state('');

	let submitting = $state(false);
</script>

<svelte:head>
	<title>Feedback - Islamic Jeopardy</title>
	<meta name="description" content="Send us your feedback, suggestions, or report issues" />
</svelte:head>

<div class="container mx-auto px-4 py-8 max-w-2xl">
	<!-- Header -->
	<div class="mb-8 text-center">
		<div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10">
			<MessageSquare class="h-8 w-8 text-primary" />
		</div>
		<h1 class="mb-2 text-3xl font-extrabold tracking-tight text-gradient sm:text-4xl">
			Send Us Feedback
		</h1>
		<p class="text-muted-foreground">
			We'd love to hear from you! Share your thoughts, suggestions, or report any issues.
		</p>
	</div>

	<!-- Success Message -->
	{#if form?.success}
		<Card class="mb-6 border-2 border-green-500/20 bg-green-50/50 dark:bg-green-950/20">
			<CardHeader>
				<CardTitle class="text-green-700 dark:text-green-400">Thank You!</CardTitle>
				<CardDescription class="text-green-600 dark:text-green-500">
					Your feedback has been sent successfully. We'll get back to you soon!
				</CardDescription>
			</CardHeader>
		</Card>
	{/if}

	<!-- Error Message -->
	{#if form?.error}
		<Card class="mb-6 border-2 border-destructive/20 bg-destructive/5">
			<CardHeader>
				<CardTitle class="text-destructive">Error</CardTitle>
				<CardDescription class="text-destructive/80">
					{form.error}
				</CardDescription>
			</CardHeader>
		</Card>
	{/if}

	<!-- Feedback Form -->
	<Card class="shadow-lg">
		<CardHeader>
			<CardTitle>Feedback Form</CardTitle>
			<CardDescription>
				Fill out the form below and we'll receive your message at{' '}
				<a href="mailto:support@islamjeopardy.com" class="text-primary hover:underline">
					support@islamjeopardy.com
				</a>
			</CardDescription>
		</CardHeader>
		<CardContent>
			<form
				method="POST"
				use:enhance={() => {
					submitting = true;
					return async ({ result, update }) => {
						await update();
						submitting = false;
						if (result.type === 'success') {
							const data = result.data as { success?: boolean; error?: string };
							if (data?.success) {
								// Clear form on success
								name = '';
								email = '';
								subject = '';
								message = '';
							}
						}
					};
				}}
			>
				<div class="space-y-4">
					<div class="grid gap-4 sm:grid-cols-2">
						<div class="space-y-2">
							<label for="name" class="text-sm font-medium">
								Name <span class="text-muted-foreground">(optional)</span>
							</label>
							<Input
								id="name"
								name="name"
								bind:value={name}
								placeholder="Your name"
								disabled={submitting}
							/>
						</div>
						<div class="space-y-2">
							<label for="email" class="text-sm font-medium">
								Email <span class="text-destructive">*</span>
							</label>
							<Input
								id="email"
								name="email"
								type="email"
								bind:value={email}
								placeholder="your.email@example.com"
								required
								disabled={submitting}
							/>
						</div>
					</div>

					<div class="space-y-2">
						<label for="subject" class="text-sm font-medium">
							Subject <span class="text-muted-foreground">(optional)</span>
						</label>
						<Input
							id="subject"
							name="subject"
							bind:value={subject}
							placeholder="What is this about?"
							disabled={submitting}
						/>
					</div>

					<div class="space-y-2">
						<label for="message" class="text-sm font-medium">
							Message <span class="text-destructive">*</span>
						</label>
						<Textarea
							id="message"
							name="message"
							bind:value={message}
							placeholder="Tell us what's on your mind..."
							rows="6"
							required
							disabled={submitting}
							class="resize-none"
						/>
					</div>

					<div class="pt-2">
						<Button
							type="submit"
							size="lg"
							class="w-full sm:w-auto gradient-primary border-0 text-white shadow-lg shadow-primary/25 active:shadow-primary/15 transition-all touch-target"
							disabled={submitting || !message.trim() || !email.trim()}
						>
							{#if submitting}
								<span class="mr-2 h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent"></span>
								Sending...
							{:else}
								<Send class="mr-2 h-5 w-5" />
								Send Feedback
							{/if}
						</Button>
					</div>
				</div>
			</form>
		</CardContent>
	</Card>
</div>

