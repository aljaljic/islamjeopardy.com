<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Mail, Lock, LogIn, AlertCircle } from 'lucide-svelte';
	import { enhance } from '$app/forms';
	import { toast } from '$lib/stores/toast';
	import type { ActionData } from './$types';

	let { form }: { form: ActionData } = $props();
	let lastError = $state<string | null>(null);

	// Show toast notification when form error changes
	$effect(() => {
		if (form?.error && form.error !== lastError) {
			toast.error(form.error);
			lastError = form.error;
		}
	});
</script>

<div class="flex min-h-screen items-center justify-center bg-background p-4">
	<Card class="w-full max-w-md border-2 shadow-xl">
		<CardHeader class="text-center">
			<div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl gradient-primary shadow-lg shadow-primary/25">
				<LogIn class="h-7 w-7 text-white" />
			</div>
			<CardTitle class="text-2xl">Welcome Back</CardTitle>
			<CardDescription>Enter your credentials to access your account</CardDescription>
		</CardHeader>
		<CardContent>
			<form 
				method="POST" 
				class="space-y-5"
				use:enhance={() => {
					return async ({ result, update }) => {
						await update();
						// Toast notifications are handled by $effect when form state updates
					};
				}}
			>
				{#if form?.error}
					<div class="flex items-start gap-3 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
						<AlertCircle class="h-5 w-5 shrink-0 mt-0.5" />
						<span>{form.error}</span>
					</div>
				{/if}

				<div class="space-y-2">
					<label for="email" class="text-sm font-medium flex items-center gap-2">
						<Mail class="h-4 w-4 text-muted-foreground" />
						Email
					</label>
					<Input
						type="email"
						id="email"
						name="email"
						placeholder="you@example.com"
						required
						value={form?.email ?? ''}
						class="touch-target"
					/>
				</div>

				<div class="space-y-2">
					<label for="password" class="text-sm font-medium flex items-center gap-2">
						<Lock class="h-4 w-4 text-muted-foreground" />
						Password
					</label>
					<Input
						type="password"
						id="password"
						name="password"
						placeholder="Enter your password"
						required
						class="touch-target"
					/>
				</div>

				<Button
					type="submit"
					class="w-full min-h-[48px] font-semibold gradient-primary border-0 text-white shadow-lg shadow-primary/25 active:shadow-primary/15 active:scale-[0.98] transition-all touch-target"
				>
					<LogIn class="mr-2 h-4 w-4" />
					Login
				</Button>

				<div class="text-center text-sm text-muted-foreground pt-2">
					Don't have an account?{' '}
					<a href="/auth/signup" class="font-medium text-primary hover:underline active:opacity-70">
						Sign up
					</a>
				</div>
			</form>
		</CardContent>
	</Card>
</div>
