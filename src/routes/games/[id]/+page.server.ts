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

	// Get user's rating if logged in
	let userRating = null;
	let isFavorited = false;
	if (session) {
		const { data: rating } = await supabase
			.from('ratings')
			.select('rating, review_text')
			.eq('game_id', params.id)
			.eq('user_id', session.user.id)
			.single();

		userRating = rating;

		const { data: favorite } = await supabase
			.from('favorites')
			.select('id')
			.eq('game_id', params.id)
			.eq('user_id', session.user.id)
			.single();

		isFavorited = !!favorite;
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
			average_rating: game.average_rating,
			rating_count: game.rating_count,
			created_at: game.created_at,
			creator_id: game.creator_id,
			creator: {
				username: game.profiles.username,
				display_name: game.profiles.display_name,
				avatar_url: game.profiles.avatar_url
			}
		},
		categories,
		userRating,
		isFavorited,
		isOwner: session?.user?.id === game.creator_id,
		session
	};
};

export const actions: Actions = {
	rate: async ({ request, params, locals: { supabase, safeGetSession } }) => {
		const { session } = await safeGetSession();
		if (!session) {
			return fail(401, { error: 'You must be logged in to rate' });
		}

		const formData = await request.formData();
		const rating = parseInt(formData.get('rating') as string);

		if (rating < 1 || rating > 5) {
			return fail(400, { error: 'Rating must be between 1 and 5' });
		}

		const { error } = await supabase.from('ratings').upsert(
			{
				game_id: params.id,
				user_id: session.user.id,
				rating
			},
			{ onConflict: 'game_id,user_id' }
		);

		if (error) {
			return fail(500, { error: 'Failed to save rating' });
		}

		return { success: true };
	},

	toggleFavorite: async ({ params, locals: { supabase, safeGetSession } }) => {
		const { session } = await safeGetSession();
		if (!session) {
			return fail(401, { error: 'You must be logged in' });
		}

		// Check if already favorited
		const { data: existing } = await supabase
			.from('favorites')
			.select('id')
			.eq('game_id', params.id)
			.eq('user_id', session.user.id)
			.single();

		if (existing) {
			await supabase.from('favorites').delete().eq('id', existing.id);
		} else {
			await supabase.from('favorites').insert({
				game_id: params.id,
				user_id: session.user.id
			});
		}

		return { success: true };
	}
};
