-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: hostelconnect_db
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ai_action_logs`
--

DROP TABLE IF EXISTS `ai_action_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_action_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `alert_id` int NOT NULL,
  `action_type` varchar(100) NOT NULL,
  `action_description` text,
  `performed_by` int NOT NULL,
  `performed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `outcome` text,
  PRIMARY KEY (`id`),
  KEY `idx_alert_id` (`alert_id`),
  KEY `idx_performed_by` (`performed_by`),
  CONSTRAINT `ai_action_logs_ibfk_1` FOREIGN KEY (`alert_id`) REFERENCES `ai_outpass_alerts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ai_action_logs_ibfk_2` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_action_logs`
--

LOCK TABLES `ai_action_logs` WRITE;
/*!40000 ALTER TABLE `ai_action_logs` DISABLE KEYS */;
INSERT INTO `ai_action_logs` VALUES (1,5,'send_reminder','SMS reminder sent to student',1,'2026-02-15 17:37:42','SMS successfully delivered. Message: \"Please return to hostel immediately. Your outpass has expired.\"');
/*!40000 ALTER TABLE `ai_action_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_alert_rules`
--

DROP TABLE IF EXISTS `ai_alert_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_alert_rules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `alert_id` int NOT NULL,
  `rule_name` varchar(100) NOT NULL,
  `rule_description` text,
  `threshold_value` varchar(50) DEFAULT NULL,
  `actual_value` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_alert_id` (`alert_id`),
  CONSTRAINT `ai_alert_rules_ibfk_1` FOREIGN KEY (`alert_id`) REFERENCES `ai_alerts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_alert_rules`
--

LOCK TABLES `ai_alert_rules` WRITE;
/*!40000 ALTER TABLE `ai_alert_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_alert_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_alerts`
--

DROP TABLE IF EXISTS `ai_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `alert_type` enum('late_return','repeated_leave','complaint_delay','suspicious_pattern','safety_concern','policy_violation') NOT NULL,
  `risk_level` enum('low','medium','high') NOT NULL,
  `related_user_id` int DEFAULT NULL,
  `related_student_id` int DEFAULT NULL,
  `related_outpass_id` int DEFAULT NULL,
  `related_complaint_id` int DEFAULT NULL,
  `related_visitor_id` int DEFAULT NULL,
  `message` varchar(255) NOT NULL,
  `explanation` text NOT NULL,
  `confidence_score` decimal(4,3) DEFAULT NULL,
  `agent_name` varchar(100) DEFAULT NULL,
  `suggested_action` text,
  `status` enum('active','acknowledged','resolved','dismissed') DEFAULT 'active',
  `acknowledged_by` int DEFAULT NULL,
  `acknowledged_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `related_user_id` (`related_user_id`),
  KEY `related_student_id` (`related_student_id`),
  KEY `related_outpass_id` (`related_outpass_id`),
  KEY `related_complaint_id` (`related_complaint_id`),
  KEY `related_visitor_id` (`related_visitor_id`),
  KEY `acknowledged_by` (`acknowledged_by`),
  KEY `idx_alert_type` (`alert_type`),
  KEY `idx_risk_level` (`risk_level`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `ai_alerts_ibfk_1` FOREIGN KEY (`related_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ai_alerts_ibfk_2` FOREIGN KEY (`related_student_id`) REFERENCES `students` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ai_alerts_ibfk_3` FOREIGN KEY (`related_outpass_id`) REFERENCES `outpasses` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ai_alerts_ibfk_4` FOREIGN KEY (`related_complaint_id`) REFERENCES `complaints` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ai_alerts_ibfk_5` FOREIGN KEY (`related_visitor_id`) REFERENCES `visitors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ai_alerts_ibfk_6` FOREIGN KEY (`acknowledged_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ai_alerts_chk_1` CHECK (((`confidence_score` is null) or ((`confidence_score` >= 0) and (`confidence_score` <= 1))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_alerts`
--

LOCK TABLES `ai_alerts` WRITE;
/*!40000 ALTER TABLE `ai_alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_learning_patterns`
--

DROP TABLE IF EXISTS `ai_learning_patterns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_learning_patterns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pattern_type` varchar(100) NOT NULL,
  `pattern_data` json NOT NULL,
  `occurrence_count` int DEFAULT '1',
  `accuracy_score` decimal(5,2) DEFAULT '0.00',
  `first_detected` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_detected` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_pattern_type` (`pattern_type`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_learning_patterns`
--

LOCK TABLES `ai_learning_patterns` WRITE;
/*!40000 ALTER TABLE `ai_learning_patterns` DISABLE KEYS */;
INSERT INTO `ai_learning_patterns` VALUES (1,'grace_period','{\"minutes\": 30, \"description\": \"Standard grace period for late returns\"}',1,0.00,'2026-02-15 18:09:04','2026-02-15 18:09:04',1),(2,'high_frequency_threshold','{\"description\": \"High frequency outpass threshold\", \"outpasses_per_week\": 3}',1,0.00,'2026-02-15 18:09:04','2026-02-15 18:09:04',1),(3,'repeat_late_threshold','{\"late_count\": 3, \"description\": \"Repeated late pattern detection\", \"period_days\": 30}',1,0.00,'2026-02-15 18:09:04','2026-02-15 18:09:04',1),(4,'no_exit_timeout','{\"hours\": 2, \"description\": \"Hours after approval to detect no-exit\"}',1,0.00,'2026-02-15 18:09:04','2026-02-15 18:09:04',1);
/*!40000 ALTER TABLE `ai_learning_patterns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_outpass_alerts`
--

DROP TABLE IF EXISTS `ai_outpass_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_outpass_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `outpass_id` int NOT NULL,
  `student_id` int NOT NULL,
  `alert_type` enum('late_return','no_exit','frequent_outpass','repeated_late','suspicious_pattern') NOT NULL,
  `risk_level` enum('low','medium','high','critical') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `recommended_actions` json NOT NULL,
  `context_data` json DEFAULT NULL,
  `status` enum('pending','acknowledged','action_taken','resolved','dismissed') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `acknowledged_at` timestamp NULL DEFAULT NULL,
  `acknowledged_by` int DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` text,
  PRIMARY KEY (`id`),
  KEY `idx_outpass_id` (`outpass_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_risk_level` (`risk_level`),
  KEY `idx_created_at` (`created_at`),
  KEY `acknowledged_by` (`acknowledged_by`),
  CONSTRAINT `ai_outpass_alerts_ibfk_1` FOREIGN KEY (`outpass_id`) REFERENCES `outpasses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ai_outpass_alerts_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ai_outpass_alerts_ibfk_3` FOREIGN KEY (`acknowledged_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_outpass_alerts`
--

LOCK TABLES `ai_outpass_alerts` WRITE;
/*!40000 ALTER TABLE `ai_outpass_alerts` DISABLE KEYS */;
INSERT INTO `ai_outpass_alerts` VALUES (1,9,1,'late_return','high','⚠️ Late Return Detected: Rajesh Kumar','Rajesh Kumar (CS2021049) has not returned 2 hours after expected return time. Expected: 09:52 PM, Current delay: 2 hours.','[{\"label\": \"? Send SMS Reminder\", \"action\": \"send_reminder\", \"priority\": \"high\"}, {\"label\": \"? Call Student\", \"action\": \"call_student\", \"priority\": \"high\"}, {\"label\": \"?‍?‍? Notify Parent\", \"action\": \"notify_parent\", \"priority\": \"medium\"}]','{\"delay_minutes\": 120, \"last_incident\": \"3 days ago\", \"late_returns_count\": 2, \"total_outpasses_this_month\": 5}','pending','2026-02-15 17:52:42',NULL,NULL,NULL,NULL),(2,10,7,'late_return','critical','? CRITICAL: Severely Delayed Return - CH Sathwik Reddy','Student has been delayed for over 8 hours. Last known location: Home. This is a pattern of repeated late returns.','[{\"label\": \"? Urgent Call Required\", \"action\": \"call_student\", \"priority\": \"high\"}, {\"label\": \"? Emergency Parent Alert\", \"action\": \"notify_parent\", \"priority\": \"high\"}, {\"label\": \"⚠️ Flag for Monitoring\", \"action\": \"mark_flagged\", \"priority\": \"high\"}, {\"label\": \"? Schedule Counseling\", \"action\": \"schedule_meeting\", \"priority\": \"medium\"}]','{\"risk_score\": 85, \"delay_minutes\": 480, \"repeat_offender\": true, \"late_returns_count\": 4, \"total_outpasses_this_month\": 8}','pending','2026-02-15 17:52:42',NULL,NULL,NULL,NULL),(3,11,8,'no_exit','medium','? No Exit Detected: S. Phanindher Reddy','Outpass was approved 3 hours ago but student has not exited the hostel. Destination: Mall. This could indicate a forgotten check-out or possible misuse.','[{\"label\": \"? Remind to Check Out\", \"action\": \"send_reminder\", \"priority\": \"medium\"}, {\"label\": \"❌ Cancel Outpass\", \"action\": \"cancel_outpass\", \"priority\": \"low\"}, {\"label\": \"? Call to Verify\", \"action\": \"call_student\", \"priority\": \"medium\"}]','{\"approval_time\": \"08:52 PM\", \"hours_since_approval\": 3, \"no_exit_incidents_this_month\": 2}','pending','2026-02-15 17:52:42',NULL,NULL,NULL,NULL),(4,13,7,'repeated_late','high','? Pattern Alert: Repeated Late Returns','CH Sathwik Reddy has been late on 4 out of 8 outpasses this month. This indicates a concerning pattern requiring intervention.','[{\"label\": \"? Mandatory Counseling\", \"action\": \"schedule_meeting\", \"priority\": \"high\"}, {\"label\": \"? Restrict Future Outpasses\", \"action\": \"restrict_outpass\", \"priority\": \"medium\"}, {\"label\": \"?‍?‍? Parent Meeting\", \"action\": \"notify_parent\", \"priority\": \"medium\"}]','{\"late_count\": 4, \"late_percentage\": 50, \"total_outpasses\": 8, \"pattern_detected\": \"frequent_late_returns\", \"pattern_duration_days\": 30}','pending','2026-02-15 17:52:42',NULL,NULL,NULL,NULL),(5,9,1,'frequent_outpass','medium','? High Outpass Frequency: Rajesh Kumar','Student has requested 5 outpasses this week, which is above the normal threshold of 3 per week. Monitor for potential misuse or personal issues.','[{\"label\": \"? Send Usage Notice\", \"action\": \"send_reminder\", \"priority\": \"low\"}, {\"label\": \"? Informal Check-in\", \"action\": \"schedule_meeting\", \"priority\": \"medium\"}, {\"label\": \"?️ Monitor Activity\", \"action\": \"mark_flagged\", \"priority\": \"low\"}]','{\"reasons\": [\"Medical\", \"Shopping\", \"Bank\", \"Family\", \"Personal\"], \"threshold\": 3, \"outpasses_this_week\": 5}','acknowledged','2026-02-15 17:52:42','2026-02-15 17:22:42',1,NULL,NULL);
/*!40000 ALTER TABLE `ai_outpass_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_outpass_events`
--

DROP TABLE IF EXISTS `ai_outpass_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_outpass_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `outpass_id` int NOT NULL,
  `event_type` enum('submitted','approved','rejected','exited','returned','overdue','cancelled') NOT NULL,
  `event_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `triggered_by` int DEFAULT NULL,
  `event_data` json DEFAULT NULL,
  `ai_processed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_outpass_id` (`outpass_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_ai_processed` (`ai_processed`),
  KEY `idx_event_timestamp` (`event_timestamp`),
  KEY `triggered_by` (`triggered_by`),
  CONSTRAINT `ai_outpass_events_ibfk_1` FOREIGN KEY (`outpass_id`) REFERENCES `outpasses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ai_outpass_events_ibfk_2` FOREIGN KEY (`triggered_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_outpass_events`
--

LOCK TABLES `ai_outpass_events` WRITE;
/*!40000 ALTER TABLE `ai_outpass_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_outpass_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_student_risk_profiles`
--

DROP TABLE IF EXISTS `ai_student_risk_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_student_risk_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `overall_risk_score` decimal(5,2) DEFAULT '0.00',
  `risk_level` enum('low','medium','high','critical') DEFAULT 'low',
  `total_outpasses` int DEFAULT '0',
  `late_returns_count` int DEFAULT '0',
  `on_time_returns_count` int DEFAULT '0',
  `no_exit_count` int DEFAULT '0',
  `average_delay_minutes` int DEFAULT '0',
  `last_outpass_date` timestamp NULL DEFAULT NULL,
  `last_incident_date` timestamp NULL DEFAULT NULL,
  `behavioral_flags` json DEFAULT NULL,
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_id` (`student_id`),
  KEY `idx_risk_level` (`risk_level`),
  KEY `idx_student_id` (`student_id`),
  CONSTRAINT `ai_student_risk_profiles_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_student_risk_profiles`
--

LOCK TABLES `ai_student_risk_profiles` WRITE;
/*!40000 ALTER TABLE `ai_student_risk_profiles` DISABLE KEYS */;
INSERT INTO `ai_student_risk_profiles` VALUES (1,1,75.50,'high',5,4,1,0,0,NULL,NULL,'[\"repeated_late\", \"high_frequency\"]','2026-02-15 18:22:42'),(2,7,35.00,'medium',8,2,6,0,0,NULL,NULL,'[\"no_exit_pattern\"]','2026-02-15 18:22:42'),(3,8,15.00,'low',5,0,5,0,0,NULL,NULL,'[]','2026-02-15 18:22:42');
/*!40000 ALTER TABLE `ai_student_risk_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `actor_identifier` varchar(255) DEFAULT NULL,
  `actor_role` varchar(50) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `target_type` varchar(100) DEFAULT NULL,
  `target_id` varchar(100) DEFAULT NULL,
  `outcome` enum('success','failure') NOT NULL,
  `details` text,
  `request_id` varchar(64) DEFAULT NULL,
  `ip_address` varchar(64) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_user_id` (`user_id`),
  KEY `idx_audit_action` (`action`),
  KEY `idx_audit_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=191 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,NULL,NULL,NULL,'login',NULL,NULL,'failure','{\"reason\": \"missing_credentials\"}','f0c191edcef78b1b','127.0.0.1','2026-03-09 15:46:58'),(2,NULL,NULL,NULL,'login',NULL,NULL,'failure','{\"reason\": \"missing_credentials\"}','ac728e87506d6319','127.0.0.1','2026-03-09 15:47:39'),(3,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','240afd72e48bdab0','127.0.0.1','2026-03-09 15:47:56'),(4,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','5584a44edeecffc7','127.0.0.1','2026-03-09 15:48:42'),(5,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','3eebceefff2840bd','127.0.0.1','2026-03-09 16:46:44'),(6,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','32af9c88eb4fbbb4','127.0.0.1','2026-03-09 17:09:05'),(7,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','88778e5235c3a201','127.0.0.1','2026-03-09 17:41:46'),(8,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','219556e9e577a285','127.0.0.1','2026-03-11 05:41:38'),(9,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','19a2be64f075cd90','127.0.0.1','2026-03-11 05:44:43'),(10,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','8193104925917d93','127.0.0.1','2026-03-11 06:09:13'),(11,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','2d705ee7f41e8921','127.0.0.1','2026-03-11 06:09:27'),(12,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','175dca359469ab42','127.0.0.1','2026-03-11 06:10:54'),(13,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','a2e5922f01967d6f','127.0.0.1','2026-03-11 06:11:23'),(14,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','a98a69faf2647143','127.0.0.1','2026-03-11 06:12:16'),(15,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','67d0fae6b9dec3a3','127.0.0.1','2026-03-11 06:16:24'),(16,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','10b4e91b23a82879','127.0.0.1','2026-03-11 06:19:03'),(17,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ebc1a1c8fb00b76c','127.0.0.1','2026-03-11 06:19:26'),(18,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','fb4ef093fb0ec538','127.0.0.1','2026-03-11 06:22:00'),(19,26,'tec878','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','29b4a4f181ffdf7f','127.0.0.1','2026-03-11 06:44:36'),(20,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4e81b5278ee3683c','127.0.0.1','2026-03-11 06:45:22'),(21,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0e18d765f8c8ed6d','127.0.0.1','2026-03-11 06:47:30'),(22,26,'tec878','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','200a62072fb68a50','127.0.0.1','2026-03-11 06:47:50'),(23,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','9b2a0c0258608683','127.0.0.1','2026-03-11 06:48:04'),(24,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','1bb60d92191f32a1','127.0.0.1','2026-03-11 12:46:25'),(25,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0ddc4a4dc600737b','127.0.0.1','2026-03-11 12:46:49'),(26,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','030bef37f8203112','127.0.0.1','2026-03-11 12:54:34'),(27,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','224727befc6168dd','127.0.0.1','2026-03-12 08:57:42'),(28,23,'23r21a66j3','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','52ef2f4337df72e5','127.0.0.1','2026-03-12 09:01:07'),(29,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','767dd129f22cbc0c','127.0.0.1','2026-03-12 09:04:54'),(30,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0dca625273530d60','127.0.0.1','2026-03-12 09:11:28'),(31,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','e3778b6be3cfa8f4','127.0.0.1','2026-03-12 09:13:41'),(32,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','b2e63a86febc443a','127.0.0.1','2026-03-12 09:21:30'),(33,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','bd87be4284362905','127.0.0.1','2026-03-12 09:25:29'),(34,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','f3a129df6031b1cb','127.0.0.1','2026-03-12 13:12:10'),(35,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','3662735e0fe24838','127.0.0.1','2026-03-12 13:12:21'),(36,1,'student@hostel.edu','student','login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','7be33427ead2a4be','127.0.0.1','2026-03-12 13:38:31'),(37,1,'student@hostel.edu','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','21b3ae4b5532e457','127.0.0.1','2026-03-12 13:39:59'),(38,3,'admin@hostel.edu','admin','login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','c11a0e3ead94bf1d','127.0.0.1','2026-03-12 13:41:30'),(39,3,'admin@hostel.edu','admin','login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 3}','a320a4e77446646a','127.0.0.1','2026-03-12 13:41:43'),(40,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0034498ba1cd8e7a','127.0.0.1','2026-03-12 13:42:32'),(41,1,'student@hostel.edu','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4449c5e3c176ad23','127.0.0.1','2026-03-12 13:46:24'),(42,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','d04980e0f6763d9f','127.0.0.1','2026-03-12 13:56:26'),(43,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','6e9a51430a4effd9','127.0.0.1','2026-03-12 14:03:20'),(44,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4e9f9b85d05edba3','127.0.0.1','2026-03-12 14:06:16'),(45,1,'student@hostel.edu','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','459460d61455612e','127.0.0.1','2026-03-12 14:08:11'),(46,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ae439d8d62d44920','127.0.0.1','2026-03-12 14:11:19'),(47,NULL,'rajesh@hostel.edu',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','1a95763ca152e03e','127.0.0.1','2026-03-12 14:17:47'),(48,NULL,'rajesh@hostel.edu',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 3}','0c4d01eef7854fca','127.0.0.1','2026-03-12 14:18:27'),(49,NULL,'rajesh@hostel.edu',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 2}','89198ae2f0d38422','127.0.0.1','2026-03-12 14:19:04'),(50,NULL,'rajesh@hostel.edu',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 1}','6fcbf08facd876f7','127.0.0.1','2026-03-12 14:24:25'),(51,NULL,'rajesh@hostel.edu',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 0}','bc400073993fe7fc','127.0.0.1','2026-03-12 14:24:40'),(52,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','e4d2613b18b72dda','127.0.0.1','2026-03-12 14:26:28'),(53,NULL,'rajesh@hostel.edu',NULL,'login',NULL,NULL,'failure','{\"reason\": \"lockout\", \"retry_after_seconds\": 259}','07ca4a4fcc3d2f5a','127.0.0.1','2026-03-12 14:35:20'),(54,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','bc5809e130b17a4a','127.0.0.1','2026-03-12 14:39:03'),(55,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','c72fe8319c5d39fe','127.0.0.1','2026-03-12 14:43:27'),(56,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','993690f9b0d2f1f5','127.0.0.1','2026-03-12 14:46:41'),(57,1,'student@hostel.edu','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','db8807412176fec0','127.0.0.1','2026-03-12 14:50:36'),(58,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','32ada4c0ead08d7b','127.0.0.1','2026-03-12 16:18:57'),(59,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','a07e0b8bef9a5322','127.0.0.1','2026-03-12 16:19:05'),(60,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','705ac0781cab9c6b','127.0.0.1','2026-03-12 16:19:13'),(61,NULL,'23r1a66j3',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','de71bc397a2b8a24','127.0.0.1','2026-03-12 16:23:00'),(62,NULL,'23r1a66j3',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 3}','23e3774c0f4c84c6','127.0.0.1','2026-03-12 16:23:07'),(63,23,'23r21a66j3','student','login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','5f73ae68d81e4d81','127.0.0.1','2026-03-12 16:23:35'),(64,23,'23r21a66j3','student','login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 3}','1e99fd9f81b32fcd','127.0.0.1','2026-03-12 16:23:49'),(65,37,'23r21a66f6','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','b9b1ede704372a93','127.0.0.1','2026-03-12 16:24:03'),(66,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','d583c0d8f93f4a40','127.0.0.1','2026-03-12 18:26:41'),(67,1,'student@hostel.edu','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','fc9b991acaf48a90','127.0.0.1','2026-03-12 18:55:26'),(68,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','e1e4468f8df34e88','127.0.0.1','2026-03-12 18:55:32'),(69,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','e4d0a56e451d3884','127.0.0.1','2026-03-12 18:55:45'),(70,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','d8a40fc096b4bd15','127.0.0.1','2026-03-12 18:56:16'),(71,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','855c4d70b7112149','127.0.0.1','2026-03-12 18:56:59'),(72,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','e9c21545f10ecef0','127.0.0.1','2026-03-12 18:58:36'),(73,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','01c24ecf11de02eb','127.0.0.1','2026-03-13 06:57:14'),(74,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','f78ce06576dff6a7','127.0.0.1','2026-03-13 07:00:09'),(75,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','6d740c3aeb884c11','127.0.0.1','2026-03-13 07:02:12'),(76,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','30a25c4c9d5b10b7','127.0.0.1','2026-03-13 07:03:58'),(77,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','93d0c2bb90621c6b','127.0.0.1','2026-03-13 07:07:16'),(78,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','88bf01af4a2cfa3c','127.0.0.1','2026-03-13 07:25:41'),(79,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','b3bba8b10d1872ff','127.0.0.1','2026-03-13 07:29:51'),(80,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ceb6965c6998e757','127.0.0.1','2026-03-13 07:34:32'),(81,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','db5e2fca6a4d9f08','127.0.0.1','2026-03-13 07:34:39'),(82,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','c6af1f6b3dd7a351','127.0.0.1','2026-03-13 08:22:24'),(83,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','53b6ac82dd4c588a','127.0.0.1','2026-03-13 09:06:12'),(84,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','124a6ac8f581511e','127.0.0.1','2026-03-13 09:06:29'),(85,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','7d784866eeba13f2','127.0.0.1','2026-03-13 09:06:42'),(86,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','e5f9b3e2654096b3','127.0.0.1','2026-03-13 09:29:14'),(87,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','a46eb5a2579db5dd','127.0.0.1','2026-03-13 09:29:39'),(88,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','efe70dbce3b6a1ff','127.0.0.1','2026-03-13 09:29:50'),(89,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4205e401dbc306c7','127.0.0.1','2026-03-13 09:55:14'),(90,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','5d70dfbac49afce2','127.0.0.1','2026-03-13 09:56:07'),(91,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','94a03ff40d0ef9ba','127.0.0.1','2026-03-13 11:07:08'),(92,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','1569e32e3da64976','127.0.0.1','2026-03-13 11:08:12'),(93,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','b5e991bf6fd78e28','127.0.0.1','2026-03-13 11:13:42'),(94,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','43241ee11f70a833','127.0.0.1','2026-03-13 11:14:08'),(95,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','c51f8f1248d3da71','127.0.0.1','2026-03-13 11:21:59'),(96,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','aaaad6c5ea31a6b9','127.0.0.1','2026-03-13 11:22:17'),(97,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','895da5a975cc0fca','127.0.0.1','2026-03-13 11:22:23'),(98,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','9ec1ed3dc3cd3b5c','127.0.0.1','2026-03-13 18:30:05'),(99,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','66396c40d1e306e7','127.0.0.1','2026-03-13 19:08:59'),(100,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','955db0df8d5e25a0','127.0.0.1','2026-03-13 19:29:37'),(101,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','cc4d477e8a9ab306','127.0.0.1','2026-03-13 19:46:11'),(102,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','8aef1fdfabc1ce52','127.0.0.1','2026-03-13 19:53:32'),(103,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','e1e4bb308b8eef6c','127.0.0.1','2026-03-13 20:04:03'),(104,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ca2a1fc538730e56','127.0.0.1','2026-03-13 20:11:43'),(105,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','9d8c18789b84818b','127.0.0.1','2026-03-13 20:17:00'),(106,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ac6adaf929cc2086','127.0.0.1','2026-03-13 20:18:08'),(107,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','66acc3833c55f04e','127.0.0.1','2026-03-13 20:37:09'),(108,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','f4eacf3efd41329d','127.0.0.1','2026-03-13 20:37:40'),(109,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0685d479fb8a85f8','127.0.0.1','2026-03-13 20:45:24'),(110,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','f3160c5ce562855a','127.0.0.1','2026-03-13 20:45:40'),(111,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','c8e8dedc78c4dccc','127.0.0.1','2026-03-14 04:08:01'),(112,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','f43d426200b7c589','127.0.0.1','2026-03-14 04:24:09'),(113,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','6867c8e42971fa70','127.0.0.1','2026-03-14 04:35:53'),(114,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','eca0654d9f95024a','127.0.0.1','2026-03-14 04:37:03'),(115,27,'tec298','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','8775ef71ebe937dc','127.0.0.1','2026-03-14 05:01:50'),(116,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ef2984c61159e7b9','127.0.0.1','2026-03-14 05:02:03'),(117,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','fa850faa7314f4fc','127.0.0.1','2026-03-14 05:20:00'),(118,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 3}','819e72724cca921d','127.0.0.1','2026-03-14 05:20:21'),(119,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 2}','6e713d93431ebe9d','127.0.0.1','2026-03-14 05:20:40'),(120,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','225b88a10f2efbfa','127.0.0.1','2026-03-14 05:28:10'),(121,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 1}','aad14a3a528d909e','127.0.0.1','2026-03-14 05:28:41'),(122,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 0}','624fcdff5fa7dd91','127.0.0.1','2026-03-14 05:28:42'),(123,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"lockout\", \"retry_after_seconds\": 899}','9d6d31c6b5f1c5c0','127.0.0.1','2026-03-14 05:28:42'),(124,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"lockout\", \"retry_after_seconds\": 866}','9592be68435f213e','127.0.0.1','2026-03-14 05:29:15'),(125,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"lockout\", \"retry_after_seconds\": 839}','6bf77c66bd0f066c','127.0.0.1','2026-03-14 05:29:42'),(126,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"lockout\", \"retry_after_seconds\": 836}','a90b893670cc0a55','127.0.0.1','2026-03-14 05:29:45'),(127,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"lockout\", \"retry_after_seconds\": 835}','77c2638190e4dc3d','127.0.0.1','2026-03-14 05:29:46'),(128,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"lockout\", \"retry_after_seconds\": 835}','b2c85ab722664e66','127.0.0.1','2026-03-14 05:29:46'),(129,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','5989b13512a1b3e8','127.0.0.1','2026-03-14 05:31:24'),(130,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 3}','09dda991faf9fabb','127.0.0.1','2026-03-14 05:31:56'),(131,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','1f0c37bd578ae6e3','127.0.0.1','2026-03-14 05:32:05'),(132,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 2}','2404e0fcb340589e','127.0.0.1','2026-03-14 05:32:54'),(133,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','a43e27ddd05aa079','127.0.0.1','2026-03-14 05:32:58'),(134,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 4}','eb2f45bbbe618895','127.0.0.1','2026-03-14 05:35:07'),(135,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','058900d475878c18','127.0.0.1','2026-03-14 05:35:11'),(136,NULL,'23r21a66j1',NULL,'login',NULL,NULL,'failure','{\"reason\": \"invalid_credentials\", \"remaining_attempts\": 3}','8056e96f45f879bc','127.0.0.1','2026-03-14 05:35:51'),(137,36,'23r21a66j1','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4512c42b7042f721','127.0.0.1','2026-03-14 05:38:40'),(138,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','df2b3836c4d5cc3c','127.0.0.1','2026-03-14 05:38:49'),(139,24,'tec116','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','594e3446d45e0553','127.0.0.1','2026-03-14 05:48:05'),(140,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','1be29d6963a420fc','127.0.0.1','2026-03-14 05:48:31'),(141,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4e8b14a6a6aca7a4','127.0.0.1','2026-03-14 05:54:49'),(142,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','08ae9462dc2a348e','127.0.0.1','2026-03-14 05:56:20'),(143,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','eb9a449b78b552bf','127.0.0.1','2026-03-14 06:01:42'),(144,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4e97345591d873a5','127.0.0.1','2026-03-14 06:08:45'),(145,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0758d98667b16a52','127.0.0.1','2026-03-14 06:08:59'),(146,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','bdba33c23400c22a','127.0.0.1','2026-03-14 06:09:05'),(147,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','9dee908441575d66','127.0.0.1','2026-03-14 06:11:45'),(148,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','3168d5d62b23d4c2','127.0.0.1','2026-03-14 06:12:48'),(149,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','256c03f320e15ded','127.0.0.1','2026-03-14 06:16:31'),(150,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','6fa320a8bbcf6970','127.0.0.1','2026-03-14 06:24:33'),(151,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','5ae37dd735a5e485','127.0.0.1','2026-03-14 06:45:48'),(152,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','9c09e657f0f8983e','127.0.0.1','2026-03-14 06:45:57'),(153,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ad0e559358676f78','127.0.0.1','2026-03-14 06:46:35'),(154,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','5ccb85dd1d49fb91','127.0.0.1','2026-03-14 06:57:54'),(155,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0adf040b7761d95b','127.0.0.1','2026-03-14 06:58:04'),(156,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','88d3244355f0a512','127.0.0.1','2026-03-14 06:58:14'),(157,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','bfb44ef89160186a','127.0.0.1','2026-03-14 06:58:53'),(158,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','eb39f2d94285c146','127.0.0.1','2026-03-14 07:01:20'),(159,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','da60597327997c69','127.0.0.1','2026-03-14 07:01:31'),(160,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','8c97f6bf9b16ebca','127.0.0.1','2026-03-14 07:01:44'),(161,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','42bef6cbeae5bb38','127.0.0.1','2026-03-14 07:02:14'),(162,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','a8b0e8b77536e6af','127.0.0.1','2026-03-14 07:02:26'),(163,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','31707f30bc8f8840','127.0.0.1','2026-03-14 07:02:42'),(164,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','04dde49ebc16c66c','127.0.0.1','2026-03-14 07:03:10'),(165,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','692e3716ea27d3dc','127.0.0.1','2026-03-14 07:10:04'),(166,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','1784b2689b65f4f6','127.0.0.1','2026-03-14 07:10:25'),(167,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','4d1362b52147af02','127.0.0.1','2026-03-14 07:44:36'),(168,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','d76ab3ef2523eb2b','127.0.0.1','2026-03-14 07:44:56'),(169,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','dd6ad43beac56bdc','127.0.0.1','2026-03-14 08:02:44'),(170,4,'technician@hostel.edu','technician','login',NULL,NULL,'success','{\"login_method\": \"password\"}','a4ae202083b5f3c2','127.0.0.1','2026-03-14 08:05:29'),(171,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','b8c3b2b5f587929c','127.0.0.1','2026-03-14 08:10:58'),(172,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ae345cc9e514d7dc','127.0.0.1','2026-03-14 08:13:04'),(173,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','9678341a9d3f2651','127.0.0.1','2026-03-14 08:14:15'),(174,5,'security@hostel.edu','security','login',NULL,NULL,'success','{\"login_method\": \"password\"}','ad571d15e3ac9494','127.0.0.1','2026-03-14 08:18:25'),(175,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','7ea55e67ce0d3766','127.0.0.1','2026-03-14 08:30:44'),(176,3,'admin@hostel.edu','admin','login',NULL,NULL,'success','{\"login_method\": \"password\"}','618ac9897e200c4a','127.0.0.1','2026-03-14 08:38:51'),(177,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','90d173b882c7fdb3','127.0.0.1','2026-03-14 09:39:30'),(178,2,'warden@hostel.edu','warden','login',NULL,NULL,'success','{\"login_method\": \"password\"}','0dade70abe882952','127.0.0.1','2026-03-14 09:42:46'),(179,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','f59940780c8d616e','127.0.0.1','2026-03-14 09:44:07'),(180,NULL,NULL,NULL,'outpass_otp_send','outpass','20','failure','{\"reason\": \"parent_email_missing\"}','b3c90bf34881b78b','127.0.0.1','2026-03-14 09:44:59'),(181,37,'23r21a66f6','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','18e25564062a45fb','127.0.0.1','2026-03-14 09:45:19'),(182,NULL,NULL,NULL,'outpass_otp_send','outpass','21','failure','{\"reason\": \"rate_limited\", \"retry_after_seconds\": 117}','e0e659a334ec08c1','127.0.0.1','2026-03-14 09:46:09'),(183,NULL,NULL,NULL,'outpass_otp_send','outpass','20','failure','{\"reason\": \"parent_email_missing\"}','fda4b7d7b502a28d','127.0.0.1','2026-03-14 09:50:03'),(184,NULL,NULL,NULL,'outpass_otp_send','outpass','21','success','{\"email_sent\": true, \"parent_email\": \"nikhilkanneboina206@gmail.com\"}','8bb53f291a37a070','127.0.0.1','2026-03-14 09:50:08'),(185,NULL,NULL,NULL,'outpass_otp_send','outpass','20','failure','{\"reason\": \"parent_email_missing\"}','c4ad04ae93a01b19','127.0.0.1','2026-03-14 09:50:14'),(186,NULL,NULL,NULL,'outpass_otp_send','outpass','20','failure','{\"reason\": \"parent_email_missing\"}','79bca6d3d5273cb7','127.0.0.1','2026-03-14 09:50:18'),(187,NULL,NULL,NULL,'outpass_otp_verify','outpass','21','failure','{\"reason\": \"otp_expired\"}','e847d62209f316ed','127.0.0.1','2026-03-14 10:24:41'),(188,NULL,NULL,NULL,'outpass_otp_send','outpass','21','success','{\"email_sent\": true, \"parent_email\": \"nikhilkanneboina206@gmail.com\"}','41ae121fdd299e97','127.0.0.1','2026-03-14 10:27:17'),(189,NULL,NULL,NULL,'outpass_otp_verify','outpass','21','success','{\"status\": \"approved_otp\"}','3d6d8853825073b2','127.0.0.1','2026-03-14 10:27:42'),(190,22,'23r21a6675','student','login',NULL,NULL,'success','{\"login_method\": \"password\"}','351b04c6df375228','127.0.0.1','2026-03-14 10:34:49');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocks`
--

DROP TABLE IF EXISTS `blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blocks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `block_name` varchar(50) NOT NULL,
  `block_gender` enum('male','female') NOT NULL,
  `total_floors` int DEFAULT NULL,
  `warden_id` int DEFAULT NULL,
  `description` text,
  `status` enum('active','maintenance','closed') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `block_name` (`block_name`),
  KEY `idx_block_name` (`block_name`),
  KEY `idx_warden_id` (`warden_id`),
  KEY `idx_block_gender` (`block_gender`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocks`
--

LOCK TABLES `blocks` WRITE;
/*!40000 ALTER TABLE `blocks` DISABLE KEYS */;
INSERT INTO `blocks` VALUES (1,'Block A','male',4,NULL,NULL,'active','2026-02-08 06:54:22'),(2,'Block B','male',5,NULL,NULL,'active','2026-02-08 06:54:22'),(5,'Girls Block A','female',1,NULL,NULL,'active','2026-03-08 18:51:30');
/*!40000 ALTER TABLE `blocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_branch_name` (`name`),
  KEY `idx_branch_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'CSE','active','2026-02-08 15:31:22','2026-02-08 15:31:22'),(2,'CSE (AIML)','active','2026-02-08 15:31:38','2026-02-08 15:31:38'),(3,'CSE (DS)','active','2026-02-08 15:31:46','2026-02-08 15:31:46'),(4,'CSE (IT)','active','2026-02-08 15:31:55','2026-02-08 15:31:55'),(5,'IT','active','2026-02-08 15:31:58','2026-02-08 15:31:58'),(6,'ECE','active','2026-02-08 15:32:02','2026-02-08 15:32:02'),(7,'MECH','active','2026-02-08 15:32:05','2026-02-08 15:32:05'),(8,'EEE','active','2026-02-08 15:32:13','2026-02-08 15:32:13'),(9,'AERO','active','2026-02-08 15:32:19','2026-03-14 05:54:30'),(10,'CSE (CS)','active','2026-02-08 15:32:47','2026-02-08 15:32:47');
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `college_leaves`
--

DROP TABLE IF EXISTS `college_leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `college_leaves` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reason` varchar(255) NOT NULL,
  `reason_code` enum('sick','personal_work','assignment','health_issue','family_work','other') DEFAULT 'other',
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `total_days` int NOT NULL,
  `status` enum('pending','approved','rejected','cancelled') DEFAULT 'pending',
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text,
  `faculty_notified` tinyint(1) DEFAULT '0',
  `faculty_notified_at` timestamp NULL DEFAULT NULL,
  `hostel_stay_confirmed` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_from_date` (`from_date`),
  KEY `idx_to_date` (`to_date`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_approved_by` (`approved_by`),
  KEY `idx_reason_code` (`reason_code`),
  CONSTRAINT `college_leaves_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `college_leaves_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `college_leaves_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `college_leaves`
--

LOCK TABLES `college_leaves` WRITE;
/*!40000 ALTER TABLE `college_leaves` DISABLE KEYS */;
/*!40000 ALTER TABLE `college_leaves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `colleges`
--

DROP TABLE IF EXISTS `colleges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `colleges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_college_name` (`name`),
  KEY `idx_college_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `colleges`
--

LOCK TABLES `colleges` WRITE;
/*!40000 ALTER TABLE `colleges` DISABLE KEYS */;
INSERT INTO `colleges` VALUES (1,'MLR Institute of Technology (MLRIT)','active','2026-02-08 15:29:44','2026-02-08 15:30:52'),(2,'Institute of Aeronautical Engineering (IARE)','active','2026-02-08 15:30:35','2026-03-14 05:54:15'),(3,'Marri Laxman Reddy Institute of Technology and Management (MLRITM)','active','2026-02-08 15:31:19','2026-02-08 15:31:19');
/*!40000 ALTER TABLE `colleges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaint_agentic_alerts`
--

DROP TABLE IF EXISTS `complaint_agentic_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaint_agentic_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `complaint_id` int DEFAULT NULL,
  `alert_type` enum('critical','unassigned_delay','delayed','technician_reminder','escalated','anomaly','recommendation') NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `alert_key` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `metadata_json` json DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `alert_key` (`alert_key`),
  KEY `complaint_id` (`complaint_id`),
  KEY `idx_alert_type` (`alert_type`),
  KEY `idx_alert_severity` (`severity`),
  KEY `idx_alert_created_at` (`created_at`),
  KEY `idx_alert_is_read` (`is_read`),
  CONSTRAINT `complaint_agentic_alerts_ibfk_1` FOREIGN KEY (`complaint_id`) REFERENCES `complaints` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54665 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaint_agentic_alerts`
--

LOCK TABLES `complaint_agentic_alerts` WRITE;
/*!40000 ALTER TABLE `complaint_agentic_alerts` DISABLE KEYS */;
INSERT INTO `complaint_agentic_alerts` VALUES (1,1,'unassigned_delay','high','unassigned_delay_1','Unassigned Complaint #1','Complaint #1 has not been assigned for over 2 hours.','{\"age_hours\": 742.7}',0,'2026-03-08 10:24:14','2026-03-11 06:09:29'),(2,1,'delayed','high','delayed_1','Complaint Delayed #1','Complaint #1 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 742.7}',0,'2026-03-08 10:24:14','2026-03-11 06:10:26'),(3,1,'escalated','critical','escalated_1','Complaint Escalated #1','Complaint #1 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 674.9}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(4,2,'unassigned_delay','high','unassigned_delay_2','Unassigned Complaint #2','Complaint #2 has not been assigned for over 2 hours.','{\"age_hours\": 711.7}',0,'2026-03-08 10:24:14','2026-03-11 05:56:28'),(5,2,'delayed','high','delayed_2','Complaint Delayed #2','Complaint #2 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 711.8}',0,'2026-03-08 10:24:14','2026-03-11 05:57:25'),(6,2,'escalated','critical','escalated_2','Complaint Escalated #2','Complaint #2 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 644.2}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(7,3,'unassigned_delay','high','unassigned_delay_3','Unassigned Complaint #3','Complaint #3 has not been assigned for over 2 hours.','{\"age_hours\": 711.7}',0,'2026-03-08 10:24:14','2026-03-11 05:56:28'),(8,3,'delayed','high','delayed_3','Complaint Delayed #3','Complaint #3 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 711.8}',0,'2026-03-08 10:24:14','2026-03-11 05:57:25'),(9,3,'escalated','critical','escalated_3','Complaint Escalated #3','Complaint #3 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 644.2}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(10,4,'critical','critical','critical_4','Critical Complaint #4','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"plumbing\"}',0,'2026-03-08 10:24:14','2026-03-14 14:14:16'),(11,4,'unassigned_delay','high','unassigned_delay_4','Unassigned Complaint #4','Complaint #4 has not been assigned for over 2 hours.','{\"age_hours\": 711.3}',0,'2026-03-08 10:24:14','2026-03-11 05:52:28'),(12,4,'delayed','high','delayed_4','Complaint Delayed #4','Complaint #4 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 783.2}',0,'2026-03-08 10:24:14','2026-03-14 05:48:27'),(13,4,'escalated','critical','escalated_4','Complaint Escalated #4','Complaint #4 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 643.8}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(14,5,'unassigned_delay','high','unassigned_delay_5','Unassigned Complaint #5','Complaint #5 has not been assigned for over 2 hours.','{\"age_hours\": 711.3}',0,'2026-03-08 10:24:14','2026-03-11 05:56:25'),(15,5,'delayed','high','delayed_5','Complaint Delayed #5','Complaint #5 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 711.3}',0,'2026-03-08 10:24:14','2026-03-11 05:56:28'),(16,5,'escalated','critical','escalated_5','Complaint Escalated #5','Complaint #5 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 643.8}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(17,6,'critical','critical','critical_6','Critical Complaint #6','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"plumbing\"}',0,'2026-03-08 10:24:14','2026-03-14 14:14:16'),(18,6,'delayed','high','delayed_6','Complaint Delayed #6','Complaint #6 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 783.1}',0,'2026-03-08 10:24:14','2026-03-14 05:48:27'),(19,6,'escalated','critical','escalated_6','Complaint Escalated #6','Complaint #6 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 643.7}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(20,6,'technician_reminder','medium','tech_reminder_6_643','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(21,7,'critical','critical','critical_7','Critical Complaint #7','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"electrical\"}',0,'2026-03-08 10:24:14','2026-03-14 14:14:16'),(22,7,'delayed','high','delayed_7','Complaint Delayed #7','Complaint #7 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 643.6}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(23,7,'escalated','critical','escalated_7','Complaint Escalated #7','Complaint #7 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 643.6}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(24,7,'technician_reminder','medium','tech_reminder_7_643','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(25,10,'critical','critical','critical_10','Critical Complaint #10','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"electrical\"}',0,'2026-03-08 10:24:14','2026-03-14 14:14:16'),(26,10,'delayed','high','delayed_10','Complaint Delayed #10','Complaint #10 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 711.5}',0,'2026-03-08 10:24:14','2026-03-11 06:48:27'),(27,10,'escalated','critical','escalated_10','Complaint Escalated #10','Complaint #10 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 643.1}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(28,10,'technician_reminder','medium','tech_reminder_10_643','Technician Reminder Needed #10','No technician status update for complaint #10 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(29,11,'critical','critical','critical_11','Critical Complaint #11','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"plumbing\"}',0,'2026-03-08 10:24:14','2026-03-14 05:48:01'),(30,11,'delayed','high','delayed_11','Complaint Delayed #11','Complaint #11 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 643.1}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(31,11,'escalated','critical','escalated_11','Complaint Escalated #11','Complaint #11 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 643.1}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(32,11,'technician_reminder','medium','tech_reminder_11_643','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(33,12,'delayed','high','delayed_12','Complaint Delayed #12','Complaint #12 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 643.1}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(34,12,'escalated','critical','escalated_12','Complaint Escalated #12','Complaint #12 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 643.1}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(35,12,'technician_reminder','medium','tech_reminder_12_643','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(36,14,'critical','critical','critical_14','Critical Complaint #14','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"electrical\"}',0,'2026-03-08 10:24:14','2026-03-14 14:14:16'),(37,14,'delayed','high','delayed_14','Complaint Delayed #14','Complaint #14 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 708.9}',0,'2026-03-08 10:24:14','2026-03-11 06:48:27'),(38,14,'escalated','critical','escalated_14','Complaint Escalated #14','Complaint #14 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 640.5}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(39,14,'technician_reminder','medium','tech_reminder_14_640','Technician Reminder Needed #14','No technician status update for complaint #14 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(40,15,'critical','critical','critical_15','Critical Complaint #15','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"electrical\"}',0,'2026-03-08 10:24:14','2026-03-14 14:14:16'),(41,15,'delayed','high','delayed_15','Complaint Delayed #15','Complaint #15 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 708.9}',0,'2026-03-08 10:24:14','2026-03-11 06:48:27'),(42,15,'escalated','critical','escalated_15','Complaint Escalated #15','Complaint #15 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 640.5}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(43,15,'technician_reminder','medium','tech_reminder_15_640','Technician Reminder Needed #15','No technician status update for complaint #15 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 10:24:14','2026-03-08 10:24:14'),(203,NULL,'recommendation','medium','manual_test_alert_20260308160026','Test Alert: UI Preview','This is a manually inserted test alert to verify dashboard rendering.','{\"source\": \"manual-test\", \"purpose\": \"ui-preview\"}',0,'2026-03-08 10:30:26','2026-03-08 10:30:26'),(4567,6,'technician_reminder','medium','tech_reminder_6_647','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-08 14:24:14','2026-03-08 14:24:14'),(4569,7,'technician_reminder','medium','tech_reminder_7_647','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 14:24:14','2026-03-08 14:24:14'),(4571,10,'technician_reminder','medium','tech_reminder_10_647','Technician Reminder Needed #10','No technician status update for complaint #10 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 14:24:14','2026-03-08 14:24:14'),(4573,11,'technician_reminder','medium','tech_reminder_11_647','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-08 14:24:14','2026-03-08 14:24:14'),(4574,12,'technician_reminder','medium','tech_reminder_12_647','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-08 14:24:14','2026-03-08 14:24:14'),(4576,14,'technician_reminder','medium','tech_reminder_14_644','Technician Reminder Needed #14','No technician status update for complaint #14 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 14:24:14','2026-03-08 14:24:14'),(4578,15,'technician_reminder','medium','tech_reminder_15_644','Technician Reminder Needed #15','No technician status update for complaint #15 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 14:24:14','2026-03-08 14:24:14'),(6879,6,'technician_reminder','medium','tech_reminder_6_651','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-08 18:24:36','2026-03-08 18:24:36'),(6881,7,'technician_reminder','medium','tech_reminder_7_651','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 18:24:36','2026-03-08 18:24:36'),(6883,10,'technician_reminder','medium','tech_reminder_10_651','Technician Reminder Needed #10','No technician status update for complaint #10 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 18:24:36','2026-03-08 18:24:36'),(6885,11,'technician_reminder','medium','tech_reminder_11_651','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-08 18:24:36','2026-03-08 18:24:36'),(6886,12,'technician_reminder','medium','tech_reminder_12_651','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-08 18:24:36','2026-03-08 18:24:36'),(6889,14,'technician_reminder','medium','tech_reminder_14_648','Technician Reminder Needed #14','No technician status update for complaint #14 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 18:24:36','2026-03-08 18:24:36'),(6891,15,'technician_reminder','medium','tech_reminder_15_648','Technician Reminder Needed #15','No technician status update for complaint #15 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-08 18:24:36','2026-03-08 18:24:36'),(8011,6,'technician_reminder','medium','tech_reminder_6_660','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-09 03:30:07','2026-03-09 03:30:07'),(8013,7,'technician_reminder','medium','tech_reminder_7_660','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 03:30:07','2026-03-09 03:30:07'),(8015,10,'technician_reminder','medium','tech_reminder_10_660','Technician Reminder Needed #10','No technician status update for complaint #10 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 03:30:07','2026-03-09 03:30:07'),(8017,11,'technician_reminder','medium','tech_reminder_11_660','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-09 03:30:07','2026-03-09 03:30:07'),(8018,12,'technician_reminder','medium','tech_reminder_12_660','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-09 03:30:07','2026-03-09 03:30:07'),(8020,14,'technician_reminder','medium','tech_reminder_14_657','Technician Reminder Needed #14','No technician status update for complaint #14 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 03:30:07','2026-03-09 03:30:07'),(8022,15,'technician_reminder','medium','tech_reminder_15_657','Technician Reminder Needed #15','No technician status update for complaint #15 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 03:30:07','2026-03-09 03:30:07'),(8043,6,'technician_reminder','medium','tech_reminder_6_669','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-09 12:39:27','2026-03-09 12:39:27'),(8045,7,'technician_reminder','medium','tech_reminder_7_669','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 12:39:27','2026-03-09 12:39:27'),(8047,10,'technician_reminder','medium','tech_reminder_10_669','Technician Reminder Needed #10','No technician status update for complaint #10 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 12:39:27','2026-03-09 12:39:27'),(8049,11,'technician_reminder','medium','tech_reminder_11_669','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-09 12:39:27','2026-03-09 12:39:27'),(8050,12,'technician_reminder','medium','tech_reminder_12_669','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-09 12:39:27','2026-03-09 12:39:27'),(8052,14,'technician_reminder','medium','tech_reminder_14_666','Technician Reminder Needed #14','No technician status update for complaint #14 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 12:39:27','2026-03-09 12:39:27'),(8054,15,'technician_reminder','medium','tech_reminder_15_666','Technician Reminder Needed #15','No technician status update for complaint #15 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 12:39:27','2026-03-09 12:39:27'),(12715,6,'technician_reminder','medium','tech_reminder_6_673','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-09 16:39:43','2026-03-09 16:39:43'),(12717,7,'technician_reminder','medium','tech_reminder_7_673','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 16:39:44','2026-03-09 16:39:44'),(12719,10,'technician_reminder','medium','tech_reminder_10_673','Technician Reminder Needed #10','No technician status update for complaint #10 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 16:39:44','2026-03-09 16:39:44'),(12721,11,'technician_reminder','medium','tech_reminder_11_673','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-09 16:39:44','2026-03-09 16:39:44'),(12722,12,'technician_reminder','medium','tech_reminder_12_673','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-09 16:39:44','2026-03-09 16:39:44'),(12724,14,'technician_reminder','medium','tech_reminder_14_670','Technician Reminder Needed #14','No technician status update for complaint #14 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 16:39:44','2026-03-09 16:39:44'),(12726,15,'technician_reminder','medium','tech_reminder_15_670','Technician Reminder Needed #15','No technician status update for complaint #15 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-09 16:39:44','2026-03-09 16:39:44'),(15867,6,'technician_reminder','medium','tech_reminder_6_710','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 05:39:24','2026-03-11 05:39:24'),(15869,7,'technician_reminder','medium','tech_reminder_7_710','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 05:39:24','2026-03-11 05:39:24'),(15871,10,'technician_reminder','medium','tech_reminder_10_710','Technician Reminder Needed #10','No technician status update for complaint #10 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 05:39:24','2026-03-11 05:39:24'),(15873,11,'technician_reminder','medium','tech_reminder_11_710','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 05:39:24','2026-03-11 05:39:24'),(15874,12,'technician_reminder','medium','tech_reminder_12_710','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-11 05:39:24','2026-03-11 05:39:24'),(15876,14,'technician_reminder','medium','tech_reminder_14_707','Technician Reminder Needed #14','No technician status update for complaint #14 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 05:39:24','2026-03-11 05:39:24'),(15878,15,'technician_reminder','medium','tech_reminder_15_707','Technician Reminder Needed #15','No technician status update for complaint #15 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 05:39:24','2026-03-11 05:39:24'),(17060,2,'technician_reminder','medium','tech_reminder_2_6','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(17061,3,'technician_reminder','medium','tech_reminder_3_6','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(17063,4,'technician_reminder','medium','tech_reminder_4_6','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(17064,5,'technician_reminder','medium','tech_reminder_5_6','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(17066,6,'technician_reminder','medium','tech_reminder_6_718','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(17068,7,'technician_reminder','medium','tech_reminder_7_717','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(17071,11,'technician_reminder','medium','tech_reminder_11_717','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(17072,12,'technician_reminder','medium','tech_reminder_12_717','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-11 12:44:58','2026-03-11 12:44:58'),(20372,2,'technician_reminder','medium','tech_reminder_2_10','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20373,3,'technician_reminder','medium','tech_reminder_3_10','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20375,4,'technician_reminder','medium','tech_reminder_4_10','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20376,5,'technician_reminder','medium','tech_reminder_5_10','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20378,6,'technician_reminder','medium','tech_reminder_6_722','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20380,7,'technician_reminder','medium','tech_reminder_7_721','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20383,11,'technician_reminder','medium','tech_reminder_11_721','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20384,12,'technician_reminder','medium','tech_reminder_12_721','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-11 16:45:26','2026-03-11 16:45:26'),(20394,2,'technician_reminder','medium','tech_reminder_2_26','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20395,3,'technician_reminder','medium','tech_reminder_3_26','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20397,4,'technician_reminder','medium','tech_reminder_4_27','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20398,5,'technician_reminder','medium','tech_reminder_5_26','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20400,6,'technician_reminder','medium','tech_reminder_6_738','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20402,7,'technician_reminder','medium','tech_reminder_7_738','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20405,11,'technician_reminder','medium','tech_reminder_11_737','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20406,12,'technician_reminder','medium','tech_reminder_12_737','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-12 08:56:23','2026-03-12 08:56:23'),(20997,2,'technician_reminder','medium','tech_reminder_2_30','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(20998,3,'technician_reminder','medium','tech_reminder_3_31','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(21000,4,'technician_reminder','medium','tech_reminder_4_31','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(21001,5,'technician_reminder','medium','tech_reminder_5_31','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(21003,6,'technician_reminder','medium','tech_reminder_6_742','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(21005,7,'technician_reminder','medium','tech_reminder_7_742','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(21008,11,'technician_reminder','medium','tech_reminder_11_741','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(21009,12,'technician_reminder','medium','tech_reminder_12_741','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-12 12:57:17','2026-03-12 12:57:17'),(21104,17,'technician_reminder','medium','tech_reminder_17_4','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-12 13:03:17','2026-03-12 13:03:17'),(21820,18,'critical','critical','critical_18','Critical Complaint #18','High-priority complaint raised in Room 101 (Block A).','{\"category\": \"electrical\"}',0,'2026-03-12 13:55:15','2026-03-14 14:14:16'),(24749,2,'technician_reminder','medium','tech_reminder_2_35','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24750,3,'technician_reminder','medium','tech_reminder_3_35','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24752,4,'technician_reminder','medium','tech_reminder_4_35','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24753,5,'technician_reminder','medium','tech_reminder_5_35','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24755,6,'technician_reminder','medium','tech_reminder_6_746','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24757,7,'technician_reminder','medium','tech_reminder_7_746','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24760,11,'technician_reminder','medium','tech_reminder_11_745','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24761,12,'technician_reminder','medium','tech_reminder_12_745','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-12 16:57:56','2026-03-12 16:57:56'),(24860,17,'technician_reminder','medium','tech_reminder_17_8','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-12 17:03:56','2026-03-12 17:03:56'),(25542,18,'technician_reminder','medium','tech_reminder_18_4','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-12 18:20:48','2026-03-12 18:20:48'),(26447,2,'technician_reminder','medium','tech_reminder_2_46','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26448,3,'technician_reminder','medium','tech_reminder_3_46','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26450,4,'technician_reminder','medium','tech_reminder_4_46','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26451,5,'technician_reminder','medium','tech_reminder_5_46','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26453,6,'technician_reminder','medium','tech_reminder_6_757','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26455,7,'technician_reminder','medium','tech_reminder_7_757','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26458,11,'technician_reminder','medium','tech_reminder_11_757','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26459,12,'technician_reminder','medium','tech_reminder_12_757','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26462,17,'technician_reminder','medium','tech_reminder_17_19','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(26464,18,'technician_reminder','medium','tech_reminder_18_14','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 04:28:49','2026-03-13 04:28:49'),(29059,2,'technician_reminder','medium','tech_reminder_2_50','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29060,3,'technician_reminder','medium','tech_reminder_3_50','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29062,4,'technician_reminder','medium','tech_reminder_4_50','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29063,5,'technician_reminder','medium','tech_reminder_5_50','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29065,6,'technician_reminder','medium','tech_reminder_6_761','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29067,7,'technician_reminder','medium','tech_reminder_7_761','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29070,11,'technician_reminder','medium','tech_reminder_11_761','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29071,12,'technician_reminder','medium','tech_reminder_12_761','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29074,17,'technician_reminder','medium','tech_reminder_17_23','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29076,18,'technician_reminder','medium','tech_reminder_18_18','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 08:29:29','2026-03-13 08:29:29'),(29630,17,'delayed','high','delayed_17','Complaint Delayed #17','Complaint #17 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 24.0}',0,'2026-03-13 09:03:30','2026-03-13 09:03:30'),(32993,2,'technician_reminder','medium','tech_reminder_2_54','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(32994,3,'technician_reminder','medium','tech_reminder_3_54','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(32996,4,'technician_reminder','medium','tech_reminder_4_54','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(32997,5,'technician_reminder','medium','tech_reminder_5_54','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(32999,6,'technician_reminder','medium','tech_reminder_6_765','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(33001,7,'technician_reminder','medium','tech_reminder_7_765','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(33004,11,'technician_reminder','medium','tech_reminder_11_765','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(33005,12,'technician_reminder','medium','tech_reminder_12_765','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(33008,17,'technician_reminder','medium','tech_reminder_17_27','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(33010,18,'technician_reminder','medium','tech_reminder_18_22','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 12:29:36','2026-03-13 12:29:36'),(34387,18,'delayed','high','delayed_18','Complaint Delayed #18','Complaint #18 has remained unresolved for over 24 hours and is marked delayed.','{\"age_hours\": 24.0}',0,'2026-03-13 13:55:39','2026-03-13 13:55:39'),(36844,2,'technician_reminder','medium','tech_reminder_2_58','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36845,3,'technician_reminder','medium','tech_reminder_3_58','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36847,4,'technician_reminder','medium','tech_reminder_4_58','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36848,5,'technician_reminder','medium','tech_reminder_5_58','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36850,6,'technician_reminder','medium','tech_reminder_6_769','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36852,7,'technician_reminder','medium','tech_reminder_7_769','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36855,11,'technician_reminder','medium','tech_reminder_11_769','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36856,12,'technician_reminder','medium','tech_reminder_12_769','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36859,17,'technician_reminder','medium','tech_reminder_17_31','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(36861,18,'technician_reminder','medium','tech_reminder_18_26','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 16:29:43','2026-03-13 16:29:43'),(40726,2,'technician_reminder','medium','tech_reminder_2_62','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40727,3,'technician_reminder','medium','tech_reminder_3_62','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40729,4,'technician_reminder','medium','tech_reminder_4_62','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40730,5,'technician_reminder','medium','tech_reminder_5_62','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40732,6,'technician_reminder','medium','tech_reminder_6_773','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40734,7,'technician_reminder','medium','tech_reminder_7_773','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40737,11,'technician_reminder','medium','tech_reminder_11_773','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40738,12,'technician_reminder','medium','tech_reminder_12_773','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40741,17,'technician_reminder','medium','tech_reminder_17_35','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(40743,18,'technician_reminder','medium','tech_reminder_18_30','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-13 20:29:52','2026-03-13 20:29:52'),(41064,2,'technician_reminder','medium','tech_reminder_2_70','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41065,3,'technician_reminder','medium','tech_reminder_3_70','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41067,4,'technician_reminder','medium','tech_reminder_4_70','Technician Reminder Needed #4','No technician status update for complaint #4 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41068,5,'technician_reminder','medium','tech_reminder_5_70','Technician Reminder Needed #5','No technician status update for complaint #5 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41070,6,'technician_reminder','medium','tech_reminder_6_781','Technician Reminder Needed #6','No technician status update for complaint #6 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41072,7,'technician_reminder','medium','tech_reminder_7_781','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41075,11,'technician_reminder','medium','tech_reminder_11_780','Technician Reminder Needed #11','No technician status update for complaint #11 after assignment. Reminder generated for Kumar Singh.','{\"technician_name\": \"Kumar Singh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41076,12,'technician_reminder','medium','tech_reminder_12_780','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41079,17,'technician_reminder','medium','tech_reminder_17_43','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41081,18,'technician_reminder','medium','tech_reminder_18_38','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 04:04:35','2026-03-14 04:04:35'),(41346,19,'critical','critical','critical_19','Critical Complaint #19','High-priority complaint raised in Room 102 (Block A).','{\"category\": \"electrical\"}',0,'2026-03-14 04:20:57','2026-03-14 14:14:16'),(41644,NULL,'anomaly','high','anomaly_room_101_Block A','Complaint Hotspot Detected','Room 101 - Block A generated 4 complaints in the last 7 days.','{\"count\": 4, \"block_name\": \"Block A\", \"room_number\": \"101\"}',0,'2026-03-14 04:36:59','2026-03-14 04:56:02'),(46057,7,'technician_reminder','medium','tech_reminder_7_785','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 08:04:52','2026-03-14 08:04:52'),(46059,12,'technician_reminder','medium','tech_reminder_12_784','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-14 08:04:52','2026-03-14 08:04:52'),(46063,18,'technician_reminder','medium','tech_reminder_18_42','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 08:04:52','2026-03-14 08:04:52'),(46065,2,'technician_reminder','medium','tech_reminder_2_74','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 08:04:52','2026-03-14 08:04:52'),(46066,3,'technician_reminder','medium','tech_reminder_3_74','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 08:04:52','2026-03-14 08:04:52'),(46067,17,'technician_reminder','medium','tech_reminder_17_47','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-14 08:04:52','2026-03-14 08:04:52'),(46588,19,'technician_reminder','medium','tech_reminder_19_4','Technician Reminder Needed #19','No technician status update for complaint #19 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 08:21:00','2026-03-14 08:21:00'),(47438,20,'technician_reminder','medium','tech_reminder_20_4','Technician Reminder Needed #20','No technician status update for complaint #20 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 08:46:03','2026-03-14 08:46:03'),(47981,17,'escalated','critical','escalated_17','Complaint Escalated #17','Complaint #17 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 48.0}',0,'2026-03-14 09:03:04','2026-03-14 09:03:04'),(52576,2,'technician_reminder','medium','tech_reminder_2_78','Technician Reminder Needed #2','No technician status update for complaint #2 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 12:05:00','2026-03-14 12:05:00'),(52577,3,'technician_reminder','medium','tech_reminder_3_78','Technician Reminder Needed #3','No technician status update for complaint #3 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 12:05:00','2026-03-14 12:05:00'),(52581,7,'technician_reminder','medium','tech_reminder_7_789','Technician Reminder Needed #7','No technician status update for complaint #7 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 12:05:00','2026-03-14 12:05:00'),(52583,12,'technician_reminder','medium','tech_reminder_12_788','Technician Reminder Needed #12','No technician status update for complaint #12 after assignment. Reminder generated for Vijay.','{\"technician_name\": \"Vijay\"}',0,'2026-03-14 12:05:00','2026-03-14 12:05:00'),(52586,17,'technician_reminder','medium','tech_reminder_17_51','Technician Reminder Needed #17','No technician status update for complaint #17 after assignment. Reminder generated for Sai.','{\"technician_name\": \"Sai\"}',0,'2026-03-14 12:05:00','2026-03-14 12:05:00'),(52588,18,'technician_reminder','medium','tech_reminder_18_46','Technician Reminder Needed #18','No technician status update for complaint #18 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 12:05:00','2026-03-14 12:05:00'),(52846,19,'technician_reminder','medium','tech_reminder_19_8','Technician Reminder Needed #19','No technician status update for complaint #19 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 12:21:01','2026-03-14 12:21:01'),(53255,20,'technician_reminder','medium','tech_reminder_20_8','Technician Reminder Needed #20','No technician status update for complaint #20 after assignment. Reminder generated for Rajesh.','{\"technician_name\": \"Rajesh\"}',0,'2026-03-14 12:46:13','2026-03-14 12:46:13'),(54359,18,'escalated','critical','escalated_18','Complaint Escalated #18','Complaint #18 exceeded 48 hours unresolved and has been escalated to the warden.','{\"age_hours\": 48.0}',0,'2026-03-14 13:55:15','2026-03-14 13:55:15');
/*!40000 ALTER TABLE `complaint_agentic_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaint_history`
--

DROP TABLE IF EXISTS `complaint_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaint_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `complaint_id` int NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) DEFAULT NULL,
  `changed_by` int DEFAULT NULL,
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `changed_by` (`changed_by`),
  KEY `idx_complaint_id` (`complaint_id`),
  CONSTRAINT `complaint_history_ibfk_1` FOREIGN KEY (`complaint_id`) REFERENCES `complaints` (`id`) ON DELETE CASCADE,
  CONSTRAINT `complaint_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaint_history`
--

LOCK TABLES `complaint_history` WRITE;
/*!40000 ALTER TABLE `complaint_history` DISABLE KEYS */;
INSERT INTO `complaint_history` VALUES (1,8,'assigned','in_progress',NULL,NULL,'2026-02-09 17:50:53'),(2,8,'in_progress','resolved',NULL,NULL,'2026-02-09 17:51:23'),(3,13,'assigned','in_progress',NULL,NULL,'2026-02-09 17:57:29'),(4,13,'in_progress','resolved',NULL,NULL,'2026-02-09 17:57:57'),(5,9,'assigned','in_progress',NULL,NULL,'2026-02-15 17:44:17'),(6,9,'in_progress','resolved',NULL,NULL,'2026-02-15 17:44:31'),(8,4,'delayed','assigned',NULL,NULL,'2026-03-11 05:52:40'),(9,5,'delayed','assigned',NULL,NULL,'2026-03-11 05:56:26'),(10,3,'delayed','assigned',NULL,NULL,'2026-03-11 05:56:47'),(11,2,'delayed','assigned',NULL,NULL,'2026-03-11 05:57:19'),(12,1,'delayed','assigned',NULL,NULL,'2026-03-11 06:09:56'),(13,1,'delayed','in_progress',NULL,NULL,'2026-03-11 06:19:13'),(14,1,'in_progress','resolved',NULL,NULL,'2026-03-11 06:19:17'),(15,15,'delayed','in_progress',NULL,NULL,'2026-03-11 06:47:54'),(16,10,'delayed','in_progress',NULL,NULL,'2026-03-11 06:47:56'),(17,14,'delayed','in_progress',NULL,NULL,'2026-03-11 06:47:57'),(18,20,'pending','assigned',NULL,NULL,'2026-03-14 04:45:58'),(19,11,'delayed','in_progress',NULL,NULL,'2026-03-14 05:48:11'),(20,5,'delayed','in_progress',NULL,NULL,'2026-03-14 05:48:13'),(21,4,'delayed','in_progress',NULL,NULL,'2026-03-14 05:48:18'),(22,6,'delayed','in_progress',NULL,NULL,'2026-03-14 05:48:19'),(23,11,'in_progress','resolved',NULL,NULL,'2026-03-14 05:48:24'),(24,5,'in_progress','resolved',NULL,NULL,'2026-03-14 05:48:25');
/*!40000 ALTER TABLE `complaint_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaints`
--

DROP TABLE IF EXISTS `complaints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaints` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `category` enum('electrical','plumbing','carpentry','hvac','wifi','furniture','internet','cleaning','security','other') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `status` enum('pending','assigned','in_progress','delayed','resolved','closed','cancelled') DEFAULT 'pending',
  `assigned_technician_id` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` text,
  `rating` int DEFAULT NULL,
  `feedback` text,
  `attachments` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `block_id` int DEFAULT NULL,
  `ai_priority` enum('low','medium','high') DEFAULT 'low',
  `delayed_at` datetime DEFAULT NULL,
  `escalated_at` datetime DEFAULT NULL,
  `last_technician_update_at` datetime DEFAULT NULL,
  `last_reminder_sent_at` datetime DEFAULT NULL,
  `reminder_count` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_category` (`category`),
  KEY `idx_priority` (`priority`),
  KEY `idx_assigned_technician` (`assigned_technician_id`),
  KEY `idx_complaints_ai_priority` (`ai_priority`),
  KEY `idx_complaints_delayed_at` (`delayed_at`),
  KEY `idx_complaints_escalated_at` (`escalated_at`),
  CONSTRAINT `complaints_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `complaints_ibfk_2` FOREIGN KEY (`assigned_technician_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `complaints_chk_1` CHECK (((`rating` is null) or ((`rating` >= 1) and (`rating` <= 5))))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaints`
--

LOCK TABLES `complaints` WRITE;
/*!40000 ALTER TABLE `complaints` DISABLE KEYS */;
INSERT INTO `complaints` VALUES (1,1,'other','Broken ceiling fan in room','Broken ceiling fan in room','Room 101, Block A','medium','resolved',4,'2026-03-11 06:09:56','2026-03-11 06:19:17','Task completed',NULL,NULL,NULL,'2026-02-08 07:27:39','2026-03-11 06:19:17',NULL,'medium','2026-03-11 11:40:26','2026-03-08 15:54:14','2026-03-11 11:49:17',NULL,0),(2,8,'other','fan is not working','fan is not working','Room 302','medium','delayed',26,'2026-03-11 05:57:19',NULL,NULL,NULL,NULL,NULL,'2026-02-09 14:11:56','2026-03-14 12:05:00',NULL,'low','2026-03-11 11:27:25','2026-03-08 15:54:14',NULL,'2026-03-14 17:35:00',16),(3,8,'other','rwesdtbhnj trbhjn  rwdcvb utgh tvhb','rwesdtbhnj trbhjn  rwdcvb utgh tvhb','Room 302','medium','delayed',26,'2026-03-11 05:56:47',NULL,NULL,NULL,NULL,NULL,'2026-02-09 14:12:15','2026-03-14 12:05:00',NULL,'low','2026-03-11 11:27:25','2026-03-08 15:54:14',NULL,'2026-03-14 17:35:00',16),(4,1,'plumbing','sdfgh','sdfgh','Room 302','high','delayed',24,'2026-03-11 05:52:40',NULL,NULL,NULL,NULL,NULL,'2026-02-09 14:34:39','2026-03-14 05:48:27',NULL,'high','2026-03-14 11:18:27','2026-03-08 15:54:14','2026-03-14 11:18:18','2026-03-14 09:34:35',14),(5,1,'other','asdfg','asdfg','Room 302','medium','resolved',24,'2026-03-11 05:56:26','2026-03-14 05:48:25','Task completed',NULL,NULL,NULL,'2026-02-09 14:35:53','2026-03-14 05:48:25',NULL,'low','2026-03-11 11:26:28','2026-03-08 15:54:14','2026-03-14 11:18:25','2026-03-14 09:34:35',14),(6,1,'plumbing','assdfghgnm','assdfghgnm','Room 302','high','delayed',24,'2026-02-09 14:44:15',NULL,NULL,NULL,NULL,NULL,'2026-02-09 14:44:14','2026-03-14 05:48:27',NULL,'high','2026-03-14 11:18:27','2026-03-08 15:54:14','2026-03-14 11:18:19','2026-03-14 09:34:35',23),(7,1,'electrical','fcgvbhnm','fcgvbhnm','Room 302','high','delayed',26,'2026-02-09 14:47:09',NULL,NULL,NULL,NULL,NULL,'2026-02-09 14:47:09','2026-03-14 12:05:00',NULL,'high','2026-03-08 15:54:14','2026-03-08 15:54:14',NULL,'2026-03-14 17:35:00',25),(8,1,'hvac','rdfghnjm','rdfghnjm','Room 101','medium','resolved',4,'2026-02-09 15:17:14','2026-02-09 17:51:23','completed',NULL,NULL,NULL,'2026-02-09 15:17:13','2026-02-09 17:51:23',NULL,'low',NULL,NULL,NULL,NULL,0),(9,1,'wifi','bnm','bnm','Room 101','medium','resolved',27,'2026-02-09 15:18:02','2026-02-15 17:44:31','completed',NULL,NULL,NULL,'2026-02-09 15:18:01','2026-02-15 17:44:31',NULL,'low',NULL,NULL,NULL,NULL,0),(10,1,'electrical','edfghj','edfghj','Room 101','high','delayed',26,'2026-02-09 15:18:11',NULL,NULL,NULL,NULL,NULL,'2026-02-09 15:18:10','2026-03-11 06:48:27',NULL,'high','2026-03-11 12:18:27','2026-03-08 15:54:14','2026-03-11 12:17:56','2026-03-11 11:09:24',9),(11,1,'plumbing','rgh','rgh','Room 101','high','resolved',24,'2026-02-09 15:18:23','2026-03-14 05:48:24','Task completed',NULL,NULL,NULL,'2026-02-09 15:18:23','2026-03-14 05:48:24',NULL,'high','2026-03-08 15:54:14','2026-03-08 15:54:14','2026-03-14 11:18:24','2026-03-14 09:34:35',23),(12,1,'carpentry','rtyjuk','rtyjuk','Room 101','medium','delayed',25,'2026-02-09 15:19:03',NULL,NULL,NULL,NULL,NULL,'2026-02-09 15:19:02','2026-03-14 12:05:00',NULL,'medium','2026-03-08 15:54:14','2026-03-08 15:54:14',NULL,'2026-03-14 17:35:00',25),(13,1,'other','rtyui','rtyui','Room 101','medium','resolved',4,'2026-02-09 15:22:00','2026-02-09 17:57:57','completed successfully',NULL,NULL,NULL,'2026-02-09 15:19:13','2026-02-09 17:57:57',NULL,'low',NULL,NULL,NULL,NULL,0),(14,1,'electrical','Test complaint with block info','Test complaint with block info','Room 101','high','delayed',26,'2026-02-09 17:56:36',NULL,NULL,NULL,NULL,NULL,'2026-02-09 17:56:35','2026-03-11 06:48:27',1,'high','2026-03-11 12:18:27','2026-03-08 15:54:14','2026-03-11 12:17:57','2026-03-11 11:09:24',9),(15,1,'electrical','Test complaint with block info','Test complaint with block info','Room 101','high','delayed',26,'2026-02-09 17:56:47',NULL,NULL,NULL,NULL,NULL,'2026-02-09 17:56:46','2026-03-11 06:48:27',1,'high','2026-03-11 12:18:27','2026-03-08 15:54:14','2026-03-11 12:17:54','2026-03-11 11:09:24',9),(17,8,'wifi','wifi signal is not coming and even it reachable th...','wifi signal is not coming and even it reachable the network is not loading','Room 101','low','delayed',27,'2026-03-12 09:03:04',NULL,NULL,NULL,NULL,NULL,'2026-03-12 09:03:03','2026-03-14 12:05:00',1,'low','2026-03-13 14:33:30','2026-03-14 14:33:04',NULL,'2026-03-14 17:35:00',13),(18,1,'electrical','The tube light is flickering and then turns off','The tube light is flickering and then turns off','Room 101','high','delayed',26,'2026-03-12 13:55:15',NULL,NULL,NULL,NULL,NULL,'2026-03-12 13:55:15','2026-03-14 13:55:15',1,'high','2026-03-13 19:25:39','2026-03-14 19:25:15',NULL,'2026-03-14 17:35:00',11),(19,7,'electrical','fan is not working','fan is not working','Room 101','high','assigned',26,'2026-03-14 04:20:58',NULL,NULL,NULL,NULL,NULL,'2026-03-14 04:20:57','2026-03-14 12:21:01',1,'high',NULL,NULL,NULL,'2026-03-14 17:51:01',3),(20,7,'other','fan is not working','fan is not working','Room 101','low','assigned',26,'2026-03-14 04:45:58',NULL,NULL,NULL,NULL,NULL,'2026-03-14 04:36:35','2026-03-14 12:46:13',1,'low',NULL,NULL,NULL,'2026-03-14 18:16:13',2);
/*!40000 ALTER TABLE `complaints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_agentic_alerts`
--

DROP TABLE IF EXISTS `leave_agentic_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_agentic_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `related_leave_id` int DEFAULT NULL,
  `student_id` int DEFAULT NULL,
  `alert_type` enum('pending_too_long','frequent_leave','suspicious_pattern','attendance_conflict','limit_exceeded','recommendation') NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `detection_key` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `metadata_json` json DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `detection_key` (`detection_key`),
  KEY `related_leave_id` (`related_leave_id`),
  KEY `student_id` (`student_id`),
  KEY `idx_leave_alert_type` (`alert_type`),
  KEY `idx_leave_alert_severity` (`severity`),
  KEY `idx_leave_alert_created_at` (`created_at`),
  KEY `idx_leave_alert_is_read` (`is_read`),
  CONSTRAINT `leave_agentic_alerts_ibfk_1` FOREIGN KEY (`related_leave_id`) REFERENCES `leave_requests` (`id`) ON DELETE SET NULL,
  CONSTRAINT `leave_agentic_alerts_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4561 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_agentic_alerts`
--

LOCK TABLES `leave_agentic_alerts` WRITE;
/*!40000 ALTER TABLE `leave_agentic_alerts` DISABLE KEYS */;
INSERT INTO `leave_agentic_alerts` VALUES (1,NULL,7,'limit_exceeded','high','leave_limit_7','Leave Limit Exceeded','CH Sathwik Reddy (23R21A6675) has 5 leave requests in 30 days.','{\"leave_count_30d\": 5}',0,'2026-03-08 10:49:57','2026-03-09 17:43:58'),(2,NULL,7,'suspicious_pattern','high','same_day_leave_7','Multiple Same-Day Leave Requests','CH Sathwik Reddy submitted 2 leave requests on the same day in the last 30 days.','{\"same_day_max\": 2}',0,'2026-03-08 10:49:57','2026-03-09 17:43:58'),(3,NULL,7,'attendance_conflict','medium','attendance_conflict_7','Attendance Conflict Pattern','CH Sathwik Reddy has 4 weekday leaves in 30 days. Review for class/CRT/activity attendance conflict.','{\"weekday_leaves\": 4}',0,'2026-03-08 10:49:57','2026-03-09 17:43:58'),(4,NULL,8,'suspicious_pattern','high','same_day_leave_8','Multiple Same-Day Leave Requests','S. Phanindher Reddy submitted 2 leave requests on the same day in the last 30 days.','{\"same_day_max\": 2}',0,'2026-03-08 10:49:57','2026-03-09 17:43:58'),(5,NULL,NULL,'recommendation','medium','leave_reco_1_2026_09','Leave Monitoring Recommendation','1 students crossed leave frequency limits in the last 30 days. Schedule mentoring/counseling review.','{\"type\": \"student_support\"}',0,'2026-03-08 10:49:57','2026-03-08 18:29:38'),(1345,NULL,NULL,'recommendation','medium','leave_reco_1_2026_10','Leave Monitoring Recommendation','1 students crossed leave frequency limits in the last 30 days. Schedule mentoring/counseling review.','{\"type\": \"student_support\"}',0,'2026-03-08 18:30:38','2026-03-09 17:43:59');
/*!40000 ALTER TABLE `leave_agentic_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_alerts`
--

DROP TABLE IF EXISTS `leave_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `alert_type` enum('high_frequency','unusual_pattern','medical_concern','behavioral_flag') DEFAULT 'high_frequency',
  `alert_message` text,
  `alert_level` enum('warning','alert','critical') DEFAULT 'warning',
  `suggested_action` varchar(255) DEFAULT NULL,
  `action_taken` varchar(500) DEFAULT NULL,
  `action_taken_by` int DEFAULT NULL,
  `action_taken_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','acknowledged','resolved') DEFAULT 'pending',
  `assigned_to` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `action_taken_by` (`action_taken_by`),
  KEY `assigned_to` (`assigned_to`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_alert_type` (`alert_type`),
  KEY `idx_alert_level` (`alert_level`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `leave_alerts_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_alerts_ibfk_2` FOREIGN KEY (`action_taken_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `leave_alerts_ibfk_3` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_alerts`
--

LOCK TABLES `leave_alerts` WRITE;
/*!40000 ALTER TABLE `leave_alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_monitoring`
--

DROP TABLE IF EXISTS `leave_monitoring`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_monitoring` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `leave_type` varchar(50) DEFAULT 'college_leave',
  `leave_count_last_30_days` int DEFAULT '0',
  `leave_count_last_60_days` int DEFAULT '0',
  `leave_count_last_90_days` int DEFAULT '0',
  `leave_count_this_semester` int DEFAULT '0',
  `average_days_per_leave` float DEFAULT '0',
  `most_common_reason` varchar(50) DEFAULT NULL,
  `frequency_alert_level` enum('low','medium','high','critical') DEFAULT 'low',
  `requires_counseling` tinyint(1) DEFAULT '0',
  `requires_medical_review` tinyint(1) DEFAULT '0',
  `flagged_by_ai` tinyint(1) DEFAULT '0',
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_student` (`student_id`),
  KEY `idx_frequency_alert` (`frequency_alert_level`),
  KEY `idx_flagged` (`flagged_by_ai`),
  CONSTRAINT `leave_monitoring_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39995 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_monitoring`
--

LOCK TABLES `leave_monitoring` WRITE;
/*!40000 ALTER TABLE `leave_monitoring` DISABLE KEYS */;
INSERT INTO `leave_monitoring` VALUES (1,1,'college_leave',1,1,1,1,4,NULL,'low',0,0,0,'2026-03-14 14:14:19'),(2,7,'college_leave',2,2,2,2,4.5,NULL,'low',0,0,0,'2026-03-14 14:14:19'),(3,8,'college_leave',0,0,0,0,0,NULL,'low',0,0,0,'2026-03-14 14:14:19'),(4,9,'college_leave',0,0,0,0,0,NULL,'low',0,0,0,'2026-03-14 14:14:19'),(5,10,'college_leave',0,0,0,0,0,NULL,'low',0,0,0,'2026-03-14 14:14:19'),(7,12,'college_leave',0,0,0,0,0,NULL,'low',0,0,0,'2026-03-14 14:14:19'),(33435,13,'college_leave',0,0,0,0,0,NULL,'low',0,0,0,'2026-03-14 14:14:19');
/*!40000 ALTER TABLE `leave_monitoring` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `leave_type` enum('medical','personal','family_emergency','vacation','other') NOT NULL,
  `leave_reason` text NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `total_days` int NOT NULL,
  `status` enum('pending','approved','active','completed','expired','rejected','cancelled') DEFAULT 'pending',
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text,
  `supporting_documents` varchar(255) DEFAULT NULL,
  `emergency_contact` varchar(20) DEFAULT NULL,
  `destination` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `active_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `expired_at` datetime DEFAULT NULL,
  `pending_alert_sent_at` datetime DEFAULT NULL,
  `ai_flagged` tinyint(1) DEFAULT '0',
  `ai_flag_reason` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_from_date` (`from_date`),
  KEY `idx_leave_type` (`leave_type`),
  KEY `idx_leave_active_at` (`active_at`),
  KEY `idx_leave_completed_at` (`completed_at`),
  KEY `idx_leave_pending_alert_sent` (`pending_alert_sent_at`),
  CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES (1,1,'medical','Doctor\'s appointment','2026-02-15','2026-02-17',3,'completed',1,'2026-02-08 19:31:40',NULL,NULL,NULL,NULL,'2026-02-08 07:28:19','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(2,7,'medical','fever','2026-02-09','2026-02-09',1,'completed',1,'2026-02-08 18:52:44',NULL,NULL,NULL,NULL,'2026-02-08 18:25:38','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(3,8,'family_emergency','attend family function','2026-02-10','2026-02-10',1,'completed',1,'2026-02-08 19:16:02',NULL,NULL,NULL,NULL,'2026-02-08 19:09:41','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(4,8,'personal','nothing','2026-02-11','2026-02-11',1,'completed',1,'2026-02-08 19:36:18',NULL,NULL,NULL,NULL,'2026-02-08 19:18:08','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(5,7,'vacation','gfcbhn','2026-02-11','2026-02-20',10,'completed',2,'2026-02-08 19:54:01',NULL,NULL,NULL,NULL,'2026-02-08 19:40:22','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(6,8,'vacation','ugadi','2026-02-11','2026-02-14',4,'completed',2,'2026-02-08 20:01:45',NULL,NULL,NULL,NULL,'2026-02-08 19:57:10','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(7,1,'personal','leave','2026-02-10','2026-02-10',1,'rejected',2,'2026-02-08 20:06:28','not approved',NULL,NULL,NULL,'2026-02-08 20:06:09','2026-02-08 20:06:28',NULL,NULL,NULL,NULL,0,NULL),(8,1,'medical','vbn','2026-02-11','2026-02-12',2,'completed',2,'2026-02-08 20:10:22',NULL,NULL,NULL,NULL,'2026-02-08 20:10:03','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(9,7,'personal','ddfgh','2026-02-09','2026-02-18',10,'completed',2,'2026-02-08 20:15:52',NULL,NULL,NULL,NULL,'2026-02-08 20:12:58','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(10,7,'personal','sdfgb','2026-02-19','2026-02-19',1,'rejected',2,'2026-02-08 20:14:57','more leaves taken',NULL,NULL,NULL,'2026-02-08 20:13:18','2026-02-08 20:14:57',NULL,NULL,NULL,NULL,0,NULL),(11,7,'personal','dfgb','2026-02-12','2026-02-26',15,'completed',2,'2026-02-08 20:13:53',NULL,NULL,NULL,NULL,'2026-02-08 20:13:33','2026-03-08 10:49:57',NULL,'2026-03-08 16:19:57',NULL,NULL,0,NULL),(12,1,'medical','Going home for festival to Hometown','2026-03-13','2026-03-16',4,'active',2,'2026-03-12 13:58:39',NULL,NULL,NULL,NULL,'2026-03-12 13:51:12','2026-03-12 18:30:48','2026-03-13 00:00:48',NULL,NULL,NULL,0,NULL),(13,7,'medical','got fever','2026-03-14','2026-03-21',8,'rejected',2,'2026-03-14 04:32:07','not too many days',NULL,NULL,NULL,'2026-03-14 04:15:32','2026-03-14 04:32:07',NULL,NULL,NULL,NULL,0,NULL),(14,7,'medical','got fever','2026-03-23','2026-03-23',1,'approved',2,'2026-03-14 04:34:52',NULL,NULL,NULL,NULL,'2026-03-14 04:17:31','2026-03-14 04:34:52',NULL,NULL,NULL,NULL,0,NULL);
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mess_menu`
--

DROP TABLE IF EXISTS `mess_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mess_menu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `day_of_week` enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday') NOT NULL,
  `meal_type` enum('breakfast','lunch','snacks','dinner') NOT NULL,
  `menu_items` text NOT NULL,
  `special_notes` text,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_day_of_week` (`day_of_week`),
  KEY `idx_meal_type` (`meal_type`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mess_menu`
--

LOCK TABLES `mess_menu` WRITE;
/*!40000 ALTER TABLE `mess_menu` DISABLE KEYS */;
INSERT INTO `mess_menu` VALUES (1,'monday','breakfast','Idli\nSambar\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(2,'monday','lunch','Plain Rice\nCabbage Fry\nTomato Dal\nDrumstick Sambar\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(3,'monday','snacks','Veg & Egg Noodles / Onion Samosa\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(4,'monday','dinner','Plain Rice\nBobbatlu\nBrinjal Curry\nKandagadala Curry\nMethi Dal\nEgg Fry\nTomato Rasam\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(5,'tuesday','breakfast','Uthappam / Pesarattu\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(6,'tuesday','lunch','Plain Rice\nBendi Fry/Curry\nThotakura Dal\nMiriyalu Rasam\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(7,'tuesday','snacks','Veg Puff & Egg Puff\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(8,'tuesday','dinner','Plain Rice\nMixed Vegetable Curry\nEgg Curry\nDal Tadka\nChapathi\nCarrot Sambar\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(9,'wednesday','breakfast','Wada\nSambar\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(10,'wednesday','lunch','Plain Rice\nChikkudukaya Tomato Curry\nPumpkin Sambar\nDosakaya Dal\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(11,'wednesday','snacks','Mixed Fruits (Separate) / Sweet Corn / Banana\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(12,'wednesday','dinner','Plain Rice\nBagara Rice\nChicken Curry\nPaneer Butter Masala\nPumpkin Sambar\nRaita\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(13,'thursday','breakfast','Dosa\nAloo Masala Curry\nPalli Chutney\nGinger Chutney\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(14,'thursday','lunch','Plain Rice\nMethi Dal\nDonda Fry/Curry\nTomato Rasam\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(15,'thursday','snacks','Cool Cake / Pineapple Cake / Butterscotch Cake / Plum Cake\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(16,'thursday','dinner','Plain Rice\nChapathi\nDal Fry\nMeal Maker / Rajma\nEgg Burji / Egg Masala\nMajjiga Charu\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(17,'friday','breakfast','Lemon Rice / Tamarind Rice\nUpma\nBread Jam\nTomato Chutney\nPalli Chutney\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(18,'friday','lunch','Plain Rice\nAahu Curry/Fry\nChukkakura Dal\nSorakaya Sambar\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(19,'friday','snacks','Punugulu / Mirchi Bajji\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(20,'friday','dinner','Plain Rice\nEgg/Veg Fried Rice OR Veg Pulav\nTomato Egg Curry\nAahu Curry\nCarrot Sambar\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(21,'saturday','breakfast','Mysore Bonda\nTomato Chutney\nPalli Chutney\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(22,'saturday','lunch','Plain Rice\nMixed Veg Curry\nBachalakara Dal\nRasam/Sambar\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(23,'saturday','snacks','Dil Pasand / Donuts / Burger / Dil Kush\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(24,'saturday','dinner','Plain Rice\nSambar Rice\nThotakura Dal\nGobi Manchuria / Veg Manchuria\nMiriyalu Rasam\nBoiled Egg\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(25,'sunday','breakfast','Chapathi\nChole Curry\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(26,'sunday','lunch','Plain Rice\nBrinjal Curry\nMoong Dal\nCarrot Sambar\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(27,'sunday','snacks','Cashew / Moon Fruit / Osmania Biscuits\nTea & Milk (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40'),(28,'sunday','dinner','Plain Rice\nBagara Rice\nChicken Curry / Chicken Biryani\nPaneer Butter Masala / Paneer Biryani\nCarrot Sambar\nRaita\nDouble Ka Meetha (2 times) / Semiya Payasam / Kadduka Kheer\nCurd, Papad & Chutneys (Common)',NULL,NULL,NULL,'2026-03-09 15:36:40');
/*!40000 ALTER TABLE `mess_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `notification_type` enum('info','warning','alert','reminder','announcement') DEFAULT 'info',
  `related_module` varchar(50) DEFAULT NULL,
  `related_id` int DEFAULT NULL,
  `is_read` enum('yes','no') DEFAULT 'no',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'Overdue Outpass - S. Phanindher Reddy','Student returned 301 minutes late (ID: 5)','warning','outpass',5,'no','2026-02-10 17:41:01'),(4,2,'Overdue Outpass - CH Sathwik Reddy','Student returned 918 minutes late (ID: 7)','warning','outpass',7,'no','2026-02-12 05:38:51'),(5,2,'Late Return - K NIKHIL','Student returned 16 days 3:08 hours late (ID: 16)','warning','outpass',16,'no','2026-03-08 12:47:25'),(6,2,'Late Return - K NIKHIL','Student returned 16 days 3:08 hours late (ID: 16)','warning','outpass',16,'no','2026-03-08 12:47:38'),(7,2,'Late Return - K NIKHIL','Student returned 16 days 3:08 hours late (ID: 16)','warning','outpass',16,'no','2026-03-08 12:47:43'),(8,2,'Late Return - K NIKHIL','Student returned 16 days 3:09 hours late (ID: 16)','warning','outpass',16,'no','2026-03-08 12:48:48'),(9,2,'Late Return - K NIKHIL','Student returned 16 days 3:11 hours late (ID: 16)','warning','outpass',16,'no','2026-03-08 12:50:35'),(10,2,'Late Return - K NIKHIL','Student returned 17 days 4:25 hours late (ID: 15)','warning','outpass',15,'no','2026-03-08 12:50:46'),(11,2,'Late Return - CH Sathwik Reddy','Student returned 16 days 20:30 hours late (ID: 14)','warning','outpass',14,'no','2026-03-08 12:53:49'),(12,2,'Late Return - S. Phanindher Reddy','Student returned 20 days 14:31 hours late (ID: 11)','warning','outpass',11,'no','2026-03-08 12:53:54'),(13,2,'Late Return - K. Rajesh Kumar','Student returned 20 days 16:31 hours late (ID: 12)','warning','outpass',12,'no','2026-03-08 12:53:58'),(14,2,'Late Return - CH Sathwik Reddy','Student returned 20 days 19:01 hours late (ID: 13)','warning','outpass',13,'no','2026-03-08 12:54:03'),(15,2,'Late Return - K. Rajesh Kumar','Student returned 20 days 20:32 hours late (ID: 9)','warning','outpass',9,'no','2026-03-08 12:55:21'),(16,2,'Late Return - CH Sathwik Reddy','Student returned 21 days 2:32 hours late (ID: 10)','warning','outpass',10,'no','2026-03-08 12:55:25'),(17,2,'Late Return - CH Sathwik Reddy','Student returned 24 days 22:35 hours late (ID: 7)','warning','outpass',7,'no','2026-03-08 12:55:29'),(18,2,'Late Return - S. Phanindher Reddy','Student returned 26 days 0:15 hours late (ID: 5)','warning','outpass',5,'no','2026-03-08 12:55:35'),(19,2,'Late Return - CH Sathwik Reddy','Student returned 6 days 19:45 hours late (ID: 19)','warning','outpass',19,'no','2026-03-14 08:15:26');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `outpasses`
--

DROP TABLE IF EXISTS `outpasses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `outpasses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `reason` varchar(255) NOT NULL,
  `destination` varchar(255) DEFAULT NULL,
  `out_date` date NOT NULL,
  `out_time` time NOT NULL,
  `expected_return_time` datetime NOT NULL,
  `actual_return_time` datetime DEFAULT NULL,
  `status` enum('pending','pending_otp','approved','approved_otp','rejected','exited','returned','overdue') DEFAULT 'pending',
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text,
  `emergency_contact` varchar(20) DEFAULT NULL,
  `parent_consent` enum('yes','no','not_required') DEFAULT 'not_required',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `actual_exit_time` datetime DEFAULT NULL,
  `is_overdue` tinyint(1) DEFAULT '0',
  `late_minutes` int DEFAULT '0',
  `grace_period_applied` tinyint(1) DEFAULT '0',
  `exit_logged_by` int DEFAULT NULL,
  `return_logged_by` int DEFAULT NULL,
  `security_notes` text,
  `monitor_state` enum('on_time','grace_period','overdue') DEFAULT 'on_time',
  `risk_level` enum('low','medium','high') DEFAULT 'low',
  `overdue_alert_sent_student` tinyint(1) DEFAULT '0',
  `overdue_alert_sent_parent` tinyint(1) DEFAULT '0',
  `overdue_notified_at` datetime DEFAULT NULL,
  `approval_method` enum('manual','otp') DEFAULT 'manual',
  `otp_code` varchar(64) DEFAULT NULL,
  `otp_sent_at` datetime DEFAULT NULL,
  `otp_verified_at` datetime DEFAULT NULL,
  `otp_attempts` int DEFAULT '0',
  `holiday_mode_request` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_out_date` (`out_date`),
  KEY `idx_approved_by` (`approved_by`),
  KEY `fk_exit_logged_by` (`exit_logged_by`),
  KEY `fk_return_logged_by` (`return_logged_by`),
  KEY `idx_outpass_monitor_state` (`monitor_state`),
  KEY `idx_outpass_risk_level` (`risk_level`),
  CONSTRAINT `fk_exit_logged_by` FOREIGN KEY (`exit_logged_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_return_logged_by` FOREIGN KEY (`return_logged_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `outpasses_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `outpasses_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `outpasses`
--

LOCK TABLES `outpasses` WRITE;
/*!40000 ALTER TABLE `outpasses` DISABLE KEYS */;
INSERT INTO `outpasses` VALUES (1,1,'Family Emergency','Home Town','2026-02-10','09:00:00','2026-02-12 18:00:00',NULL,'rejected',2,'2026-02-08 16:55:26','rejected by parent',NULL,'not_required','2026-02-08 07:26:55','2026-02-08 16:55:26',NULL,0,0,0,NULL,NULL,NULL,'on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(2,8,'outing','hyderabad','2026-02-09','10:30:00','2026-02-10 01:00:00','2026-02-08 22:52:30','returned',2,'2026-02-08 16:45:57',NULL,NULL,'not_required','2026-02-08 16:37:00','2026-02-08 17:22:29','2026-02-08 22:50:42',0,0,0,5,5,'Student exited; Student returned','on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(3,7,'festival','home','2026-02-08','10:00:00','2026-02-12 05:00:00','2026-02-10 23:14:23','returned',2,'2026-02-08 16:54:06',NULL,NULL,'not_required','2026-02-08 16:52:11','2026-02-10 17:44:23','2026-02-10 23:14:18',0,0,0,5,5,'Student exited; Student returned','on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(4,8,'For festival','home','2026-02-14','19:20:00','2026-02-24 10:00:00','2026-02-10 22:49:03','returned',2,'2026-02-08 16:59:00',NULL,NULL,'not_required','2026-02-08 16:58:45','2026-02-10 17:19:02','2026-02-10 22:44:04',0,0,0,5,5,'Student exited; Student returned','on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(5,8,'to watch movie','Balnagar','2026-02-09','20:00:00','2026-02-10 18:10:00','2026-03-08 18:25:35','returned',2,'2026-02-09 12:48:12',NULL,NULL,'not_required','2026-02-09 12:40:37','2026-03-08 12:55:35','2026-02-10 22:49:15',1,37455,0,5,5,'Student exited; Student returned; Student returned; Student returned','overdue','medium',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(6,8,'ertgh','dfgh','2026-02-10','23:15:00','2026-02-12 23:08:00','2026-02-10 23:14:11','returned',2,'2026-02-10 17:34:35',NULL,NULL,'not_required','2026-02-10 17:34:11','2026-02-10 17:44:10','2026-02-10 23:14:05',0,0,0,5,5,'Student exited; Student returned','on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(7,7,'want to go home','home','2026-02-11','18:54:00','2026-02-11 19:50:00','2026-03-08 18:25:30','returned',2,'2026-02-11 13:20:21',NULL,NULL,'not_required','2026-02-11 13:20:03','2026-03-08 12:55:29','2026-02-12 11:08:43',1,35915,0,5,5,'Student exited; Student returned; Student returned','overdue','high',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(8,9,'want to go for a movie','Balnagar','2026-02-12','12:00:00','2026-02-12 16:00:00','2026-02-12 11:09:38','returned',2,'2026-02-12 05:24:05',NULL,NULL,'not_required','2026-02-12 05:23:31','2026-02-12 05:39:37','2026-02-12 11:00:45',0,0,0,5,5,'Student exited; Student returned','on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(9,1,'Medical appointment','City Hospital','2026-02-15','18:52:42','2026-02-15 21:52:42','2026-03-08 18:25:22','returned',1,'2026-02-15 12:22:42',NULL,NULL,'not_required','2026-02-15 06:22:42','2026-03-08 12:55:21','2026-02-15 18:52:42',1,30032,0,NULL,5,'Student returned','overdue','high',1,0,'2026-02-17 21:24:19','manual',NULL,NULL,NULL,0,0),(10,7,'Family emergency','Home','2026-02-15','13:52:42','2026-02-15 15:52:42','2026-03-08 18:25:26','returned',1,'2026-02-15 07:22:42',NULL,NULL,'not_required','2026-02-15 06:22:42','2026-03-08 12:55:25','2026-02-15 13:52:42',1,30392,0,NULL,5,'Student returned','overdue','high',1,0,'2026-02-17 21:24:19','manual',NULL,NULL,NULL,0,0),(11,8,'Shopping','Mall','2026-02-16','01:52:42','2026-02-16 03:52:42','2026-03-08 18:23:54','returned',1,'2026-02-15 15:22:42',NULL,NULL,'not_required','2026-02-15 06:22:42','2026-03-08 12:53:54',NULL,1,29671,0,NULL,5,'Student returned','overdue','medium',1,0,'2026-03-08 18:04:39','manual',NULL,NULL,NULL,0,0),(12,1,'Bank work','City Center','2026-02-15','22:52:42','2026-02-16 01:52:42','2026-03-08 18:23:58','returned',1,'2026-02-15 16:22:42',NULL,NULL,'not_required','2026-02-15 06:22:42','2026-03-08 12:53:58','2026-02-15 22:52:42',1,29791,0,NULL,5,'Student returned','overdue','high',1,0,'2026-02-17 21:24:19','manual',NULL,NULL,NULL,0,0),(13,7,'College work','Campus','2026-02-15','19:52:42','2026-02-15 23:22:42','2026-03-08 18:24:03','returned',1,'2026-02-15 13:22:42',NULL,NULL,'not_required','2026-02-15 06:22:42','2026-03-08 12:54:03','2026-02-15 19:52:42',1,29941,0,NULL,5,'Student returned','overdue','high',1,0,'2026-02-17 21:24:19','manual',NULL,NULL,NULL,0,0),(14,7,'going for home','home','2026-02-17','00:00:00','2026-02-19 21:53:00','2026-03-08 18:23:49','returned',2,'2026-02-18 06:10:33',NULL,NULL,'not_required','2026-02-17 16:23:58','2026-03-08 12:53:49',NULL,1,24270,0,NULL,5,'Student returned','overdue','high',1,0,'2026-03-08 18:04:39','manual',NULL,NULL,NULL,0,0),(15,12,'to go home','home','2026-02-18','13:55:00','2026-02-19 13:55:00','2026-03-08 18:20:46','returned',NULL,'2026-02-18 08:36:33',NULL,NULL,'not_required','2026-02-18 08:25:46','2026-03-08 12:50:46',NULL,1,24745,0,NULL,5,'Student returned','overdue','high',1,1,'2026-03-08 18:04:39','otp','246840','2026-02-18 14:05:43','2026-02-18 14:06:33',1,1),(16,12,'to watch movie','IDPL','2026-02-19','15:08:00','2026-02-20 15:09:00','2026-03-08 18:20:35','returned',NULL,'2026-02-18 08:38:46',NULL,NULL,'not_required','2026-02-18 08:38:17','2026-03-08 12:50:35',NULL,1,23231,0,NULL,5,'Student returned; Student returned; Student returned; Student returned; Student returned','overdue','high',1,1,'2026-03-08 18:04:39','otp','290587','2026-02-18 14:08:22','2026-02-18 14:08:46',1,1),(17,1,'Buying supplies','City Center','2026-03-12','20:00:00','2026-03-12 22:00:00',NULL,'rejected',2,'2026-03-14 04:29:48','time over',NULL,'not_required','2026-03-12 13:48:28','2026-03-14 04:29:48',NULL,0,0,0,NULL,NULL,NULL,'on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(18,7,'moving out','IDPL','2026-03-07','10:00:00','2026-03-13 16:00:00',NULL,'rejected',2,'2026-03-14 04:30:07','not approved',NULL,'not_required','2026-03-14 04:11:56','2026-03-14 04:30:07',NULL,0,0,0,NULL,NULL,NULL,'on_time','low',0,0,NULL,'manual',NULL,NULL,NULL,0,0),(19,7,'to home','home','2026-03-15','08:00:00','2026-03-07 18:00:00','2026-03-14 13:45:27','returned',2,'2026-03-14 04:29:08',NULL,NULL,'not_required','2026-03-14 04:14:53','2026-03-14 08:15:26',NULL,1,9825,0,NULL,5,'Student returned','overdue','high',1,0,'2026-03-14 10:00:01','manual',NULL,NULL,NULL,0,0),(20,7,'wanna go home','home','2026-03-14','15:14:00','2026-03-15 12:00:00',NULL,'pending_otp',NULL,NULL,NULL,NULL,'not_required','2026-03-14 09:44:55','2026-03-14 09:44:55',NULL,0,0,0,NULL,NULL,NULL,'on_time','low',0,0,NULL,'otp',NULL,NULL,NULL,0,1),(21,12,'go home','home','2026-03-14','17:00:00','2026-03-14 21:00:00',NULL,'approved_otp',NULL,'2026-03-14 10:27:42',NULL,NULL,'not_required','2026-03-14 09:46:02','2026-03-14 10:27:42',NULL,0,0,0,NULL,NULL,NULL,'on_time','low',0,0,NULL,'otp',NULL,'2026-03-14 15:57:12','2026-03-14 15:57:42',1,1);
/*!40000 ALTER TABLE `outpasses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parcels`
--

DROP TABLE IF EXISTS `parcels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parcels` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `courier_name` varchar(100) DEFAULT NULL,
  `sender_name` varchar(100) DEFAULT NULL,
  `sender_contact` varchar(20) DEFAULT NULL,
  `parcel_type` enum('document','package','box','other') DEFAULT 'package',
  `weight` decimal(10,2) DEFAULT NULL,
  `received_date` date NOT NULL,
  `received_time` time NOT NULL,
  `received_by` int DEFAULT NULL,
  `status` enum('received','notified','collected','returned') DEFAULT 'received',
  `collection_date` datetime DEFAULT NULL,
  `collected_by` varchar(100) DEFAULT NULL,
  `collector_id_proof` varchar(50) DEFAULT NULL,
  `storage_location` varchar(50) DEFAULT NULL,
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tracking_number` (`tracking_number`),
  KEY `received_by` (`received_by`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_tracking_number` (`tracking_number`),
  KEY `idx_status` (`status`),
  KEY `idx_received_date` (`received_date`),
  CONSTRAINT `parcels_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `parcels_ibfk_2` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parcels`
--

LOCK TABLES `parcels` WRITE;
/*!40000 ALTER TABLE `parcels` DISABLE KEYS */;
INSERT INTO `parcels` VALUES (1,7,'','Amazon','','','package',NULL,'2026-02-08','23:12:08',NULL,'collected','2026-02-08 23:13:20','Security Staff',NULL,NULL,'collect from office','2026-02-08 17:42:07','2026-02-08 17:43:20'),(3,7,NULL,'Amazon','','','package',NULL,'2026-02-08','23:18:23',NULL,'collected','2026-02-08 23:19:31','Security Staff',NULL,NULL,'','2026-02-08 17:48:23','2026-02-08 17:49:31'),(4,8,NULL,'Amazon','','','package',NULL,'2026-02-08','23:20:13',NULL,'collected','2026-02-08 23:20:27','Security Staff',NULL,NULL,'','2026-02-08 17:50:13','2026-02-08 17:50:27'),(5,8,'-','Amazon','PNR',' - ','package',NULL,'2026-02-10','23:27:49',NULL,'collected','2026-02-12 11:15:53','Security Staff',NULL,NULL,'Got shoes','2026-02-10 17:57:48','2026-02-12 05:45:53'),(6,9,NULL,'Amazon','Navaroj','9948548275','package',NULL,'2026-02-12','11:07:44',NULL,'collected','2026-02-12 11:15:57','Security Staff',NULL,NULL,'Got shoes order','2026-02-12 05:37:44','2026-02-12 05:45:57'),(7,7,NULL,'Amazon','PNR','','box',NULL,'2026-02-19','10:42:59',NULL,'collected','2026-02-20 11:27:42','Security Staff',NULL,NULL,'','2026-02-19 05:12:59','2026-02-20 05:57:42'),(8,10,NULL,'Amazon','Navaroj','','box',NULL,'2026-02-20','11:28:11',NULL,'collected','2026-03-09 00:24:57','Security Staff',NULL,NULL,'','2026-02-20 05:58:10','2026-03-08 18:54:57'),(9,10,NULL,'Ajio','PNR','','package',NULL,'2026-03-11','11:48:15',NULL,'collected','2026-03-11 11:51:24','Security Staff',NULL,NULL,'','2026-03-11 06:18:14','2026-03-11 06:21:24'),(10,10,'AUTO-0314-001','BlueDart','','','package',NULL,'2026-03-14','13:46:33',NULL,'collected','2026-03-14 13:47:05','Security Staff',NULL,NULL,'','2026-03-14 08:16:33','2026-03-14 08:17:05');
/*!40000 ALTER TABLE `parcels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `room_allocations`
--

DROP TABLE IF EXISTS `room_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_allocations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `room_id` int NOT NULL,
  `allocation_date` date NOT NULL,
  `checkout_date` date DEFAULT NULL,
  `status` enum('active','completed','transferred') DEFAULT 'active',
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_room_id` (`room_id`),
  KEY `idx_status` (`status`),
  KEY `idx_allocation_date` (`allocation_date`),
  CONSTRAINT `room_allocations_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `room_allocations_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_allocations`
--

LOCK TABLES `room_allocations` WRITE;
/*!40000 ALTER TABLE `room_allocations` DISABLE KEYS */;
INSERT INTO `room_allocations` VALUES (11,1,136,'2026-03-09',NULL,'active',NULL,'2026-03-08 19:03:42'),(12,7,136,'2026-03-09','2026-03-14','transferred',NULL,'2026-03-08 19:03:42'),(13,8,136,'2026-03-09',NULL,'active',NULL,'2026-03-08 19:03:42'),(14,9,136,'2026-03-09',NULL,'active',NULL,'2026-03-08 19:03:42'),(15,10,137,'2026-03-09',NULL,'active',NULL,'2026-03-08 19:03:42'),(17,12,137,'2026-03-09',NULL,'active',NULL,'2026-03-08 19:03:42'),(18,7,137,'2026-03-14',NULL,'active',NULL,'2026-03-14 04:56:16'),(21,13,136,'2026-03-14',NULL,'active',NULL,'2026-03-14 09:35:22'),(22,13,138,'2026-03-14',NULL,'active',NULL,'2026-03-14 09:35:27');
/*!40000 ALTER TABLE `room_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `room_change_requests`
--

DROP TABLE IF EXISTS `room_change_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_change_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `current_room_id` int DEFAULT NULL,
  `requested_room_id` int DEFAULT NULL,
  `requested_block_id` int DEFAULT NULL,
  `preference_reason` varchar(255) DEFAULT NULL,
  `full_reason` text NOT NULL,
  `room_preference` varchar(100) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `requested_block_id` (`requested_block_id`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_current_room` (`current_room_id`),
  KEY `idx_requested_room` (`requested_room_id`),
  CONSTRAINT `room_change_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `room_change_requests_ibfk_2` FOREIGN KEY (`current_room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL,
  CONSTRAINT `room_change_requests_ibfk_3` FOREIGN KEY (`requested_room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL,
  CONSTRAINT `room_change_requests_ibfk_4` FOREIGN KEY (`requested_block_id`) REFERENCES `blocks` (`id`) ON DELETE SET NULL,
  CONSTRAINT `room_change_requests_ibfk_5` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_change_requests`
--

LOCK TABLES `room_change_requests` WRITE;
/*!40000 ALTER TABLE `room_change_requests` DISABLE KEYS */;
INSERT INTO `room_change_requests` VALUES (1,7,NULL,NULL,1,'need to change','need to change','Double','approved',1,'2026-02-08 15:44:07',NULL,'2026-02-08 15:36:35','2026-02-08 15:44:07'),(2,8,NULL,NULL,1,'need to change to another room','need to change to another room','Double','approved',2,'2026-02-10 16:34:14',NULL,'2026-02-10 16:30:15','2026-02-10 16:34:14'),(3,9,NULL,NULL,1,'In room water is leaking','In room water is leaking','Double','approved',2,'2026-02-12 05:29:33',NULL,'2026-02-12 05:25:41','2026-02-12 05:29:33'),(4,10,NULL,NULL,1,'want to change the request','want to change the request',NULL,'approved',2,'2026-02-12 06:11:40',NULL,'2026-02-12 06:11:06','2026-02-12 06:11:40'),(5,9,NULL,NULL,1,'for fun','for fun',NULL,'approved',2,'2026-02-12 06:13:10',NULL,'2026-02-12 06:12:51','2026-02-12 06:13:10'),(6,7,136,137,1,'wanna change the room','wanna change the room','102','approved',2,'2026-03-14 04:56:16',NULL,'2026-03-14 04:22:08','2026-03-14 04:56:16'),(7,7,136,138,1,'i not willing to stay in this room','i not willing to stay in this room','103','rejected',2,'2026-03-14 04:53:33','Room not available','2026-03-14 04:23:51','2026-03-14 04:53:33');
/*!40000 ALTER TABLE `room_change_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rooms`
--

DROP TABLE IF EXISTS `rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rooms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `block_id` int NOT NULL,
  `room_number` varchar(20) NOT NULL,
  `floor` int DEFAULT NULL,
  `capacity` int NOT NULL DEFAULT '2',
  `occupied_count` int NOT NULL DEFAULT '0',
  `room_type` enum('single','shared','suite') DEFAULT 'shared',
  `rent_per_month` decimal(10,2) DEFAULT NULL,
  `amenities` text,
  `status` enum('available','full','maintenance') DEFAULT 'available',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_room` (`block_id`,`room_number`),
  KEY `idx_room_number` (`room_number`),
  KEY `idx_status` (`status`),
  KEY `idx_room_type` (`room_type`),
  CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`block_id`) REFERENCES `blocks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rooms_chk_1` CHECK ((`occupied_count` <= `capacity`))
) ENGINE=InnoDB AUTO_INCREMENT=180 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rooms`
--

LOCK TABLES `rooms` WRITE;
/*!40000 ALTER TABLE `rooms` DISABLE KEYS */;
INSERT INTO `rooms` VALUES (136,1,'101',NULL,4,4,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','full','2026-03-08 18:50:36'),(137,1,'102',NULL,4,4,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','full','2026-03-08 18:50:36'),(138,1,'103',NULL,4,1,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(139,1,'104',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(140,1,'201',NULL,5,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(141,1,'202',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(142,1,'203',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(146,1,'303',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(147,1,'304',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(148,1,'401',NULL,5,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(150,1,'403',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:36'),(152,2,'101',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(153,2,'102',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(154,2,'103',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(155,2,'104',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(156,2,'201',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(157,2,'202',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(158,2,'203',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(159,2,'204',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(160,2,'301',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(161,2,'302',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(162,2,'303',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(163,2,'304',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(164,2,'401',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(165,2,'402',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(166,2,'403',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(168,2,'501',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(169,2,'502',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(170,2,'503',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(171,2,'504',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:50:40'),(172,5,'001',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30'),(173,5,'002',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30'),(174,5,'003',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30'),(175,5,'004',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30'),(176,5,'101',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30'),(177,5,'102',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30'),(178,5,'103',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30'),(179,5,'104',NULL,4,0,'shared',NULL,'WiFi, Study Table, Wardrobe, Ceiling Fan','available','2026-03-08 18:51:30');
/*!40000 ALTER TABLE `rooms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `migration_name` varchar(255) NOT NULL,
  `applied_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `migration_name` (`migration_name`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES (1,'2026_02_09_expand_complaint_categories.sql','2026-03-09 15:36:39'),(2,'2026_02_09_seed_mess_menu.sql','2026-03-09 15:36:40'),(3,'2026_02_11_add_staff_id.sql','2026-03-09 15:36:40'),(4,'2026_02_12_add_floor_preference.sql','2026-03-09 15:36:40'),(5,'2026_02_17_add_outpass_agentic_monitoring.sql','2026-03-09 15:36:40'),(6,'2026_02_17_add_parent_email.sql','2026-03-09 15:36:40'),(7,'2026_02_18_add_holiday_mode_otp.sql','2026-03-09 15:36:40'),(8,'2026_03_08_add_block_gender.sql','2026-03-09 15:36:40'),(9,'2026_03_08_add_complaint_agentic_monitoring.sql','2026-03-09 15:36:40'),(10,'2026_03_08_add_leave_agentic_monitoring.sql','2026-03-09 15:36:40'),(11,'2026_03_08_add_security_agentic_monitoring.sql','2026-03-09 15:36:40'),(12,'2026_03_09_harden_auth_otp.sql','2026-03-09 15:36:40'),(13,'2026_03_09_add_audit_logs.sql','2026-03-09 15:43:57'),(14,'2026_03_09_add_default_room_amenities.sql','2026-03-09 17:40:45');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `security_agentic_alerts`
--

DROP TABLE IF EXISTS `security_agentic_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `security_agentic_alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int DEFAULT NULL,
  `related_outpass_id` int DEFAULT NULL,
  `alert_type` enum('late_return','missing_return','night_movement','unauthorized_exit_attempt','repeat_violation','risk_escalation','recommendation') NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `detection_key` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `metadata_json` json DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `detection_key` (`detection_key`),
  KEY `student_id` (`student_id`),
  KEY `related_outpass_id` (`related_outpass_id`),
  KEY `idx_security_alert_type` (`alert_type`),
  KEY `idx_security_alert_severity` (`severity`),
  KEY `idx_security_alert_created_at` (`created_at`),
  KEY `idx_security_alert_is_read` (`is_read`),
  CONSTRAINT `security_agentic_alerts_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `security_agentic_alerts_ibfk_2` FOREIGN KEY (`related_outpass_id`) REFERENCES `outpasses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=40299 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `security_agentic_alerts`
--

LOCK TABLES `security_agentic_alerts` WRITE;
/*!40000 ALTER TABLE `security_agentic_alerts` DISABLE KEYS */;
INSERT INTO `security_agentic_alerts` VALUES (1,1,9,'missing_return','critical','missing_return_9','Missing Student After Outpass Return Time','K. Rajesh Kumar (23R21A6601) has not returned after approved outpass return time. Delay: 20 days 20:32 hours.','{\"status\": \"overdue\", \"late_minutes\": 30032}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(2,7,10,'missing_return','critical','missing_return_10','Missing Student After Outpass Return Time','CH Sathwik Reddy (23R21A6675) has not returned after approved outpass return time. Delay: 21 days 2:32 hours.','{\"status\": \"overdue\", \"late_minutes\": 30392}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(3,8,11,'missing_return','critical','missing_return_11','Missing Student After Outpass Return Time','S. Phanindher Reddy (23R21A66J3) has not returned after approved outpass return time. Delay: 20 days 14:30 hours.','{\"status\": \"overdue\", \"late_minutes\": 29670}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(4,1,12,'missing_return','critical','missing_return_12','Missing Student After Outpass Return Time','K. Rajesh Kumar (23R21A6601) has not returned after approved outpass return time. Delay: 20 days 16:30 hours.','{\"status\": \"overdue\", \"late_minutes\": 29790}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(5,7,13,'missing_return','critical','missing_return_13','Missing Student After Outpass Return Time','CH Sathwik Reddy (23R21A6675) has not returned after approved outpass return time. Delay: 20 days 19:00 hours.','{\"status\": \"overdue\", \"late_minutes\": 29940}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(6,7,14,'missing_return','critical','missing_return_14','Missing Student After Outpass Return Time','CH Sathwik Reddy (23R21A6675) has not returned after approved outpass return time. Delay: 16 days 20:30 hours.','{\"status\": \"overdue\", \"late_minutes\": 24270}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(7,12,15,'missing_return','critical','missing_return_15','Missing Student After Outpass Return Time','K NIKHIL (23R21A66F6) has not returned after approved outpass return time. Delay: 17 days 4:25 hours.','{\"status\": \"overdue\", \"late_minutes\": 24745}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(8,12,16,'missing_return','critical','missing_return_16','Missing Student After Outpass Return Time','K NIKHIL (23R21A66F6) has not returned after approved outpass return time. Delay: 16 days 3:07 hours.','{\"status\": \"overdue\", \"late_minutes\": 23227}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(9,7,3,'night_movement','medium','night_movement_6','Restricted Hours Movement Detected','Night movement logged for CH Sathwik Reddy (23R21A6675) during restricted hours.','{\"log_id\": 6, \"timestamp\": \"2026-02-10T23:14:23\"}',0,'2026-03-08 12:34:28','2026-03-12 17:44:02'),(10,7,3,'night_movement','medium','night_movement_5','Restricted Hours Movement Detected','Night movement logged for CH Sathwik Reddy (23R21A6675) during restricted hours.','{\"log_id\": 5, \"timestamp\": \"2026-02-10T23:14:17\"}',0,'2026-03-08 12:34:28','2026-03-12 17:44:02'),(11,8,6,'night_movement','medium','night_movement_4','Restricted Hours Movement Detected','Night movement logged for S. Phanindher Reddy (23R21A66J3) during restricted hours.','{\"log_id\": 4, \"timestamp\": \"2026-02-10T23:14:10\"}',0,'2026-03-08 12:34:28','2026-03-12 17:44:02'),(12,8,6,'night_movement','medium','night_movement_3','Restricted Hours Movement Detected','Night movement logged for S. Phanindher Reddy (23R21A66J3) during restricted hours.','{\"log_id\": 3, \"timestamp\": \"2026-02-10T23:14:05\"}',0,'2026-03-08 12:34:28','2026-03-12 17:44:02'),(13,8,5,'night_movement','medium','night_movement_2','Restricted Hours Movement Detected','Night movement logged for S. Phanindher Reddy (23R21A66J3) during restricted hours.','{\"log_id\": 2, \"timestamp\": \"2026-02-10T23:11:01\"}',0,'2026-03-08 12:34:28','2026-03-12 17:40:02'),(14,8,5,'night_movement','medium','night_movement_1','Restricted Hours Movement Detected','Night movement logged for S. Phanindher Reddy (23R21A66J3) during restricted hours.','{\"log_id\": 1, \"timestamp\": \"2026-02-10T23:05:26\"}',0,'2026-03-08 12:34:28','2026-03-12 17:35:02'),(15,1,NULL,'repeat_violation','medium','repeat_violation_1','Repeated Rule Violations','K. Rajesh Kumar (23R21A6601) has repeated security violations in last 30 days (late=2, unauthorized=0, missing=0, night=0).','{\"risk_level\": \"low\", \"risk_score\": 30, \"late_returns_30d\": 2, \"missing_returns_30d\": 0, \"night_movements_30d\": 0, \"unauthorized_exits_30d\": 0}',0,'2026-03-08 12:34:28','2026-03-14 14:14:20'),(16,7,NULL,'repeat_violation','high','repeat_violation_7','Repeated Rule Violations','CH Sathwik Reddy (23R21A6675) has repeated security violations in last 30 days (late=5, unauthorized=0, missing=0, night=0).','{\"risk_level\": \"high\", \"risk_score\": 75, \"late_returns_30d\": 5, \"missing_returns_30d\": 0, \"night_movements_30d\": 0, \"unauthorized_exits_30d\": 0}',0,'2026-03-08 12:34:28','2026-03-14 14:14:20'),(17,7,NULL,'risk_escalation','critical','risk_escalation_7','High Security Risk Student','CH Sathwik Reddy (23R21A6675) is marked HIGH risk with score 75.','{\"risk_level\": \"high\", \"risk_score\": 75}',0,'2026-03-08 12:34:28','2026-03-14 14:14:20'),(18,8,NULL,'repeat_violation','medium','repeat_violation_8','Repeated Rule Violations','S. Phanindher Reddy (23R21A66J3) has repeated security violations in last 30 days (late=2, unauthorized=0, missing=0, night=0).','{\"risk_level\": \"low\", \"risk_score\": 30, \"late_returns_30d\": 2, \"missing_returns_30d\": 0, \"night_movements_30d\": 0, \"unauthorized_exits_30d\": 0}',0,'2026-03-08 12:34:28','2026-03-14 14:14:20'),(19,8,NULL,'risk_escalation','critical','risk_escalation_8','High Security Risk Student','S. Phanindher Reddy (23R21A66J3) is marked HIGH risk with score 77.','{\"risk_level\": \"high\", \"risk_score\": 77}',1,'2026-03-08 12:34:28','2026-03-11 12:51:10'),(20,12,NULL,'repeat_violation','medium','repeat_violation_12','Repeated Rule Violations','K NIKHIL (23R21A66F6) has repeated security violations in last 30 days (late=2, unauthorized=0, missing=0, night=0).','{\"risk_level\": \"low\", \"risk_score\": 30, \"late_returns_30d\": 2, \"missing_returns_30d\": 0, \"night_movements_30d\": 0, \"unauthorized_exits_30d\": 0}',0,'2026-03-08 12:34:28','2026-03-14 14:14:20'),(361,12,16,'late_return','high','late_return_16','Late Return Detected','K NIKHIL (23R21A66F6) returned 16 days 3:11 hours after approved time for outpass OP-16.','{\"final_status\": \"returned\", \"late_minutes\": 23231, \"grace_period_applied\": false}',1,'2026-03-08 12:47:25','2026-03-11 12:51:10'),(461,12,15,'late_return','high','late_return_15','Late Return Detected','K NIKHIL (23R21A66F6) returned 17 days 4:25 hours after approved time for outpass OP-15.','{\"final_status\": \"returned\", \"late_minutes\": 24745, \"grace_period_applied\": false}',1,'2026-03-08 12:50:46','2026-03-11 12:51:10'),(516,7,14,'late_return','high','late_return_14','Late Return Detected','CH Sathwik Reddy (23R21A6675) returned 16 days 20:30 hours after approved time for outpass OP-14.','{\"final_status\": \"returned\", \"late_minutes\": 24270, \"grace_period_applied\": false}',1,'2026-03-08 12:53:49','2026-03-11 12:51:10'),(517,8,11,'late_return','high','late_return_11','Late Return Detected','S. Phanindher Reddy (23R21A66J3) returned 20 days 14:31 hours after approved time for outpass OP-11.','{\"final_status\": \"returned\", \"late_minutes\": 29671, \"grace_period_applied\": false}',1,'2026-03-08 12:53:54','2026-03-11 12:51:10'),(518,1,12,'late_return','high','late_return_12','Late Return Detected','K. Rajesh Kumar (23R21A6601) returned 20 days 16:31 hours after approved time for outpass OP-12.','{\"final_status\": \"returned\", \"late_minutes\": 29791, \"grace_period_applied\": false}',1,'2026-03-08 12:53:58','2026-03-11 12:51:10'),(519,7,13,'late_return','high','late_return_13','Late Return Detected','CH Sathwik Reddy (23R21A6675) returned 20 days 19:01 hours after approved time for outpass OP-13.','{\"final_status\": \"returned\", \"late_minutes\": 29941, \"grace_period_applied\": false}',1,'2026-03-08 12:54:03','2026-03-11 12:51:10'),(546,1,9,'late_return','high','late_return_9','Late Return Detected','K. Rajesh Kumar (23R21A6601) returned 20 days 20:32 hours after approved time for outpass OP-9.','{\"final_status\": \"returned\", \"late_minutes\": 30032, \"grace_period_applied\": false}',1,'2026-03-08 12:55:21','2026-03-11 12:51:10'),(547,7,10,'late_return','high','late_return_10','Late Return Detected','CH Sathwik Reddy (23R21A6675) returned 21 days 2:32 hours after approved time for outpass OP-10.','{\"final_status\": \"returned\", \"late_minutes\": 30392, \"grace_period_applied\": false}',1,'2026-03-08 12:55:25','2026-03-11 12:51:10'),(548,7,7,'late_return','high','late_return_7','Late Return Detected','CH Sathwik Reddy (23R21A6675) returned 24 days 22:35 hours after approved time for outpass OP-7.','{\"final_status\": \"returned\", \"late_minutes\": 35915, \"grace_period_applied\": false}',1,'2026-03-08 12:55:29','2026-03-11 12:51:10'),(549,8,5,'late_return','high','late_return_5','Late Return Detected','S. Phanindher Reddy (23R21A66J3) returned 26 days 0:15 hours after approved time for outpass OP-5.','{\"final_status\": \"returned\", \"late_minutes\": 37455, \"grace_period_applied\": false}',1,'2026-03-08 12:55:35','2026-03-11 12:51:10'),(31632,7,19,'missing_return','critical','missing_return_19','Missing Student After Outpass Return Time','CH Sathwik Reddy (23R21A6675) has not returned after approved outpass return time. Delay: 6 days 19:45 hours.','{\"status\": \"overdue\", \"late_minutes\": 9825}',0,'2026-03-14 04:29:59','2026-03-14 08:15:02'),(35148,7,19,'late_return','high','late_return_19','Late Return Detected','CH Sathwik Reddy (23R21A6675) returned 6 days 19:45 hours after approved time for outpass OP-19.','{\"final_status\": \"returned\", \"late_minutes\": 9825, \"grace_period_applied\": false}',0,'2026-03-14 08:15:26','2026-03-14 08:15:26');
/*!40000 ALTER TABLE `security_agentic_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `security_logs`
--

DROP TABLE IF EXISTS `security_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `security_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `activity_type` enum('outpass','visitor','parcel','incident','patrol','emergency','other') NOT NULL,
  `description` text NOT NULL,
  `related_student_id` int DEFAULT NULL,
  `related_visitor_id` int DEFAULT NULL,
  `related_outpass_id` int DEFAULT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'low',
  `location` varchar(100) DEFAULT NULL,
  `logged_by` int NOT NULL,
  `action_taken` text,
  `follow_up_required` enum('yes','no') DEFAULT 'no',
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `related_student_id` (`related_student_id`),
  KEY `related_visitor_id` (`related_visitor_id`),
  KEY `related_outpass_id` (`related_outpass_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_severity` (`severity`),
  KEY `idx_logged_by` (`logged_by`),
  CONSTRAINT `security_logs_ibfk_1` FOREIGN KEY (`related_student_id`) REFERENCES `students` (`id`) ON DELETE SET NULL,
  CONSTRAINT `security_logs_ibfk_2` FOREIGN KEY (`related_visitor_id`) REFERENCES `visitors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `security_logs_ibfk_3` FOREIGN KEY (`related_outpass_id`) REFERENCES `outpasses` (`id`) ON DELETE SET NULL,
  CONSTRAINT `security_logs_ibfk_4` FOREIGN KEY (`logged_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `security_logs`
--

LOCK TABLES `security_logs` WRITE;
/*!40000 ALTER TABLE `security_logs` DISABLE KEYS */;
INSERT INTO `security_logs` VALUES (1,'outpass','Student S. Phanindher Reddy (23R21A66J3) marked as returned from outpass OP-5 (295 mins late)',8,NULL,5,'critical','Gate',5,'Student return recorded. Status: overdue. Late: 295 mins. Notes: Student returned','yes','2026-02-10 17:35:26'),(2,'outpass','Student S. Phanindher Reddy (23R21A66J3) marked as returned from outpass OP-5 (301 mins late)',8,NULL,5,'critical','Gate',5,'Student return recorded. Status: overdue. Late: 301 mins. Notes: Student returned','yes','2026-02-10 17:41:01'),(3,'outpass','Student S. Phanindher Reddy (23R21A66J3) marked as exited using outpass OP-6',8,NULL,6,'low','Gate',5,'Student exit recorded. Notes: Student exited','no','2026-02-10 17:44:05'),(4,'outpass','Student S. Phanindher Reddy (23R21A66J3) marked as returned from outpass OP-6',8,NULL,6,'low','Gate',5,'Student return recorded. Status: returned. Late: 0 mins. Notes: Student returned','no','2026-02-10 17:44:10'),(5,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as exited using outpass OP-3',7,NULL,3,'low','Gate',5,'Student exit recorded. Notes: Student exited','no','2026-02-10 17:44:17'),(6,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as returned from outpass OP-3',7,NULL,3,'low','Gate',5,'Student return recorded. Status: returned. Late: 0 mins. Notes: Student returned','no','2026-02-10 17:44:23'),(7,'visitor','Visitor Navaroj allowed entry. Visiting student: S. Phanindher Reddy (23R21A66J3). Room: 101. Purpose: To give documents',8,1,NULL,'low','Room 101',5,'Visitor entry recorded','no','2026-02-10 18:19:36'),(8,'outpass','Student V Shiva Kumar (24R25A6620) marked as exited using outpass OP-8',9,NULL,8,'low','Gate',5,'Student exit recorded. Notes: Student exited','no','2026-02-12 05:30:44'),(9,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as exited using outpass OP-7',7,NULL,7,'low','Gate',5,'Student exit recorded. Notes: Student exited','no','2026-02-12 05:38:42'),(10,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as returned from outpass OP-7 (918 mins late)',7,NULL,7,'critical','Gate',5,'Student return recorded. Status: overdue. Late: 918 mins. Notes: Student returned','yes','2026-02-12 05:38:51'),(11,'outpass','Student V Shiva Kumar (24R25A6620) marked as returned from outpass OP-8',9,NULL,8,'low','Gate',5,'Student return recorded. Status: returned. Late: 0 mins. Notes: Student returned','no','2026-02-12 05:39:37'),(12,'visitor','Visitor PNR allowed entry. Visiting student: S. Phanindher Reddy (23R21A66J3). Room: 101. Purpose: To give documents',8,2,NULL,'low','Room 101',5,'Visitor entry recorded','no','2026-02-19 09:09:05'),(13,'outpass','Student K NIKHIL (23R21A66F6) marked as returned from outpass OP-16 (16 days 3:08 hours late)',12,NULL,16,'critical','Gate',5,'Student return recorded. Status: overdue. Late: 16 days 3:08 hours. Notes: Student returned','yes','2026-03-08 12:47:25'),(14,'outpass','Student K NIKHIL (23R21A66F6) marked as returned from outpass OP-16 (16 days 3:08 hours late)',12,NULL,16,'critical','Gate',5,'Student return recorded. Status: overdue. Late: 16 days 3:08 hours. Notes: Student returned','yes','2026-03-08 12:47:38'),(15,'outpass','Student K NIKHIL (23R21A66F6) marked as returned from outpass OP-16 (16 days 3:08 hours late)',12,NULL,16,'critical','Gate',5,'Student return recorded. Status: overdue. Late: 16 days 3:08 hours. Notes: Student returned','yes','2026-03-08 12:47:43'),(16,'outpass','Student K NIKHIL (23R21A66F6) marked as returned from outpass OP-16 (16 days 3:09 hours late)',12,NULL,16,'critical','Gate',5,'Student return recorded. Status: overdue. Late: 16 days 3:09 hours. Notes: Student returned','yes','2026-03-08 12:48:48'),(17,'outpass','Student K NIKHIL (23R21A66F6) marked as returned from outpass OP-16 (16 days 3:11 hours late)',12,NULL,16,'critical','Gate',5,'Student return recorded. Status: returned. Late: 16 days 3:11 hours. Notes: Student returned','yes','2026-03-08 12:50:35'),(18,'outpass','Student K NIKHIL (23R21A66F6) marked as returned from outpass OP-15 (17 days 4:25 hours late)',12,NULL,15,'critical','Gate',5,'Student return recorded. Status: returned. Late: 17 days 4:25 hours. Notes: Student returned','yes','2026-03-08 12:50:46'),(19,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as returned from outpass OP-14 (16 days 20:30 hours late)',7,NULL,14,'critical','Gate',5,'Student return recorded. Status: returned. Late: 16 days 20:30 hours. Notes: Student returned','yes','2026-03-08 12:53:49'),(20,'outpass','Student S. Phanindher Reddy (23R21A66J3) marked as returned from outpass OP-11 (20 days 14:31 hours late)',8,NULL,11,'critical','Gate',5,'Student return recorded. Status: returned. Late: 20 days 14:31 hours. Notes: Student returned','yes','2026-03-08 12:53:54'),(21,'outpass','Student K. Rajesh Kumar (23R21A6601) marked as returned from outpass OP-12 (20 days 16:31 hours late)',1,NULL,12,'critical','Gate',5,'Student return recorded. Status: returned. Late: 20 days 16:31 hours. Notes: Student returned','yes','2026-03-08 12:53:58'),(22,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as returned from outpass OP-13 (20 days 19:01 hours late)',7,NULL,13,'critical','Gate',5,'Student return recorded. Status: returned. Late: 20 days 19:01 hours. Notes: Student returned','yes','2026-03-08 12:54:03'),(23,'outpass','Student K. Rajesh Kumar (23R21A6601) marked as returned from outpass OP-9 (20 days 20:32 hours late)',1,NULL,9,'critical','Gate',5,'Student return recorded. Status: returned. Late: 20 days 20:32 hours. Notes: Student returned','yes','2026-03-08 12:55:21'),(24,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as returned from outpass OP-10 (21 days 2:32 hours late)',7,NULL,10,'critical','Gate',5,'Student return recorded. Status: returned. Late: 21 days 2:32 hours. Notes: Student returned','yes','2026-03-08 12:55:25'),(25,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as returned from outpass OP-7 (24 days 22:35 hours late)',7,NULL,7,'critical','Gate',5,'Student return recorded. Status: returned. Late: 24 days 22:35 hours. Notes: Student returned','yes','2026-03-08 12:55:29'),(26,'outpass','Student S. Phanindher Reddy (23R21A66J3) marked as returned from outpass OP-5 (26 days 0:15 hours late)',8,NULL,5,'critical','Gate',5,'Student return recorded. Status: returned. Late: 26 days 0:15 hours. Notes: Student returned','yes','2026-03-08 12:55:35'),(27,'outpass','Student CH Sathwik Reddy (23R21A6675) marked as returned from outpass OP-19 (6 days 19:45 hours late)',7,NULL,19,'critical','Gate',5,'Student return recorded. Status: returned. Late: 6 days 19:45 hours. Notes: Student returned','yes','2026-03-14 08:15:26'),(28,'visitor','Visitor Copilot Visitor allowed entry. Visiting student: M Aravind  (23R21A66G5). Room: 102. Purpose: Document handover',10,3,NULL,'low','Room 102',5,'Visitor entry recorded','no','2026-03-14 08:18:04'),(29,'visitor','Visitor Navaroj allowed entry. Visiting student: S. Phanindher Reddy (23R21A66J3). Room: 101. Purpose: To give documents',8,4,NULL,'low','Room 101',5,'Visitor entry recorded','no','2026-03-14 08:19:10'),(30,'visitor','Visitor Regression Visitor allowed entry. Visiting student: M Aravind  (23R21A66G5). Room: 102. Purpose: Exit log verification',10,5,NULL,'low','Room 102',5,'Visitor entry recorded','no','2026-03-14 08:24:38'),(31,'visitor','Visitor Regression Visitor marked as exited. Visited student: M Aravind  (23R21A66G5). Room: 102',10,5,NULL,'low','Room 102',5,'Visitor exit recorded','no','2026-03-14 08:24:59');
/*!40000 ALTER TABLE `security_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `security_personnel`
--

DROP TABLE IF EXISTS `security_personnel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `security_personnel` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `employee_id` varchar(50) NOT NULL,
  `shift_timing` varchar(50) DEFAULT NULL,
  `gate_assigned` varchar(50) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `idx_employee_id` (`employee_id`),
  CONSTRAINT `security_personnel_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `security_personnel`
--

LOCK TABLES `security_personnel` WRITE;
/*!40000 ALTER TABLE `security_personnel` DISABLE KEYS */;
INSERT INTO `security_personnel` VALUES (1,5,'SEC751','Morning','Block A','0000000000','2026-02-11 13:07:02');
/*!40000 ALTER TABLE `security_personnel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `security_student_risk_profiles`
--

DROP TABLE IF EXISTS `security_student_risk_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `security_student_risk_profiles` (
  `student_id` int NOT NULL,
  `risk_score` int DEFAULT '0',
  `risk_level` enum('low','medium','high') DEFAULT 'low',
  `late_returns_30d` int DEFAULT '0',
  `missing_returns_30d` int DEFAULT '0',
  `unauthorized_exits_30d` int DEFAULT '0',
  `night_movements_30d` int DEFAULT '0',
  `violation_count_30d` int DEFAULT '0',
  `last_incident_at` datetime DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`),
  KEY `idx_security_risk_level` (`risk_level`),
  KEY `idx_security_risk_score` (`risk_score`),
  KEY `idx_security_violation_count` (`violation_count_30d`),
  CONSTRAINT `security_student_risk_profiles_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `security_student_risk_profiles`
--

LOCK TABLES `security_student_risk_profiles` WRITE;
/*!40000 ALTER TABLE `security_student_risk_profiles` DISABLE KEYS */;
INSERT INTO `security_student_risk_profiles` VALUES (1,30,'low',2,0,0,0,2,'2026-03-14 19:44:20','2026-03-14 14:14:20'),(7,75,'high',5,0,0,0,5,'2026-03-14 19:44:20','2026-03-14 14:14:20'),(8,30,'low',2,0,0,0,2,'2026-03-14 19:44:20','2026-03-14 14:14:20'),(9,0,'low',0,0,0,0,0,'2026-03-14 19:44:20','2026-03-14 14:14:20'),(10,0,'low',0,0,0,0,0,'2026-03-14 19:44:20','2026-03-14 14:14:20'),(12,30,'low',2,0,0,0,2,'2026-03-14 19:44:20','2026-03-14 14:14:20'),(13,0,'low',0,0,0,0,0,'2026-03-14 19:44:20','2026-03-14 14:14:20');
/*!40000 ALTER TABLE `security_student_risk_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `roll_number` varchar(50) NOT NULL,
  `college_name` varchar(150) DEFAULT NULL,
  `branch` varchar(100) DEFAULT NULL,
  `year` varchar(20) DEFAULT NULL,
  `room_id` int DEFAULT NULL,
  `fee_status` enum('paid','pending','overdue') DEFAULT 'pending',
  `registration_status` enum('pending','approved','rejected') DEFAULT 'pending',
  `phone` varchar(20) DEFAULT NULL,
  `parent_phone` varchar(20) DEFAULT NULL,
  `parent_name` varchar(100) DEFAULT NULL,
  `parent_email` varchar(150) DEFAULT NULL,
  `address` text,
  `blood_group` varchar(10) DEFAULT NULL,
  `emergency_contact` varchar(20) DEFAULT NULL,
  `payment_proof_url` varchar(500) DEFAULT NULL,
  `preferred_block` varchar(50) DEFAULT NULL,
  `floor_preference` varchar(50) DEFAULT NULL,
  `room_preference` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `gender` enum('male','female','other') DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `roll_number` (`roll_number`),
  KEY `idx_roll_number` (`roll_number`),
  KEY `idx_registration_status` (`registration_status`),
  KEY `idx_fee_status` (`fee_status`),
  KEY `fk_student_room` (`room_id`),
  KEY `idx_college_name` (`college_name`),
  CONSTRAINT `fk_student_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL,
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (1,1,'23R21A6601','Marri Laxman Reddy Institute of Technology and Management (MLRITM)','CSE','3rd Year',136,'paid','approved','9876543210','9876543210','Kumar',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-02-08 07:05:37','2026-03-08 19:03:42',NULL),(7,22,'23R21A6675','MLR Institute of Technology (MLRIT)','CSE (AIML)','3rd Year',137,'paid','approved','8121099999','9908157266','CH Yella Reddy',NULL,NULL,NULL,NULL,'/api/files/payment-proof/ddd58dba3669c07b_background_demo.jpg',NULL,NULL,NULL,'2026-02-08 13:57:54','2026-03-14 04:56:16',NULL),(8,23,'23R21A66J3','MLR Institute of Technology (MLRIT)','CSE (AIML)','3rd Year',136,'paid','approved','7396396190','9994612027','wredsfghbnjm',NULL,NULL,NULL,NULL,'/api/files/payment-proof/1aaed986f1be5963_ddd58dba3669c07b_background_demo.jpg','Block A',NULL,'Double Sharing','2026-02-08 16:33:36','2026-03-08 19:03:42',NULL),(9,29,'24R25A6620','MLR Institute of Technology (MLRIT)','CSE (AIML)','3rd Year',136,'paid','approved','6302525651','9908185201','sdcfvbfghjkl',NULL,NULL,NULL,NULL,NULL,'Block A',NULL,NULL,'2026-02-12 05:20:47','2026-03-08 19:03:42','male'),(10,30,'23R21A66G5','MLR Institute of Technology (MLRIT)','CSE (AIML)','3rd',137,'paid','approved','8520852020','9521095210','sdfghjklsdfghjk',NULL,NULL,NULL,NULL,'/api/files/payment-proof/14abe2753b8b09ce_ddd58dba3669c07b_background_demo.jpg','Block A',NULL,NULL,'2026-02-12 05:48:07','2026-03-08 19:03:42','male'),(12,37,'23R21A66F6','MLR Institute of Technology (MLRIT)','CSE (AIML)','3rd Year',137,'paid','approved','7410741085','9510951020','K Srinivas','nikhilkanneboina206@gmail.com',NULL,NULL,NULL,NULL,'Block A','1st Floor',NULL,'2026-02-18 08:20:31','2026-03-08 19:03:42','male'),(13,56,'25R21B4330','Institute of Aeronautical Engineering (IARE)','CSE','2nd Year',138,'pending','approved','9876543210','9123456780','Workflow Parent','parentworkflow434330@example.com','Rejection Reason: Rejected by admin',NULL,NULL,NULL,'Block A','2nd Floor',NULL,'2026-03-14 08:37:30','2026-03-14 09:35:27','male');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `description` varchar(255) DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'college_holiday_mode','true',NULL,2,'2026-02-18 08:24:38','2026-03-14 05:54:40');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `technicians`
--

DROP TABLE IF EXISTS `technicians`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technicians` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `employee_id` varchar(50) NOT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `alternate_phone` varchar(20) DEFAULT NULL,
  `shift_timing` varchar(50) DEFAULT NULL,
  `availability_status` enum('available','busy','on_leave','off_duty') DEFAULT 'available',
  `expertise_areas` text,
  `assigned_blocks` text,
  `rating` decimal(3,2) DEFAULT NULL,
  `total_complaints_resolved` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_specialization` (`specialization`),
  KEY `idx_availability` (`availability_status`),
  CONSTRAINT `technicians_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `technicians_chk_1` CHECK (((`rating` is null) or ((`rating` >= 0) and (`rating` <= 5))))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `technicians`
--

LOCK TABLES `technicians` WRITE;
/*!40000 ALTER TABLE `technicians` DISABLE KEYS */;
INSERT INTO `technicians` VALUES (1,4,'EMP001','HVAC','9876543210','','8AM-5PM','available','',NULL,NULL,0,'2026-02-09 12:52:40','2026-02-09 13:13:42'),(2,24,'EMP002','Plumbing','9876543211','','10AM-7PM','available','',NULL,NULL,0,'2026-02-09 12:57:46','2026-03-13 19:07:40'),(3,25,'EMP003','Carpentry','9876543212','','9AM-6PM','available','','Block A, Block B',NULL,0,'2026-02-09 13:02:16','2026-02-09 13:13:34'),(4,26,'EMP004','Electrical','9876543213','',NULL,'available','fans and lights',NULL,NULL,0,'2026-02-09 13:12:36','2026-03-14 04:57:08'),(5,27,'EMP005','HVAC','9876543214','',NULL,'available','',NULL,NULL,0,'2026-02-09 13:12:43','2026-03-14 05:01:09'),(14,55,'TEC552','Electrical','9746120852',NULL,NULL,'available',NULL,NULL,NULL,0,'2026-03-14 08:31:42','2026-03-14 08:31:42');
/*!40000 ALTER TABLE `technicians` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `staff_id` varchar(10) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('student','warden','admin','technician','security') NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `roll_number` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `roll_number` (`roll_number`),
  UNIQUE KEY `staff_id` (`staff_id`),
  KEY `idx_email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_staff_id` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'K. Rajesh Kumar','student@hostel.edu','USR308',NULL,'scrypt:32768:8:1$Yh3lfsZN7wGjlJo2$f2f6e0b7cce7e328d6aeed8950e160035666fc479ddc7f45f796de186e5f4bbdfea930e02e779eabf43d9350111301595138a668827d0ab8956eafb62433ea8e','student','active','2026-02-08 06:57:50','2026-03-13 19:38:39','CS2021049'),(2,'Mr. Sharma','warden@hostel.edu','WAR337',NULL,'scrypt:32768:8:1$xloXhh7iC0ERrcbN$f599fc770ac846ac01da53a6d4f14ba81c541134004a5f34c3eb035b1debb7108dafb47abc7e07218dd2bfa14f1fb4d5e45615940abbc34d16b8d28d80594082','warden','active','2026-02-08 06:57:50','2026-02-10 18:33:49',NULL),(3,'Admin User','admin@hostel.edu','ADM992',NULL,'scrypt:32768:8:1$udhKeJUlMe5DvuYd$9dc35fbe9696debce1d4dd61b784db402b366255049301fff73fe2160b801e2cc8f43a257d2b7add78ee1a7bb0c13d056399674427dbc70f6f4d2671b6b52f7b','admin','active','2026-02-08 06:57:50','2026-02-11 13:02:39',NULL),(4,'Ramesh','technician@hostel.edu','TEC310',NULL,'scrypt:32768:8:1$c6yyZ9D66JHAVLNB$091c53ec4fd49e77eb1292bcc4ea7564ff60495ebf83d6f99967ae6f56a55aeb839d5c09962217fb91d6e0581fdecddef0e48ba5798caca87e345f4fc9880b26','technician','active','2026-02-08 06:57:50','2026-02-10 18:33:49',NULL),(5,'Suresh','security@hostel.edu','SEC751',NULL,'scrypt:32768:8:1$NbTOM3A4sBqSsnxd$7eae585c6bfba71cab5829b3e585dab6d5d3f2bf2271fa0de72f6af89366439a69ccb24bcdf3f220b27f77909565840b9bae7cd00c1e24f8d0c38243441c0297','security','active','2026-02-08 06:57:50','2026-03-13 09:36:19',NULL),(22,'CH Sathwik Reddy','challasathwikreddy55@gmail.com','USR668',NULL,'scrypt:32768:8:1$ny4lVDrJnbSmvYeJ$1a1875539e94f06a34c40ea5ed1db2853cd266848a6a5e7c1c7c374fbbf7be8cfd3d783af6d3f7f2e831696043892cc75e20a9f5680f021728e2beeaeca1a232','student','active','2026-02-08 13:57:54','2026-03-13 19:38:35','23R21A6675'),(23,'S. Phanindher Reddy','phanindhereddysundu@gmail.com','USR551',NULL,'scrypt:32768:8:1$t7Mp0FflHWpoTShg$99d9020fd74acd9800e8e21443024cf89f8381377f30d539820d768ba5b92bf937c7b75b8b5698801cbe89ba67d876fa6031fcbbad085f8ff2c60de22472a24f','student','active','2026-02-08 16:33:36','2026-03-13 19:39:00','23R21A66J3'),(24,'Kumar Singh','kumar.plumbing@hostel.edu','TEC116',NULL,'scrypt:32768:8:1$IiPvncKF9RKWhPAS$8045d1ab451dbbeb4e61971b70212952233c6212d0e3fc053acb6b3ba0c10df354e9b3b4ad536ab5c84a46680d4c3f1986c42f0cf67afa148844b680a1ea474c','technician','active','2026-02-09 12:57:46','2026-03-14 05:47:48',NULL),(25,'Vijay','vijay.carpentry@hostel.edu','TEC889',NULL,'scrypt:32768:8:1$mZ6jsZMik4oEwBKE$ec7b07e97a1cc9ac09149daee855f23a07f08db4b796c473daa62d57decb7dc5a1e98e83f4bcfa8677a1066a863f578921a96e44f9701af7ff0e2ade71fb881f','technician','active','2026-02-09 13:02:16','2026-02-10 18:33:49',NULL),(26,'Rajesh','rajesh.technician@hostel.edu','TEC878',NULL,'scrypt:32768:8:1$u39Jxs7MczEj4qdT$626d0aa34185282942c67f1789cfdfc1c145b3b7a5ba37449222d3244b7633d15d7c0fb0d04b6f4c44e5b62249310012bdbcecc3b41dfef05a133e34d2bf2ace','technician','active','2026-02-09 13:12:36','2026-03-11 06:44:18',NULL),(27,'Sai','sai.wifi@hostel.edu','TEC298',NULL,'scrypt:32768:8:1$qAAFfIgoeeOL5Dsn$10e263601a23f89605621ccda3ce454986d600217d1aac279d6776653ef4d8407ad47a7a2493352ef06ee10e2eec79c6f9843710d408ab7f70f6c8c20038b05d','technician','active','2026-02-09 13:12:43','2026-03-14 05:01:09',NULL),(29,'V Shiva Kumar','shivavakkapathi@gmail.com',NULL,NULL,'scrypt:32768:8:1$aMEf6jKOI6491zLt$d37a91af8c1fba0f8d9d3fda760fc27d6e0431c5d6472c830812b43dea3cd9db38b56d3608178251feac5633a458ff33364c0df0668064a41e26581401f6540c','student','active','2026-02-12 05:20:47','2026-03-13 19:38:31','24R25A6620'),(30,'M Aravind ','maggidiaravind5@gmail.com',NULL,NULL,'scrypt:32768:8:1$Bg2QGu1S2WeyRPSr$82d90ac76e65a977fe094c9d2e8bb0230f44f49ad688da0f6421b58917608d7c91dda85ffa241f610d5887923fdd7a0008660dff38442a547639afe89a0b9bc0','student','active','2026-02-12 05:48:07','2026-03-13 19:38:26','23R21A66G5'),(37,'K NIKHIL','23R21A66F6@mlrit.ac.in',NULL,NULL,'scrypt:32768:8:1$Qsm6ekbOoAktKx0N$26e964c19a84b9b6321d4368681727f224cf16188e0ae393022eaaaffb5de8a0f3a8e15cf7f35dd7972a310fd40aa5024589839672c7e8c6b4dc63605448f519','student','active','2026-02-18 08:20:31','2026-02-18 08:22:10','23R21A66F6'),(42,'hbhjndsf','kjsdnf@gmail.com','SEC210',NULL,'scrypt:32768:8:1$yNCuDifBpnTsYXtI$452152472802e8e2b1e24faecc57b497f855c438e51b2a06d22eaa3f2516fdc309ed230926ade16fdf58a66add7b146e6c4ad60904242d3593888ad0a1847a19','security','active','2026-03-14 06:33:32','2026-03-14 06:33:32',NULL),(43,'hbhjndsf','kjsnf@gmail.com','SEC958',NULL,'scrypt:32768:8:1$frmumjwQ7FvidPsz$737d1e4b2716b2aa4f7d5bab93aaf16c2c8e752495c1a66e6ddb8800d0e463f65fa344698de830c7ee8981a5564a708b2c47af5fe0b1b213995d0177f3d452da','security','active','2026-03-14 06:33:56','2026-03-14 06:33:56',NULL),(55,'demo','demo@gmail.com','TEC552',NULL,'scrypt:32768:8:1$qUoCzjjSxnRnTZpY$45f2acf598304036506c0846808facf43fb1ed7d2fb348c3c4b391fe2af807e31c2eb707361246a358c107c7d26ae0f3478a15f48b0b95fe3b91c731fce66253','technician','active','2026-03-14 08:31:42','2026-03-14 08:31:42',NULL),(56,'Workflow Student 434330','workflow434330@example.com',NULL,NULL,'scrypt:32768:8:1$oWmTdwNo3cmeAogH$73b0919ed909f5b96f2b1045781279a3dae377095d0a7be0f63c0dd8d265bf81a3623c6c7f0342d5a558bebe6c74309541edebe8ba94ff1ee38583da24951304','student','active','2026-03-14 08:37:30','2026-03-14 09:35:22','25R21B4330');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `visitors`
--

DROP TABLE IF EXISTS `visitors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visitors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `visitor_name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `id_type` enum('aadhar','pan','driving_license','voter_id','other') NOT NULL,
  `id_number` varchar(50) NOT NULL,
  `student_id` int NOT NULL,
  `relationship` varchar(50) DEFAULT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `entry_time` datetime NOT NULL,
  `exit_time` datetime DEFAULT NULL,
  `status` enum('inside','exited','overstayed') DEFAULT 'inside',
  `approved_by` int DEFAULT NULL,
  `vehicle_number` varchar(20) DEFAULT NULL,
  `items_carried` text,
  `security_guard_id` int DEFAULT NULL,
  `photo_captured` enum('yes','no') DEFAULT 'no',
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `approved_by` (`approved_by`),
  KEY `security_guard_id` (`security_guard_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_status` (`status`),
  KEY `idx_entry_time` (`entry_time`),
  KEY `idx_id_number` (`id_number`),
  CONSTRAINT `visitors_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `visitors_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `visitors_ibfk_3` FOREIGN KEY (`security_guard_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `visitors`
--

LOCK TABLES `visitors` WRITE;
/*!40000 ALTER TABLE `visitors` DISABLE KEYS */;
INSERT INTO `visitors` VALUES (1,'Navaroj','9948548725','other','N/A',8,NULL,'To give documents','2026-02-10 23:49:35','2026-02-11 22:38:05','exited',NULL,NULL,NULL,5,'no',NULL,'2026-02-10 18:19:35','2026-02-11 17:08:05'),(2,'PNR','8520852085','other','N/A',8,NULL,'To give documents','2026-02-19 14:39:05','2026-02-20 11:27:13','exited',NULL,NULL,NULL,5,'no',NULL,'2026-02-19 09:09:05','2026-02-20 05:57:13'),(3,'Copilot Visitor','9876543211','other','N/A',10,NULL,'Document handover','2026-03-14 13:48:04','2026-03-14 13:48:40','exited',NULL,NULL,NULL,5,'no',NULL,'2026-03-14 08:18:04','2026-03-14 08:18:40'),(4,'Navaroj','9876543214','other','N/A',8,NULL,'To give documents','2026-03-14 13:49:10','2026-03-14 13:52:27','exited',NULL,NULL,NULL,5,'no',NULL,'2026-03-14 08:19:10','2026-03-14 08:22:27'),(5,'Regression Visitor','9876501234','other','N/A',10,NULL,'Exit log verification','2026-03-14 13:54:38','2026-03-14 13:54:59','exited',NULL,NULL,NULL,5,'no',NULL,'2026-03-14 08:24:38','2026-03-14 08:24:59');
/*!40000 ALTER TABLE `visitors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_active_students`
--

DROP TABLE IF EXISTS `vw_active_students`;
/*!50001 DROP VIEW IF EXISTS `vw_active_students`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_active_students` AS SELECT 
 1 AS `id`,
 1 AS `roll_number`,
 1 AS `name`,
 1 AS `email`,
 1 AS `branch`,
 1 AS `year`,
 1 AS `room_number`,
 1 AS `block_name`,
 1 AS `fee_status`,
 1 AS `phone`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_pending_outpasses`
--

DROP TABLE IF EXISTS `vw_pending_outpasses`;
/*!50001 DROP VIEW IF EXISTS `vw_pending_outpasses`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_pending_outpasses` AS SELECT 
 1 AS `id`,
 1 AS `student_id`,
 1 AS `roll_number`,
 1 AS `student_name`,
 1 AS `reason`,
 1 AS `destination`,
 1 AS `expected_return_time`,
 1 AS `created_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `wardens`
--

DROP TABLE IF EXISTS `wardens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wardens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `employee_id` varchar(50) NOT NULL,
  `hostel_block` varchar(50) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `office_location` varchar(100) DEFAULT NULL,
  `designation` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `idx_employee_id` (`employee_id`),
  CONSTRAINT `wardens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wardens`
--

LOCK TABLES `wardens` WRITE;
/*!40000 ALTER TABLE `wardens` DISABLE KEYS */;
INSERT INTO `wardens` VALUES (1,2,'WAR337','Block A','9876543210','Warden Office 1',NULL,'2026-02-11 16:31:49');
/*!40000 ALTER TABLE `wardens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `vw_active_students`
--

/*!50001 DROP VIEW IF EXISTS `vw_active_students`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_active_students` AS select `s`.`id` AS `id`,`s`.`roll_number` AS `roll_number`,`u`.`name` AS `name`,`u`.`email` AS `email`,`s`.`branch` AS `branch`,`s`.`year` AS `year`,`r`.`room_number` AS `room_number`,`b`.`block_name` AS `block_name`,`s`.`fee_status` AS `fee_status`,`s`.`phone` AS `phone` from (((`students` `s` join `users` `u` on((`s`.`user_id` = `u`.`id`))) left join `rooms` `r` on((`s`.`room_id` = `r`.`id`))) left join `blocks` `b` on((`r`.`block_id` = `b`.`id`))) where (`u`.`status` = 'active') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_pending_outpasses`
--

/*!50001 DROP VIEW IF EXISTS `vw_pending_outpasses`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_pending_outpasses` AS select `o`.`id` AS `id`,`o`.`student_id` AS `student_id`,`s`.`roll_number` AS `roll_number`,`u`.`name` AS `student_name`,`o`.`reason` AS `reason`,`o`.`destination` AS `destination`,`o`.`expected_return_time` AS `expected_return_time`,`o`.`created_at` AS `created_at` from ((`outpasses` `o` join `students` `s` on((`o`.`student_id` = `s`.`id`))) join `users` `u` on((`s`.`user_id` = `u`.`id`))) where (`o`.`status` = 'pending') order by `o`.`created_at` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-14 19:44:53
