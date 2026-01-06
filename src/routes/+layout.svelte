<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import Navigation from '$lib/components/navigation.svelte';
	import { Toast } from '$lib/components/ui/toast';
	import type { LayoutData } from './$types';

	let { children, data }: { children: any; data: LayoutData } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<!-- iOS app-like meta tags -->
	<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="default" />
</svelte:head>

<div class="flex min-h-screen flex-col bg-background no-tap-highlight">
	<Navigation session={data.session} />
	<main class="flex-1 animate-page-in safe-bottom">
		{@render children()}
	</main>

	<!-- Toast notifications -->
	<Toast />
</div>
