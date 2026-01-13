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

<nav class="fixed bottom-0 left-0 right-0 z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl border-t border-gray-200/60 dark:border-gray-700/60">
	<div class="flex items-center justify-around px-2 pb-[env(safe-area-inset-bottom)] pt-2">
		{#each tabs as tab}
			<a
				href={tab.href}
				class="flex flex-col items-center justify-center min-w-[64px] py-1 px-3 rounded-lg transition-all duration-150 no-tap-highlight active:scale-95 {isActive(tab.href)
					? 'text-primary'
					: 'text-gray-500 dark:text-gray-400'}"
			>
				<svelte:component
					this={tab.icon}
					class="h-6 w-6 transition-transform {isActive(tab.href) ? 'scale-110' : ''}"
					strokeWidth={isActive(tab.href) ? 2.5 : 1.5}
				/>
				<span class="text-[10px] font-medium mt-1 {isActive(tab.href) ? 'font-semibold' : ''}">
					{tab.label}
				</span>
			</a>
		{/each}
	</div>
</nav>
