-- STEP 2: Add categories and rename Etiquette
-- Run this AFTER 01_add_enum_values.sql completes

-- Update existing "Islamic Etiquette" category to "Manners"
UPDATE categories
SET name = 'Manners',
    category_type = 'islamic_manners'
WHERE name = 'Islamic Etiquette' OR category_type = 'islamic_etiquette';

-- Add new categories
INSERT INTO categories (name, category_type, description)
VALUES ('Seerah', 'seerah', 'Questions about the life of Prophet Muhammad (PBUH)')
ON CONFLICT DO NOTHING;

INSERT INTO categories (name, category_type, description)
VALUES ('Fiqh', 'fiqh', 'Questions about Islamic jurisprudence and rulings')
ON CONFLICT DO NOTHING;

INSERT INTO categories (name, category_type, description)
VALUES ('Arabic Language', 'arabic_language', 'Questions about Arabic language and vocabulary')
ON CONFLICT DO NOTHING;
