import { redirect, fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { safeGetSession } }) => {
	const { session } = await safeGetSession();

	if (session) {
		redirect(303, '/');
	}

	return {};
};

export const actions: Actions = {
	default: async ({ request, locals: { supabase }, url }) => {
		const formData = await request.formData();
		const email = formData.get('email') as string;
		const password = formData.get('password') as string;
		const usernameRaw = formData.get('username') as string;
		const displayName = formData.get('display_name') as string;

		if (!email || !password || !usernameRaw) {
			return fail(400, {
				error: 'Email, username, and password are required',
				email,
				username: usernameRaw,
				displayName
			});
		}

		// Normalize username: lowercase and trim
		const username = usernameRaw.toLowerCase().trim();

		if (username.length < 3 || username.length > 20) {
			return fail(400, {
				error: 'Username must be between 3 and 20 characters',
				email,
				username: usernameRaw,
				displayName
			});
		}

		if (password.length < 6) {
			return fail(400, {
				error: 'Password must be at least 6 characters',
				email,
				username: usernameRaw,
				displayName
			});
		}

		// Check if username already exists
		const { data: existingProfile } = await supabase
			.from('profiles')
			.select('id')
			.eq('username', username)
			.single();

		if (existingProfile) {
			return fail(400, {
				error: 'This username is already taken. Please choose another one.',
				email,
				username: usernameRaw,
				displayName
			});
		}

		const { error } = await supabase.auth.signUp({
			email,
			password,
			options: {
				data: {
					username,
					display_name: displayName || username
				},
				emailRedirectTo: `${url.origin}/auth/callback`
			}
		});

		if (error) {
			return fail(400, {
				error: error.message,
				email,
				username: usernameRaw,
				displayName
			});
		}

		return {
			success: true,
			message: 'Check your email to confirm your account'
		};
	}
};
