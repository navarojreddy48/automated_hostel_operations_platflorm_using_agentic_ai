-- Complaint agentic monitoring schema updates
ALTER TABLE complaints
  MODIFY COLUMN status ENUM('pending', 'assigned', 'in_progress', 'delayed', 'resolved', 'closed', 'cancelled') DEFAULT 'pending';

ALTER TABLE complaints
  ADD COLUMN ai_priority ENUM('low', 'medium', 'high') DEFAULT 'low',
  ADD COLUMN delayed_at DATETIME NULL,
  ADD COLUMN escalated_at DATETIME NULL,
  ADD COLUMN last_technician_update_at DATETIME NULL,
  ADD COLUMN last_reminder_sent_at DATETIME NULL,
  ADD COLUMN reminder_count INT DEFAULT 0;

CREATE INDEX idx_complaints_ai_priority ON complaints(ai_priority);
CREATE INDEX idx_complaints_delayed_at ON complaints(delayed_at);
CREATE INDEX idx_complaints_escalated_at ON complaints(escalated_at);

CREATE TABLE IF NOT EXISTS complaint_agentic_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  complaint_id INT NULL,
  alert_type ENUM('critical', 'unassigned_delay', 'delayed', 'technician_reminder', 'escalated', 'anomaly', 'recommendation') NOT NULL,
  severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
  alert_key VARCHAR(255) UNIQUE,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  metadata_json JSON NULL,
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
  INDEX idx_alert_type (alert_type),
  INDEX idx_alert_severity (severity),
  INDEX idx_alert_created_at (created_at),
  INDEX idx_alert_is_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
