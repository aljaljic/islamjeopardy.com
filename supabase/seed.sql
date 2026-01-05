-- Islamic Jeopardy Sample Games Seed Data
-- Run this AFTER schema.sql to add sample games for users to play immediately

-- ============================================================================
-- SAMPLE GAMES (No login required to play these)
-- ============================================================================

-- System user for sample games (already created in auth.users)
-- Create/update the profile for the system user
INSERT INTO profiles (id, username, display_name)
VALUES ('87b6bf37-46a4-4d21-8d45-5d3c6501ef48', 'islamjeopardy', 'Islamic Jeopardy Team')
ON CONFLICT (id) DO UPDATE
SET username = EXCLUDED.username,
    display_name = EXCLUDED.display_name;

-- ============================================================================
-- GAME 1: Islamic Basics (Kids - Ages 5-10)
-- ============================================================================

INSERT INTO games (id, title, description, difficulty, creator_id, is_public, total_plays, average_rating, rating_count)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'Islamic Basics for Kids',
  'A fun introduction to Islam for young learners. Perfect for family game nights!',
  'kids',
  '87b6bf37-46a4-4d21-8d45-5d3c6501ef48',
  true,
  0,
  NULL,
  0
) ON CONFLICT (id) DO NOTHING;

-- Game 1 Categories (using existing category IDs from schema seed)
INSERT INTO game_categories (id, game_id, category_id, display_order)
SELECT
  gen_random_uuid(),
  '11111111-1111-1111-1111-111111111111',
  id,
  row_num - 1
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name) as row_num
  FROM categories
  WHERE name IN ('Prophets', 'Quran', 'Islamic Beliefs', 'Islamic Etiquette', 'General Knowledge')
) sub
WHERE row_num <= 5
ON CONFLICT DO NOTHING;

-- Game 1 Questions
-- We need to get the game_category IDs first, so we'll use a DO block
DO $$
DECLARE
  gc_prophets UUID;
  gc_quran UUID;
  gc_beliefs UUID;
  gc_etiquette UUID;
  gc_general UUID;
BEGIN
  -- Get game_category IDs for Game 1
  SELECT gc.id INTO gc_prophets FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '11111111-1111-1111-1111-111111111111' AND c.name = 'Prophets';
  SELECT gc.id INTO gc_quran FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '11111111-1111-1111-1111-111111111111' AND c.name = 'Quran';
  SELECT gc.id INTO gc_beliefs FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '11111111-1111-1111-1111-111111111111' AND c.name = 'Islamic Beliefs';
  SELECT gc.id INTO gc_etiquette FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '11111111-1111-1111-1111-111111111111' AND c.name = 'Islamic Etiquette';
  SELECT gc.id INTO gc_general FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '11111111-1111-1111-1111-111111111111' AND c.name = 'General Knowledge';

  -- Validate all category IDs were found
  IF gc_prophets IS NULL OR gc_quran IS NULL OR gc_beliefs IS NULL OR gc_etiquette IS NULL OR gc_general IS NULL THEN
    RAISE EXCEPTION 'Failed to find game categories for Game 1. Make sure game_categories were created successfully.';
  END IF;

  -- Prophets Questions (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('11111111-1111-1111-1111-111111111111', gc_prophets, 'Who was the first prophet?', 'Adam (peace be upon him)', 100, 0),
  ('11111111-1111-1111-1111-111111111111', gc_prophets, 'Who built the Ark?', 'Nuh (Noah) peace be upon him', 200, 1),
  ('11111111-1111-1111-1111-111111111111', gc_prophets, 'Who was thrown into the fire but did not burn?', 'Ibrahim (Abraham) peace be upon him', 300, 2),
  ('11111111-1111-1111-1111-111111111111', gc_prophets, 'Who was swallowed by a whale?', 'Yunus (Jonah) peace be upon him', 400, 3),
  ('11111111-1111-1111-1111-111111111111', gc_prophets, 'Who is the final prophet in Islam?', 'Muhammad (peace be upon him)', 500, 4);

  -- Quran Questions (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('11111111-1111-1111-1111-111111111111', gc_quran, 'What is the holy book of Islam?', 'The Quran', 100, 0),
  ('11111111-1111-1111-1111-111111111111', gc_quran, 'What is the first surah of the Quran?', 'Surah Al-Fatiha', 200, 1),
  ('11111111-1111-1111-1111-111111111111', gc_quran, 'What language was the Quran revealed in?', 'Arabic', 300, 2),
  ('11111111-1111-1111-1111-111111111111', gc_quran, 'What is the shortest surah in the Quran?', 'Surah Al-Kawthar (108)', 400, 3),
  ('11111111-1111-1111-1111-111111111111', gc_quran, 'In which month was the Quran first revealed?', 'Ramadan', 500, 4);

  -- Islamic Beliefs Questions (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('11111111-1111-1111-1111-111111111111', gc_beliefs, 'How many pillars of Islam are there?', 'Five', 100, 0),
  ('11111111-1111-1111-1111-111111111111', gc_beliefs, 'What do Muslims say to declare their faith?', 'Shahada (La ilaha illallah...)', 200, 1),
  ('11111111-1111-1111-1111-111111111111', gc_beliefs, 'How many times a day do Muslims pray?', 'Five times', 300, 2),
  ('11111111-1111-1111-1111-111111111111', gc_beliefs, 'What is the name of the fasting month?', 'Ramadan', 400, 3),
  ('11111111-1111-1111-1111-111111111111', gc_beliefs, 'What is the pilgrimage to Mecca called?', 'Hajj', 500, 4);

  -- Islamic Etiquette Questions (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('11111111-1111-1111-1111-111111111111', gc_etiquette, 'What do Muslims say before eating?', 'Bismillah (In the name of Allah)', 100, 0),
  ('11111111-1111-1111-1111-111111111111', gc_etiquette, 'What do Muslims say after sneezing?', 'Alhamdulillah (Praise be to Allah)', 200, 1),
  ('11111111-1111-1111-1111-111111111111', gc_etiquette, 'Which hand should we eat with?', 'Right hand', 300, 2),
  ('11111111-1111-1111-1111-111111111111', gc_etiquette, 'What do we say when greeting another Muslim?', 'Assalamu Alaikum (Peace be upon you)', 400, 3),
  ('11111111-1111-1111-1111-111111111111', gc_etiquette, 'What should we say when we hear good news?', 'MashaAllah (Allah has willed it)', 500, 4);

  -- General Knowledge Questions (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('11111111-1111-1111-1111-111111111111', gc_general, 'What is the holiest city in Islam?', 'Mecca', 100, 0),
  ('11111111-1111-1111-1111-111111111111', gc_general, 'What is the name of the Islamic place of worship?', 'Mosque (Masjid)', 200, 1),
  ('11111111-1111-1111-1111-111111111111', gc_general, 'What color is often associated with Islam?', 'Green', 300, 2),
  ('11111111-1111-1111-1111-111111111111', gc_general, 'What is the crescent moon and star a symbol of?', 'Islam', 400, 3),
  ('11111111-1111-1111-1111-111111111111', gc_general, 'What is Friday prayer called?', 'Jummah', 500, 4);
END $$;

-- ============================================================================
-- GAME 2: Stories of the Prophets (Beginner)
-- ============================================================================

INSERT INTO games (id, title, description, difficulty, creator_id, is_public, total_plays, average_rating, rating_count)
VALUES (
  '22222222-2222-2222-2222-222222222222',
  'Stories of the Prophets',
  'Test your knowledge of the prophets mentioned in the Quran. Great for teenagers and adults!',
  'beginner',
  '87b6bf37-46a4-4d21-8d45-5d3c6501ef48',
  true,
  0,
  NULL,
  0
) ON CONFLICT (id) DO NOTHING;

-- Game 2 Categories
INSERT INTO game_categories (id, game_id, category_id, display_order)
SELECT
  gen_random_uuid(),
  '22222222-2222-2222-2222-222222222222',
  id,
  row_num - 1
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name) as row_num
  FROM categories
  WHERE name IN ('Prophets', 'Quran', 'Islamic History', 'Islamic Beliefs', 'General Knowledge')
) sub
WHERE row_num <= 5
ON CONFLICT DO NOTHING;

-- Game 2 Questions
DO $$
DECLARE
  gc_prophets UUID;
  gc_quran UUID;
  gc_history UUID;
  gc_beliefs UUID;
  gc_general UUID;
BEGIN
  SELECT gc.id INTO gc_prophets FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '22222222-2222-2222-2222-222222222222' AND c.name = 'Prophets';
  SELECT gc.id INTO gc_quran FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '22222222-2222-2222-2222-222222222222' AND c.name = 'Quran';
  SELECT gc.id INTO gc_history FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '22222222-2222-2222-2222-222222222222' AND c.name = 'Islamic History';
  SELECT gc.id INTO gc_beliefs FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '22222222-2222-2222-2222-222222222222' AND c.name = 'Islamic Beliefs';
  SELECT gc.id INTO gc_general FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '22222222-2222-2222-2222-222222222222' AND c.name = 'General Knowledge';

  -- Validate all category IDs were found
  IF gc_prophets IS NULL OR gc_quran IS NULL OR gc_history IS NULL OR gc_beliefs IS NULL OR gc_general IS NULL THEN
    RAISE EXCEPTION 'Failed to find game categories for Game 2. Make sure game_categories were created successfully.';
  END IF;

  -- Prophets Questions (Beginner)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('22222222-2222-2222-2222-222222222222', gc_prophets, 'Which prophet could talk to animals?', 'Sulaiman (Solomon) peace be upon him', 100, 0),
  ('22222222-2222-2222-2222-222222222222', gc_prophets, 'Who was known for his patience during extreme hardship?', 'Ayyub (Job) peace be upon him', 200, 1),
  ('22222222-2222-2222-2222-222222222222', gc_prophets, 'Which prophet was given the Zabur (Psalms)?', 'Dawud (David) peace be upon him', 300, 2),
  ('22222222-2222-2222-2222-222222222222', gc_prophets, 'Who interpreted the king''s dream about seven fat and seven lean cows?', 'Yusuf (Joseph) peace be upon him', 400, 3),
  ('22222222-2222-2222-2222-222222222222', gc_prophets, 'Which prophet was raised to heaven alive?', 'Isa (Jesus) peace be upon him', 500, 4);

  -- Quran Questions (Beginner)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('22222222-2222-2222-2222-222222222222', gc_quran, 'How many surahs are in the Quran?', '114 surahs', 100, 0),
  ('22222222-2222-2222-2222-222222222222', gc_quran, 'Which surah is called the "Heart of the Quran"?', 'Surah Ya-Sin (36)', 200, 1),
  ('22222222-2222-2222-2222-222222222222', gc_quran, 'What is the longest surah in the Quran?', 'Surah Al-Baqarah (2)', 300, 2),
  ('22222222-2222-2222-2222-222222222222', gc_quran, 'Which surah mentions the story of Yusuf in detail?', 'Surah Yusuf (12)', 400, 3),
  ('22222222-2222-2222-2222-222222222222', gc_quran, 'What does "Quran" literally mean?', 'The Recitation', 500, 4);

  -- History Questions (Beginner)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('22222222-2222-2222-2222-222222222222', gc_history, 'In which city was Prophet Muhammad (pbuh) born?', 'Mecca', 100, 0),
  ('22222222-2222-2222-2222-222222222222', gc_history, 'What year did the Hijra (migration to Medina) occur?', '622 CE', 200, 1),
  ('22222222-2222-2222-2222-222222222222', gc_history, 'Who was the first woman to accept Islam?', 'Khadijah (RA)', 300, 2),
  ('22222222-2222-2222-2222-222222222222', gc_history, 'What was the first battle in Islamic history?', 'Battle of Badr', 400, 3),
  ('22222222-2222-2222-2222-222222222222', gc_history, 'Who was the first Caliph after Prophet Muhammad (pbuh)?', 'Abu Bakr (RA)', 500, 4);

  -- Islamic Beliefs Questions (Beginner)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('22222222-2222-2222-2222-222222222222', gc_beliefs, 'How many articles of faith (Iman) are there?', 'Six', 100, 0),
  ('22222222-2222-2222-2222-222222222222', gc_beliefs, 'What is the name of the angel who brought revelation?', 'Jibreel (Gabriel)', 200, 1),
  ('22222222-2222-2222-2222-222222222222', gc_beliefs, 'What are the two main Islamic celebrations called?', 'Eid al-Fitr and Eid al-Adha', 300, 2),
  ('22222222-2222-2222-2222-222222222222', gc_beliefs, 'What is Zakat?', 'Obligatory charity (2.5% of wealth)', 400, 3),
  ('22222222-2222-2222-2222-222222222222', gc_beliefs, 'What is the Night of Power (Laylat al-Qadr)?', 'The night the Quran was first revealed', 500, 4);

  -- General Knowledge Questions (Beginner)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('22222222-2222-2222-2222-222222222222', gc_general, 'What direction do Muslims face when praying?', 'Qibla (toward the Kaaba in Mecca)', 100, 0),
  ('22222222-2222-2222-2222-222222222222', gc_general, 'What is the black stone at the Kaaba called?', 'Hajar al-Aswad', 200, 1),
  ('22222222-2222-2222-2222-222222222222', gc_general, 'What is the name of the well near the Kaaba?', 'Zamzam', 300, 2),
  ('22222222-2222-2222-2222-222222222222', gc_general, 'What are the two holy cities besides Mecca?', 'Medina and Jerusalem', 400, 3),
  ('22222222-2222-2222-2222-222222222222', gc_general, 'What is Ihram?', 'Sacred state/clothing worn during Hajj or Umrah', 500, 4);
END $$;

-- ============================================================================
-- GAME 3: Advanced Islamic Knowledge
-- ============================================================================

INSERT INTO games (id, title, description, difficulty, creator_id, is_public, total_plays, average_rating, rating_count)
VALUES (
  '33333333-3333-3333-3333-333333333333',
  'Advanced Islamic Knowledge',
  'Challenge yourself with deeper questions about Islamic theology, history, and jurisprudence.',
  'advanced',
  '87b6bf37-46a4-4d21-8d45-5d3c6501ef48',
  true,
  0,
  NULL,
  0
) ON CONFLICT (id) DO NOTHING;

-- Game 3 Categories
INSERT INTO game_categories (id, game_id, category_id, display_order)
SELECT
  gen_random_uuid(),
  '33333333-3333-3333-3333-333333333333',
  id,
  row_num - 1
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name) as row_num
  FROM categories
  WHERE name IN ('Quran', 'Hadith', 'Islamic History', 'Islamic Beliefs', 'Sunnah')
) sub
WHERE row_num <= 5
ON CONFLICT DO NOTHING;

-- Game 3 Questions
DO $$
DECLARE
  gc_quran UUID;
  gc_hadith UUID;
  gc_history UUID;
  gc_beliefs UUID;
  gc_sunnah UUID;
BEGIN
  SELECT gc.id INTO gc_quran FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '33333333-3333-3333-3333-333333333333' AND c.name = 'Quran';
  SELECT gc.id INTO gc_hadith FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '33333333-3333-3333-3333-333333333333' AND c.name = 'Hadith';
  SELECT gc.id INTO gc_history FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '33333333-3333-3333-3333-333333333333' AND c.name = 'Islamic History';
  SELECT gc.id INTO gc_beliefs FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '33333333-3333-3333-3333-333333333333' AND c.name = 'Islamic Beliefs';
  SELECT gc.id INTO gc_sunnah FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '33333333-3333-3333-3333-333333333333' AND c.name = 'Sunnah';

  -- Validate all category IDs were found
  IF gc_quran IS NULL OR gc_hadith IS NULL OR gc_history IS NULL OR gc_beliefs IS NULL OR gc_sunnah IS NULL THEN
    RAISE EXCEPTION 'Failed to find game categories for Game 3. Make sure game_categories were created successfully.';
  END IF;

  -- Quran Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('33333333-3333-3333-3333-333333333333', gc_quran, 'How many years did it take for the Quran to be fully revealed?', '23 years', 100, 0),
  ('33333333-3333-3333-3333-333333333333', gc_quran, 'What is the science of Quran recitation called?', 'Tajweed', 200, 1),
  ('33333333-3333-3333-3333-333333333333', gc_quran, 'Which companion compiled the Quran into one book?', 'Uthman ibn Affan (RA)', 300, 2),
  ('33333333-3333-3333-3333-333333333333', gc_quran, 'What are the circumstances of revelation called?', 'Asbab al-Nuzul', 400, 3),
  ('33333333-3333-3333-3333-333333333333', gc_quran, 'What is the study of Quranic interpretation called?', 'Tafsir', 500, 4);

  -- Hadith Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('33333333-3333-3333-3333-333333333333', gc_hadith, 'What are the six authentic hadith collections called?', 'Kutub al-Sittah (The Six Books)', 100, 0),
  ('33333333-3333-3333-3333-333333333333', gc_hadith, 'Who compiled Sahih Bukhari?', 'Imam Muhammad al-Bukhari', 200, 1),
  ('33333333-3333-3333-3333-333333333333', gc_hadith, 'What is the chain of narrators in a hadith called?', 'Isnad (or Sanad)', 300, 2),
  ('33333333-3333-3333-3333-333333333333', gc_hadith, 'What is a hadith with a weak chain of narration called?', 'Da''if (weak)', 400, 3),
  ('33333333-3333-3333-3333-333333333333', gc_hadith, 'What is the text/content of a hadith called?', 'Matn', 500, 4);

  -- History Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('33333333-3333-3333-3333-333333333333', gc_history, 'What treaty was signed in 628 CE between Muslims and Quraysh?', 'Treaty of Hudaybiyyah', 100, 0),
  ('33333333-3333-3333-3333-333333333333', gc_history, 'Which dynasty built the Dome of the Rock?', 'Umayyad Dynasty', 200, 1),
  ('33333333-3333-3333-3333-333333333333', gc_history, 'What was the House of Wisdom (Bayt al-Hikma)?', 'A major intellectual center in Baghdad', 300, 2),
  ('33333333-3333-3333-3333-333333333333', gc_history, 'Who was the Muslim general who conquered Spain?', 'Tariq ibn Ziyad', 400, 3),
  ('33333333-3333-3333-3333-333333333333', gc_history, 'What year was the conquest of Mecca?', '630 CE (8 AH)', 500, 4);

  -- Islamic Beliefs Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('33333333-3333-3333-3333-333333333333', gc_beliefs, 'What are the 99 names of Allah called?', 'Asma ul-Husna', 100, 0),
  ('33333333-3333-3333-3333-333333333333', gc_beliefs, 'What is the Islamic concept of divine decree?', 'Qadr (or Qadar)', 200, 1),
  ('33333333-3333-3333-3333-333333333333', gc_beliefs, 'What is Tawakkul?', 'Trust and reliance on Allah', 300, 2),
  ('33333333-3333-3333-3333-333333333333', gc_beliefs, 'What are the recording angels called?', 'Kiraman Katibin', 400, 3),
  ('33333333-3333-3333-3333-333333333333', gc_beliefs, 'What is the barrier between this life and the hereafter?', 'Barzakh', 500, 4);

  -- Sunnah Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, points, display_order) VALUES
  ('33333333-3333-3333-3333-333333333333', gc_sunnah, 'What is the voluntary night prayer called?', 'Tahajjud (or Qiyam al-Layl)', 100, 0),
  ('33333333-3333-3333-3333-333333333333', gc_sunnah, 'What dua is recommended when looking in a mirror?', 'Allahumma anta hassanta khalqi fa hassin khuluqi', 200, 1),
  ('33333333-3333-3333-3333-333333333333', gc_sunnah, 'What is the Sunnah number of rakats before Fajr?', 'Two rakats', 300, 2),
  ('33333333-3333-3333-3333-333333333333', gc_sunnah, 'What prayer is performed during a solar eclipse?', 'Salat al-Kusuf', 400, 3),
  ('33333333-3333-3333-3333-333333333333', gc_sunnah, 'What is I''tikaf?', 'Spiritual retreat in the mosque, especially in last 10 days of Ramadan', 500, 4);
END $$;

-- ============================================================================
-- Success message
-- ============================================================================
DO $$ BEGIN RAISE NOTICE 'Sample games created successfully! You now have 3 games ready to play.'; END $$;
