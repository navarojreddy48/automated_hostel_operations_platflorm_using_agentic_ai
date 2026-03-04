-- Migration: Add parent_email column to students table
-- Date: 2026-02-17
-- Description: Add parent email field to enable email notifications to parents

ALTER TABLE students ADD COLUMN parent_email VARCHAR(150) AFTER parent_name;

-- Add index for parent_email
CREATE INDEX idx_parent_email ON students(parent_email);
