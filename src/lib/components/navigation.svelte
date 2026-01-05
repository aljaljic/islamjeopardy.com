<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import type { Session } from '@supabase/supabase-js';

	let { session }: { session: Session | null } = $props();
</script>

<nav class="border-b bg-card">
	<div class="container mx-auto flex h-16 items-center justify-between px-4">
		<a href="/" class="flex items-center space-x-2">
			<span class="text-2xl">🕌</span>
			<span class="text-xl font-bold">Islamic Jeopardy</span>
		</a>

		<div class="flex items-center gap-4">
			{#if session}
				<a href="/games/new">
					<Button variant="outline">Create Game</Button>
				</a>
				<a href="/games/my-games">
					<Button variant="ghost">My Games</Button>
				</a>
				<form method="POST" action="/auth/logout">
					<Button variant="ghost" type="submit">Logout</Button>
				</form>
			{:else}
				<a href="/auth/login">
					<Button variant="ghost">Login</Button>
				</a>
				<a href="/auth/signup">
					<Button>Sign Up</Button>
				</a>
			{/if}
		</div>
	</div>
</nav>
