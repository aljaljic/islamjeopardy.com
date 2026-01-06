<script lang="ts">
	import { fly, fade } from 'svelte/transition';
	import { X } from 'lucide-svelte';
	import type { Snippet } from 'svelte';

	type $$Props = {
		open?: boolean;
		side?: 'left' | 'right';
		children?: Snippet;
		onclose?: () => void;
	};

	let {
		open = $bindable(false),
		side = 'left',
		children,
		onclose
	}: $$Props = $props();

	function handleClose() {
		open = false;
		onclose?.();
	}

	function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Escape') handleClose();
	}

	function handleBackdropClick() {
		handleClose();
	}
</script>

<svelte:window onkeydown={handleKeydown} />

{#if open}
	<!-- Backdrop -->
	<button
		transition:fade={{ duration: 200 }}
		class="fixed inset-0 z-50 bg-white cursor-default"
		onclick={handleBackdropClick}
		aria-label="Close menu"
	></button>

	<!-- Sheet Panel -->
	<div
		transition:fly={{ x: side === 'left' ? -300 : 300, duration: 300, opacity: 1 }}
		class="fixed top-0 z-50 h-full w-[280px] bg-card shadow-2xl safe-top safe-bottom
			{side === 'left' ? 'left-0 safe-left' : 'right-0 safe-right'}"
	>
		<div class="flex h-full flex-col">
			<div class="flex items-center justify-between border-b px-4 py-3">
				<span class="text-lg font-semibold">Menu</span>
				<button
					onclick={handleClose}
					class="rounded-full p-2 hover:bg-muted active:bg-muted/80 transition-colors touch-target"
					aria-label="Close menu"
				>
					<X class="h-5 w-5" />
				</button>
			</div>
			<div class="flex-1 overflow-y-auto p-4 scroll-touch">
				{@render children?.()}
			</div>
		</div>
	</div>
{/if}
