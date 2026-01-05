<script lang="ts">
	import type { HTMLSelectAttributes } from 'svelte/elements';
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';

	type $$Props = HTMLSelectAttributes & {
		children?: Snippet;
	};

	let { class: className, value = $bindable(), children, ...restProps }: $$Props = $props();
</script>

<select
	bind:value
	class={cn(
		'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-base ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 md:text-sm',
		className
	)}
	{...restProps}
>
	{@render children?.()}
</select>
