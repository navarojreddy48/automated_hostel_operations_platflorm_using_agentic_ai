-- Foundational demo data

INSERT INTO colleges (name, status) VALUES
('MLR Institute of Technology (MLRIT)', 'active'),
('Institute of Aeronautical Engineering (IARE)', 'active'),
('Marri Laxman Reddy Institute of Technology and Management (MLRITM)', 'active');

INSERT INTO branches (name, status) VALUES
('CSE', 'active'),
('CSE (AIML)', 'active'),
('CSE (DS)', 'active'),
('CSE (IT)', 'active'),
('IT', 'active'),
('ECE', 'active'),
('MECH', 'active'),
('EEE', 'active'),
('AERO', 'active'),
('CSE (CS)', 'active');

-- Hostel Blocks
INSERT INTO blocks (block_name, block_gender, total_floors, status) VALUES
('A Block', 'male', 4, 'active'),
('B Block', 'female', 4, 'active');

-- Rooms (for demo, 2 per block)
INSERT INTO rooms (block_id, room_number, floor, capacity, occupied_count, room_type, status) VALUES
(1, '101', 1, 4, 2, 'shared', 'available'),
(1, '102', 1, 4, 1, 'shared', 'available'),
(2, '201', 1, 4, 1, 'shared', 'available'),
(2, '202', 1, 4, 0, 'shared', 'available');

-- Admin user
INSERT INTO users (name, email, username, password, role, status) VALUES
('Admin User', 'admin@hostelconnect.in', 'admin', 'adminpassword', 'admin', 'active');

-- Wardens (linked to users, demo: 2)
INSERT INTO users (name, email, username, password, role, staff_id, status) VALUES
('Rajesh Warden', 'warden.rajesh@hostelconnect.in', 'wardenrajesh', 'password', 'warden', 'W001', 'active'),
('Lakshmi Warden', 'warden.lakshmi@hostelconnect.in', 'wardenlakshmi', 'password', 'warden', 'W002', 'active');

INSERT INTO wardens (user_id, employee_id, hostel_block, phone, office_location, designation) VALUES
(2, 'W001', 'A Block', '900010001', 'A Block Office', 'Chief Warden'),
(3, 'W002', 'B Block', '900010002', 'B Block Office', 'Deputy Warden');

-- Security Personnel (linked to users, demo: 2)
INSERT INTO users (name, email, username, password, role, staff_id, status) VALUES
('Raghav Security', 'security.raghav@hostelconnect.in', 'securityraghav', 'password', 'security', 'S001', 'active'),
('Anitha Security', 'security.anitha@hostelconnect.in', 'securityanitha', 'password', 'security', 'S002', 'active');

INSERT INTO security_personnel (user_id, employee_id, shift_timing, gate_assigned, phone) VALUES
(4, 'S001', 'Day', 'Main Gate', '900020001'),
(5, 'S002', 'Night', 'Side Gate', '900020002');

-- Technicians (linked to users, demo: 2)
INSERT INTO users (name, email, username, password, role, staff_id, status) VALUES
('Mahesh Tech', 'tech.mahesh@hostelconnect.in', 'techmahesh', 'password', 'technician', 'T001', 'active'),
('Sunil Tech', 'tech.sunil@hostelconnect.in', 'techsunil', 'password', 'technician', 'T002', 'active');

INSERT INTO technicians (user_id, employee_id, specialization, phone, availability_status) VALUES
(6, 'T001', 'Electrician', '900030001', 'available'),
(7, 'T002', 'Plumber', '900030002', 'available');

-- Room Allocations (link students to rooms, demo: 2)
INSERT INTO room_allocations (student_id, room_id, allocation_date, status) VALUES
(1, 1, '2026-03-01', 'active'),
(2, 2, '2026-03-01', 'active');

-- Outpasses (demo: 1)
INSERT INTO outpasses (student_id, reason, destination, out_date, out_time, expected_return_time, status, approval_method, approved_by) VALUES
(1, 'Family Visit', 'Hyderabad', '2026-03-10', '09:00:00', '2026-03-12 18:00:00', 'approved', 'manual', 2);

-- Complaints (demo: 1)
INSERT INTO complaints (student_id, block_id, category, title, description, priority, status, assigned_technician_id) VALUES
(1, 1, 'electrical', 'Light not working', 'The light in room 101 is not working.', 'medium', 'in_progress', 6);

-- Parcels (demo: 1)
INSERT INTO parcels (student_id, tracking_number, courier_name, sender_name, sender_contact, parcel_type, weight, received_date, received_time, received_by, status) VALUES
(1, 'TRK123456', 'BlueDart', 'Parent Ramesh', '800000001', 'package', 2.5, '2026-03-05', '10:30:00', 4, 'received');

-- Visitors (demo: 1)
INSERT INTO visitors (visitor_name, phone, id_type, id_number, student_id, relationship, purpose, entry_time, status, approved_by, security_guard_id) VALUES
('Suresh Kumar', '8888888888', 'aadhar', 'AADH1234', 1, 'Father', 'Visit', '2026-03-06 11:00:00', 'inside', 2, 4);

-- Notifications (demo: 1)
INSERT INTO notifications (user_id, title, message, notification_type, is_read) VALUES
(1, 'Welcome', 'Welcome to HostelConnect!', 'info', 'no');

-- System Settings (demo: 1)
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('holiday_mode', 'off', 'Holiday mode is currently off');

-- Leave Requests (demo: 1)
INSERT INTO leave_requests (student_id, leave_type, leave_reason, from_date, to_date, total_days, status, approved_by) VALUES
(1, 'personal', 'Attending family function', '2026-03-15', '2026-03-18', 4, 'approved', 2);

-- College Leaves (demo: 1)
INSERT INTO college_leaves (student_id, user_id, reason, reason_code, from_date, to_date, total_days, status, approved_by) VALUES
(1, 1, 'Project work', 'assignment', '2026-03-20', '2026-03-22', 3, 'approved', 2);

-- Leave Monitoring (demo: 1)
INSERT INTO leave_monitoring (student_id, leave_type, leave_count_last_30_days, leave_count_last_60_days, leave_count_last_90_days, leave_count_this_semester, average_days_per_leave, most_common_reason, frequency_alert_level, requires_counseling, requires_medical_review, flagged_by_ai) VALUES
(1, 'college_leave', 1, 1, 1, 1, 3.0, 'assignment', 'low', 0, 0, 0);

-- Leave Alerts (demo: 1)
INSERT INTO leave_alerts (student_id, alert_type, alert_message, alert_level, status) VALUES
(1, 'high_frequency', 'Student has taken multiple leaves recently.', 'warning', 'pending');

-- Leave Agentic Alerts (demo: 1)
INSERT INTO leave_agentic_alerts (related_leave_id, student_id, alert_type, severity, detection_key, title, message, is_read) VALUES
(1, 1, 'frequent_leave', 'medium', 'LEAVE001', 'Frequent Leave Alert', 'Student has taken frequent leaves.', 0);

-- Complaint History (demo: 1)
INSERT INTO complaint_history (complaint_id, old_status, new_status, changed_by, remarks) VALUES
(1, 'pending', 'in_progress', 6, 'Technician assigned and started work.');

-- Complaint Agentic Alerts (demo: 1)
INSERT INTO complaint_agentic_alerts (complaint_id, alert_type, severity, alert_key, title, message, is_read) VALUES
(1, 'delayed', 'medium', 'COMP001', 'Delayed Complaint', 'Complaint resolution is delayed.', 0);

-- Security Logs (demo: 1)
INSERT INTO security_logs (activity_type, description, related_student_id, severity, location, logged_by, action_taken, follow_up_required) VALUES
('outpass', 'Student exited for outpass.', 1, 'low', 'Main Gate', 4, 'Checked out', 'no');

-- Security Agentic Alerts (demo: 1)
INSERT INTO security_agentic_alerts (student_id, alert_type, severity, detection_key, title, message, is_read) VALUES
(1, 'late_return', 'low', 'SEC001', 'Late Return Alert', 'Student returned late from outpass.', 0);

-- Security Student Risk Profiles (demo: 1)
INSERT INTO security_student_risk_profiles (student_id, risk_score, risk_level, late_returns_30d, missing_returns_30d, unauthorized_exits_30d, night_movements_30d, violation_count_30d) VALUES
(1, 10, 'low', 1, 0, 0, 0, 1);

-- Mess Menu (demo: 1)
INSERT INTO mess_menu (day_of_week, meal_type, menu_items, special_notes, effective_from) VALUES
('monday', 'lunch', 'Rice, Dal, Curry, Curd', 'Veg only', '2026-03-01');

-- Audit Logs (demo: 1)
INSERT INTO audit_logs (user_id, actor_identifier, actor_role, action, target_type, target_id, outcome, details, ip_address) VALUES
(1, 'admin', 'admin', 'login', 'user', '1', 'success', 'Admin logged in', '127.0.0.1');
-- Students
-- 70 students (using provided names, cycling if needed)
INSERT INTO users (name, email, username, password, role, roll_number, status) VALUES
('Ramesh', 'ramesh@hostelconnect.in', 'ramesh', 'password', 'student', 'STU001', 'active'),
('Suresh', 'suresh@hostelconnect.in', 'suresh', 'password', 'student', 'STU002', 'active'),
('Mahesh', 'mahesh@hostelconnect.in', 'mahesh', 'password', 'student', 'STU003', 'active'),
('Naresh', 'naresh@hostelconnect.in', 'naresh', 'password', 'student', 'STU004', 'active'),
('Rajesh', 'rajesh@hostelconnect.in', 'rajesh', 'password', 'student', 'STU005', 'active'),
('Venkatesh', 'venkatesh@hostelconnect.in', 'venkatesh', 'password', 'student', 'STU006', 'active'),
('Srinivas', 'srinivas@hostelconnect.in', 'srinivas', 'password', 'student', 'STU007', 'active'),
('Srinivas Rao', 'srinivasrao@hostelconnect.in', 'srinivasrao', 'password', 'student', 'STU008', 'active'),
('Raghavendra', 'raghavendra@hostelconnect.in', 'raghavendra', 'password', 'student', 'STU009', 'active'),
('Praveen', 'praveen@hostelconnect.in', 'praveen', 'password', 'student', 'STU010', 'active'),
('Naveen', 'naveen@hostelconnect.in', 'naveen', 'password', 'student', 'STU011', 'active'),
('Kiran', 'kiran@hostelconnect.in', 'kiran', 'password', 'student', 'STU012', 'active'),
('Kiran Kumar', 'kirankumar@hostelconnect.in', 'kirankumar', 'password', 'student', 'STU013', 'active'),
('Raj Kumar', 'rajkumar@hostelconnect.in', 'rajkumar', 'password', 'student', 'STU014', 'active'),
('Sai Kumar', 'saikumar@hostelconnect.in', 'saikumar', 'password', 'student', 'STU015', 'active'),
('Sai Teja', 'saiteja@hostelconnect.in', 'saiteja', 'password', 'student', 'STU016', 'active'),
('Sai Kiran', 'saikiran@hostelconnect.in', 'saikiran', 'password', 'student', 'STU017', 'active'),
('Sai Charan', 'saicharan@hostelconnect.in', 'saicharan', 'password', 'student', 'STU018', 'active'),
('Sai Krishna', 'saikrishna@hostelconnect.in', 'saikrishna', 'password', 'student', 'STU019', 'active'),
('Sai Ram', 'sairam@hostelconnect.in', 'sairam', 'password', 'student', 'STU020', 'active'),
('Harish', 'harish@hostelconnect.in', 'harish', 'password', 'student', 'STU021', 'active'),
('Harsha', 'harsha@hostelconnect.in', 'harsha', 'password', 'student', 'STU022', 'active'),
('Manish', 'manish@hostelconnect.in', 'manish', 'password', 'student', 'STU023', 'active'),
('Rakesh', 'rakesh@hostelconnect.in', 'rakesh', 'password', 'student', 'STU024', 'active'),
('Dinesh', 'dinesh@hostelconnect.in', 'dinesh', 'password', 'student', 'STU025', 'active'),
('Anil', 'anil@hostelconnect.in', 'anil', 'password', 'student', 'STU026', 'active'),
('Sunil', 'sunil@hostelconnect.in', 'sunil', 'password', 'student', 'STU027', 'active'),
('Vinay', 'vinay@hostelconnect.in', 'vinay', 'password', 'student', 'STU028', 'active'),
('Vinod', 'vinod@hostelconnect.in', 'vinod', 'password', 'student', 'STU029', 'active'),
('Santosh', 'santosh@hostelconnect.in', 'santosh', 'password', 'student', 'STU030', 'active'),
('Prakash', 'prakash@hostelconnect.in', 'prakash', 'password', 'student', 'STU031', 'active'),
('Raju', 'raju@hostelconnect.in', 'raju', 'password', 'student', 'STU032', 'active'),
('Ravi', 'ravi@hostelconnect.in', 'ravi', 'password', 'student', 'STU033', 'active'),
('Ravi Teja', 'raviteja@hostelconnect.in', 'raviteja', 'password', 'student', 'STU034', 'active'),
('Chandra Shekhar', 'chandrashekhar@hostelconnect.in', 'chandrashekhar', 'password', 'student', 'STU035', 'active'),
('Srikanth', 'srikanth@hostelconnect.in', 'srikanth', 'password', 'student', 'STU036', 'active'),
('Sridhar', 'sridhar@hostelconnect.in', 'sridhar', 'password', 'student', 'STU037', 'active'),
('Madhav', 'madhav@hostelconnect.in', 'madhav', 'password', 'student', 'STU038', 'active'),
('Madhu', 'madhu@hostelconnect.in', 'madhu', 'password', 'student', 'STU039', 'active'),
('Krishna', 'krishna@hostelconnect.in', 'krishna', 'password', 'student', 'STU040', 'active'),
('Gopal', 'gopal@hostelconnect.in', 'gopal', 'password', 'student', 'STU041', 'active'),
('Narasimha', 'narasimha@hostelconnect.in', 'narasimha', 'password', 'student', 'STU042', 'active'),
('Narender', 'narender@hostelconnect.in', 'narender', 'password', 'student', 'STU043', 'active'),
('Rajender', 'rajender@hostelconnect.in', 'rajender', 'password', 'student', 'STU044', 'active'),
('Rajendra', 'rajendra@hostelconnect.in', 'rajendra', 'password', 'student', 'STU045', 'active'),
('Mallikarjun', 'mallikarjun@hostelconnect.in', 'mallikarjun', 'password', 'student', 'STU046', 'active'),
('Jagadeesh', 'jagadeesh@hostelconnect.in', 'jagadeesh', 'password', 'student', 'STU047', 'active'),
('Yadagiri', 'yadagiri@hostelconnect.in', 'yadagiri', 'password', 'student', 'STU048', 'active'),
('Pratap', 'pratap@hostelconnect.in', 'pratap', 'password', 'student', 'STU049', 'active'),
('Mohan', 'mohan@hostelconnect.in', 'mohan', 'password', 'student', 'STU050', 'active'),
('Raghunath', 'raghunath@hostelconnect.in', 'raghunath', 'password', 'student', 'STU051', 'active'),
('Vishnu', 'vishnu@hostelconnect.in', 'vishnu', 'password', 'student', 'STU052', 'active'),
('Surender', 'surender@hostelconnect.in', 'surender', 'password', 'student', 'STU053', 'active'),
('Vamshi', 'vamshi@hostelconnect.in', 'vamshi', 'password', 'student', 'STU054', 'active'),
('Vamshi Krishna', 'vamshikrishna@hostelconnect.in', 'vamshikrishna', 'password', 'student', 'STU055', 'active'),
('Akhil', 'akhil@hostelconnect.in', 'akhil', 'password', 'student', 'STU056', 'active'),
('Abhilash', 'abhilash@hostelconnect.in', 'abhilash', 'password', 'student', 'STU057', 'active'),
('Rahul', 'rahul@hostelconnect.in', 'rahul', 'password', 'student', 'STU058', 'active'),
('Rohit', 'rohit@hostelconnect.in', 'rohit', 'password', 'student', 'STU059', 'active'),
('Varun', 'varun@hostelconnect.in', 'varun', 'password', 'student', 'STU060', 'active'),
('Lakshmi', 'lakshmi@hostelconnect.in', 'lakshmi', 'password', 'student', 'STU061', 'active'),
('Padma', 'padma@hostelconnect.in', 'padma', 'password', 'student', 'STU062', 'active'),
('Padmavathi', 'padmavathi@hostelconnect.in', 'padmavathi', 'password', 'student', 'STU063', 'active'),
('Anitha', 'anitha@hostelconnect.in', 'anitha', 'password', 'student', 'STU064', 'active'),
('Kavitha', 'kavitha@hostelconnect.in', 'kavitha', 'password', 'student', 'STU065', 'active'),
('Sunitha', 'sunitha@hostelconnect.in', 'sunitha', 'password', 'student', 'STU066', 'active'),
('Sushma', 'sushma@hostelconnect.in', 'sushma', 'password', 'student', 'STU067', 'active'),
('Suma', 'suma@hostelconnect.in', 'suma', 'password', 'student', 'STU068', 'active'),
('Swathi', 'swathi@hostelconnect.in', 'swathi', 'password', 'student', 'STU069', 'active'),
('Swetha', 'swetha@hostelconnect.in', 'swetha', 'password', 'student', 'STU070', 'active');

-- Wardens

-- 4 wardens
INSERT INTO users (name, email, username, password, role, staff_id, status) VALUES
('Rajesh', 'warden.rajesh@hostelconnect.in', 'wardenrajesh', 'password', 'warden', 'W001', 'active'),
('Venkatesh', 'warden.venkatesh@hostelconnect.in', 'wardenvenkatesh', 'password', 'warden', 'W002', 'active'),
('Lakshmi', 'warden.lakshmi@hostelconnect.in', 'wardenlakshmi', 'password', 'warden', 'W003', 'active'),
('Padma', 'warden.padma@hostelconnect.in', 'wardenpadma', 'password', 'warden', 'W004', 'active');

-- Security

-- 4 security
INSERT INTO users (name, email, username, password, role, staff_id, status) VALUES
('Raghavendra', 'security.raghavendra@hostelconnect.in', 'securityraghavendra', 'password', 'security', 'S001', 'active'),
('Praveen', 'security.praveen@hostelconnect.in', 'securitypraveen', 'password', 'security', 'S002', 'active'),
('Anitha', 'security.anitha@hostelconnect.in', 'securityanitha', 'password', 'security', 'S003', 'active'),
('Kavitha', 'security.kavitha@hostelconnect.in', 'securitykavitha', 'password', 'security', 'S004', 'active');

-- Technicians (2 for each role: Electrician, Plumber, Carpenter, AC)

-- 2 technicians for each role (using real names)
INSERT INTO users (name, email, username, password, role, staff_id, status) VALUES
('Mahesh', 'techelec.mahesh@hostelconnect.in', 'techelecmahesh', 'password', 'technician', 'T-ELEC-01', 'active'),
('Naresh', 'techelec.naresh@hostelconnect.in', 'techelecnaresh', 'password', 'technician', 'T-ELEC-02', 'active'),
('Sunil', 'techplumb.sunil@hostelconnect.in', 'techplumbsunil', 'password', 'technician', 'T-PLUMB-01', 'active'),
('Vinay', 'techplumb.vinay@hostelconnect.in', 'techplumbvinay', 'password', 'technician', 'T-PLUMB-02', 'active'),
('Santosh', 'techcarp.santosh@hostelconnect.in', 'techcarpsantosh', 'password', 'technician', 'T-CARP-01', 'active'),
('Prakash', 'techcarp.prakash@hostelconnect.in', 'techcarpprakash', 'password', 'technician', 'T-CARP-02', 'active'),
('Ravi', 'techac.ravi@hostelconnect.in', 'techacravi', 'password', 'technician', 'T-AC-01', 'active'),
('Ravi Teja', 'techac.raviteja@hostelconnect.in', 'techacraviteja', 'password', 'technician', 'T-AC-02', 'active');

-- Students table (linking to users)
-- For demo, assuming user_id = 1 to 70 for students

INSERT INTO students (user_id, roll_number, college_name, branch, year, gender, fee_status, registration_status, phone, parent_phone, parent_name, parent_email, address, blood_group, emergency_contact) VALUES
(1, '22R21A66A1', 'MLR Institute of Technology (MLRIT)', 'CSE (AIML)', 'Final', 'male', 'paid', 'approved', '900000001', '800000001', 'Parent Ramesh', 'parent.ramesh@hostelconnect.in', 'Address 1', 'A+', '911111111'),
(2, '22R21A04A2', 'Institute of Aeronautical Engineering (IARE)', 'ECE', 'Final', 'male', 'paid', 'approved', '900000002', '800000002', 'Parent Suresh', 'parent.suresh@hostelconnect.in', 'Address 2', 'B+', '911111112'),
(3, '23R21A66A3', 'Marri Laxman Reddy Institute of Technology and Management (MLRITM)', 'CSE (DS)', '3rd', 'male', 'paid', 'approved', '900000003', '800000003', 'Parent Mahesh', 'parent.mahesh@hostelconnect.in', 'Address 3', 'O+', '911111113'),
(4, '23R21A12A4', 'MLR Institute of Technology (MLRIT)', 'CSE (IT)', '3rd', 'male', 'paid', 'approved', '900000004', '800000004', 'Parent Naresh', 'parent.naresh@hostelconnect.in', 'Address 4', 'AB+', '911111114'),
(5, '24R21A66A5', 'Institute of Aeronautical Engineering (IARE)', 'CSE (AIML)', '2nd', 'male', 'paid', 'approved', '900000005', '800000005', 'Parent Rajesh', 'parent.rajesh@hostelconnect.in', 'Address 5', 'A-', '911111115'),
(6, '24R21A04A6', 'Marri Laxman Reddy Institute of Technology and Management (MLRITM)', 'ECE', '2nd', 'male', 'paid', 'approved', '900000006', '800000006', 'Parent Venkatesh', 'parent.venkatesh@hostelconnect.in', 'Address 6', 'B-', '911111116'),
(7, '25R21A12A7', 'MLR Institute of Technology (MLRIT)', 'IT', '1st', 'male', 'paid', 'approved', '900000007', '800000007', 'Parent Srinivas', 'parent.srinivas@hostelconnect.in', 'Address 7', 'O-', '911111117'),
(8, '25R21A66A8', 'Institute of Aeronautical Engineering (IARE)', 'CSE (AIML)', '1st', 'male', 'paid', 'approved', '900000008', '800000008', 'Parent Srinivas Rao', 'parent.srinivasrao@hostelconnect.in', 'Address 8', 'AB-', '911111118'),
(9, '22R21A04A9', 'Marri Laxman Reddy Institute of Technology and Management (MLRITM)', 'ECE', 'Final', 'male', 'paid', 'approved', '900000009', '800000009', 'Parent Raghavendra', 'parent.raghavendra@hostelconnect.in', 'Address 9', 'A+', '911111119'),
(10, '23R21A12B1', 'MLR Institute of Technology (MLRIT)', 'IT', '3rd', 'male', 'paid', 'approved', '900000010', '800000010', 'Parent Praveen', 'parent.praveen@hostelconnect.in', 'Address 10', 'B+', '911111120');
