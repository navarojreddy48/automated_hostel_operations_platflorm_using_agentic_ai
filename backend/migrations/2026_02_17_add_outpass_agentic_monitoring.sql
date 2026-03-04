-- Migration: Add autonomous outpass monitoring columns
-- Date: 2026-02-17

ALTER TABLE outpasses ADD COLUMN monitor_state ENUM('on_time', 'grace_period', 'overdue') DEFAULT 'on_time';
ALTER TABLE outpasses ADD COLUMN risk_level ENUM('low', 'medium', 'high') DEFAULT 'low';
ALTER TABLE outpasses ADD COLUMN overdue_alert_sent_student TINYINT(1) DEFAULT 0;
ALTER TABLE outpasses ADD COLUMN overdue_alert_sent_parent TINYINT(1) DEFAULT 0;
ALTER TABLE outpasses ADD COLUMN overdue_notified_at DATETIME NULL;

CREATE INDEX idx_outpass_monitor_state ON outpasses(monitor_state);
CREATE INDEX idx_outpass_risk_level ON outpasses(risk_level);
