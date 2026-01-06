import type { PageServerLoad } from './$types';

// Sort order for difficulty levels
const difficultyOrder: Record<string, number> = {
	kids: 1,
	beginner: 2,
	advanced: 3
};

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
			.limit(50);

		if (error) {
			console.error('Error fetching games:', error);
			return { games: [], dbError: true };
		}

		// Sort by difficulty: kids -> beginner -> advanced, then by created_at
		const sortedGames = (games ?? []).sort((a, b) => {
			const diffA = difficultyOrder[a.difficulty] || 99;
			const diffB = difficultyOrder[b.difficulty] || 99;
			if (diffA !== diffB) return diffA - diffB;
			return new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
		});

		return { games: sortedGames.slice(0, 12) };
	} catch (e) {
		console.error('Database connection error:', e);
		return { games: [], dbError: true };
	}
};
