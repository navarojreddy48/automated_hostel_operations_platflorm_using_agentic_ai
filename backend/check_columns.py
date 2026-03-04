import mysql.connector

db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'navaroj@1923132',
    'database': 'hostelconnect_db'
}

try:
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("DESCRIBE outpasses")
    columns = cursor.fetchall()
    
    print("Current columns in outpasses table:")
    print("-" * 80)
    for col in columns:
        print(f"{col['Field']:30} {col['Type']:20} {col['Null']:5} {col['Key']:5} {col['Default']}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"Error: {e}")
