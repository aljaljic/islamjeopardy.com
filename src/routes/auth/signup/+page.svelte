<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import { Mail, Lock, User, UserPlus, AlertCircle, CheckCircle } from 'lucide-svelte';
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';

	let { form }: { form: ActionData } = $props();
</script>

<div class="flex min-h-screen items-center justify-center bg-background p-4">
	<Card class="w-full max-w-md border-2 shadow-xl">
		<CardHeader class="text-center">
			<div class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl gradient-primary shadow-lg shadow-primary/25">
				<UserPlus class="h-7 w-7 text-white" />
			</div>
			<CardTitle class="text-2xl">Create an Account</CardTitle>
			<CardDescription>Sign up to start creating and playing Islamic Jeopardy games</CardDescription>
		</CardHeader>
		<CardContent>
			{#if form?.success}
				<div class="flex items-start gap-3 rounded-xl bg-emerald-500/10 border-2 border-emerald-500/20 p-4 text-sm text-emerald-600 dark:text-emerald-400">
					<CheckCircle class="h-5 w-5 shrink-0 mt-0.5" />
					<div>
						<p class="font-semibold">Account created successfully!</p>
						<p class="mt-1 opacity-90">{form.message || 'Check your email to confirm your account'}</p>
					</div>
				</div>
			{:else}
				<form
					method="POST"
					class="space-y-5"
					use:enhance={() => {
						return async ({ result, update }) => {
							await update();
							// Form state is automatically preserved by SvelteKit
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
						<label for="username" class="text-sm font-medium flex items-center gap-2">
							<User class="h-4 w-4 text-muted-foreground" />
							Username
						</label>
						<Input
							type="text"
							id="username"
							name="username"
							placeholder="Choose a username"
							required
							minlength={3}
							maxlength={20}
							value={form?.username ?? ''}
							class="touch-target"
						/>
						<p class="text-xs text-muted-foreground">3-20 characters</p>
					</div>

					<div class="space-y-2">
						<label for="display_name" class="text-sm font-medium flex items-center gap-2">
							<User class="h-4 w-4 text-muted-foreground" />
							Display Name
							<span class="text-xs text-muted-foreground font-normal">(Optional)</span>
						</label>
						<Input
							type="text"
							id="display_name"
							name="display_name"
							placeholder="How you want to be called"
							value={form?.displayName ?? ''}
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
							placeholder="Create a password"
							required
							minlength={6}
							class="touch-target"
						/>
						<p class="text-xs text-muted-foreground">At least 6 characters</p>
					</div>

					<Button
						type="submit"
						class="w-full min-h-[48px] font-semibold gradient-primary border-0 text-white shadow-lg shadow-primary/25 active:shadow-primary/15 active:scale-[0.98] transition-all touch-target"
					>
						<UserPlus class="mr-2 h-4 w-4" />
						Sign Up
					</Button>

					<div class="text-center text-sm text-muted-foreground pt-2">
						Already have an account?{' '}
						<a href="/auth/login" class="font-medium text-primary hover:underline active:opacity-70">
							Login
						</a>
					</div>
				</form>
			{/if}
		</CardContent>
	</Card>
</div>
