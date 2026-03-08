-- Leave agentic monitoring schema updates
ALTER TABLE leave_requests
  MODIFY COLUMN status ENUM('pending', 'approved', 'active', 'completed', 'expired', 'rejected', 'cancelled') DEFAULT 'pending';

ALTER TABLE leave_requests
  ADD COLUMN active_at DATETIME NULL,
  ADD COLUMN completed_at DATETIME NULL,
  ADD COLUMN expired_at DATETIME NULL,
  ADD COLUMN pending_alert_sent_at DATETIME NULL,
  ADD COLUMN ai_flagged TINYINT(1) DEFAULT 0,
  ADD COLUMN ai_flag_reason VARCHAR(255) NULL;

CREATE INDEX idx_leave_active_at ON leave_requests(active_at);
CREATE INDEX idx_leave_completed_at ON leave_requests(completed_at);
CREATE INDEX idx_leave_pending_alert_sent ON leave_requests(pending_alert_sent_at);

CREATE TABLE IF NOT EXISTS leave_agentic_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  related_leave_id INT NULL,
  student_id INT NULL,
  alert_type ENUM('pending_too_long', 'frequent_leave', 'suspicious_pattern', 'attendance_conflict', 'limit_exceeded', 'recommendation') NOT NULL,
  severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
  detection_key VARCHAR(255) UNIQUE,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  metadata_json JSON NULL,
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (related_leave_id) REFERENCES leave_requests(id) ON DELETE SET NULL,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_leave_alert_type (alert_type),
  INDEX idx_leave_alert_severity (severity),
  INDEX idx_leave_alert_created_at (created_at),
  INDEX idx_leave_alert_is_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
