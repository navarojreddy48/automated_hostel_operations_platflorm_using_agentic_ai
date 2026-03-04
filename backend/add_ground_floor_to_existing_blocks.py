import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

def main():
    db_config = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'user': os.getenv('DB_USER', 'root'),
        'password': os.getenv('DB_PASSWORD', ''),
        'database': os.getenv('DB_NAME', 'hostelconnect_db')
    }

    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor(dictionary=True)

    cursor.execute("SELECT id, total_floors FROM blocks")
    blocks = cursor.fetchall()

    for block in blocks:
        block_id = block['id']
        cursor.execute("SELECT COUNT(*) as cnt FROM rooms WHERE block_id = %s AND room_number LIKE '0%%'", (block_id,))
        result = cursor.fetchone()
        if result['cnt'] == 0:
            # Get rooms_per_floor from any floor
            cursor.execute("SELECT COUNT(*) as cnt FROM rooms WHERE block_id = %s AND room_number LIKE '1%%'", (block_id,))
            floor_result = cursor.fetchone()
            rooms_per_floor = floor_result['cnt'] if floor_result else 4
            for room_num in range(1, rooms_per_floor + 1):
                room_number = f"0{room_num:02d}"
                cursor.execute("INSERT INTO rooms (block_id, room_number, capacity, status) VALUES (%s, %s, %s, 'available')", (block_id, room_number, 4))
            print(f"Added ground floor to block {block_id} with {rooms_per_floor} rooms.")
    connection.commit()
    cursor.close()
    connection.close()
    print("Ground floor addition complete.")

if __name__ == '__main__':
    main()
