import { redirect, fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { supabase, safeGetSession } }) => {
	const { session } = await safeGetSession();

	if (!session) {
		redirect(303, '/auth/login');
	}

	const { data: games, error } = await supabase
		.from('games')
		.select(
			`
			*,
			game_categories (
				categories (name)
			)
		`
		)
		.eq('creator_id', session.user.id)
		.order('created_at', { ascending: false });

	if (error) {
		console.error('Error fetching games:', error);
		return { games: [] };
	}

	return { games: games ?? [] };
};

export const actions: Actions = {
	delete: async ({ request, locals: { supabase, safeGetSession } }) => {
		const { session } = await safeGetSession();
		if (!session) {
			return fail(401, { error: 'You must be logged in' });
		}

		const formData = await request.formData();
		const gameId = formData.get('gameId') as string;

		// Verify ownership
		const { data: game } = await supabase
			.from('games')
			.select('creator_id')
			.eq('id', gameId)
			.single();

		if (!game || game.creator_id !== session.user.id) {
			return fail(403, { error: 'You can only delete your own games' });
		}

		// Delete game (cascades to game_categories and questions)
		const { error } = await supabase.from('games').delete().eq('id', gameId);

		if (error) {
			return fail(500, { error: 'Failed to delete game' });
		}

		return { success: true };
	},

	toggleVisibility: async ({ request, locals: { supabase, safeGetSession } }) => {
		const { session } = await safeGetSession();
		if (!session) {
			return fail(401, { error: 'You must be logged in' });
		}

		const formData = await request.formData();
		const gameId = formData.get('gameId') as string;
		const isPublic = formData.get('isPublic') === 'true';

		const { error } = await supabase
			.from('games')
			.update({ is_public: !isPublic })
			.eq('id', gameId)
			.eq('creator_id', session.user.id);

		if (error) {
			return fail(500, { error: 'Failed to update visibility' });
		}

		return { success: true };
	}
};
