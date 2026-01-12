import { error, fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params, locals: { supabase, safeGetSession } }) => {
	const { session } = await safeGetSession();

	const { data: game, error: gameError } = await supabase
		.from('games')
		.select(
			`
			*,
			profiles:creator_id (username, display_name, avatar_url),
			game_categories (
				id,
				display_order,
				categories (name, category_type)
			)
		`
		)
		.eq('id', params.id)
		.single();

	if (gameError || !game) {
		error(404, 'Game not found');
	}

	// Check access
	if (!game.is_public && game.creator_id !== session?.user?.id) {
		error(403, 'You do not have access to this game');
	}

	// Get categories sorted by display_order
	const categories = game.game_categories
		.sort((a: { display_order: number }, b: { display_order: number }) => a.display_order - b.display_order)
		.map((gc: { categories: { name: string } }) => gc.categories.name);

	return {
		game: {
			id: game.id,
			title: game.title,
			description: game.description,
			difficulty: game.difficulty,
			is_public: game.is_public,
			total_plays: game.total_plays,
			created_at: game.created_at,
			creator_id: game.creator_id,
			creator: {
				username: game.profiles.username,
				display_name: game.profiles.display_name,
				avatar_url: game.profiles.avatar_url
			}
		},
		categories,
		isOwner: session?.user?.id === game.creator_id,
		session
	};
};

export const actions: Actions = {};
