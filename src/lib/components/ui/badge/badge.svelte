<script lang="ts">
	import type { HTMLAttributes } from 'svelte/elements';
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';

	type $$Props = HTMLAttributes<HTMLSpanElement> & {
		variant?: 'default' | 'secondary' | 'outline' | 'destructive';
		children?: Snippet;
	};

	let { class: className, variant = 'default', children, ...restProps }: $$Props = $props();

	const variants = {
		default: 'bg-primary text-primary-foreground',
		secondary: 'bg-secondary text-secondary-foreground',
		outline: 'border border-input bg-background',
		destructive: 'bg-destructive text-destructive-foreground'
	};
</script>

<span
	class={cn(
		'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold transition-colors',
		variants[variant],
		className
	)}
	{...restProps}
>
	{@render children?.()}
</span>
