import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='navaroj@1923132',
    database='hostelconnect_db'
)

cursor = conn.cursor(dictionary=True)

# Students WITH parent email
cursor.execute("""
    SELECT u.name, u.email, s.parent_email, s.parent_name
    FROM students s 
    JOIN users u ON s.user_id = u.id 
    WHERE s.parent_email IS NOT NULL
""")
has_email = cursor.fetchall()

# Students WITHOUT parent email
cursor.execute("SELECT COUNT(*) as total FROM students WHERE parent_email IS NULL")
no_email = cursor.fetchone()

print(f"\n{'='*60}")
print(f"PARENT EMAIL STATUS")
print(f"{'='*60}\n")

print(f"✅ Students WITH parent email: {len(has_email)}")
print(f"❌ Students WITHOUT parent email: {no_email['total']}\n")

if has_email:
    print("Students who CAN receive OTP:")
    print("-" * 60)
    for s in has_email:
        print(f"  • {s['name']:30} ({s['email']})")
        print(f"    → Parent: {s['parent_name']} <{s['parent_email']}>")
        print()
else:
    print("❌ NO students have parent email configured!\n")

print("=" * 60)
print("\nNOTE: Only students listed above can receive OTP emails.")
print("Other students will get error: 'Parent email not available'")
print("=" * 60)

cursor.close()
conn.close()
