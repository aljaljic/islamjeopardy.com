-- Function: Delete user account (self-service)
-- This function deletes the user's profile, which cascades to all related data
-- via foreign key constraints (games, ratings, favorites, game_plays, etc.)
-- Note: The auth.users entry will remain but won't have any associated data

create or replace function delete_user_account()
returns void as $$
declare
  user_id uuid;
begin
  -- Get the current user's ID
  user_id := auth.uid();
  
  if user_id is null then
    raise exception 'You must be logged in to delete your account';
  end if;
  
  -- Delete profile (cascades to games, ratings, favorites, etc.)
  -- Due to foreign key constraints with ON DELETE CASCADE:
  -- - Deleting profile will delete all games created by the user
  -- - Deleting games will delete all game_categories and questions
  -- - Deleting profile will delete all ratings, favorites, and game_plays
  delete from public.profiles where id = user_id;
  
  -- Note: The auth.users entry will remain in auth.users table
  -- but won't have any associated data, making it effectively disabled
  -- To fully delete the auth user, use Supabase Admin API with service role key
end;
$$ language plpgsql security definer;

-- Grant execute permission to authenticated users
grant execute on function delete_user_account() to authenticated;
