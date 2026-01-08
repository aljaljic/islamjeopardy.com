/// <reference types="@sveltejs/kit" />
/// <reference no-default-lib="true"/>
/// <reference lib="esnext" />
/// <reference lib="webworker" />

import { build, files, version } from '$service-worker';

const sw = self as unknown as ServiceWorkerGlobalScope;

// Create unique cache names
const CACHE_NAME = `cache-${version}`;
const GAMES_CACHE = `games-${version}`;

// Assets to cache immediately on install
const ASSETS = [
	...build, // the app itself
	...files // everything in `static`
];

// Install: cache static assets
sw.addEventListener('install', (event) => {
	event.waitUntil(
		(async () => {
			const cache = await caches.open(CACHE_NAME);
			await cache.addAll(ASSETS);
			await sw.skipWaiting();
		})()
	);
});

// Activate: clean up old caches
sw.addEventListener('activate', (event) => {
	event.waitUntil(
		(async () => {
			// Delete old caches
			const keys = await caches.keys();
			await Promise.all(
				keys
					.filter((key) => key !== CACHE_NAME && key !== GAMES_CACHE)
					.map((key) => caches.delete(key))
			);
			await sw.clients.claim();
		})()
	);
});

// Fetch: serve from cache, fallback to network
sw.addEventListener('fetch', (event) => {
	const url = new URL(event.request.url);

	// Skip non-GET requests
	if (event.request.method !== 'GET') return;

	// Skip external requests
	if (url.origin !== location.origin) return;

	// Handle API requests (games data) with network-first, cache fallback
	if (url.pathname.startsWith('/api/') || url.pathname.includes('supabase')) {
		event.respondWith(networkFirst(event.request, GAMES_CACHE));
		return;
	}

	// Handle navigation requests with cache-first for SPA
	if (event.request.mode === 'navigate') {
		event.respondWith(
			(async () => {
				try {
					// Try network first for navigation
					const networkResponse = await fetch(event.request);
					return networkResponse;
				} catch {
					// Fallback to cached index.html for SPA routing
					const cache = await caches.open(CACHE_NAME);
					const cachedResponse = await cache.match('/index.html');
					if (cachedResponse) return cachedResponse;

					// Last resort: return any cached page
					return (await cache.match(event.request)) || new Response('Offline', { status: 503 });
				}
			})()
		);
		return;
	}

	// Handle static assets with cache-first
	event.respondWith(cacheFirst(event.request));
});

// Cache-first strategy for static assets
async function cacheFirst(request: Request): Promise<Response> {
	const cache = await caches.open(CACHE_NAME);
	const cachedResponse = await cache.match(request);

	if (cachedResponse) {
		return cachedResponse;
	}

	try {
		const networkResponse = await fetch(request);
		// Cache successful responses
		if (networkResponse.ok) {
			cache.put(request, networkResponse.clone());
		}
		return networkResponse;
	} catch {
		return new Response('Offline', { status: 503 });
	}
}

// Network-first strategy for dynamic content (API calls)
async function networkFirst(request: Request, cacheName: string): Promise<Response> {
	const cache = await caches.open(cacheName);

	try {
		const networkResponse = await fetch(request);
		// Cache successful API responses
		if (networkResponse.ok) {
			cache.put(request, networkResponse.clone());
		}
		return networkResponse;
	} catch {
		// Fallback to cache if offline
		const cachedResponse = await cache.match(request);
		if (cachedResponse) {
			return cachedResponse;
		}
		return new Response(JSON.stringify({ error: 'Offline' }), {
			status: 503,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}

// Listen for messages from the app
sw.addEventListener('message', (event) => {
	if (event.data?.type === 'CACHE_GAME') {
		// Cache a specific game's data
		const { gameId, data } = event.data;
		cacheGameData(gameId, data);
	}

	if (event.data?.type === 'SKIP_WAITING') {
		sw.skipWaiting();
	}
});

// Cache game data for offline play
async function cacheGameData(gameId: string, data: unknown) {
	const cache = await caches.open(GAMES_CACHE);
	const response = new Response(JSON.stringify(data), {
		headers: { 'Content-Type': 'application/json' }
	});
	await cache.put(`/api/games/${gameId}`, response);
}
