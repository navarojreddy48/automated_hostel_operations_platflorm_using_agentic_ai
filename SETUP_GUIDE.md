# 🚀 HostelConnect - Complete Setup Guide
## Full Stack Authentication System (React + Flask + MySQL)

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Backend Setup (Flask + MySQL)](#backend-setup)
3. [Frontend Setup (React)](#frontend-setup)
4. [Testing the System](#testing)
5. [Demo Credentials](#demo-credentials)
6. [Troubleshooting](#troubleshooting)
7. [Architecture Overview](#architecture)

---

## 1️⃣ Prerequisites

Make sure you have the following installed:

### Required Software:
- **Python 3.8+** - [Download](https://www.python.org/downloads/)
- **Node.js 16+** - [Download](https://nodejs.org/)
- **MySQL Server** - Use either:
  - **XAMPP** (Recommended for beginners) - [Download](https://www.apachefriends.org/)
  - **MySQL Installer** - [Download](https://dev.mysql.com/downloads/installer/)

### Verify Installation:
```bash
python --version
node --version
npm --version
mysql --version
```

---

## 2️⃣ Backend Setup (Flask + MySQL)

### Step 1: Install Python Dependencies

Open terminal/PowerShell in project root:

```bash
cd backend
pip install -r requirements.txt
```

**Packages installed:**
- Flask (Backend framework)
- Flask-CORS (Enable React to connect)
- mysql-connector-python (Database connection)
- Werkzeug (Password hashing)

---

### Step 2: Setup MySQL Database

#### Option A: Using XAMPP (Recommended)

1. **Start XAMPP Control Panel**
2. **Start Apache and MySQL services**
3. **Open phpMyAdmin**: http://localhost/phpmyadmin
4. **Create Database**:
   - Click "New" in left sidebar
   - Database name: `hostelconnect`
   - Collation: `utf8mb4_general_ci`
   - Click "Create"

5. **Import Schema**:
   - Click on `hostelconnect` database
   - Go to "SQL" tab
   - Open `backend/database_schema.sql` in a text editor
   - Copy **entire content**
   - Paste into SQL tab
   - Click "Go" button

✅ Database created!

#### Option B: Using MySQL Command Line

```bash
# Login to MySQL
mysql -u root -p

# Create database and import schema
CREATE DATABASE hostelconnect;
USE hostelconnect;
SOURCE D:/hostel/backend/database_schema.sql;
```

---

### Step 3: Configure Database Connection

Check `backend/app.py` (lines 10-13):

```python
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''  # Change if you set a password
app.config['MYSQL_DB'] = 'hostelconnect'
```

**If you have a MySQL password:**
- Edit `app.py`
- Change `app.config['MYSQL_PASSWORD'] = 'your_password'`

---

### Step 4: Start Flask Backend

```bash
cd backend
python app.py
```

**Expected Output:**
```
==================================================
🚀 HostelConnect Backend Server Starting...
==================================================
📍 API Base URL: http://localhost:5000
🔐 Login Endpoint: http://localhost:5000/api/login
🧪 Test Endpoint: http://localhost:5000/api/test
==================================================
 * Running on http://127.0.0.1:5000
```

**Test Backend:**
Open browser → http://localhost:5000/api/test

Should see:
```json
{
  "success": true,
  "message": "Backend is running and database is connected!"
}
```

✅ Backend is running!

**Keep this terminal open!**

---

### Step 5: Create Demo Users

Open **NEW terminal/PowerShell**:

#### Option A: Using PowerShell
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST | Select-Object -Expand Content
```

#### Option B: Using Browser
Navigate to: http://localhost:5000/api/create-demo-users

#### Option C: Using curl (Git Bash)
```bash
curl -X POST http://localhost:5000/api/create-demo-users
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Demo users created successfully",
  "users": [ ... 5 demo accounts ... ]
}
```

✅ Demo users created!

---

## 3️⃣ Frontend Setup (React)

### Step 1: Install Node Dependencies

Open **NEW terminal** (keep backend running):

```bash
cd D:/hostel/frontend
npm install
```

**New packages added:**
- `axios` (API calls to backend)

---

### Step 2: Start React Frontend

```bash
cd D:/hostel/frontend
npm run dev
```

**Expected Output:**
```
VITE v5.0.8  ready in 500 ms

➜  Local:   http://localhost:5173/
```

✅ Frontend is running!

---

## 4️⃣ Testing the System

### Test 1: Open Application
Navigate to: http://localhost:5173

### Test 2: Login with Demo Credentials

Click **"🔑 Show Demo Credentials"** button on login page

**Quick Login Buttons:**
- 👨‍🎓 Student
- 👔 Warden
- 🔧 Admin
- 🔨 Technician
- 🛡️ Security

**Or manually enter:**

| Role | Email | Password |
|------|-------|----------|
| Student | student@hostel.edu | student123 |
| Warden | warden@hostel.edu | warden123 |
| Admin | admin@hostel.edu | admin123 |
| Technician | technician@hostel.edu | tech123 |
| Security | security@hostel.edu | security123 |

### Test 3: Verify Role-Based Routing

**Student Login → Student Dashboard**
- URL: http://localhost:5173/student/dashboard
- Sidebar: Outpass, Leave, Complaints, etc.

**Warden Login → Warden Dashboard**
- URL: http://localhost:5173/warden/dashboard
- Sidebar: Outpass Approval, Leave, Complaints, etc.

**Admin Login → Admin Dashboard**
- URL: http://localhost:5173/admin/dashboard
- Sidebar: Users, Reports, Security Management

**Technician Login → Technician Dashboard**
- URL: http://localhost:5173/technician/dashboard
- Sidebar: Complaints, Tasks, Performance

**Security Login → Security Dashboard**
- URL: http://localhost:5173/security/dashboard
- Sidebar: Outpass Gate, Parcels, Visitors, AI Risk Alerts

### Test 4: Protected Routes

Try accessing a protected route without logging in:

Direct URL: http://localhost:5173/admin/dashboard

**Expected:** Redirect to login page (/login)

### Test 5: Role Restrictions

Login as Student → Try accessing admin dashboard:

Direct URL: http://localhost:5173/admin/dashboard

**Expected:** Redirect back to student dashboard

✅ Authentication working!

---

## 5️⃣ Demo Credentials

### Quick Reference Card:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         HOSTELCONNECT DEMO ACCOUNTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👨‍🎓 STUDENT
   Email:    student@hostel.edu
   Password: student123
   Access:   Outpass, Leave, Complaints, Mess, Room

👔 WARDEN
   Email:    warden@hostel.edu
   Password: warden123
   Access:   Approve Outpass/Leave, Manage Students

🔧 ADMIN
   Email:    admin@hostel.edu
   Password: admin123
   Access:   Full System Control, Reports, Users

🔨 TECHNICIAN
   Email:    technician@hostel.edu
   Password: tech123
   Access:   Complaints, Tasks, Performance

🛡️ SECURITY
   Email:    security@hostel.edu
   Password: security123
   Access:   Gate Management, Parcels, Visitors, AI Alerts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 6️⃣ Troubleshooting

### ❌ Backend won't start

**Error:** `ModuleNotFoundError`

**Fix:**
```bash
cd backend
pip install --upgrade pip
pip install -r requirements.txt
```

---

### ❌ Database connection failed

**Error:** `Database connection error: 2003`

**Fix:**
1. Check if MySQL is running (XAMPP → Start MySQL)
2. Verify database name is `hostelconnect`
3. Check username/password in `backend/app.py`

---

### ❌ Cannot connect to server

**Error in browser:** "Cannot connect to server"

**Fix:**
1. Make sure backend is running: `python backend/app.py`
2. Check backend URL in browser: http://localhost:5000/api/test
3. If port 5000 is busy, change port in `backend/app.py`:
   ```python
   app.run(debug=True, port=5001)  # Use port 5001
   ```
   Then update `frontend/src/utils/auth.js`:
   ```javascript
   const API_BASE_URL = 'http://localhost:5001/api';
   ```

---

### ❌ CORS errors in browser

**Error:** `CORS policy: No 'Access-Control-Allow-Origin'`

**Fix:**
1. Verify `Flask-CORS` is installed: `pip install Flask-Cors`
2. Check `backend/app.py` has: `CORS(app)`

---

### ❌ Demo users not created

**Error:** `Duplicate entry` or `Table doesn't exist`

**Fix:**
1. Drop and recreate database:
   ```sql
   DROP DATABASE hostelconnect;
   CREATE DATABASE hostelconnect;
   USE hostelconnect;
   SOURCE D:/hostel/backend/database_schema.sql;
   ```

2. Retry creating demo users:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST
   ```

---

### ❌ Frontend won't start

**Error:** `Cannot find module 'axios'`

**Fix:**
```bash
cd D:/hostel/frontend
npm install axios
npm run dev
```

---

## 7️⃣ Architecture Overview

### System Flow:

```
User Login
    ↓
React Frontend (Login.jsx)
    ↓ [POST /api/login]
Flask Backend (app.py)
    ↓ [Query users table]
MySQL Database
    ↓ [Return user data]
Flask Backend
    ↓ [Hash password verification]
    ✓ [Login Success]
React Frontend
    ↓ [Store in localStorage]
    ↓ [Navigate to role-based dashboard]
Protected Route (ProtectedRoute.jsx)
    ↓ [Check authentication]
    ✓ [Render Dashboard]
```

### File Structure:

```
hostel/
├── backend/
│   ├── app.py                  # Flask API
│   ├── requirements.txt        # Python packages
│   ├── database_schema.sql     # MySQL schema
│   └── README.md              # Backend docs
├── frontend/
│   ├── frontend/src/
│   │   ├── components/
│   │   │   └── ProtectedRoute.jsx  # Route guard
│   │   ├── pages/
│   │   │   ├── Login.jsx           # Login UI
│   │   │   ├── student/            # Student pages
│   │   │   ├── warden/             # Warden pages
│   │   │   ├── admin/              # Admin pages
│   │   │   ├── technician/         # Technician pages
│   │   │   └── security/           # Security pages
│   │   ├── utils/
│   │   │   └── auth.js             # Auth functions
│   │   ├── App.jsx                 # Routes
│   │   └── main.jsx
│   └── package.json
└── SETUP_GUIDE.md (this file)
```

### Security Features:

✅ **Password Hashing** - Werkzeug bcrypt
✅ **Protected Routes** - ProtectedRoute component
✅ **Role-Based Access** - allowedRoles prop
✅ **Session Management** - localStorage (upgrade to JWT later)
✅ **SQL Injection Protection** - Parameterized queries
✅ **CORS Security** - Flask-CORS enabled

---

## 🎉 You're All Set!

**Both servers running:**
- Backend: http://localhost:5000
- Frontend: http://localhost:5173

**Next Steps:**
1. Login with any demo account
2. Explore role-based dashboards
3. Test protected routes
4. Add new features!

**For Production:**
- Use environment variables for config
- Implement JWT tokens
- Add refresh tokens
- Enable HTTPS
- Remove demo endpoints
- Add rate limiting

---

## 📞 Need Help?

**Common Issues:**
- Backend: Check terminal for errors
- Database: Verify MySQL is running
- Frontend: Check browser console (F12)

**Quick Commands:**
```bash
# Backend
cd backend && python app.py

# Frontend
cd frontend && npm run dev

# Create demo users
Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST
```

---

**Happy Coding! 🚀**
