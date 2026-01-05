<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Input } from '$lib/components/ui/input';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card';
	import type { ActionData } from './$types';

	let { form }: { form: ActionData } = $props();
</script>

<div class="flex min-h-screen items-center justify-center bg-background p-4">
	<Card class="w-full max-w-md">
		<CardHeader>
			<CardTitle>Create an Account</CardTitle>
			<CardDescription>Sign up to start creating and playing Islamic Jeopardy games</CardDescription>
		</CardHeader>
		<CardContent>
			{#if form?.success}
				<div class="rounded-md bg-green-500/15 p-4 text-sm text-green-600 dark:text-green-400">
					<p class="font-medium">Account created successfully!</p>
					<p class="mt-1">{form.message}</p>
				</div>
			{:else}
				<form method="POST" class="space-y-4">
					{#if form?.error}
						<div class="rounded-md bg-destructive/15 p-3 text-sm text-destructive">
							{form.error}
						</div>
					{/if}

					<div class="space-y-2">
						<label for="email" class="text-sm font-medium">Email</label>
						<Input
							type="email"
							id="email"
							name="email"
							placeholder="you@example.com"
							required
							value={form?.email ?? ''}
						/>
					</div>

					<div class="space-y-2">
						<label for="username" class="text-sm font-medium">Username</label>
						<Input
							type="text"
							id="username"
							name="username"
							placeholder="Choose a username"
							required
							minlength={3}
							maxlength={20}
							value={form?.username ?? ''}
						/>
						<p class="text-xs text-muted-foreground">3-20 characters</p>
					</div>

					<div class="space-y-2">
						<label for="display_name" class="text-sm font-medium">Display Name (Optional)</label>
						<Input
							type="text"
							id="display_name"
							name="display_name"
							placeholder="How you want to be called"
							value={form?.displayName ?? ''}
						/>
					</div>

					<div class="space-y-2">
						<label for="password" class="text-sm font-medium">Password</label>
						<Input
							type="password"
							id="password"
							name="password"
							placeholder="Create a password"
							required
							minlength={6}
						/>
						<p class="text-xs text-muted-foreground">At least 6 characters</p>
					</div>

					<Button type="submit" class="w-full">Sign Up</Button>

					<div class="text-center text-sm text-muted-foreground">
						Already have an account?
						<a href="/auth/login" class="text-primary hover:underline">Login</a>
					</div>
				</form>
			{/if}
		</CardContent>
	</Card>
</div>
