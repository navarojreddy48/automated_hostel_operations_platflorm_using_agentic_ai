-- Add staff_id column to users table
-- Staff ID format: 3-letter prefix (WAR/TEC/SEC) + 3 random digits

ALTER TABLE users ADD COLUMN staff_id VARCHAR(20) UNIQUE DEFAULT NULL AFTER role;

-- Create index for faster lookups
CREATE INDEX idx_staff_id ON users(staff_id);

-- Generate staff IDs for existing wardens, technicians, and security staff
-- These will be randomly generated with proper prefixes

-- Note: New staff_id values will be auto-generated when users are created
