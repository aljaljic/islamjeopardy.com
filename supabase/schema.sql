-- Islamic Jeopardy Database Schema
-- Run this in your Supabase SQL Editor: https://app.supabase.com/project/YOUR_PROJECT/sql/new

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ============================================================================
-- ENUMS
-- ============================================================================

create type category_type as enum (
  'prophets',
  'quran',
  'hadith',
  'sunnah',
  'islamic_beliefs',
  'islamic_manners',
  'history',
  'seerah',
  'fiqh',
  'arabic_language',
  'other'
);

create type difficulty_level as enum ('kids', 'beginner', 'advanced');

-- ============================================================================
-- TABLES
-- ============================================================================

-- Profiles Table
-- Auto-created on user signup, extends auth.users
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,

  constraint username_length check (char_length(username) >= 3 and char_length(username) <= 20)
);

comment on table profiles is 'User profiles, one per auth.users';

-- Categories Table
-- Predefined Islamic topics for games
create table categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  category_type category_type not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

comment on table categories is 'Predefined Islamic categories (Prophets, Quran, Hadith, etc.)';

-- Games Table
-- User-created Jeopardy games
create table games (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  difficulty difficulty_level not null,
  creator_id uuid references profiles(id) on delete cascade not null,
  is_public boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,

  -- Denormalized for performance
  total_plays integer default 0,
  average_rating numeric(3, 2),
  rating_count integer default 0,

  constraint title_length check (char_length(title) >= 3 and char_length(title) <= 100)
);

comment on table games is 'User-created Jeopardy games';

-- Indexes for performance
create index games_creator_id_idx on games(creator_id);
create index games_difficulty_idx on games(difficulty);
create index games_created_at_idx on games(created_at desc);
create index games_average_rating_idx on games(average_rating desc nulls last);
create index games_total_plays_idx on games(total_plays desc);

-- Game Categories Table
-- Links games to 5 categories with display order
create table game_categories (
  id uuid default gen_random_uuid() primary key,
  game_id uuid references games(id) on delete cascade not null,
  category_id uuid references categories(id) on delete cascade not null,
  display_order integer not null,

  unique(game_id, category_id),
  unique(game_id, display_order),
  constraint display_order_range check (display_order >= 0 and display_order < 5)
);

comment on table game_categories is 'Each game has exactly 5 categories in order';

create index game_categories_game_id_idx on game_categories(game_id);

-- Questions Table
-- 25 questions per game (5 categories × 5 point values)
create table questions (
  id uuid default gen_random_uuid() primary key,
  game_id uuid references games(id) on delete cascade not null,
  game_category_id uuid references game_categories(id) on delete cascade not null,
  question_text text not null,
  answer_text text not null,
  explanation text,
  points integer not null,
  display_order integer not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,

  constraint points_valid check (points in (100, 200, 300, 400, 500)),
  constraint display_order_range check (display_order >= 0 and display_order < 5),
  unique(game_category_id, display_order)
);

comment on table questions is 'Each game has 25 questions (5 per category, point values 100-500)';

create index questions_game_id_idx on questions(game_id);
create index questions_game_category_id_idx on questions(game_category_id);

-- Ratings Table
-- User ratings for games (1-5 stars with optional review)
create table ratings (
  id uuid default gen_random_uuid() primary key,
  game_id uuid references games(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  rating integer not null,
  review_text text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,

  unique(game_id, user_id),
  constraint rating_valid check (rating >= 1 and rating <= 5)
);

comment on table ratings is 'User ratings (1-5 stars) with optional review text';

create index ratings_game_id_idx on ratings(game_id);
create index ratings_user_id_idx on ratings(user_id);

-- Favorites Table
-- User favorites for quick access
create table favorites (
  id uuid default gen_random_uuid() primary key,
  game_id uuid references games(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,

  unique(game_id, user_id)
);

comment on table favorites is 'User favorited games';

create index favorites_game_id_idx on favorites(game_id);
create index favorites_user_id_idx on favorites(user_id);

-- Game Plays Table
-- Track when games are played (increments game.total_plays)
create table game_plays (
  id uuid default gen_random_uuid() primary key,
  game_id uuid references games(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete set null,
  player_count integer not null,
  completed_at timestamp with time zone default timezone('utc'::text, now()) not null,

  constraint player_count_valid check (player_count >= 1 and player_count <= 8)
);

comment on table game_plays is 'Tracks completed game sessions';

create index game_plays_game_id_idx on game_plays(game_id);
create index game_plays_user_id_idx on game_plays(user_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
alter table profiles enable row level security;
alter table categories enable row level security;
alter table games enable row level security;
alter table game_categories enable row level security;
alter table questions enable row level security;
alter table ratings enable row level security;
alter table favorites enable row level security;
alter table game_plays enable row level security;

-- Profiles Policies
create policy "Public profiles are viewable by everyone"
  on profiles for select
  using (true);

create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

-- Categories Policies
create policy "Categories are viewable by everyone"
  on categories for select
  using (true);

-- Games Policies
create policy "Public games are viewable by everyone"
  on games for select
  using (is_public = true or auth.uid() = creator_id);

create policy "Authenticated users can insert games"
  on games for insert
  with check (auth.uid() = creator_id);

create policy "Creators can update own games"
  on games for update
  using (auth.uid() = creator_id);

create policy "Creators can delete own games"
  on games for delete
  using (auth.uid() = creator_id);

-- Game Categories Policies
create policy "Game categories follow game visibility"
  on game_categories for select
  using (
    exists (
      select 1 from games
      where games.id = game_categories.game_id
      and (games.is_public = true or games.creator_id = auth.uid())
    )
  );

create policy "Authenticated users can insert game categories"
  on game_categories for insert
  with check (
    exists (
      select 1 from games
      where games.id = game_categories.game_id
      and games.creator_id = auth.uid()
    )
  );

create policy "Creators can update own game categories"
  on game_categories for update
  using (
    exists (
      select 1 from games
      where games.id = game_categories.game_id
      and games.creator_id = auth.uid()
    )
  );

create policy "Creators can delete own game categories"
  on game_categories for delete
  using (
    exists (
      select 1 from games
      where games.id = game_categories.game_id
      and games.creator_id = auth.uid()
    )
  );

-- Questions Policies
create policy "Questions follow game visibility"
  on questions for select
  using (
    exists (
      select 1 from games
      where games.id = questions.game_id
      and (games.is_public = true or games.creator_id = auth.uid())
    )
  );

create policy "Authenticated users can insert questions"
  on questions for insert
  with check (
    exists (
      select 1 from games
      where games.id = questions.game_id
      and games.creator_id = auth.uid()
    )
  );

create policy "Creators can update own questions"
  on questions for update
  using (
    exists (
      select 1 from games
      where games.id = questions.game_id
      and games.creator_id = auth.uid()
    )
  );

create policy "Creators can delete own questions"
  on questions for delete
  using (
    exists (
      select 1 from games
      where games.id = questions.game_id
      and games.creator_id = auth.uid()
    )
  );

-- Ratings Policies
create policy "Ratings are viewable by everyone"
  on ratings for select
  using (true);

create policy "Authenticated users can insert ratings"
  on ratings for insert
  with check (auth.uid() = user_id);

create policy "Users can update own ratings"
  on ratings for update
  using (auth.uid() = user_id);

create policy "Users can delete own ratings"
  on ratings for delete
  using (auth.uid() = user_id);

-- Favorites Policies
create policy "Users can view own favorites"
  on favorites for select
  using (auth.uid() = user_id);

create policy "Users can insert own favorites"
  on favorites for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own favorites"
  on favorites for delete
  using (auth.uid() = user_id);

-- Game Plays Policies
create policy "Users can view own game plays"
  on game_plays for select
  using (auth.uid() = user_id or user_id is null);

create policy "Authenticated users can insert game plays"
  on game_plays for insert
  with check (auth.uid() = user_id or user_id is null);

-- ============================================================================
-- TRIGGERS & FUNCTIONS
-- ============================================================================

-- Function: Update game ratings when ratings change
create or replace function update_game_rating()
returns trigger as $$
begin
  update games
  set
    average_rating = (
      select avg(rating)::numeric(3,2)
      from ratings
      where game_id = coalesce(new.game_id, old.game_id)
    ),
    rating_count = (
      select count(*)
      from ratings
      where game_id = coalesce(new.game_id, old.game_id)
    )
  where id = coalesce(new.game_id, old.game_id);

  return coalesce(new, old);
end;
$$ language plpgsql security definer;

-- Trigger: Update ratings on insert/update/delete
create trigger on_rating_change
  after insert or update or delete on ratings
  for each row execute function update_game_rating();

-- Function: Increment game plays
create or replace function increment_game_plays()
returns trigger as $$
begin
  update games
  set total_plays = total_plays + 1
  where id = new.game_id;

  return new;
end;
$$ language plpgsql security definer;

-- Trigger: Increment plays on new game_play
create trigger on_game_play
  after insert on game_plays
  for each row execute function increment_game_plays();

-- Function: Create profile on user signup
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8)),
    coalesce(new.raw_user_meta_data->>'display_name', 'User')
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger: Create profile on auth.users insert
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert predefined Islamic categories
insert into categories (name, category_type, description) values
  ('Prophets', 'prophets', 'Questions about the Prophets in Islam'),
  ('Quran', 'quran', 'Questions about the Holy Quran'),
  ('Hadith', 'hadith', 'Questions about Hadith and sayings of Prophet Muhammad (PBUH)'),
  ('Sunnah', 'sunnah', 'Questions about the Sunnah of the Prophet'),
  ('Islamic Beliefs', 'islamic_beliefs', 'Questions about core Islamic beliefs and theology'),
  ('Manners', 'islamic_manners', 'Questions about Islamic etiquette and manners'),
  ('Islamic History', 'history', 'Questions about Islamic history'),
  ('Seerah', 'seerah', 'Questions about the life of Prophet Muhammad (PBUH)'),
  ('Fiqh', 'fiqh', 'Questions about Islamic jurisprudence and rulings'),
  ('Arabic Language', 'arabic_language', 'Questions about Arabic language and vocabulary'),
  ('General Knowledge', 'other', 'General Islamic knowledge');

-- ============================================================================
-- DONE!
-- ============================================================================
-- Your database schema is now set up!
-- Next steps:
-- 1. Fill in your .env file with Supabase credentials
-- 2. Generate TypeScript types: npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/lib/types/database.types.ts
