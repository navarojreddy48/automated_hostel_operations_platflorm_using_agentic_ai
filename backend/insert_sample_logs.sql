-- Insert sample security logs for testing
INSERT INTO security_logs (activity_type, description, related_student_id, severity, location, logged_by, action_taken, follow_up_required, timestamp) 
VALUES 
('outpass', 'Student exit recorded at main gate', 1, 'low', 'Gate A', 1, 'Student marked OUT', 'no', NOW()),
('visitor', 'Visitor entry registered for Room 204', NULL, 'low', 'Main Gate', 1, 'Visitor approved', 'no', DATE_SUB(NOW(), INTERVAL 30 MINUTE)),
('parcel', 'Parcel delivery logged', 2, 'low', 'Reception', 1, 'Student notified', 'no', DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('outpass', 'Student return marked late', 3, 'medium', 'Gate B', 1, 'Logged with note', 'yes', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('incident', 'Suspicious activity reported', NULL, 'high', 'Corridor C', 1, 'Investigated and recorded', 'yes', DATE_SUB(NOW(), INTERVAL 3 HOUR)),
('patrol', 'Evening patrol completed', NULL, 'low', 'Premises', 1, 'All areas secured', 'no', DATE_SUB(NOW(), INTERVAL 4 HOUR)),
('emergency', 'Medical emergency reported', 4, 'critical', 'Room A-105', 1, 'Ambulance called', 'yes', DATE_SUB(NOW(), INTERVAL 5 HOUR));
