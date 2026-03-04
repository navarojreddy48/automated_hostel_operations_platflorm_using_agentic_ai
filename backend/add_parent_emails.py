import mysql.connector

# Connect to database
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='navaroj@1923132',
    database='hostelconnect_db'
)

cursor = conn.cursor(dictionary=True)

print("\n" + "="*70)
print("ADD PARENT EMAILS FOR STUDENTS")
print("="*70 + "\n")

# Get students without parent email
cursor.execute("""
    SELECT s.id, s.user_id, u.name, u.email, s.parent_name
    FROM students s
    JOIN users u ON s.user_id = u.id
    WHERE s.parent_email IS NULL
    ORDER BY s.id
""")
students = cursor.fetchall()

if not students:
    print("✅ All students already have parent emails!\n")
    cursor.close()
    conn.close()
    exit()

print(f"Found {len(students)} students without parent email:\n")

# Update each student
for idx, student in enumerate(students, 1):
    print(f"{idx}. {student['name']} (ID: {student['id']})")
    print(f"   Student Email: {student['email']}")
    print(f"   Parent Name: {student['parent_name'] or 'Not set'}")
    
    parent_email = input(f"   Enter parent email (or press Enter to skip): ").strip()
    
    if parent_email:
        # Validate basic email format
        if '@' in parent_email and '.' in parent_email:
            try:
                cursor.execute("""
                    UPDATE students 
                    SET parent_email = %s 
                    WHERE id = %s
                """, (parent_email, student['id']))
                conn.commit()
                print(f"   ✅ Updated parent email to: {parent_email}\n")
            except Exception as e:
                print(f"   ❌ Error updating: {e}\n")
        else:
            print(f"   ❌ Invalid email format. Skipped.\n")
    else:
        print(f"   ⏭️  Skipped\n")

print("="*70)
print("Update complete!")
print("="*70 + "\n")

# Show final status
cursor.execute("SELECT COUNT(*) as total FROM students WHERE parent_email IS NOT NULL")
result = cursor.fetchone()
print(f"Students with parent email: {result['total']}")

cursor.close()
conn.close()
