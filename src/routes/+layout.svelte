<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import Navigation from '$lib/components/navigation.svelte';
	import IOSTabBar from '$lib/components/ios-tab-bar.svelte';
	import { Toast } from '$lib/components/ui/toast';
	import { page } from '$app/stores';
	import { browser } from '$app/environment';
	import { offline } from '$lib/stores/offline.svelte';
	import { isCapacitorApp } from '$lib/utils/device';
	import { WifiOff } from 'lucide-svelte';
	import type { LayoutData } from './$types';

	let { children, data }: { children: any; data: LayoutData } = $props();

	// Hide navbar when playing a game
	let isPlayingGame = $derived($page.url.pathname.match(/^\/games\/[^/]+\/play$/));
	
	// Show iOS tab bar only in native Capacitor app, top nav everywhere else (including iOS Safari)
	let showIOSTabBar = $derived(browser && isCapacitorApp() && !isPlayingGame);
	let showTopNav = $derived(!browser || !isCapacitorApp());
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<!-- iOS app-like meta tags -->
	<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="default" />
	<!-- Apple Smart App Banner - shows native iOS banner prompting to download the app -->
	<meta name="apple-itunes-app" content="app-id=6757568105" />
</svelte:head>

<div class="flex min-h-full flex-col bg-background no-tap-highlight overflow-y-auto">
	<!-- Offline indicator -->
	{#if !offline.isOnline}
		<div class="bg-amber-500 text-white text-center py-1.5 px-4 text-sm font-medium flex items-center justify-center gap-2">
			<WifiOff class="h-4 w-4" />
			<span>You're offline. Some features may be limited.</span>
		</div>
	{/if}

	<!-- Show top navigation on web, hide on iOS -->
	{#if showTopNav && !isPlayingGame}
		<Navigation session={data.session} />
	{/if}

	<main class="flex-1" class:pb-20={showIOSTabBar} class:safe-bottom={!showIOSTabBar}>
		{@render children()}
	</main>

	<!-- iOS bottom tab bar -->
	{#if showIOSTabBar}
		<IOSTabBar session={data.session} />
	{/if}

	<!-- Toast notifications -->
	<Toast />
</div>
