-- Migration: Add explanation field to questions table
-- Run this if you already have the questions table created

-- Add explanation column (nullable, optional field)
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS explanation text;

-- Add comment
COMMENT ON COLUMN questions.explanation IS 'Optional 1-2 line explanation for learning purposes';

