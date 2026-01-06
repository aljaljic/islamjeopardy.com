import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

// Sort order for difficulty levels
const difficultyOrder: Record<string, number> = {
	kids: 1,
	beginner: 2,
	advanced: 3
};

export const load: PageServerLoad = async ({ locals: { supabase }, url }) => {
	// If teams parameter is provided, redirect to first available game (kids difficulty first)
	const teams = url.searchParams.get('teams');
	if (teams) {
		const { data: games, error } = await supabase
			.from('games')
			.select('id, difficulty')
			.eq('is_public', true)
			.limit(50);

		if (!error && games && games.length > 0) {
			// Sort and pick the first one (kids difficulty preferred)
			const sorted = games.sort((a, b) => {
				const diffA = difficultyOrder[a.difficulty] || 99;
				const diffB = difficultyOrder[b.difficulty] || 99;
				return diffA - diffB;
			});
			throw redirect(302, `/games/${sorted[0].id}/play?teams=${teams}`);
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
		.limit(50);

	// Sort by difficulty: kids -> beginner -> advanced, then by created_at
	const sortedGames = (games ?? []).sort((a, b) => {
		const diffA = difficultyOrder[a.difficulty] || 99;
		const diffB = difficultyOrder[b.difficulty] || 99;
		return diffA - diffB;
	});

	// Get selected game ID from query param
	const selectedGameParam = url.searchParams.get('game');

	return {
		games: sortedGames.slice(0, 20),
		dbError: !!error,
		selectedGameId: selectedGameParam
	};
};

