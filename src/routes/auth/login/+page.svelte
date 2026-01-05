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
			<CardTitle>Login to Islamic Jeopardy</CardTitle>
			<CardDescription>Enter your credentials to access your account</CardDescription>
		</CardHeader>
		<CardContent>
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
					<label for="password" class="text-sm font-medium">Password</label>
					<Input
						type="password"
						id="password"
						name="password"
						placeholder="Enter your password"
						required
					/>
				</div>

				<Button type="submit" class="w-full">Login</Button>

				<div class="text-center text-sm text-muted-foreground">
					Don't have an account?
					<a href="/auth/signup" class="text-primary hover:underline">Sign up</a>
				</div>
			</form>
		</CardContent>
	</Card>
</div>
