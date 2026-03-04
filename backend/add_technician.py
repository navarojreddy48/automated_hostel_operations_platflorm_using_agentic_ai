import mysql.connector

# Connect to database
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='navaroj@1923132',
    database='hostelconnect_db'
)

cursor = conn.cursor()

# Insert technician profile for existing technician user
query = """
INSERT INTO technicians (user_id, employee_id, specialization, phone, shift_timing, availability_status, expertise_areas)
SELECT id, 'EMP001', 'Electrical & Plumbing', '9876543210', '9AM-6PM', 'available', 'Electrical repairs, Lighting, Power issues, Plumbing'
FROM users 
WHERE email = 'technician@hostel.edu' AND role = 'technician'
"""

cursor.execute(query)
conn.commit()

print(f'✓ Inserted {cursor.rowcount} technician record')

# Verify
cursor.execute("SELECT t.*, u.name, u.email FROM technicians t JOIN users u ON t.user_id = u.id")
results = cursor.fetchall()
print(f'\nTotal technicians in database: {len(results)}')
for row in results:
    print(f'  - {row[14]} ({row[15]}) - {row[3]} specialist')

cursor.close()
conn.close()
