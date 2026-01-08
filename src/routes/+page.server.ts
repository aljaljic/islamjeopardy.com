import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { supabase } }) => {
	try {
		const { data: games, error } = await supabase
			.from('games')
			.select(
				`
				*,
				profiles:creator_id (
					username,
					display_name
				)
			`
			)
			.eq('is_public', true)
			.order('upvotes', { ascending: false })
			.order('created_at', { ascending: false })
			.limit(20);

		if (error) {
			console.error('Error fetching games:', error);
			return { games: [], dbError: true };
		}

		return { games: games ?? [] };
	} catch (e) {
		console.error('Database connection error:', e);
		return { games: [], dbError: true };
	}
};
