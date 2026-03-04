import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='navaroj@1923132',
    database='hostelconnect_db'
)

cursor = conn.cursor()

# Find outpass-related tables
cursor.execute("SHOW TABLES LIKE '%outpass%'")
tables = cursor.fetchall()

print("Tables with 'outpass' in name:")
for table in tables:
    print(f"  - {table[0]}")

# Find all tables
cursor.execute("SHOW TABLES")
all_tables = cursor.fetchall()
print(f"\nAll tables ({len(all_tables)}):")
for table in sorted([t[0] for t in all_tables]):
    print(f"  - {table}")

cursor.close()
conn.close()
