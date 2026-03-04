-- Migration: Add payment_proof_url column to students table
-- This stores the path/URL to the payment proof document (receipt image or PDF)

ALTER TABLE students ADD COLUMN payment_proof_url VARCHAR(500) AFTER emergency_contact;
