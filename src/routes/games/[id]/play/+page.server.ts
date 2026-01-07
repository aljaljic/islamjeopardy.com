import { error } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ params, url, locals: { supabase, safeGetSession } }) => {
	const { session } = await safeGetSession();
	const teamsParam = url.searchParams.get('teams');
	const djParam = url.searchParams.get('dj');
	const initialTeamCount = teamsParam ? Math.max(1, Math.min(8, parseInt(teamsParam) || 2)) : null;
	const initialDoubleJeopardy = djParam !== null ? djParam === '1' : null;

	// Fetch game with categories
	const { data: game, error: gameError } = await supabase
		.from('games')
		.select(
			`
			*,
			profiles:creator_id (username, display_name),
			game_categories (
				id,
				category_id,
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

	// Check access (public or owner)
	if (!game.is_public && game.creator_id !== session?.user?.id) {
		error(403, 'You do not have access to this game');
	}

	// Fetch questions for all game_categories
	const gameCategoryIds = game.game_categories.map((gc: { id: string }) => gc.id);
	const { data: questions, error: qError } = await supabase
		.from('questions')
		.select('*')
		.in('game_category_id', gameCategoryIds)
		.order('display_order');

	if (qError) {
		error(500, 'Failed to load questions');
	}

	// Structure data for the game board
	const categories = game.game_categories
		.sort(
			(a: { display_order: number }, b: { display_order: number }) =>
				a.display_order - b.display_order
		)
		.map((gc: { id: string; categories: { name: string; category_type: string } }) => ({
			id: gc.id,
			name: gc.categories.name,
			category_type: gc.categories.category_type,
			questions: questions
				.filter((q: { game_category_id: string }) => q.game_category_id === gc.id)
				.sort((a: { points: number }, b: { points: number }) => a.points - b.points)
				.map((q: { id: string; question_text: string; answer_text: string; explanation: string | null; points: number }) => ({
					id: q.id,
					question_text: q.question_text,
					answer_text: q.answer_text,
					explanation: q.explanation,
					points: q.points
				}))
		}));

	return {
		game: {
			id: game.id,
			title: game.title,
			description: game.description,
			difficulty: game.difficulty,
			creator: game.profiles?.display_name || game.profiles?.username
		},
		categories,
		session,
		initialTeamCount,
		initialDoubleJeopardy
	};
};

export const actions: Actions = {
	incrementPlays: async ({ params, locals: { supabase } }) => {
		// Increment play count - works for all users (no auth required)
		const { data: gameData } = await supabase
			.from('games')
			.select('total_plays')
			.eq('id', params.id)
			.single();

		if (gameData) {
			await supabase
				.from('games')
				.update({ total_plays: (gameData.total_plays || 0) + 1 })
				.eq('id', params.id);
		}

		return { success: true };
	}
};
