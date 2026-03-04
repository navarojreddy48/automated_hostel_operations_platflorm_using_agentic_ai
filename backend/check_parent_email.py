import mysql.connector
import json

# Connect to database
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='navaroj@1923132',
    database='hostelconnect_db'
)

cursor = conn.cursor(dictionary=True)

print("=== Checking Parent Emails ===\n")

# Check students with parent emails
cursor.execute("""
    SELECT u.id as user_id, u.email, u.name, 
           s.parent_email, s.parent_name 
    FROM users u 
    JOIN students s ON u.id = s.user_id 
    WHERE u.role='student' 
    LIMIT 5
""")
results = cursor.fetchall()
print("Students with parent emails:")
print(json.dumps(results, indent=2, default=str))

print("\n=== Checking Tables ===\n")

# Find outpass table
cursor.execute("SHOW TABLES")
all_tables = cursor.fetchall()
print("All tables in database:")
for table in all_tables:
    table_name = list(table.values())[0] if isinstance(table, dict) else table[0]
    if 'outpass' in table_name.lower():
        print(f"  * {table_name} (outpass-related)")
    else:
        print(f"  - {table_name}")

print("\n=== Checking Outpasses ===\n")

# Check pending_otp outpasses
try:
    cursor.execute("""
        SELECT id, student_id, destination, status, 
               approval_method, otp_sent_at, otp_verified_at
        FROM outpasses 
        WHERE status = 'pending_otp'
        ORDER BY id DESC
        LIMIT 5
    """)
    outpasses = cursor.fetchall()
    print("Pending OTP outpasses:")
    print(json.dumps(outpasses, indent=2, default=str))
except Exception as e:
    print(f"Error querying outpasses: {e}")

cursor.close()
conn.close()
