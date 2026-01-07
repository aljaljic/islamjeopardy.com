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

function loadFamilyName(): string {
	if (!browser) return '';
	return localStorage.getItem(FAMILY_NAME_KEY) || '';
}

function saveFamilyName(name: string) {
	if (!browser) return;
	localStorage.setItem(FAMILY_NAME_KEY, name);
}

// Reactive state using Svelte 5 runes
let results = $state<GameResult[]>(loadResults());
let family = $state<string>(loadFamilyName());

// Derived leaderboard entries
function getLeaderboard(): LeaderboardEntry[] {
	const teamStats = new Map<
		string,
		{
			wins: number;
			games: number;
			scores: number[];
			familyName: string;
		}
	>();

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
}

// Export reactive getters and actions
export const leaderboard = {
	get results() {
		return results;
	},

	get entries() {
		return getLeaderboard();
	},

	getRecentGames(limit = 10): GameResult[] {
		return results.slice(0, limit);
	},

	addResult(result: Omit<GameResult, 'id' | 'playedAt'>) {
		const newResult: GameResult = {
			...result,
			id: crypto.randomUUID(),
			playedAt: new Date().toISOString()
		};

		results = [newResult, ...results].slice(0, 100); // Keep last 100 games
		saveResults(results);
		return newResult;
	},

	deleteResult(id: string) {
		results = results.filter((r) => r.id !== id);
		saveResults(results);
	},

	clearAll() {
		results = [];
		saveResults([]);
	},

	reload() {
		results = loadResults();
	}
};

export const familyName = {
	get value() {
		return family;
	},

	set(name: string) {
		family = name;
		saveFamilyName(name);
	},

	reload() {
		family = loadFamilyName();
	}
};
