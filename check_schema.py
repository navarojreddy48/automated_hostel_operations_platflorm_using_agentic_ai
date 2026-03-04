import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='navaroj@1923132',
    database='hostelconnect_db'
)
cursor = conn.cursor(dictionary=True)

# Check users table columns
print("=== USERS TABLE ===")
cursor.execute("DESC users")
for row in cursor.fetchall():
    print(f"{row['Field']}: {row['Type']}")

print("\n=== TECHNICIANS TABLE ===")
cursor.execute("DESC technicians")
for row in cursor.fetchall():
    print(f"{row['Field']}: {row['Type']}")

# Check if staff_id exists in both
print("\n=== VERIFICATION ===")
cursor.execute("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='users' AND COLUMN_NAME='staff_id'")
if cursor.fetchone():
    print("✅ staff_id exists in users table")
else:
    print("❌ staff_id NOT in users table")

cursor.execute("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='technicians' AND COLUMN_NAME='staff_id'")
if cursor.fetchone():
    print("✅ staff_id exists in technicians table")
else:
    print("❌ staff_id NOT in technicians table")

cursor.close()
conn.close()
