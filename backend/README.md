# HostelConnect Backend

Flask-based REST API for HostelConnect authentication system.

## 🚀 Setup Instructions

### 1. Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Set Up MySQL Database

**Option A: Using XAMPP**
- Start XAMPP Control Panel
- Start Apache and MySQL
- Open phpMyAdmin: http://localhost/phpmyadmin
- Create new database: `hostelconnect`
- Import schema: Copy contents of `database_schema.sql` and run in SQL tab

**Option B: Using MySQL Command Line**
```bash
mysql -u root -p < database_schema.sql
```

### 3. Configure Database Connection

Edit `app.py` if needed (default config):
```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''  # Change if you set a password
app.config['MYSQL_DB'] = 'hostelconnect'
```

### 4. Run Flask Backend

```bash
python app.py
```

Backend will start on: **http://localhost:5000**

### 5. Create Demo Users

**Method 1: Using Browser/Postman**
Send POST request to:
```
http://localhost:5000/api/create-demo-users
```

**Method 2: Using curl**
```bash
curl -X POST http://localhost:5000/api/create-demo-users
```

**Method 3: Using PowerShell**
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST
```

## 🔐 Demo Login Credentials

After creating demo users, use these credentials:

| Role | Email | Password |
|------|-------|----------|
| Student | student@hostel.edu | student123 |
| Warden | warden@hostel.edu | warden123 |
| Admin | admin@hostel.edu | admin123 |
| Technician | technician@hostel.edu | tech123 |
| Security | security@hostel.edu | security123 |

## 📡 API Endpoints

### Test Connection
```
GET http://localhost:5000/api/test
```

### Login
```
POST http://localhost:5000/api/login
Content-Type: application/json

{
  "email": "student@hostel.edu",
  "password": "student123"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": 1,
    "name": "Rajesh Kumar",
    "email": "student@hostel.edu",
    "role": "student"
  }
}
```

### Logout
```
POST http://localhost:5000/api/logout
```

## 🛠 Troubleshooting

### Issue: Module not found
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Issue: MySQL connection failed
- Check if MySQL is running (XAMPP or MySQL service)
- Verify database `hostelconnect` exists
- Check username/password in `app.py`

### Issue: Port 5000 already in use
Change port in `app.py`:
```python
app.run(debug=True, port=5001)  # Use different port
```

### Issue: CORS errors
- Ensure Flask-CORS is installed
- Check `CORS(app)` is enabled in `app.py`

## 📁 File Structure

```
backend/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── database_schema.sql    # MySQL database schema
└── README.md             # This file
```

## 🔒 Security Notes

- Passwords are hashed using Werkzeug's `generate_password_hash`
- Never store plain text passwords
- Remove `/api/create-demo-users` endpoint in production
- Use environment variables for sensitive config in production
- Implement JWT tokens for production (currently using localStorage)

## 🚦 Next Steps

1. ✅ Backend running
2. ✅ Database created
3. ✅ Demo users added
4. 🔄 Frontend integration (Login.jsx)
5. 🔄 Protected routes
6. 🔄 Role-based access control
