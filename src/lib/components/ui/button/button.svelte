<script lang="ts">
	import type { HTMLButtonAttributes } from 'svelte/elements';
	import type { Snippet } from 'svelte';
	import { cn } from '$lib/utils';

	type $$Props = HTMLButtonAttributes & {
		variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link' | 'gradient';
		size?: 'default' | 'sm' | 'lg' | 'icon';
		children?: Snippet;
	};

	let {
		class: className,
		variant = 'default',
		size = 'default',
		type = 'button',
		children,
		...restProps
	}: $$Props = $props();

	const variants = {
		default: 'bg-primary text-primary-foreground hover:bg-primary/90 shadow-sm hover:shadow-md',
		destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90 shadow-sm',
		outline: 'border-2 border-input bg-background hover:bg-accent hover:text-accent-foreground hover:border-primary/50',
		secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80 shadow-sm',
		ghost: 'hover:bg-accent hover:text-accent-foreground',
		link: 'text-primary underline-offset-4 hover:underline',
		gradient: 'gradient-primary text-white border-0 shadow-lg shadow-primary/25 hover:shadow-primary/40'
	};

	const sizes = {
		default: 'h-10 px-4 py-2',
		sm: 'h-9 rounded-md px-3',
		lg: 'h-12 rounded-lg px-8',
		icon: 'h-10 w-10'
	};
</script>

<button
	{type}
	class={cn(
		'inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-lg text-sm font-medium ring-offset-background transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 active:scale-[0.98]',
		variants[variant],
		sizes[size],
		className
	)}
	{...restProps}
>
	{@render children?.()}
</button>
