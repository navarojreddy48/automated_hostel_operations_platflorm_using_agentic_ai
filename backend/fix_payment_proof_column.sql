-- Add payment_proof_url column to students table
USE hostelconnect_db;
ALTER TABLE students ADD COLUMN payment_proof_url VARCHAR(500) AFTER emergency_contact;
