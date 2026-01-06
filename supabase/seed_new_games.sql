-- New Sample Games: Seerah, Arabic for Kids, Fiqh Advanced
-- Run this AFTER running the category migrations (01 and 02)

-- ============================================================================
-- GAME 4: Life of the Prophet (Seerah) - Beginner
-- ============================================================================

INSERT INTO games (id, title, description, difficulty, creator_id, is_public, total_plays, average_rating, rating_count)
VALUES (
  '44444444-4444-4444-4444-444444444444',
  'Life of the Prophet (Seerah)',
  'Learn about the blessed life of Prophet Muhammad (peace be upon him) from birth to legacy.',
  'beginner',
  '87b6bf37-46a4-4d21-8d45-5d3c6501ef48',
  true,
  0,
  NULL,
  0
) ON CONFLICT (id) DO NOTHING;

-- Game 4 Categories
INSERT INTO game_categories (id, game_id, category_id, display_order)
SELECT
  gen_random_uuid(),
  '44444444-4444-4444-4444-444444444444',
  id,
  row_num - 1
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name) as row_num
  FROM categories
  WHERE name IN ('Seerah', 'Prophets', 'Islamic History', 'Hadith', 'General Knowledge')
) sub
WHERE row_num <= 5
ON CONFLICT DO NOTHING;

-- Game 4 Questions
DO $$
DECLARE
  gc_seerah UUID;
  gc_prophets UUID;
  gc_history UUID;
  gc_hadith UUID;
  gc_general UUID;
BEGIN
  SELECT gc.id INTO gc_seerah FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '44444444-4444-4444-4444-444444444444' AND c.name = 'Seerah';
  SELECT gc.id INTO gc_prophets FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '44444444-4444-4444-4444-444444444444' AND c.name = 'Prophets';
  SELECT gc.id INTO gc_history FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '44444444-4444-4444-4444-444444444444' AND c.name = 'Islamic History';
  SELECT gc.id INTO gc_hadith FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '44444444-4444-4444-4444-444444444444' AND c.name = 'Hadith';
  SELECT gc.id INTO gc_general FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '44444444-4444-4444-4444-444444444444' AND c.name = 'General Knowledge';

  IF gc_seerah IS NULL OR gc_prophets IS NULL OR gc_history IS NULL OR gc_hadith IS NULL OR gc_general IS NULL THEN
    RAISE EXCEPTION 'Failed to find game categories for Game 4 (Seerah). Make sure categories exist.';
  END IF;

  -- Seerah Questions (Beginner)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('44444444-4444-4444-4444-444444444444', gc_seerah, 'In what year was Prophet Muhammad (pbuh) born?', '570 CE (Year of the Elephant)', 'This year is called the Year of the Elephant because Abraha tried to destroy the Kaaba with elephants.', 100, 0),
  ('44444444-4444-4444-4444-444444444444', gc_seerah, 'What was the name of the Prophet''s mother?', 'Aminah bint Wahb', 'She passed away when the Prophet was only 6 years old.', 200, 1),
  ('44444444-4444-4444-4444-444444444444', gc_seerah, 'Who was the Prophet''s foster mother who nursed him?', 'Halimah al-Sa''diyah', 'It was common for Meccan families to send children to the desert for a healthier upbringing.', 300, 2),
  ('44444444-4444-4444-4444-444444444444', gc_seerah, 'At what age did the Prophet receive his first revelation?', '40 years old', 'The first revelation came in the Cave of Hira during Ramadan.', 400, 3),
  ('44444444-4444-4444-4444-444444444444', gc_seerah, 'What was the Prophet''s profession before prophethood?', 'Merchant/Trader', 'He was known as Al-Amin (The Trustworthy) and As-Sadiq (The Truthful).', 500, 4);

  -- Prophets Questions (about companions and family)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('44444444-4444-4444-4444-444444444444', gc_prophets, 'Who was the Prophet''s first wife?', 'Khadijah bint Khuwaylid (RA)', 'She was 15 years older than him and was the first to accept Islam.', 100, 0),
  ('44444444-4444-4444-4444-444444444444', gc_prophets, 'How many children did the Prophet have with Khadijah?', 'Six children', 'Four daughters (Zainab, Ruqayyah, Umm Kulthum, Fatimah) and two sons (Qasim, Abdullah).', 200, 1),
  ('44444444-4444-4444-4444-444444444444', gc_prophets, 'Who was the Prophet''s uncle who protected him?', 'Abu Talib', 'He never accepted Islam but protected the Prophet until his death.', 300, 2),
  ('44444444-4444-4444-4444-444444444444', gc_prophets, 'Who was the first man to accept Islam?', 'Abu Bakr al-Siddiq (RA)', 'He immediately believed without any hesitation.', 400, 3),
  ('44444444-4444-4444-4444-444444444444', gc_prophets, 'Who was the first child to accept Islam?', 'Ali ibn Abi Talib (RA)', 'He was about 10 years old when he accepted Islam.', 500, 4);

  -- History Questions (Seerah events)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('44444444-4444-4444-4444-444444444444', gc_history, 'What is the name of the cave where the Prophet received first revelation?', 'Cave of Hira', 'Located on Jabal al-Noor (Mountain of Light) near Mecca.', 100, 0),
  ('44444444-4444-4444-4444-444444444444', gc_history, 'What was the night journey to Jerusalem called?', 'Isra', 'The Prophet traveled from Mecca to Jerusalem in one night.', 200, 1),
  ('44444444-4444-4444-4444-444444444444', gc_history, 'What was the ascension to the heavens called?', 'Mi''raj', 'During this journey, the five daily prayers were prescribed.', 300, 2),
  ('44444444-4444-4444-4444-444444444444', gc_history, 'Where did Muslims migrate to escape persecution before Medina?', 'Abyssinia (Ethiopia)', 'The Christian king Negus (Najashi) gave them protection.', 400, 3),
  ('44444444-4444-4444-4444-444444444444', gc_history, 'What is the Islamic calendar based on?', 'The Hijra (migration to Medina)', 'Year 1 AH (After Hijra) corresponds to 622 CE.', 500, 4);

  -- Hadith Questions (Prophet's sayings and character)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('44444444-4444-4444-4444-444444444444', gc_hadith, 'What was the Prophet''s nickname meaning "The Trustworthy"?', 'Al-Amin', 'Even before prophethood, he was known for his honesty.', 100, 0),
  ('44444444-4444-4444-4444-444444444444', gc_hadith, 'Complete: "The best of you are those who..."?', '...are best to their families', 'The Prophet emphasized good treatment of family.', 200, 1),
  ('44444444-4444-4444-4444-444444444444', gc_hadith, 'What did the Prophet say about smiling?', 'Smiling at your brother is charity', 'Even small acts of kindness are rewarded.', 300, 2),
  ('44444444-4444-4444-4444-444444444444', gc_hadith, 'What did the Prophet call the strong person?', 'One who controls themselves when angry', 'Physical strength is not true strength in Islam.', 400, 3),
  ('44444444-4444-4444-4444-444444444444', gc_hadith, 'What were the Prophet''s last words?', 'With the highest companion (Allah)', 'He was given the choice to live or meet Allah, and chose Allah.', 500, 4);

  -- General Knowledge (Seerah facts)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('44444444-4444-4444-4444-444444444444', gc_general, 'In which city is the Prophet''s mosque and tomb?', 'Medina', 'Masjid al-Nabawi is the second holiest site in Islam.', 100, 0),
  ('44444444-4444-4444-4444-444444444444', gc_general, 'How old was the Prophet when he passed away?', '63 years old', 'He passed away in 632 CE (11 AH).', 200, 1),
  ('44444444-4444-4444-4444-444444444444', gc_general, 'What color turban did the Prophet often wear?', 'Black or White', 'He also wore green on occasions.', 300, 2),
  ('44444444-4444-4444-4444-444444444444', gc_general, 'What was the Prophet''s favorite food?', 'Dates and milk, also loved tharid (bread soaked in broth)', 'He lived simply despite being a leader.', 400, 3),
  ('44444444-4444-4444-4444-444444444444', gc_general, 'How many years did the Prophet live in Medina?', '10 years', 'From the Hijra in 622 CE until his death in 632 CE.', 500, 4);
END $$;

-- ============================================================================
-- GAME 5: Arabic for Kids
-- ============================================================================

INSERT INTO games (id, title, description, difficulty, creator_id, is_public, total_plays, average_rating, rating_count)
VALUES (
  '55555555-5555-5555-5555-555555555555',
  'Arabic for Kids',
  'Fun Arabic vocabulary and phrases for young learners! Learn the language of the Quran.',
  'kids',
  '87b6bf37-46a4-4d21-8d45-5d3c6501ef48',
  true,
  0,
  NULL,
  0
) ON CONFLICT (id) DO NOTHING;

-- Game 5 Categories
INSERT INTO game_categories (id, game_id, category_id, display_order)
SELECT
  gen_random_uuid(),
  '55555555-5555-5555-5555-555555555555',
  id,
  row_num - 1
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name) as row_num
  FROM categories
  WHERE name IN ('Arabic Language', 'Quran', 'Manners', 'Islamic Beliefs', 'General Knowledge')
) sub
WHERE row_num <= 5
ON CONFLICT DO NOTHING;

-- Game 5 Questions
DO $$
DECLARE
  gc_arabic UUID;
  gc_quran UUID;
  gc_manners UUID;
  gc_beliefs UUID;
  gc_general UUID;
BEGIN
  SELECT gc.id INTO gc_arabic FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '55555555-5555-5555-5555-555555555555' AND c.name = 'Arabic Language';
  SELECT gc.id INTO gc_quran FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '55555555-5555-5555-5555-555555555555' AND c.name = 'Quran';
  SELECT gc.id INTO gc_manners FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '55555555-5555-5555-5555-555555555555' AND c.name = 'Manners';
  SELECT gc.id INTO gc_beliefs FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '55555555-5555-5555-5555-555555555555' AND c.name = 'Islamic Beliefs';
  SELECT gc.id INTO gc_general FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '55555555-5555-5555-5555-555555555555' AND c.name = 'General Knowledge';

  IF gc_arabic IS NULL OR gc_quran IS NULL OR gc_manners IS NULL OR gc_beliefs IS NULL OR gc_general IS NULL THEN
    RAISE EXCEPTION 'Failed to find game categories for Game 5 (Arabic). Make sure categories exist.';
  END IF;

  -- Arabic Language Questions (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('55555555-5555-5555-5555-555555555555', gc_arabic, 'How many letters are in the Arabic alphabet?', '28 letters', 'Arabic is written from right to left!', 100, 0),
  ('55555555-5555-5555-5555-555555555555', gc_arabic, 'What is the first letter of the Arabic alphabet?', 'Alif (ا)', 'Alif makes an "a" sound.', 200, 1),
  ('55555555-5555-5555-5555-555555555555', gc_arabic, 'What does "Kitab" mean in Arabic?', 'Book', 'Al-Kitab is one of the names for the Quran.', 300, 2),
  ('55555555-5555-5555-5555-555555555555', gc_arabic, 'What does "Masjid" mean?', 'Place of prostration (Mosque)', 'It comes from the word "sajda" (prostration).', 400, 3),
  ('55555555-5555-5555-5555-555555555555', gc_arabic, 'What does "Shukran" mean?', 'Thank you', 'The response is "Afwan" (You''re welcome).', 500, 4);

  -- Quran Arabic Questions (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('55555555-5555-5555-5555-555555555555', gc_quran, 'What does "Bismillah" mean?', 'In the name of Allah', 'Muslims say this before starting anything.', 100, 0),
  ('55555555-5555-5555-5555-555555555555', gc_quran, 'What does "Alhamdulillah" mean?', 'All praise is for Allah', 'We say this to thank Allah.', 200, 1),
  ('55555555-5555-5555-5555-555555555555', gc_quran, 'What does "SubhanAllah" mean?', 'Glory be to Allah', 'We say this when amazed by Allah''s creation.', 300, 2),
  ('55555555-5555-5555-5555-555555555555', gc_quran, 'What does "Allahu Akbar" mean?', 'Allah is the Greatest', 'This is said during prayer and the adhan.', 400, 3),
  ('55555555-5555-5555-5555-555555555555', gc_quran, 'What does "La ilaha illallah" mean?', 'There is no god but Allah', 'This is part of the Shahada (declaration of faith).', 500, 4);

  -- Manners/Greetings in Arabic (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('55555555-5555-5555-5555-555555555555', gc_manners, 'What does "Assalamu Alaikum" mean?', 'Peace be upon you', 'The Islamic greeting between Muslims.', 100, 0),
  ('55555555-5555-5555-5555-555555555555', gc_manners, 'What is the reply to "Assalamu Alaikum"?', 'Wa Alaikum Assalam', 'It means "And upon you be peace."', 200, 1),
  ('55555555-5555-5555-5555-555555555555', gc_manners, 'What does "JazakAllahu Khairan" mean?', 'May Allah reward you with goodness', 'A beautiful way to say thank you.', 300, 2),
  ('55555555-5555-5555-5555-555555555555', gc_manners, 'What does "InshaAllah" mean?', 'If Allah wills', 'We say this when talking about the future.', 400, 3),
  ('55555555-5555-5555-5555-555555555555', gc_manners, 'What does "MashaAllah" mean?', 'What Allah has willed', 'We say this to express appreciation and ward off envy.', 500, 4);

  -- Islamic Beliefs Arabic Words (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('55555555-5555-5555-5555-555555555555', gc_beliefs, 'What does "Salah" mean?', 'Prayer', 'Muslims pray 5 times a day.', 100, 0),
  ('55555555-5555-5555-5555-555555555555', gc_beliefs, 'What does "Sawm" mean?', 'Fasting', 'Muslims fast during Ramadan.', 200, 1),
  ('55555555-5555-5555-5555-555555555555', gc_beliefs, 'What does "Zakat" mean?', 'Charity/Purification of wealth', 'One of the five pillars of Islam.', 300, 2),
  ('55555555-5555-5555-5555-555555555555', gc_beliefs, 'What does "Jannah" mean?', 'Paradise/Heaven', 'The reward for believers in the afterlife.', 400, 3),
  ('55555555-5555-5555-5555-555555555555', gc_beliefs, 'What does "Tawba" mean?', 'Repentance', 'Turning back to Allah and asking forgiveness.', 500, 4);

  -- General Arabic Words (Kids)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('55555555-5555-5555-5555-555555555555', gc_general, 'What does "Ummi" mean?', 'My mother', 'Family is very important in Islam.', 100, 0),
  ('55555555-5555-5555-5555-555555555555', gc_general, 'What does "Abi" mean?', 'My father', 'Respecting parents is emphasized in Islam.', 200, 1),
  ('55555555-5555-5555-5555-555555555555', gc_general, 'What does "Maa" mean?', 'Water', 'Water is a blessing from Allah.', 300, 2),
  ('55555555-5555-5555-5555-555555555555', gc_general, 'What does "Shams" mean?', 'Sun', 'There is a surah called Ash-Shams (The Sun).', 400, 3),
  ('55555555-5555-5555-5555-555555555555', gc_general, 'What does "Qamar" mean?', 'Moon', 'There is a surah called Al-Qamar (The Moon).', 500, 4);
END $$;

-- ============================================================================
-- GAME 6: Advanced Fiqh (Islamic Jurisprudence)
-- ============================================================================

INSERT INTO games (id, title, description, difficulty, creator_id, is_public, total_plays, average_rating, rating_count)
VALUES (
  '66666666-6666-6666-6666-666666666666',
  'Advanced Fiqh Challenge',
  'Test your knowledge of Islamic jurisprudence, rulings, and the principles of fiqh.',
  'advanced',
  '87b6bf37-46a4-4d21-8d45-5d3c6501ef48',
  true,
  0,
  NULL,
  0
) ON CONFLICT (id) DO NOTHING;

-- Game 6 Categories
INSERT INTO game_categories (id, game_id, category_id, display_order)
SELECT
  gen_random_uuid(),
  '66666666-6666-6666-6666-666666666666',
  id,
  row_num - 1
FROM (
  SELECT id, ROW_NUMBER() OVER (ORDER BY name) as row_num
  FROM categories
  WHERE name IN ('Fiqh', 'Sunnah', 'Hadith', 'Islamic Beliefs', 'Quran')
) sub
WHERE row_num <= 5
ON CONFLICT DO NOTHING;

-- Game 6 Questions
DO $$
DECLARE
  gc_fiqh UUID;
  gc_sunnah UUID;
  gc_hadith UUID;
  gc_beliefs UUID;
  gc_quran UUID;
BEGIN
  SELECT gc.id INTO gc_fiqh FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '66666666-6666-6666-6666-666666666666' AND c.name = 'Fiqh';
  SELECT gc.id INTO gc_sunnah FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '66666666-6666-6666-6666-666666666666' AND c.name = 'Sunnah';
  SELECT gc.id INTO gc_hadith FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '66666666-6666-6666-6666-666666666666' AND c.name = 'Hadith';
  SELECT gc.id INTO gc_beliefs FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '66666666-6666-6666-6666-666666666666' AND c.name = 'Islamic Beliefs';
  SELECT gc.id INTO gc_quran FROM game_categories gc JOIN categories c ON gc.category_id = c.id WHERE gc.game_id = '66666666-6666-6666-6666-666666666666' AND c.name = 'Quran';

  IF gc_fiqh IS NULL OR gc_sunnah IS NULL OR gc_hadith IS NULL OR gc_beliefs IS NULL OR gc_quran IS NULL THEN
    RAISE EXCEPTION 'Failed to find game categories for Game 6 (Fiqh). Make sure categories exist.';
  END IF;

  -- Fiqh Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('66666666-6666-6666-6666-666666666666', gc_fiqh, 'What are the four main Sunni schools of fiqh?', 'Hanafi, Maliki, Shafi''i, Hanbali', 'Named after the four great imams who founded them.', 100, 0),
  ('66666666-6666-6666-6666-666666666666', gc_fiqh, 'What is the Arabic term for Islamic jurisprudence?', 'Fiqh', 'Literally means "deep understanding."', 200, 1),
  ('66666666-6666-6666-6666-666666666666', gc_fiqh, 'What are the five categories of actions in fiqh?', 'Wajib, Mustahabb, Mubah, Makruh, Haram', 'Obligatory, Recommended, Permissible, Disliked, Forbidden.', 300, 2),
  ('66666666-6666-6666-6666-666666666666', gc_fiqh, 'What is "Usul al-Fiqh"?', 'Principles/Foundations of Islamic Jurisprudence', 'The methodology used to derive rulings.', 400, 3),
  ('66666666-6666-6666-6666-666666666666', gc_fiqh, 'What are the four primary sources of Islamic law?', 'Quran, Sunnah, Ijma (consensus), Qiyas (analogy)', 'These are the foundations of deriving rulings.', 500, 4);

  -- Sunnah/Worship Fiqh Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('66666666-6666-6666-6666-666666666666', gc_sunnah, 'What invalidates wudu (ablution)?', 'Passing wind, using bathroom, deep sleep, bleeding (in some madhabs)', 'Different schools have slightly different rulings.', 100, 0),
  ('66666666-6666-6666-6666-666666666666', gc_sunnah, 'What is the minimum amount for Zakat on gold?', '85 grams (nisab)', 'Zakat is 2.5% of wealth above this threshold.', 200, 1),
  ('66666666-6666-6666-6666-666666666666', gc_sunnah, 'What is Tayammum?', 'Dry ablution using clean earth/dust', 'Permitted when water is unavailable or harmful.', 300, 2),
  ('66666666-6666-6666-6666-666666666666', gc_sunnah, 'What is the ruling on combining prayers while traveling?', 'Permissible (Jam'')', 'Dhuhr with Asr, and Maghrib with Isha can be combined.', 400, 3),
  ('66666666-6666-6666-6666-666666666666', gc_sunnah, 'What is Sujud al-Sahw?', 'Prostration of forgetfulness', 'Done at the end of prayer for mistakes in prayer.', 500, 4);

  -- Hadith/Evidence Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('66666666-6666-6666-6666-666666666666', gc_hadith, 'What is a Mutawatir hadith?', 'Hadith narrated by many people at every level, impossible to fabricate', 'The strongest category of hadith.', 100, 0),
  ('66666666-6666-6666-6666-666666666666', gc_hadith, 'What is an Ahad hadith?', 'Hadith with limited number of narrators', 'Classified into Sahih, Hasan, or Da''if.', 200, 1),
  ('66666666-6666-6666-6666-666666666666', gc_hadith, 'What does "Sahih" mean in hadith classification?', 'Authentic/Sound', 'Meets all criteria for authenticity.', 300, 2),
  ('66666666-6666-6666-6666-666666666666', gc_hadith, 'What is "Jarh wa Ta''dil"?', 'Science of criticizing and validating hadith narrators', 'Used to determine narrator reliability.', 400, 3),
  ('66666666-6666-6666-6666-666666666666', gc_hadith, 'What is a Mawquf hadith?', 'Saying attributed to a Companion, not the Prophet', 'Different from Marfu'' (attributed to the Prophet).', 500, 4);

  -- Islamic Beliefs/Aqeedah related to Fiqh (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('66666666-6666-6666-6666-666666666666', gc_beliefs, 'What is Ijtihad?', 'Independent reasoning to derive legal rulings', 'Used when no clear text exists on an issue.', 100, 0),
  ('66666666-6666-6666-6666-666666666666', gc_beliefs, 'What is Taqlid?', 'Following a qualified scholar''s opinion without knowing evidence', 'Common for laypeople to follow a madhab.', 200, 1),
  ('66666666-6666-6666-6666-666666666666', gc_beliefs, 'What is the difference between Fatwa and Hukm?', 'Fatwa is non-binding opinion, Hukm is legal ruling', 'A judge issues Hukm, a scholar issues Fatwa.', 300, 2),
  ('66666666-6666-6666-6666-666666666666', gc_beliefs, 'What is Maslaha in fiqh?', 'Public interest/benefit', 'A consideration in deriving rulings.', 400, 3),
  ('66666666-6666-6666-6666-666666666666', gc_beliefs, 'What is the principle "Hardship brings ease" in fiqh?', 'Al-Mashaqqah Tajlib al-Taysir', 'One of the five major maxims of Islamic law.', 500, 4);

  -- Quran/Legal Verses Questions (Advanced)
  INSERT INTO questions (game_id, game_category_id, question_text, answer_text, explanation, points, display_order) VALUES
  ('66666666-6666-6666-6666-666666666666', gc_quran, 'What are the verses of legal rulings called?', 'Ayat al-Ahkam', 'About 500 verses deal with legal matters.', 100, 0),
  ('66666666-6666-6666-6666-666666666666', gc_quran, 'What is Naskh in Quranic interpretation?', 'Abrogation - later verse superseding earlier one', 'A principle in understanding some rulings.', 200, 1),
  ('66666666-6666-6666-6666-666666666666', gc_quran, 'Which surah contains many family law rulings?', 'Surah An-Nisa (The Women)', 'Covers inheritance, marriage, and women''s rights.', 300, 2),
  ('66666666-6666-6666-6666-666666666666', gc_quran, 'What is the longest verse in the Quran about?', 'Financial transactions (Ayat al-Dayn)', 'Surah Al-Baqarah, verse 282 - about debts and contracts.', 400, 3),
  ('66666666-6666-6666-6666-666666666666', gc_quran, 'What does "Muhkam" mean in Quranic terminology?', 'Clear, unambiguous verses', 'Opposite of Mutashabih (ambiguous verses).', 500, 4);
END $$;

-- ============================================================================
-- Success message
-- ============================================================================
DO $$ BEGIN RAISE NOTICE 'New sample games created successfully! Added: Seerah (Beginner), Arabic for Kids, and Advanced Fiqh.'; END $$;
