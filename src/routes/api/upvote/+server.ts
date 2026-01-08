import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const POST: RequestHandler = async ({ request, locals: { supabase } }) => {
	try {
		const { gameId, remove } = await request.json();

		if (!gameId) {
			return json({ error: 'Game ID required' }, { status: 400 });
		}

		const rpcName = remove ? 'downvote_game' : 'upvote_game';
		const { data, error } = await supabase.rpc(rpcName, { game_id: gameId });

		if (error) {
			console.error('Upvote error:', error);
			return json({ error: 'Failed to update vote' }, { status: 500 });
		}

		return json({ success: true, upvotes: data });
	} catch (e) {
		console.error('Upvote error:', e);
		return json({ error: 'Failed to update vote' }, { status: 500 });
	}
};
