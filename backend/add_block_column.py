import mysql.connector
from mysql.connector import Error

try:
    connection = mysql.connector.connect(
        host='localhost',
        user='root',
        password='navaroj@1923132',
        database='hostelconnect_db'
    )
    
    cursor = connection.cursor()
    
    # Check if column exists
    cursor.execute("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='complaints' AND COLUMN_NAME='block_id'")
    exists = cursor.fetchone()
    
    if not exists:
        # Add block_id column
        cursor.execute('ALTER TABLE complaints ADD COLUMN block_id INT')
        connection.commit()
        print('✓ block_id column added successfully')
    else:
        print('✓ block_id column already exists')
    
    cursor.close()
    connection.close()
    
except Error as e:
    print(f'Error: {e}')
