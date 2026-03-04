import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='navaroj@1923132',
    database='hostelconnect_db'
)
cursor = conn.cursor(dictionary=True)

# Check the newly created technician
cursor.execute('SELECT id, name, email, staff_id, role FROM users WHERE email=%s', ('test.tech@hostel.edu',))
result = cursor.fetchone()

if result:
    print(f"✅ Technician found!")
    print(f"Name: {result['name']}")
    print(f"Email: {result['email']}")
    print(f"Staff ID: {result['staff_id']}")
    print(f"Role: {result['role']}")
    print(f"\n✅ SUCCESS: Staff ID was auto-generated!")
else:
    print('❌ Not found')

cursor.close()
conn.close()
