<script lang="ts">
	import { page } from '$app/stores';
	import type { Session } from '@supabase/supabase-js';
	import { Home, Gamepad2, Trophy, Settings, User } from 'lucide-svelte';

	let { session }: { session: Session | null } = $props();

	// Check if current path matches (exact or starts with for nested routes)
	function isActive(path: string): boolean {
		const currentPath = $page.url.pathname;
		if (path === '/') {
			return currentPath === '/';
		}
		return currentPath === path || currentPath.startsWith(path + '/');
	}

	// Define tabs based on auth state
	let tabs = $derived(
		session?.user
			? [
					{ href: '/', icon: Home, label: 'Home' },
					{ href: '/play-now', icon: Gamepad2, label: 'Play' },
					{ href: '/leaderboard', icon: Trophy, label: 'Leaderboard' },
					{ href: '/settings', icon: Settings, label: 'Settings' }
				]
			: [
					{ href: '/', icon: Home, label: 'Home' },
					{ href: '/play-now', icon: Gamepad2, label: 'Play' },
					{ href: '/leaderboard', icon: Trophy, label: 'Leaderboard' },
					{ href: '/auth/login', icon: User, label: 'Login' }
				]
	);
</script>

<nav class="fixed bottom-0 left-0 right-0 z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl border-t border-gray-200/60 dark:border-gray-700/60 pb-[env(safe-area-inset-bottom)] transform-gpu">
	<div class="flex items-stretch justify-around px-2">
		{#each tabs as tab}
			<a
				href={tab.href}
				class="flex flex-col items-center justify-center flex-1 h-[50px] no-tap-highlight active:opacity-70 {isActive(tab.href)
					? 'text-primary'
					: 'text-gray-500 dark:text-gray-400'}"
			>
				<svelte:component
					this={tab.icon}
					class="h-6 w-6"
					strokeWidth={2}
				/>
				<span class="text-[10px] mt-1 font-medium">
					{tab.label}
				</span>
			</a>
		{/each}
	</div>
</nav>
