import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { safeGetSession } }) => {
	const { session } = await safeGetSession();

	if (!session) {
		redirect(303, '/auth/login');
	}

	return {
		session
	};
};

export const actions: Actions = {
	deleteAccount: async ({ request, locals: { supabase, safeGetSession } }) => {
		const { session } = await safeGetSession();

		if (!session) {
			return fail(401, { error: 'You must be logged in to delete your account' });
		}

		const formData = await request.formData();
		const confirmation = formData.get('confirmation') as string;

		// Require user to type "DELETE" to confirm
		if (confirmation !== 'DELETE') {
			return fail(400, {
				error: 'Please type "DELETE" to confirm account deletion',
				confirmation
			});
		}

		// Delete all user data via database function
		// This will delete profile, games, ratings, favorites, etc.
		const { error: deleteError } = await supabase.rpc('delete_user_account');

		if (deleteError) {
			return fail(500, {
				error: 'Failed to delete account. Please contact support if this persists.',
				confirmation
			});
		}

		// Note: The auth user will remain in auth.users but won't have any associated data
		// To fully delete the auth user, you would need to use Supabase Admin API
		// For now, we delete all data and sign out

		// Sign out and redirect
		await supabase.auth.signOut();
		redirect(303, '/');
	}
};
