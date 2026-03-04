import mysql.connector

# Database Configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'navaroj@1923132',
    'database': 'hostelconnect_db'
}

def test_parcels():
    """Test parcels data and endpoints"""
    print("=" * 60)
    print("Testing Parcels Data")
    print("=" * 60)
    
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor(dictionary=True)
        
        # Check students
        print("\n1. Checking Students:")
        cursor.execute("SELECT * FROM students LIMIT 1")
        sample = cursor.fetchone()
        if sample:
            print(f"   Student columns: {list(sample.keys())}")
        
        cursor.execute("SELECT id, user_id FROM students LIMIT 5")
        students = cursor.fetchall()
        if students:
            for s in students:
                # Get user info
                cursor.execute("SELECT name, email FROM users WHERE id = %s", (s['user_id'],))
                user = cursor.fetchone()
                user_name = user['name'] if user else 'Unknown'
                print(f"   Student: {user_name} (user_id={s['user_id']}, student_id={s['id']})")
        else:
            print("   No students found!")
            
        # Check parcels
        print("\n2. Checking Parcels:")
        cursor.execute("SELECT * FROM parcels")
        parcels = cursor.fetchall()
        
        if parcels:
            print(f"   Total parcels: {len(parcels)}")
            for p in parcels[:5]:  # Show first 5
                cursor.execute("""
                    SELECT u.name 
                    FROM students s 
                    JOIN users u ON s.user_id = u.id 
                    WHERE s.id = %s
                """, (p['student_id'],))
                student = cursor.fetchone()
                student_name = student['name'] if student else 'Unknown'
                print(f"   Parcel #{p['id']}: {p['parcel_type'] or 'Package'} for {student_name}")
                print(f"      Status: {p['status']}, Received: {p['received_date']}")
        else:
            print("   ✗ No parcels in database!")
            print("\n   Creating sample parcel...")
            
            # Get first student
            cursor.execute("SELECT id FROM students LIMIT 1")
            first_student = cursor.fetchone()
            
            if first_student:
                cursor.execute("""
                    INSERT INTO parcels 
                    (student_id, parcel_type, courier_name, sender_name, tracking_number, 
                     received_date, status, remarks)
                    VALUES (%s, %s, %s, %s, %s, CURDATE(), %s, %s)
                """, (
                    first_student['id'],
                    'Package',
                    'BlueDart',
                    'Amazon',
                    'TRACK123456',
                    'received',
                    'Sample parcel for testing'
                ))
                connection.commit()
                print(f"   ✓ Created sample parcel for student_id={first_student['id']}")
            else:
                print("   ✗ Cannot create sample - no students exist")
        
        # Test the API query
        print("\n3. Testing API Query Logic:")
        if students:
            test_user_id = students[0]['user_id']
            print(f"   Testing with user_id={test_user_id}")
            
            cursor.execute("SELECT id FROM students WHERE user_id = %s", (test_user_id,))
            student = cursor.fetchone()
            
            if student:
                print(f"   ✓ Found student_id={student['id']}")
                
                cursor.execute("""
                    SELECT p.*
                    FROM parcels p
                    WHERE p.student_id = %s
                    ORDER BY p.received_date DESC
                """, (student['id'],))
                student_parcels = cursor.fetchall()
                
                print(f"   ✓ Found {len(student_parcels)} parcels for this student")
                for p in student_parcels:
                    print(f"      - {p['parcel_type'] or 'Package'}: {p['status']}")
            else:
                print(f"   ✗ No student found for user_id={test_user_id}")
        
        cursor.close()
        connection.close()
        
        print("\n" + "=" * 60)
        print("Test Complete")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n✗ Error: {e}")

if __name__ == '__main__':
    test_parcels()
