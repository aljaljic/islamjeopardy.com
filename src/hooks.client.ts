import type { HandleClientError } from '@sveltejs/kit';

export const handleError: HandleClientError = async ({ error, event }) => {
	// Better error logging - handle various error types
	if (error instanceof Error) {
		console.error('Client error:', error.message, error.stack);
	} else if (typeof error === 'string') {
		console.error('Client error:', error);
	} else {
		console.error('Client error:', JSON.stringify(error, null, 2));
	}

	return {
		message: error instanceof Error ? error.message : 'An unexpected error occurred'
	};
};
