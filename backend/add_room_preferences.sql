-- Add room preference columns to students table
USE hostelconnect_db;

-- Note: Run this only once. If columns already exist, this will error.
ALTER TABLE students 
ADD COLUMN preferred_block VARCHAR(50) AFTER payment_proof_url,
ADD COLUMN room_preference VARCHAR(50) AFTER preferred_block;
