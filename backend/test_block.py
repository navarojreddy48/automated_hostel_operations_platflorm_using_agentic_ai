import mysql.connector

try:
    connection = mysql.connector.connect(
        host='localhost',
        user='root',
        password='navaroj@1923132',
        database='hostelconnect_db'
    )
    
    cursor = connection.cursor(dictionary=True)
    
    # Check the latest complaint
    cursor.execute("SELECT id, block_id, location, category FROM complaints ORDER BY id DESC LIMIT 3")
    results = cursor.fetchall()
    
    print("Latest Complaints:")
    for row in results:
        print(f"ID: {row['id']}, Block ID: {row['block_id']}, Location: {row['location']}, Category: {row['category']}")
    
    cursor.close()
    connection.close()
    
except Exception as e:
    print(f'Error: {e}')
