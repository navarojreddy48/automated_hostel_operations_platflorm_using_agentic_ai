"""
Apply Holiday Mode and OTP Migration
Run this script to add holiday mode and OTP support to the database
"""

import mysql.connector
import sys
import os

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'navaroj@1923132',
    'database': 'hostelconnect_db'
}

def apply_migration():
    """Apply the holiday mode migration SQL"""
    try:
        print("Connecting to database...")
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        # Read migration file
        migration_file = os.path.join(
            os.path.dirname(__file__), 
            'migrations', 
            '2026_02_18_add_holiday_mode_otp.sql'
        )
        
        print(f"Reading migration file: {migration_file}")
        with open(migration_file, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Split by semicolon and execute each statement
        statements = [s.strip() for s in sql_content.split(';') if s.strip() and not s.strip().startswith('--')]
        
        print(f"\nExecuting {len(statements)} SQL statements...")
        for i, statement in enumerate(statements, 1):
            try:
                # Skip comments
                if statement.strip().startswith('--'):
                    continue
                    
                print(f"\n[{i}/{len(statements)}] Executing...")
                cursor.execute(statement)
                connection.commit()
                print(f"✓ Success")
            except mysql.connector.Error as e:
                # Ignore duplicate column errors (migration already applied)
                if 'Duplicate column name' in str(e) or 'Duplicate key name' in str(e):
                    print(f"⚠ Skipped (already exists)")
                else:
                    print(f"✗ Error: {e}")
                    raise
        
        cursor.close()
        connection.close()
        
        print("\n" + "="*50)
        print("✅ Migration applied successfully!")
        print("="*50)
        print("\nNew features enabled:")
        print("  • College Holiday Mode toggle")
        print("  • OTP verification for outpasses")
        print("  • Parent email OTP delivery")
        print("  • Auto-approval after OTP verification")
        print("\nYou can now:")
        print("  1. Enable Holiday Mode from Warden Outpass page")
        print("  2. Students can choose OTP or Manual approval")
        print("  3. OTP sent to parent email automatically")
        
    except mysql.connector.Error as e:
        print(f"\n❌ Database error: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print(f"\n❌ Migration file not found: {migration_file}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    print("="*50)
    print("Holiday Mode & OTP Migration")
    print("="*50)
    apply_migration()
