import { redirect, fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals: { safeGetSession, supabase } }) => {
	const { session } = await safeGetSession();

	if (!session) {
		redirect(303, '/auth/login');
	}

	const { data: categories, error } = await supabase
		.from('categories')
		.select('*')
		.order('name');

	if (error) {
		console.error('Error fetching categories:', error);
		return { categories: [] };
	}

	return { categories: categories ?? [] };
};

export const actions: Actions = {
	default: async ({ request, locals: { supabase, safeGetSession } }) => {
		const { session } = await safeGetSession();
		if (!session) {
			return fail(401, { error: 'You must be logged in to create a game' });
		}

		const formData = await request.formData();
		const gameDataStr = formData.get('gameData') as string;

		if (!gameDataStr) {
			return fail(400, { error: 'Invalid form data' });
		}

		let gameData;
		try {
			gameData = JSON.parse(gameDataStr);
		} catch {
			return fail(400, { error: 'Invalid form data' });
		}

		// Validate game data
		if (!gameData.title || gameData.title.trim().length < 3) {
			return fail(400, { error: 'Title must be at least 3 characters' });
		}

		if (!gameData.categories || gameData.categories.length !== 5) {
			return fail(400, { error: 'You must select exactly 5 categories' });
		}

		if (!gameData.questions || gameData.questions.length !== 25) {
			return fail(400, { error: 'You must add 25 questions (5 per category)' });
		}

		// Create the game
		const { data: game, error: gameError } = await supabase
			.from('games')
			.insert({
				title: gameData.title.trim(),
				description: gameData.description?.trim() || null,
				difficulty: gameData.difficulty,
				is_public: gameData.is_public,
				creator_id: session.user.id
			})
			.select()
			.single();

		if (gameError) {
			console.error('Error creating game:', gameError);
			return fail(500, { error: 'Failed to create game' });
		}

		// Create game_categories
		const gameCategoryInserts = gameData.categories.map(
			(cat: { category_id: string }, index: number) => ({
				game_id: game.id,
				category_id: cat.category_id,
				display_order: index
			})
		);

		const { data: gameCategories, error: gcError } = await supabase
			.from('game_categories')
			.insert(gameCategoryInserts)
			.select();

		if (gcError) {
			// Rollback: delete the game
			await supabase.from('games').delete().eq('id', game.id);
			console.error('Error creating game categories:', gcError);
			return fail(500, { error: 'Failed to create game categories' });
		}

		// Create questions
		const questionInserts = gameData.questions.map(
			(q: { category_id: string; question_text: string; answer_text: string; points: number }) => {
				const gameCategory = gameCategories.find(
					(gc: { category_id: string }) => gc.category_id === q.category_id
				);
				return {
					game_id: game.id,
					game_category_id: gameCategory!.id,
					question_text: q.question_text,
					answer_text: q.answer_text,
					points: q.points,
					display_order: Math.floor(q.points / 100) - 1
				};
			}
		);

		const { error: qError } = await supabase.from('questions').insert(questionInserts);

		if (qError) {
			// Rollback
			await supabase.from('games').delete().eq('id', game.id);
			console.error('Error creating questions:', qError);
			return fail(500, { error: 'Failed to create questions' });
		}

		redirect(303, `/games/${game.id}`);
	}
};
