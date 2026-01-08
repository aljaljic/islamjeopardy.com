import { createBrowserClient } from '@supabase/ssr';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';
import type { LayoutLoad } from './$types';
import type { Database } from '$lib/types/database.types';

// Prerendering is disabled because we need dynamic Supabase auth
export const prerender = false;

export const load: LayoutLoad = async ({ data, depends, fetch }) => {
	depends('supabase:auth');

	const supabase = createBrowserClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
		global: {
			fetch
		}
	});

	const {
		data: { session }
	} = await supabase.auth.getSession();

	return {
		session: session ?? data.session,
		user: session?.user ?? data.user,
		supabase
	};
};
