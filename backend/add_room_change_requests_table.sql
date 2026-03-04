-- Add room_change_requests table
USE hostelconnect_db;

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
  INDEX idx_requested_room (requested_room_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
