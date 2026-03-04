# HostelConnect - Quick Start Commands

## 🚀 Quick Start (All-in-One)

### First Time Setup:

1. **Install Backend Dependencies:**
```bash
cd backend
pip install -r requirements.txt
cd ..
```

2. **Install Frontend Dependencies:**
```bash
cd frontend
npm install
```

3. **Setup MySQL Database:**
- Start XAMPP/MySQL
- Create database `hostelconnect`
- Import schema from `backend/database_schema.sql`

4. **Start Backend (Terminal 1):**
```bash
cd backend
python app.py
```

5. **Start Frontend (Terminal 2):**
```bash
cd frontend
npm run dev
```

6. **Create Demo Users (Terminal 3):**
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST
```

7. **Open Browser:**
```
http://localhost:5173
```

---

## 🔧 Daily Development Commands

### Start Backend:
```bash
cd backend
python app.py
```
**Runs on:** http://localhost:5000

### Start Frontend:
```bash
cd frontend
npm run dev
```
**Runs on:** http://localhost:5173

---

## 🧪 Testing Commands

### Test Backend Connection:
```bash
curl http://localhost:5000/api/test
```

### Create Demo Users:
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST
```

### Test Login (PowerShell):
```powershell
$body = @{
    email = "student@hostel.edu"
    password = "student123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5000/api/login" -Method POST -Body $body -ContentType "application/json"
```

---

## 📊 Database Commands

### Access MySQL (Command Line):
```bash
mysql -u root -p
USE hostelconnect;
```

### View Users:
```sql
SELECT id, name, email, role FROM users;
```

### Count Users by Role:
```sql
SELECT role, COUNT(*) as count FROM users GROUP BY role;
```

---

## 🐛 Debugging Commands

### Check if Backend is Running:
```bash
curl http://localhost:5000/health
```

### Check Python Packages:
```bash
pip list
```

### Check Node Packages:
```bash
cd frontend
npm list --depth=0
```

### View Backend Logs:
Check terminal where `python app.py` is running

### View Frontend Logs:
Open browser console (F12)

---

## 🔄 Reset Commands

### Reset Database:
```sql
DROP DATABASE hostelconnect;
CREATE DATABASE hostelconnect;
USE hostelconnect;
SOURCE D:/hostel/backend/database_schema.sql;
```

### Recreate Demo Users:
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST
```

### Clear Browser Storage:
```javascript
// In browser console (F12)
localStorage.clear();
location.reload();
```

---

## 📦 Dependency Management

### Update Python Packages:
```bash
cd backend
pip install --upgrade -r requirements.txt
```

### Update Node Packages:
```bash
cd frontend
npm update
```

### Add New Python Package:
```bash
pip install <package-name>
pip freeze > requirements.txt
```

### Add New Node Package:
```bash
cd frontend
npm install <package-name>
```

---

## 🚨 Common Issues & Fixes

### Port 5000 Already in Use:
Change port in `backend/app.py`:
```python
app.run(debug=True, port=5001)
```
Update `frontend/src/utils/auth.js`:
```javascript
const API_BASE_URL = 'http://localhost:5001/api';
```

### MySQL Not Running:
- XAMPP: Start MySQL service
- Windows: Start MySQL service in Services

### Module Not Found:
```bash
cd backend
pip install -r requirements.txt
```

### Axios Not Found:
```bash
cd frontend
npm install axios
```

---

## 🎯 Demo Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Student | student@hostel.edu | student123 |
| Warden | warden@hostel.edu | warden123 |
| Admin | admin@hostel.edu | admin123 |
| Technician | technician@hostel.edu | tech123 |
| Security | security@hostel.edu | security123 |

---

## 📁 Project URLs

- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:5000/api
- **Test Endpoint:** http://localhost:5000/api/test
- **phpMyAdmin:** http://localhost/phpmyadmin

---

## 💡 Pro Tips

1. **Keep both terminals open** (backend & frontend)
2. **Check backend terminal for API errors**
3. **Check browser console (F12) for frontend errors**
4. **Use demo login buttons** on the login page for quick testing
5. **Backend auto-reloads** on file changes (debug=True)
6. **Frontend hot-reloads** on file changes (Vite)

---

## 📝 Development Checklist

Before starting development:
- [ ] MySQL is running
- [ ] Backend is running (http://localhost:5000)
- [ ] Frontend is running (http://localhost:5173)
- [ ] Demo users are created
- [ ] Can login successfully

---

**Happy Coding! 🚀**
