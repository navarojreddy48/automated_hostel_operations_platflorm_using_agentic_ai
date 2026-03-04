-- Migration: Add Holiday Mode and OTP Support for Outpasses
-- Date: 2026-02-18
-- Description: Adds columns to support College Holiday Mode with OTP verification

-- Add new columns to outpasses table
ALTER TABLE outpasses 
ADD COLUMN IF NOT EXISTS approval_method ENUM('manual', 'otp') DEFAULT 'manual' COMMENT 'Approval method: manual by warden or OTP from parent',
ADD COLUMN IF NOT EXISTS otp_code VARCHAR(6) COMMENT 'Generated OTP code for parent verification',
ADD COLUMN IF NOT EXISTS otp_sent_at DATETIME COMMENT 'Timestamp when OTP was sent to parent',
ADD COLUMN IF NOT EXISTS otp_verified_at DATETIME COMMENT 'Timestamp when OTP was verified',
ADD COLUMN IF NOT EXISTS otp_attempts INT DEFAULT 0 COMMENT 'Number of OTP verification attempts',
ADD COLUMN IF NOT EXISTS holiday_mode_request TINYINT(1) DEFAULT 0 COMMENT 'Whether request was made during holiday mode';

-- Create system settings table for holiday mode toggle
CREATE TABLE IF NOT EXISTS system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT,
  description VARCHAR(255),
  updated_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_setting_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default holiday mode setting
INSERT INTO system_settings (setting_key, setting_value, description) 
VALUES ('college_holiday_mode', 'false', 'Enable/disable college holiday mode for outpass OTP verification')
ON DUPLICATE KEY UPDATE setting_value = setting_value;

-- Update status enum to include OTP-specific statuses
ALTER TABLE outpasses 
MODIFY COLUMN status ENUM('pending', 'pending_otp', 'approved', 'approved_otp', 'rejected', 'exited', 'returned', 'overdue') DEFAULT 'pending';
