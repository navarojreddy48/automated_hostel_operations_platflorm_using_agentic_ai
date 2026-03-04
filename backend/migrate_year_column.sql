-- Migration: Fix year column in students table
-- This converts the year column from INT to VARCHAR to support values like "1st", "2nd", "3rd"

ALTER TABLE students MODIFY COLUMN year VARCHAR(20);
