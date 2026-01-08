<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import Navigation from '$lib/components/navigation.svelte';
	import { Toast } from '$lib/components/ui/toast';
	import { page } from '$app/stores';
	import { offline } from '$lib/stores/offline.svelte';
	import { WifiOff } from 'lucide-svelte';
	import type { LayoutData } from './$types';

	let { children, data }: { children: any; data: LayoutData } = $props();

	// Hide navbar when playing a game
	let isPlayingGame = $derived($page.url.pathname.match(/^\/games\/[^/]+\/play$/));
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<!-- iOS app-like meta tags -->
	<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="default" />
</svelte:head>

<div class="flex min-h-full flex-col bg-background no-tap-highlight overflow-y-auto">
	<!-- Offline indicator -->
	{#if !offline.isOnline}
		<div class="bg-amber-500 text-white text-center py-1.5 px-4 text-sm font-medium flex items-center justify-center gap-2">
			<WifiOff class="h-4 w-4" />
			<span>You're offline. Some features may be limited.</span>
		</div>
	{/if}

	{#if !isPlayingGame}
		<Navigation session={data.session} />
	{/if}
	<main class="flex-1 safe-bottom">
		{@render children()}
	</main>

	<!-- Toast notifications -->
	<Toast />
</div>
