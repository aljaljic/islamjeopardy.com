<script lang="ts">
	import { cn } from '$lib/utils';

	type $$Props = {
		checked?: boolean;
		disabled?: boolean;
		class?: string;
		'aria-label'?: string;
	};

	let { checked = $bindable(false), disabled = false, class: className, 'aria-label': ariaLabel }: $$Props = $props();
</script>

<button
	type="button"
	role="switch"
	aria-checked={checked}
	aria-label={ariaLabel ?? (checked ? 'Enabled' : 'Disabled')}
	{disabled}
	onclick={() => (checked = !checked)}
	class={cn(
		'peer inline-flex h-6 w-11 shrink-0 cursor-pointer items-center rounded-full border-2 border-transparent transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background disabled:cursor-not-allowed disabled:opacity-50',
		checked ? 'bg-primary' : 'bg-input',
		className
	)}
>
	<span
		class={cn(
			'pointer-events-none block h-5 w-5 rounded-full bg-background shadow-lg ring-0 transition-transform',
			checked ? 'translate-x-5' : 'translate-x-0'
		)}
	></span>
</button>
