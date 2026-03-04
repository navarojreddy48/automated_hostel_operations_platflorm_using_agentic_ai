import mysql.connector
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def run_migration():
    """Run floor preference migration"""
    try:
        # Database connection
        connection = mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', ''),
            database=os.getenv('DB_NAME', 'hostelconnect_db')
        )
        
        cursor = connection.cursor()
        
        print("Running floor preference migration...")
        
        # Read and execute migration SQL
        migration_file = 'migrations/2026_02_12_add_floor_preference.sql'
        
        with open(migration_file, 'r') as f:
            sql_commands = f.read().split(';')
            
            for command in sql_commands:
                command = command.strip()
                if command and not command.startswith('--') and not command.startswith('USE'):
                    try:
                        cursor.execute(command)
                        print(f"✓ Executed: {command[:50]}...")
                    except mysql.connector.Error as err:
                        if 'Duplicate column' in str(err):
                            print(f"⚠ Column already exists, skipping...")
                        else:
                            print(f"✗ Error: {err}")
        
        connection.commit()
        print("\n✅ Migration completed successfully!")
        
        cursor.close()
        connection.close()
        
    except Exception as e:
        print(f"\n❌ Migration failed: {str(e)}")
        return False
    
    return True

if __name__ == "__main__":
    run_migration()
