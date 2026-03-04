-- ========================================
-- HostelConnect Database Schema
-- Complete Hostel Management System
-- Database: hostelconnect_db
-- ========================================

-- Create Database
CREATE DATABASE IF NOT EXISTS hostelconnect_db;
USE hostelconnect_db;

-- ========================================
-- 1️⃣ USERS & AUTHENTICATION
-- ========================================

-- Central users table for all system users
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('student', 'warden', 'admin', 'technician', 'security') NOT NULL,
  staff_id VARCHAR(10) UNIQUE,
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  roll_number VARCHAR(50) UNIQUE,
  
  INDEX idx_email (email),
  INDEX idx_username (username),
  INDEX idx_role (role),
  INDEX idx_status (status),
  INDEX idx_staff_id (staff_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 2️⃣ STUDENT DETAILS
-- ========================================

-- Extended student information
CREATE TABLE IF NOT EXISTS students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNIQUE NOT NULL,
  roll_number VARCHAR(50) UNIQUE NOT NULL,
  college_name VARCHAR(150),
  branch VARCHAR(100),
  year VARCHAR(20),
  gender ENUM('male', 'female', 'other'),
  room_id INT,
  fee_status ENUM('paid', 'pending', 'overdue') DEFAULT 'pending',
  registration_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  phone VARCHAR(20),
  parent_phone VARCHAR(20),
  parent_name VARCHAR(100),
  address TEXT,
  blood_group VARCHAR(10),
  emergency_contact VARCHAR(20),
  payment_proof_url VARCHAR(500),
  preferred_block VARCHAR(50),
  floor_preference VARCHAR(50),
  room_preference VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_roll_number (roll_number),
  INDEX idx_college_name (college_name),
  INDEX idx_registration_status (registration_status),
  INDEX idx_fee_status (fee_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 2️⃣1️⃣ ACADEMIC SETTINGS
-- ========================================

-- Colleges list
CREATE TABLE IF NOT EXISTS colleges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_college_name (name),
  INDEX idx_college_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Branches list
CREATE TABLE IF NOT EXISTS branches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_branch_name (name),
  INDEX idx_branch_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 3️⃣ HOSTEL BLOCKS, ROOMS & ALLOCATION
-- ========================================

-- Hostel blocks (buildings)
CREATE TABLE IF NOT EXISTS blocks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  block_name VARCHAR(50) NOT NULL UNIQUE,
  total_floors INT,
  warden_id INT,
  description TEXT,
  status ENUM('active', 'maintenance', 'closed') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_block_name (block_name),
  INDEX idx_warden_id (warden_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Rooms in each block
CREATE TABLE IF NOT EXISTS rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  block_id INT NOT NULL,
  room_number VARCHAR(20) NOT NULL,
  floor INT,
  capacity INT NOT NULL DEFAULT 4,
  occupied_count INT NOT NULL DEFAULT 0,
  room_type ENUM('single', 'shared', 'suite') DEFAULT 'shared',
  rent_per_month DECIMAL(10,2),
  amenities TEXT,
  status ENUM('available', 'full', 'maintenance') DEFAULT 'available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (block_id) REFERENCES blocks(id) ON DELETE CASCADE,
  UNIQUE KEY unique_room (block_id, room_number),
  INDEX idx_room_number (room_number),
  INDEX idx_status (status),
  INDEX idx_room_type (room_type),
  
  CHECK (occupied_count <= capacity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Room allocations (student-room mapping)
CREATE TABLE IF NOT EXISTS room_allocations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  room_id INT NOT NULL,
  allocation_date DATE NOT NULL,
  checkout_date DATE,
  status ENUM('active', 'completed', 'transferred') DEFAULT 'active',
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  INDEX idx_student_id (student_id),
  INDEX idx_room_id (room_id),
  INDEX idx_status (status),
  INDEX idx_allocation_date (allocation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Room change requests
CREATE TABLE IF NOT EXISTS room_change_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  current_room_id INT,
  requested_room_id INT,
  requested_block_id INT,
  preference_reason VARCHAR(255),
  full_reason TEXT NOT NULL,
  room_preference VARCHAR(100),
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  approved_by INT,
  approved_at TIMESTAMP NULL,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (current_room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  FOREIGN KEY (requested_room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  FOREIGN KEY (requested_block_id) REFERENCES blocks(id) ON DELETE SET NULL,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_status (status),
  INDEX idx_current_room (current_room_id),
  INDEX idx_requested_room (requested_room_id),
  INDEX requested_block_id (requested_block_id),
  INDEX approved_by (approved_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 4️⃣ OUTPASS MANAGEMENT
-- ========================================

-- Student outpass requests and tracking
CREATE TABLE IF NOT EXISTS outpasses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  reason VARCHAR(255) NOT NULL,
  destination VARCHAR(255),
  out_date DATE NOT NULL,
  out_time TIME NOT NULL,
  expected_return_time DATETIME NOT NULL,
  actual_return_time DATETIME,
  status ENUM('pending', 'approved', 'rejected', 'exited', 'returned', 'overdue') DEFAULT 'pending',
  approved_by INT,
  approved_at TIMESTAMP NULL,
  rejection_reason TEXT,
  emergency_contact VARCHAR(20),
  parent_consent ENUM('yes', 'no', 'not_required') DEFAULT 'not_required',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  actual_exit_time DATETIME,
  is_overdue TINYINT(1) DEFAULT 0,
  late_minutes INT DEFAULT 0,
  grace_period_applied TINYINT(1) DEFAULT 0,
  exit_logged_by INT,
  return_logged_by INT,
  security_notes TEXT,
  monitor_state ENUM('on_time', 'grace_period', 'overdue') DEFAULT 'on_time',
  risk_level ENUM('low', 'medium', 'high') DEFAULT 'low',
  overdue_alert_sent_student TINYINT(1) DEFAULT 0,
  overdue_alert_sent_parent TINYINT(1) DEFAULT 0,
  overdue_notified_at DATETIME NULL,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (exit_logged_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (return_logged_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_status (status),
  INDEX idx_out_date (out_date),
  INDEX idx_approved_by (approved_by),
  INDEX idx_monitor_state (monitor_state),
  INDEX idx_outpass_risk_level (risk_level),
  INDEX fk_exit_logged_by (exit_logged_by),
  INDEX fk_return_logged_by (return_logged_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 5️⃣ COLLEGE LEAVE REQUESTS
-- ========================================

-- Leave applications from students
CREATE TABLE IF NOT EXISTS leave_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  leave_type ENUM('medical', 'personal', 'family_emergency', 'vacation', 'other') NOT NULL,
  leave_reason TEXT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  total_days INT NOT NULL,
  status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',
  approved_by INT,
  approved_at TIMESTAMP NULL,
  rejection_reason TEXT,
  supporting_documents VARCHAR(255),
  emergency_contact VARCHAR(20),
  destination VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_status (status),
  INDEX idx_from_date (from_date),
  INDEX idx_leave_type (leave_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- College leave requests (additional flow)
CREATE TABLE IF NOT EXISTS college_leaves (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  user_id INT NOT NULL,
  reason VARCHAR(255) NOT NULL,
  reason_code ENUM('sick', 'personal_work', 'assignment', 'health_issue', 'family_work', 'other') DEFAULT 'other',
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  total_days INT NOT NULL,
  status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',
  approved_by INT,
  approved_at TIMESTAMP NULL,
  rejection_reason TEXT,
  faculty_notified TINYINT(1) DEFAULT 0,
  faculty_notified_at TIMESTAMP NULL,
  hostel_stay_confirmed TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_from_date (from_date),
  INDEX idx_to_date (to_date),
  INDEX idx_created_at (created_at),
  INDEX idx_approved_by (approved_by),
  INDEX idx_reason_code (reason_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Leave monitoring and alerts
CREATE TABLE IF NOT EXISTS leave_monitoring (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  leave_type VARCHAR(50) DEFAULT 'college_leave',
  leave_count_last_30_days INT DEFAULT 0,
  leave_count_last_60_days INT DEFAULT 0,
  leave_count_last_90_days INT DEFAULT 0,
  leave_count_this_semester INT DEFAULT 0,
  average_days_per_leave FLOAT DEFAULT 0,
  most_common_reason VARCHAR(50),
  frequency_alert_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
  requires_counseling TINYINT(1) DEFAULT 0,
  requires_medical_review TINYINT(1) DEFAULT 0,
  flagged_by_ai TINYINT(1) DEFAULT 0,
  last_updated TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  UNIQUE KEY unique_student (student_id),
  INDEX idx_frequency_alert (frequency_alert_level),
  INDEX idx_flagged (flagged_by_ai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS leave_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  alert_type ENUM('high_frequency', 'unusual_pattern', 'medical_concern', 'behavioral_flag') DEFAULT 'high_frequency',
  alert_message TEXT,
  alert_level ENUM('warning', 'alert', 'critical') DEFAULT 'warning',
  suggested_action VARCHAR(255),
  action_taken VARCHAR(500),
  action_taken_by INT,
  action_taken_at TIMESTAMP NULL,
  status ENUM('pending', 'acknowledged', 'resolved') DEFAULT 'pending',
  assigned_to INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP NULL,

  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (action_taken_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_status (status),
  INDEX idx_alert_type (alert_type),
  INDEX idx_alert_level (alert_level),
  INDEX idx_created_at (created_at),
  INDEX action_taken_by (action_taken_by),
  INDEX assigned_to (assigned_to)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 6️⃣ COMPLAINTS & MAINTENANCE
-- ========================================

-- Student complaints and maintenance requests
CREATE TABLE IF NOT EXISTS complaints (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  block_id INT,
  category ENUM('electrical', 'plumbing', 'carpentry', 'hvac', 'wifi', 'furniture', 'internet', 'cleaning', 'security', 'other') NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  location VARCHAR(255),
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  status ENUM('pending', 'assigned', 'in_progress', 'resolved', 'closed', 'cancelled') DEFAULT 'pending',
  assigned_technician_id INT,
  assigned_at TIMESTAMP NULL,
  resolved_at TIMESTAMP NULL,
  resolution_notes TEXT,
  rating INT,
  feedback TEXT,
  attachments VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (block_id) REFERENCES blocks(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_technician_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_block_id (block_id),
  INDEX idx_status (status),
  INDEX idx_category (category),
  INDEX idx_priority (priority),
  INDEX idx_assigned_technician (assigned_technician_id),
  
  CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Complaint status history (tracking)
CREATE TABLE IF NOT EXISTS complaint_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  complaint_id INT NOT NULL,
  old_status VARCHAR(50),
  new_status VARCHAR(50),
  changed_by INT,
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_complaint_id (complaint_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 7️⃣ TECHNICIANS
-- ========================================

-- Technician/maintenance staff details
CREATE TABLE IF NOT EXISTS technicians (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNIQUE NOT NULL,
  employee_id VARCHAR(50) UNIQUE NOT NULL,
  specialization VARCHAR(100),
  phone VARCHAR(20) NOT NULL,
  alternate_phone VARCHAR(20),
  shift_timing VARCHAR(50),
  availability_status ENUM('available', 'busy', 'on_leave', 'off_duty') DEFAULT 'available',
  expertise_areas TEXT,
  assigned_blocks TEXT,
  rating DECIMAL(3,2),
  total_complaints_resolved INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_employee_id (employee_id),
  INDEX idx_specialization (specialization),
  INDEX idx_availability (availability_status),
  
  CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 8️⃣ PARCEL MANAGEMENT
-- ========================================

-- Incoming parcels for students
CREATE TABLE IF NOT EXISTS parcels (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  tracking_number VARCHAR(100) UNIQUE,
  courier_name VARCHAR(100),
  sender_name VARCHAR(100),
  sender_contact VARCHAR(20),
  parcel_type ENUM('document', 'package', 'box', 'other') DEFAULT 'package',
  weight DECIMAL(10,2),
  received_date DATE NOT NULL,
  received_time TIME NOT NULL,
  received_by INT,
  status ENUM('received', 'notified', 'collected', 'returned') DEFAULT 'received',
  collection_date DATETIME,
  collected_by VARCHAR(100),
  collector_id_proof VARCHAR(50),
  storage_location VARCHAR(50),
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_tracking_number (tracking_number),
  INDEX idx_status (status),
  INDEX idx_received_date (received_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 9️⃣ VISITOR MANAGEMENT
-- ========================================

-- Visitor entry and tracking
CREATE TABLE IF NOT EXISTS visitors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  visitor_name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  id_type ENUM('aadhar', 'pan', 'driving_license', 'voter_id', 'other') NOT NULL,
  id_number VARCHAR(50) NOT NULL,
  student_id INT NOT NULL,
  relationship VARCHAR(50),
  purpose VARCHAR(255),
  entry_time DATETIME NOT NULL,
  exit_time DATETIME,
  status ENUM('inside', 'exited', 'overstayed') DEFAULT 'inside',
  approved_by INT,
  vehicle_number VARCHAR(20),
  items_carried TEXT,
  security_guard_id INT,
  photo_captured ENUM('yes', 'no') DEFAULT 'no',
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (security_guard_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_status (status),
  INDEX idx_entry_time (entry_time),
  INDEX idx_id_number (id_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 🔟 SECURITY LOGS
-- ========================================

-- Activity logs maintained by security personnel
CREATE TABLE IF NOT EXISTS security_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  activity_type ENUM('outpass', 'visitor', 'parcel', 'incident', 'patrol', 'emergency', 'other') NOT NULL,
  description TEXT NOT NULL,
  related_student_id INT,
  related_visitor_id INT,
  related_outpass_id INT,
  severity ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
  location VARCHAR(100),
  logged_by INT NOT NULL,
  action_taken TEXT,
  follow_up_required ENUM('yes', 'no') DEFAULT 'no',
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (related_student_id) REFERENCES students(id) ON DELETE SET NULL,
  FOREIGN KEY (related_visitor_id) REFERENCES visitors(id) ON DELETE SET NULL,
  FOREIGN KEY (related_outpass_id) REFERENCES outpasses(id) ON DELETE SET NULL,
  FOREIGN KEY (logged_by) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_activity_type (activity_type),
  INDEX idx_timestamp (timestamp),
  INDEX idx_severity (severity),
  INDEX idx_logged_by (logged_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- ADDITIONAL SUPPORTING TABLES
-- ========================================

-- Warden details
CREATE TABLE IF NOT EXISTS wardens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNIQUE NOT NULL,
  employee_id VARCHAR(50) UNIQUE NOT NULL,
  hostel_block VARCHAR(50),
  phone VARCHAR(20) NOT NULL,
  office_location VARCHAR(100),
  designation VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_employee_id (employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Security personnel details
CREATE TABLE IF NOT EXISTS security_personnel (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNIQUE NOT NULL,
  employee_id VARCHAR(50) UNIQUE NOT NULL,
  shift_timing VARCHAR(50),
  gate_assigned VARCHAR(50),
  phone VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_employee_id (employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Mess menu (optional)
CREATE TABLE IF NOT EXISTS mess_menu (
  id INT AUTO_INCREMENT PRIMARY KEY,
  day_of_week ENUM('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday') NOT NULL,
  meal_type ENUM('breakfast', 'lunch', 'snacks', 'dinner') NOT NULL,
  menu_items TEXT NOT NULL,
  special_notes TEXT,
  effective_from DATE,
  effective_to DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_day_of_week (day_of_week),
  INDEX idx_meal_type (meal_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  notification_type ENUM('info', 'warning', 'alert', 'reminder', 'announcement') DEFAULT 'info',
  related_module VARCHAR(50),
  related_id INT,
  is_read ENUM('yes', 'no') DEFAULT 'no',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_is_read (is_read),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- ADD FOREIGN KEY TO STUDENTS TABLE
-- ========================================

-- Add foreign key constraint for room_id in students table
ALTER TABLE students 
  ADD CONSTRAINT fk_student_room 
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL;

-- ========================================
-- DEMO DATA (For Testing)
-- ========================================

-- Insert demo users (passwords should be hashed by backend)
-- These will be created via /api/create-demo-users endpoint

-- Demo Login Credentials:
-- Student:     student@hostel.edu     / student123
-- Warden:      warden@hostel.edu      / warden123
-- Admin:       admin@hostel.edu       / admin123
-- Technician:  technician@hostel.edu  / tech123
-- Security:    security@hostel.edu    / security123

-- Insert sample hostel blocks
INSERT INTO blocks (block_name, total_floors, description, status) VALUES
('Block A', 4, 'Boys Hostel - Main Block', 'active'),
('Block B', 4, 'Boys Hostel - Annexe', 'active'),
('Block C', 3, 'Girls Hostel', 'active');

-- Insert sample rooms
INSERT INTO rooms (block_id, room_number, floor, capacity, occupied_count, room_type, rent_per_month, status) VALUES
(1, '101', 1, 2, 0, 'shared', 5000.00, 'available'),
(1, '102', 1, 2, 0, 'shared', 5000.00, 'available'),
(1, '103', 1, 1, 0, 'single', 8000.00, 'available'),
(1, '201', 2, 2, 0, 'shared', 5000.00, 'available'),
(1, '202', 2, 2, 0, 'shared', 5000.00, 'available'),
(2, '101', 1, 2, 0, 'shared', 5000.00, 'available'),
(2, '102', 1, 2, 0, 'shared', 5000.00, 'available'),
(3, '101', 1, 2, 0, 'shared', 5500.00, 'available'),
(3, '102', 1, 1, 0, 'single', 8500.00, 'available');

-- ========================================
-- VIEWS (For Quick Access)
-- ========================================

-- Active students with room details
CREATE OR REPLACE VIEW vw_active_students AS
SELECT 
  s.id,
  s.roll_number,
  u.name,
  u.email,
  s.branch,
  s.year,
  r.room_number,
  b.block_name,
  s.fee_status,
  s.phone
FROM students s
JOIN users u ON s.user_id = u.id
LEFT JOIN rooms r ON s.room_id = r.id
LEFT JOIN blocks b ON r.block_id = b.id
WHERE u.status = 'active';

-- Pending outpasses
CREATE OR REPLACE VIEW vw_pending_outpasses AS
SELECT 
  o.id,
  o.student_id,
  s.roll_number,
  u.name AS student_name,
  o.reason,
  o.destination,
  o.expected_return_time,
  o.created_at
FROM outpasses o
JOIN students s ON o.student_id = s.id
JOIN users u ON s.user_id = u.id
WHERE o.status = 'pending'
ORDER BY o.created_at DESC;

-- Active complaints
CREATE OR REPLACE VIEW vw_active_complaints AS
SELECT 
  c.id,
  c.category,
  c.title,
  c.priority,
  c.status,
  s.roll_number,
  u.name AS student_name,
  t.name AS technician_name,
  c.created_at
FROM complaints c
JOIN students st ON c.student_id = st.id
JOIN users u ON st.user_id = u.id
LEFT JOIN users t ON c.assigned_technician_id = t.id
WHERE c.status IN ('pending', 'assigned', 'in_progress')
ORDER BY c.priority DESC, c.created_at ASC;

-- ========================================
-- END OF SCHEMA
-- ========================================
