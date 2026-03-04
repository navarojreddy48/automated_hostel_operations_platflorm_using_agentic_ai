-- Add columns for outpass exit/return tracking
USE hostelconnect_db;

ALTER TABLE outpasses 
ADD COLUMN actual_exit_time DATETIME NULL,
ADD COLUMN actual_return_time DATETIME NULL,
ADD COLUMN is_overdue BOOLEAN DEFAULT FALSE,
ADD COLUMN late_minutes INT DEFAULT 0,
ADD COLUMN grace_period_applied BOOLEAN DEFAULT FALSE,
ADD COLUMN exit_logged_by INT NULL,
ADD COLUMN return_logged_by INT NULL,
ADD COLUMN security_notes TEXT NULL;

-- Add foreign keys for security personnel
ALTER TABLE outpasses 
ADD CONSTRAINT fk_exit_logged_by FOREIGN KEY (exit_logged_by) REFERENCES users(id) ON DELETE SET NULL,
ADD CONSTRAINT fk_return_logged_by FOREIGN KEY (return_logged_by) REFERENCES users(id) ON DELETE SET NULL;

-- Update status enum if needed (keeping as varchar for flexibility)
-- Possible statuses: pending, approved, rejected, out, returned, overdue
