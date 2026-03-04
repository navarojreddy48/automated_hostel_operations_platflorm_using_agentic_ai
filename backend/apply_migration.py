import mysql.connector
import os

# Database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'navaroj@1923132',
    'database': 'hostelconnect_db'
}

try:
    # Connect to database
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    
    # Read and execute migration file
    migration_file = 'migrations/2026_02_17_add_outpass_agentic_monitoring.sql'
    if os.path.exists(migration_file):
        with open(migration_file, 'r') as f:
            sql_content = f.read()
            # Execute each statement separately
            statements = [s.strip() for s in sql_content.split(';') if s.strip() and not s.strip().startswith('--')]
            for statement in statements:
                print(f"Executing: {statement[:50]}...")
                cursor.execute(statement)
        conn.commit()
        print("✅ Migration applied successfully!")
    else:
        print(f"❌ Migration file not found: {migration_file}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Error applying migration: {str(e)}")
