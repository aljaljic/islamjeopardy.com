import { writable, get } from 'svelte/store';
import { browser } from '$app/environment';

export interface GameResult {
	id: string;
	gameTitle: string;
	gameId: string;
	familyName: string;
	teams: {
		name: string;
		score: number;
		isWinner: boolean;
	}[];
	totalQuestions: number;
	playedAt: string; // ISO date string
}

export interface LeaderboardEntry {
	playerName: string;
	familyName: string;
	totalWins: number;
	totalGames: number;
	highestScore: number;
	averageScore: number;
}

const STORAGE_KEY = 'islamic-jeopardy-results';
const FAMILY_NAME_KEY = 'islamic-jeopardy-family';

function loadResults(): GameResult[] {
	if (!browser) return [];
	try {
		const stored = localStorage.getItem(STORAGE_KEY);
		return stored ? JSON.parse(stored) : [];
	} catch {
		return [];
	}
}

function saveResults(results: GameResult[]) {
	if (!browser) return;
	try {
		localStorage.setItem(STORAGE_KEY, JSON.stringify(results));
	} catch {
		// Storage might be full or unavailable
	}
}

function createLeaderboardStore() {
	const { subscribe, set, update } = writable<GameResult[]>(loadResults());

	return {
		subscribe,

		// Add a new game result
		addResult: (result: Omit<GameResult, 'id' | 'playedAt'>) => {
			const newResult: GameResult = {
				...result,
				id: crypto.randomUUID(),
				playedAt: new Date().toISOString()
			};

			update((results) => {
				const updated = [newResult, ...results].slice(0, 100); // Keep last 100 games
				saveResults(updated);
				return updated;
			});

			return newResult;
		},

		// Clear all results
		clearAll: () => {
			set([]);
			saveResults([]);
		},

		// Delete a specific result
		deleteResult: (id: string) => {
			update((results) => {
				const updated = results.filter((r) => r.id !== id);
				saveResults(updated);
				return updated;
			});
		},

		// Get leaderboard entries (aggregated stats per team)
		getLeaderboard: (): LeaderboardEntry[] => {
			const results = get({ subscribe });
			const teamStats = new Map<string, {
				wins: number;
				games: number;
				scores: number[];
				familyName: string;
			}>();

			results.forEach((game) => {
				game.teams.forEach((team) => {
					const key = `${game.familyName}:${team.name}`;
					const existing = teamStats.get(key) || {
						wins: 0,
						games: 0,
						scores: [],
						familyName: game.familyName
					};

					existing.games++;
					existing.scores.push(team.score);
					if (team.isWinner) existing.wins++;

					teamStats.set(key, existing);
				});
			});

			const entries: LeaderboardEntry[] = [];
			teamStats.forEach((stats, key) => {
				const playerName = key.split(':')[1];
				entries.push({
					playerName,
					familyName: stats.familyName,
					totalWins: stats.wins,
					totalGames: stats.games,
					highestScore: Math.max(...stats.scores),
					averageScore: Math.round(stats.scores.reduce((a, b) => a + b, 0) / stats.scores.length)
				});
			});

			// Sort by wins, then by highest score
			return entries.sort((a, b) => {
				if (b.totalWins !== a.totalWins) return b.totalWins - a.totalWins;
				return b.highestScore - a.highestScore;
			});
		},

		// Get recent games
		getRecentGames: (limit = 10): GameResult[] => {
			const results = get({ subscribe });
			return results.slice(0, limit);
		},

		// Reload from localStorage (useful after hydration)
		reload: () => {
			set(loadResults());
		}
	};
}

export const leaderboard = createLeaderboardStore();

// Family name store
function createFamilyNameStore() {
	const stored = browser ? localStorage.getItem(FAMILY_NAME_KEY) || '' : '';
	const { subscribe, set } = writable<string>(stored);

	return {
		subscribe,
		set: (name: string) => {
			set(name);
			if (browser) {
				localStorage.setItem(FAMILY_NAME_KEY, name);
			}
		}
	};
}

export const familyName = createFamilyNameStore();
