<script lang="ts">
	import { fly } from 'svelte/transition';
	import { toast, type Toast } from '$lib/stores/toast';
	import { X, CheckCircle, AlertCircle, AlertTriangle, Info } from 'lucide-svelte';
	import { cn } from '$lib/utils';

	let toasts: Toast[] = $state([]);

	$effect(() => {
		const unsubscribe = toast.subscribe((value) => {
			toasts = value;
		});
		return unsubscribe;
	});

	const icons = {
		success: CheckCircle,
		error: AlertCircle,
		warning: AlertTriangle,
		info: Info
	};

	const styles = {
		success: 'bg-gradient-to-r from-emerald-500 to-green-600 text-white',
		error: 'bg-gradient-to-r from-red-500 to-rose-600 text-white',
		warning: 'bg-gradient-to-r from-amber-500 to-orange-600 text-white',
		info: 'bg-gradient-to-r from-blue-500 to-indigo-600 text-white'
	};
</script>

<div class="fixed bottom-4 right-4 z-50 flex flex-col gap-2 safe-bottom safe-right">
	{#each toasts as t (t.id)}
		{@const Icon = icons[t.type]}
		<div
			in:fly={{ x: 100, duration: 300 }}
			out:fly={{ x: 100, duration: 200 }}
			class={cn(
				'flex items-center gap-3 rounded-xl px-4 py-3 shadow-lg min-w-[280px] max-w-[360px] touch-target',
				styles[t.type]
			)}
		>
			<Icon class="h-5 w-5 shrink-0" />
			<p class="flex-1 text-sm font-medium">{t.message}</p>
			<button
				onclick={() => toast.remove(t.id)}
				class="shrink-0 rounded-full p-1.5 hover:bg-white/20 active:bg-white/30 transition-colors touch-target"
				aria-label="Dismiss notification"
			>
				<X class="h-4 w-4" />
			</button>
		</div>
	{/each}
</div>
