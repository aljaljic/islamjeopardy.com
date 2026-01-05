import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { supabase }, url }) => {
	// If teams parameter is provided, redirect to first available game
	const teams = url.searchParams.get('teams');
	if (teams) {
		const { data: games, error } = await supabase
			.from('games')
			.select('id')
			.eq('is_public', true)
			.order('created_at', { ascending: false })
			.limit(1)
			.single();

		if (!error && games) {
			throw redirect(302, `/games/${games.id}/play?teams=${teams}`);
		}
	}

	// Fetch available games for selection
	const { data: games, error } = await supabase
		.from('games')
		.select(
			`
			id,
			title,
			description,
			difficulty,
			total_plays,
			average_rating,
			rating_count,
			profiles:creator_id (
				username,
				display_name
			)
		`
		)
		.eq('is_public', true)
		.order('created_at', { ascending: false })
		.limit(10);

	return {
		games: games ?? [],
		dbError: !!error
	};
};

