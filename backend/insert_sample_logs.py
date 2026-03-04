#!/usr/bin/env python3
"""
Insert sample security logs into the database for testing
"""
import mysql.connector
from datetime import datetime, timedelta

def get_db_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='navaroj@1923132',
        database='hostel'
    )

def insert_sample_logs():
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        
        # Get security user ID (assuming user_id 1 or first security personnel)
        cursor.execute("SELECT user_id FROM security_personnel LIMIT 1")
        result = cursor.fetchone()
        logged_by = result[0] if result else 1
        
        # Get some student IDs for testing
        cursor.execute("SELECT id FROM students LIMIT 5")
        students = [row[0] for row in cursor.fetchall()]
        
        # Sample log data
        logs = [
            ('outpass', 'Student exit recorded at main gate', students[0] if students else None, 'low', 'Gate A', logged_by, 'Student marked OUT', 'no'),
            ('visitor', 'Visitor entry registered for Room 204', None, 'low', 'Main Gate', logged_by, 'Visitor approved', 'no'),
            ('parcel', 'Parcel delivery logged', students[1] if len(students) > 1 else None, 'low', 'Reception', logged_by, 'Student notified', 'no'),
            ('outpass', 'Student return marked late', students[2] if len(students) > 2 else None, 'medium', 'Gate B', logged_by, 'Logged with note', 'yes'),
            ('incident', 'Suspicious activity reported', None, 'high', 'Corridor C', logged_by, 'Investigated and recorded', 'yes'),
            ('patrol', 'Evening patrol completed', None, 'low', 'Premises', logged_by, 'All areas secured', 'no'),
            ('emergency', 'Medical emergency reported', students[3] if len(students) > 3 else None, 'critical', 'Room A-105', logged_by, 'Ambulance called', 'yes'),
        ]
        
        # Insert logs with varying timestamps
        query = """
            INSERT INTO security_logs 
            (activity_type, description, related_student_id, severity, location, logged_by, action_taken, follow_up_required, timestamp)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        for i, (activity_type, description, student_id, severity, location, user_id, action, followup) in enumerate(logs):
            timestamp = datetime.now() - timedelta(hours=i*2)
            cursor.execute(query, (activity_type, description, student_id, severity, location, user_id, action, followup, timestamp))
        
        connection.commit()
        print(f"✅ Successfully inserted {len(logs)} sample security logs")
        
        cursor.close()
        connection.close()
        
    except Exception as e:
        print(f"❌ Error inserting logs: {e}")

if __name__ == '__main__':
    insert_sample_logs()
