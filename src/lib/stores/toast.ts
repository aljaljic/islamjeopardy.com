import { writable } from 'svelte/store';

export type ToastType = 'success' | 'error' | 'warning' | 'info';

export interface Toast {
	id: string;
	message: string;
	type: ToastType;
	duration: number;
}

function createToastStore() {
	const { subscribe, update } = writable<Toast[]>([]);

	function add(message: string, type: ToastType = 'info', duration = 4000): string {
		const id = crypto.randomUUID();
		update((toasts) => [...toasts, { id, message, type, duration }]);

		if (duration > 0) {
			setTimeout(() => {
				remove(id);
			}, duration);
		}

		return id;
	}

	function remove(id: string) {
		update((toasts) => toasts.filter((t) => t.id !== id));
	}

	return {
		subscribe,
		add,
		remove,
		success: (message: string, duration?: number) => add(message, 'success', duration),
		error: (message: string, duration?: number) => add(message, 'error', duration),
		warning: (message: string, duration?: number) => add(message, 'warning', duration),
		info: (message: string, duration?: number) => add(message, 'info', duration)
	};
}

export const toast = createToastStore();
