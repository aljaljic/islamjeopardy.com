-- STEP 1: Add new enum values
-- Run this FIRST in Supabase SQL Editor

ALTER TYPE category_type ADD VALUE IF NOT EXISTS 'seerah';
ALTER TYPE category_type ADD VALUE IF NOT EXISTS 'fiqh';
ALTER TYPE category_type ADD VALUE IF NOT EXISTS 'arabic_language';
ALTER TYPE category_type ADD VALUE IF NOT EXISTS 'islamic_manners';
