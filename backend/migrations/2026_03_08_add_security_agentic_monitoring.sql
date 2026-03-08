-- Security Monitoring Agent migration
-- Adds autonomous security alerts and student risk profiling tables.

CREATE TABLE IF NOT EXISTS security_agentic_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NULL,
  related_outpass_id INT NULL,
  alert_type ENUM('late_return', 'missing_return', 'night_movement', 'unauthorized_exit_attempt', 'repeat_violation', 'risk_escalation', 'recommendation') NOT NULL,
  severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
  detection_key VARCHAR(255) UNIQUE,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  metadata_json JSON NULL,
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (related_outpass_id) REFERENCES outpasses(id) ON DELETE SET NULL,
  INDEX idx_security_alert_type (alert_type),
  INDEX idx_security_alert_severity (severity),
  INDEX idx_security_alert_created_at (created_at),
  INDEX idx_security_alert_is_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS security_student_risk_profiles (
  student_id INT PRIMARY KEY,
  risk_score INT DEFAULT 0,
  risk_level ENUM('low', 'medium', 'high') DEFAULT 'low',
  late_returns_30d INT DEFAULT 0,
  missing_returns_30d INT DEFAULT 0,
  unauthorized_exits_30d INT DEFAULT 0,
  night_movements_30d INT DEFAULT 0,
  violation_count_30d INT DEFAULT 0,
  last_incident_at DATETIME NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_security_risk_level (risk_level),
  INDEX idx_security_risk_score (risk_score),
  INDEX idx_security_violation_count (violation_count_30d)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
