import mysql.connector
import sys

# Database Configuration (from app.py)
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'navaroj@1923132',
    'database': 'hostelconnect_db'
}

def test_connection():
    """Test MySQL database connection"""
    print("=" * 60)
    print("Testing Database Connection...")
    print("=" * 60)
    
    try:
        # Test connection without database first
        print("\n1. Testing MySQL server connection...")
        connection = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        print(f"   ✓ MySQL server is running on {DB_CONFIG['host']}")
        
        cursor = connection.cursor()
        cursor.execute("SELECT VERSION()")
        version = cursor.fetchone()
        print(f"   ✓ MySQL version: {version[0]}")
        
        # Check if database exists
        print(f"\n2. Checking if database '{DB_CONFIG['database']}' exists...")
        cursor.execute("SHOW DATABASES")
        databases = [db[0] for db in cursor.fetchall()]
        
        if DB_CONFIG['database'] in databases:
            print(f"   ✓ Database '{DB_CONFIG['database']}' exists")
        else:
            print(f"   ✗ Database '{DB_CONFIG['database']}' NOT FOUND")
            print(f"   Available databases: {', '.join(databases)}")
            cursor.close()
            connection.close()
            return False
        
        cursor.close()
        connection.close()
        
        # Test connection with database
        print(f"\n3. Testing connection to database '{DB_CONFIG['database']}'...")
        connection = mysql.connector.connect(**DB_CONFIG)
        print(f"   ✓ Successfully connected to database '{DB_CONFIG['database']}'")
        
        # Check some key tables
        print("\n4. Checking key tables...")
        cursor = connection.cursor()
        cursor.execute("SHOW TABLES")
        tables = [table[0] for table in cursor.fetchall()]
        
        key_tables = ['users', 'students', 'outpasses', 'complaints', 'rooms']
        for table in key_tables:
            if table in tables:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"   ✓ Table '{table}' exists with {count} records")
            else:
                print(f"   ✗ Table '{table}' NOT FOUND")
        
        cursor.close()
        connection.close()
        
        print("\n" + "=" * 60)
        print("✓ DATABASE CONNECTION SUCCESSFUL")
        print("=" * 60)
        return True
        
    except mysql.connector.Error as err:
        print(f"\n✗ DATABASE CONNECTION FAILED")
        print(f"   Error: {err}")
        print(f"   Error Code: {err.errno if hasattr(err, 'errno') else 'N/A'}")
        
        if err.errno == 2003:
            print("\n   Possible causes:")
            print("   - MySQL service is not running")
            print("   - Wrong host/port configuration")
            print("   - Firewall blocking connection")
        elif err.errno == 1045:
            print("\n   Possible causes:")
            print("   - Incorrect username or password")
            print("   - User doesn't have access to the database")
        elif err.errno == 1049:
            print("\n   Possible causes:")
            print("   - Database doesn't exist (needs to be created)")
            print("   - Run: python setup_database.py")
        
        print("\n" + "=" * 60)
        return False
    
    except Exception as e:
        print(f"\n✗ UNEXPECTED ERROR: {e}")
        print("=" * 60)
        return False

if __name__ == '__main__':
    success = test_connection()
    sys.exit(0 if success else 1)
