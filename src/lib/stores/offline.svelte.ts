// Offline state management for Capacitor iOS app
import { browser } from '$app/environment';

// Check if running in Capacitor
const isCapacitor = browser && (window as { Capacitor?: { isNativePlatform?: () => boolean } }).Capacitor?.isNativePlatform?.();

// Offline state
let isOnline = $state(browser ? navigator.onLine : true);
let pendingActions = $state<PendingAction[]>([]);

interface PendingAction {
	id: string;
	type: 'upvote' | 'downvote';
	gameId: string;
	timestamp: number;
}

interface CachedGame {
	id: string;
	title: string;
	description: string | null;
	difficulty: string;
	categories: unknown[];
	cachedAt: number;
}

// Initialize network listeners
if (browser) {
	// Use Capacitor Network plugin if available, otherwise use browser events
	if (isCapacitor) {
		import('@capacitor/network').then(({ Network }) => {
			Network.addListener('networkStatusChange', (status) => {
				isOnline = status.connected;
				if (isOnline) {
					syncPendingActions();
				}
			});

			// Get initial status
			Network.getStatus().then((status) => {
				isOnline = status.connected;
			});
		}).catch(() => {
			// Fallback to browser events if Capacitor Network not available
			setupBrowserNetworkListeners();
		});
	} else {
		setupBrowserNetworkListeners();
	}

	// Load pending actions from localStorage
	const stored = localStorage.getItem('pendingActions');
	if (stored) {
		try {
			pendingActions = JSON.parse(stored);
		} catch {
			pendingActions = [];
		}
	}
}

function setupBrowserNetworkListeners() {
	window.addEventListener('online', () => {
		isOnline = true;
		syncPendingActions();
	});

	window.addEventListener('offline', () => {
		isOnline = false;
	});
}

// Save pending actions to localStorage
function savePendingActions() {
	if (browser) {
		localStorage.setItem('pendingActions', JSON.stringify(pendingActions));
	}
}

// Add a pending action to be synced when online
export function queueAction(action: Omit<PendingAction, 'id' | 'timestamp'>) {
	const newAction: PendingAction = {
		...action,
		id: crypto.randomUUID(),
		timestamp: Date.now()
	};

	pendingActions = [...pendingActions, newAction];
	savePendingActions();

	// Try to sync immediately if online
	if (isOnline) {
		syncPendingActions();
	}
}

// Sync all pending actions with the server
async function syncPendingActions() {
	if (!browser || pendingActions.length === 0) return;

	const actionsToSync = [...pendingActions];

	for (const action of actionsToSync) {
		try {
			if (action.type === 'upvote' || action.type === 'downvote') {
				const response = await fetch('/api/upvote', {
					method: 'POST',
					headers: { 'Content-Type': 'application/json' },
					body: JSON.stringify({
						gameId: action.gameId,
						remove: action.type === 'downvote'
					})
				});

				if (response.ok) {
					// Remove from pending queue
					pendingActions = pendingActions.filter((a) => a.id !== action.id);
					savePendingActions();
				}
			}
		} catch {
			// Keep in queue for next sync attempt
			console.log('Failed to sync action, will retry later:', action);
		}
	}
}

// Cache a game for offline play
export function cacheGame(game: CachedGame) {
	if (!browser) return;

	const cached = getCachedGames();
	const existing = cached.findIndex((g) => g.id === game.id);

	if (existing >= 0) {
		cached[existing] = { ...game, cachedAt: Date.now() };
	} else {
		cached.push({ ...game, cachedAt: Date.now() });
	}

	// Keep only the 20 most recently cached games
	const sorted = cached.sort((a, b) => b.cachedAt - a.cachedAt).slice(0, 20);
	localStorage.setItem('cachedGames', JSON.stringify(sorted));

	// Also tell service worker to cache
	if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
		navigator.serviceWorker.controller.postMessage({
			type: 'CACHE_GAME',
			gameId: game.id,
			data: game
		});
	}
}

// Get all cached games
export function getCachedGames(): CachedGame[] {
	if (!browser) return [];

	const stored = localStorage.getItem('cachedGames');
	if (!stored) return [];

	try {
		return JSON.parse(stored);
	} catch {
		return [];
	}
}

// Get a specific cached game
export function getCachedGame(id: string): CachedGame | null {
	const cached = getCachedGames();
	return cached.find((g) => g.id === id) || null;
}

// Check if a game is cached
export function isGameCached(id: string): boolean {
	return getCachedGame(id) !== null;
}

// Export reactive state
export const offline = {
	get isOnline() {
		return isOnline;
	},
	get pendingActionsCount() {
		return pendingActions.length;
	},
	get hasPendingActions() {
		return pendingActions.length > 0;
	}
};
