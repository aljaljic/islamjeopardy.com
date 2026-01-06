<script lang="ts">
	import type { HTMLAttributes } from 'svelte/elements';
	import { cn } from '$lib/utils';

	type $$Props = HTMLAttributes<HTMLDivElement> & {
		variant?: 'default' | 'circular' | 'text';
	};

	let { class: className, variant = 'default', ...restProps }: $$Props = $props();

	const variants = {
		default: 'rounded-lg',
		circular: 'rounded-full',
		text: 'rounded h-4 w-full'
	};
</script>

<div
	class={cn('animate-skeleton bg-muted', variants[variant], className)}
	{...restProps}
></div>
