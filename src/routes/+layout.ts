import { createBrowserClient } from '@supabase/ssr';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';
import type { LayoutLoad } from './$types';
import type { Database } from '$lib/types/database.types';

// Prerendering is disabled because we need dynamic Supabase auth
export const prerender = false;

// Disable SSR for static/Capacitor builds
export const ssr = false;

export const load: LayoutLoad = async ({ data, depends, fetch }) => {
	depends('supabase:auth');

	const supabase = createBrowserClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
		global: {
			fetch
		}
	});

	// Wrap in try-catch to handle network failures gracefully (important for Capacitor)
	try {
		const {
			data: { session },
			error
		} = await supabase.auth.getSession();

		if (error) {
			console.warn('Supabase auth error:', error.message);
			return {
				session: data?.session ?? null,
				user: data?.user ?? null,
				supabase
			};
		}

		return {
			session: session ?? data?.session ?? null,
			user: session?.user ?? data?.user ?? null,
			supabase
		};
	} catch (err) {
		// Network errors or other failures - return default state
		console.warn('Failed to get session:', err instanceof Error ? err.message : err);
		return {
			session: data?.session ?? null,
			user: data?.user ?? null,
			supabase
		};
	}
};
