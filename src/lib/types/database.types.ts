// Database Types
// TODO: Generate this file by running:
// npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/lib/types/database.types.ts
//
// Get your project ID from: https://app.supabase.com/project/YOUR_PROJECT/settings/general

export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export type Database = {
	public: {
		Tables: {
			profiles: {
				Row: {
					id: string;
					username: string;
					display_name: string | null;
					avatar_url: string | null;
					created_at: string;
					updated_at: string;
				};
				Insert: {
					id: string;
					username: string;
					display_name?: string | null;
					avatar_url?: string | null;
					created_at?: string;
					updated_at?: string;
				};
				Update: {
					id?: string;
					username?: string;
					display_name?: string | null;
					avatar_url?: string | null;
					created_at?: string;
					updated_at?: string;
				};
			};
			categories: {
				Row: {
					id: string;
					name: string;
					category_type: 'prophets' | 'quran' | 'hadith' | 'sunnah' | 'islamic_beliefs' | 'islamic_manners' | 'history' | 'other';
					description: string | null;
					created_at: string;
				};
				Insert: {
					id?: string;
					name: string;
					category_type: 'prophets' | 'quran' | 'hadith' | 'sunnah' | 'islamic_beliefs' | 'islamic_manners' | 'history' | 'other';
					description?: string | null;
					created_at?: string;
				};
				Update: {
					id?: string;
					name?: string;
					category_type?: 'prophets' | 'quran' | 'hadith' | 'sunnah' | 'islamic_beliefs' | 'islamic_manners' | 'history' | 'other';
					description?: string | null;
					created_at?: string;
				};
			};
			games: {
				Row: {
					id: string;
					title: string;
					description: string | null;
					difficulty: 'kids' | 'beginner' | 'advanced';
					creator_id: string;
					is_public: boolean;
					created_at: string;
					updated_at: string;
					total_plays: number;
					average_rating: number | null;
					rating_count: number;
				};
				Insert: {
					id?: string;
					title: string;
					description?: string | null;
					difficulty: 'kids' | 'beginner' | 'advanced';
					creator_id: string;
					is_public?: boolean;
					created_at?: string;
					updated_at?: string;
					total_plays?: number;
					average_rating?: number | null;
					rating_count?: number;
				};
				Update: {
					id?: string;
					title?: string;
					description?: string | null;
					difficulty?: 'kids' | 'beginner' | 'advanced';
					creator_id?: string;
					is_public?: boolean;
					created_at?: string;
					updated_at?: string;
					total_plays?: number;
					average_rating?: number | null;
					rating_count?: number;
				};
			};
			game_categories: {
				Row: {
					id: string;
					game_id: string;
					category_id: string;
					display_order: number;
				};
				Insert: {
					id?: string;
					game_id: string;
					category_id: string;
					display_order: number;
				};
				Update: {
					id?: string;
					game_id?: string;
					category_id?: string;
					display_order?: number;
				};
			};
			questions: {
				Row: {
					id: string;
					game_id: string;
					game_category_id: string;
					question_text: string;
					answer_text: string;
					points: number;
					display_order: number;
					created_at: string;
				};
				Insert: {
					id?: string;
					game_id: string;
					game_category_id: string;
					question_text: string;
					answer_text: string;
					points: number;
					display_order: number;
					created_at?: string;
				};
				Update: {
					id?: string;
					game_id?: string;
					game_category_id?: string;
					question_text?: string;
					answer_text?: string;
					points?: number;
					display_order?: number;
					created_at?: string;
				};
			};
			ratings: {
				Row: {
					id: string;
					game_id: string;
					user_id: string;
					rating: number;
					review_text: string | null;
					created_at: string;
					updated_at: string;
				};
				Insert: {
					id?: string;
					game_id: string;
					user_id: string;
					rating: number;
					review_text?: string | null;
					created_at?: string;
					updated_at?: string;
				};
				Update: {
					id?: string;
					game_id?: string;
					user_id?: string;
					rating?: number;
					review_text?: string | null;
					created_at?: string;
					updated_at?: string;
				};
			};
			favorites: {
				Row: {
					id: string;
					game_id: string;
					user_id: string;
					created_at: string;
				};
				Insert: {
					id?: string;
					game_id: string;
					user_id: string;
					created_at?: string;
				};
				Update: {
					id?: string;
					game_id?: string;
					user_id?: string;
					created_at?: string;
				};
			};
			game_plays: {
				Row: {
					id: string;
					game_id: string;
					user_id: string | null;
					player_count: number;
					completed_at: string;
				};
				Insert: {
					id?: string;
					game_id: string;
					user_id?: string | null;
					player_count: number;
					completed_at?: string;
				};
				Update: {
					id?: string;
					game_id?: string;
					user_id?: string | null;
					player_count?: number;
					completed_at?: string;
				};
			};
		};
		Views: {};
		Functions: {};
		Enums: {
			category_type: 'prophets' | 'quran' | 'hadith' | 'sunnah' | 'islamic_beliefs' | 'islamic_manners' | 'history' | 'other';
			difficulty_level: 'kids' | 'beginner' | 'advanced';
		};
	};
};
