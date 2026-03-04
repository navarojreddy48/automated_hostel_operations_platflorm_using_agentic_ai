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
print("BULK ADD PARENT EMAILS (AUTO-GENERATE FROM STUDENT EMAIL)")
print("="*70 + "\n")

# Get students without parent email
cursor.execute("""
    SELECT s.id, u.name, u.email, s.parent_name
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

print(f"Will auto-generate parent emails for {len(students)} students:\n")
print("Format: parent.[student_email]\n")

confirm = input("Proceed? (yes/no): ").strip().lower()

if confirm != 'yes':
    print("Cancelled.")
    cursor.close()
    conn.close()
    exit()

print()
updated = 0

for student in students:
    # Generate parent email from student email
    parent_email = f"parent.{student['email']}"
    
    try:
        cursor.execute("""
            UPDATE students 
            SET parent_email = %s 
            WHERE id = %s
        """, (parent_email, student['id']))
        conn.commit()
        print(f"✅ {student['name']}")
        print(f"   Student: {student['email']}")
        print(f"   Parent:  {parent_email}\n")
        updated += 1
    except Exception as e:
        print(f"❌ Error for {student['name']}: {e}\n")

print("="*70)
print(f"✅ Updated {updated} parent emails!")
print("="*70 + "\n")

# Show final status
cursor.execute("""
    SELECT u.name, s.parent_email 
    FROM students s 
    JOIN users u ON s.user_id = u.id 
    WHERE s.parent_email IS NOT NULL
    ORDER BY s.id
""")
results = cursor.fetchall()

print("All students with parent emails:")
for r in results:
    print(f"  • {r['name']:30} → {r['parent_email']}")

cursor.close()
conn.close()
