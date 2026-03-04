-- Add floor_preference column to students table
-- Migration: 2026-02-12 - Add floor preference for student registration

USE hostelconnect_db;

-- Add floor_preference column if it doesn't exist
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS floor_preference VARCHAR(50) AFTER preferred_block;

-- Add index for floor preference queries
CREATE INDEX IF NOT EXISTS idx_floor_preference ON students(floor_preference);
