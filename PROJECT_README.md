# 🏠 HostelConnect - Complete Hostel Management System

> **Full-Stack Application with React, Flask, MySQL & AI-Enhanced Security Monitoring**

[![React](https://img.shields.io/badge/React-18.2-blue.svg)](https://reactjs.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0-green.svg)](https://flask.palletsprojects.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)](https://www.mysql.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-yellow.svg)](https://www.python.org/)

---

## 📖 Overview

**HostelConnect** is a comprehensive hostel management system featuring role-based dashboards, authentication, and AI-enhanced security monitoring. Built for educational institutions to streamline hostel operations.

### ✨ Key Features

🔐 **Multi-Role Authentication**
- Student, Warden, Admin, Technician, Security
- Protected routes with role-based access control
- Secure password hashing

👨‍🎓 **Student Portal**
- Outpass management
- Leave applications
- Complaint registration
- Mess menu viewing
- Parcel tracking
- Room information

👔 **Warden Dashboard**
- Approve/reject outpasses
- Manage leave requests
- Handle complaints
- Monitor student registrations
- Manage technicians
- Mess coordination

🔧 **Admin Panel**
- User management
- System reports
- Security personnel management
- Complete system oversight

🔨 **Technician Console**
- View assigned complaints
- Task history
- Performance tracking
- Notification system

🛡️ **Security Dashboard**
- Gate outpass verification
- Parcel logging system
- Visitor entry management
- Daily activity logs
- **AI Risk Alerts** - Automated monitoring for:
  - Late returns
  - Repeated outpass patterns
  - Suspicious visitor activity
  - Unusual behavior detection

---

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Node.js 16+
- MySQL Server (XAMPP recommended)

### Installation

1. **Clone Repository:**
```bash
git clone <repository-url>
cd hostel
```

2. **Install Dependencies:**
```bash
# Backend
cd backend
pip install -r requirements.txt
cd ..

# Frontend
cd frontend
npm install
```

3. **Setup Database:**
- Start MySQL (XAMPP or MySQL service)
- Create database: `hostelconnect`
- Import schema: `backend/database_schema.sql`

4. **Start Backend:**
```bash
cd backend
python app.py
```
**Runs on:** http://localhost:5000

5. **Start Frontend:**
```bash
cd frontend
npm run dev
```
**Runs on:** http://localhost:5173

6. **Create Demo Users:**
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/create-demo-users" -Method POST
```

7. **Login:**
Open http://localhost:5173 and use demo credentials

---

## 🔑 Demo Credentials

| Role | Email | Password | Dashboard |
|------|-------|----------|-----------|
| 👨‍🎓 Student | student@hostel.edu | student123 | /student/dashboard |
| 👔 Warden | warden@hostel.edu | warden123 | /warden/dashboard |
| 🔧 Admin | admin@hostel.edu | admin123 | /admin/dashboard |
| 🔨 Technician | technician@hostel.edu | tech123 | /technician/dashboard |
| 🛡️ Security | security@hostel.edu | security123 | /security/dashboard |

---

## 📁 Project Structure

```
hostel/
├── backend/                    # Flask Backend
│   ├── app.py                 # Main Flask application
│   ├── requirements.txt       # Python dependencies
│   ├── database_schema.sql    # MySQL schema
│   └── README.md             # Backend documentation
│
├── frontend/                  # React Frontend
│   ├── frontend/src/
│   │   ├── components/
│   │   │   ├── Navbar.jsx
│   │   │   ├── Footer.jsx
│   │   │   └── ProtectedRoute.jsx # Route guard
│   │   ├── pages/
│   │   │   ├── LandingPage.jsx
│   │   │   ├── Login.jsx          # Authentication UI
│   │   │   ├── student/           # Student dashboards
│   │   │   ├── warden/            # Warden dashboards
│   │   │   ├── admin/             # Admin dashboards
│   │   │   ├── technician/        # Technician dashboards
│   │   │   └── security/          # Security dashboards
│   │   ├── utils/
│   │   │   └── auth.js            # Authentication functions
│   │   ├── styles/                # CSS modules
│   │   ├── App.jsx                # Main routing
│   │   └── main.jsx               # Entry point
│   ├── package.json               # Node dependencies
│   └── vite.config.js             # Vite configuration
├── SETUP_GUIDE.md            # Detailed setup guide
├── QUICK_START.md            # Quick reference
└── README.md                 # This file
```

---

## 🛠 Technology Stack

### Frontend
- **React 18.2** - UI library
- **React Router 6** - Client-side routing
- **Axios** - HTTP client
- **Vite** - Build tool
- **CSS Modules** - Styling

### Backend
- **Flask 3.0** - Python web framework
- **Flask-CORS** - Cross-origin resource sharing
- **Werkzeug** - Password hashing
- **mysql-connector-python** - Database driver

### Database
- **MySQL 8.0** - Relational database
- **phpMyAdmin** - Database management (via XAMPP)

---

## 🔒 Security Features

✅ **Password Hashing** - Werkzeug bcrypt  
✅ **Protected Routes** - ProtectedRoute component  
✅ **Role-Based Access** - Enforced at route level  
✅ **SQL Injection Protection** - Parameterized queries  
✅ **CORS Security** - Configured for localhost development  
✅ **Session Management** - localStorage (upgrade to JWT recommended)

---

## 📚 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete setup instructions
- **[QUICK_START.md](QUICK_START.md)** - Quick command reference
- **[backend/README.md](backend/README.md)** - Backend API documentation

---

## 🧪 Testing

### Test Backend Connection:
```bash
curl http://localhost:5000/api/test
```

### Test Login API:
```powershell
$body = @{
    email = "student@hostel.edu"
    password = "student123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5000/api/login" -Method POST -Body $body -ContentType "application/json"
```

### Access Dashboards:
After logging in with demo credentials, each role redirects to its dashboard automatically.

---

## 🐛 Troubleshooting

### Backend Issues:
```bash
# Check if backend is running
curl http://localhost:5000/health

# Reinstall dependencies
cd backend
pip install --upgrade -r requirements.txt
```

### Database Issues:
```bash
# Verify MySQL is running
mysql -u root -p -e "SHOW DATABASES;"

# Recreate database
mysql -u root -p < backend/database_schema.sql
```

### Frontend Issues:
```bash
# Reinstall node modules
cd frontend
rm -rf node_modules
npm install

# Clear cache and restart
cd frontend
npm run dev
```

### Common Errors:
- **Port 5000 in use:** Change port in `backend/app.py`
- **Cannot connect to server:** Ensure backend is running
- **CORS errors:** Verify Flask-CORS is installed
- **Login fails:** Check demo users are created

---

## 🚦 API Endpoints

### Authentication:
- `POST /api/login` - User login
- `POST /api/logout` - User logout

### Testing:
- `GET /api/test` - Test database connection
- `GET /health` - Backend health check

### Development Only:
- `POST /api/create-demo-users` - Create demo accounts
  ⚠️ **Remove in production!**

---

## 📈 Future Enhancements

### Authentication:
- [ ] JWT token implementation
- [ ] Refresh token mechanism
- [ ] Password reset functionality
- [ ] Two-factor authentication

### Features:
- [ ] Real-time notifications (WebSocket)
- [ ] Email notifications
- [ ] Mobile responsive design
- [ ] Data export (PDF/Excel)
- [ ] Advanced analytics dashboard

### AI Enhancements:
- [ ] Real ML model integration
- [ ] Predictive analytics
- [ ] Anomaly detection algorithms
- [ ] Natural language processing for complaints

### Security:
- [ ] Rate limiting
- [ ] API key authentication
- [ ] HTTPS enforcement
- [ ] Environment variable management
- [ ] Session timeout

---

## 👥 User Roles & Permissions

| Feature | Student | Warden | Admin | Technician | Security |
|---------|---------|--------|-------|------------|----------|
| Outpass Request | ✅ | ❌ | ❌ | ❌ | ❌ |
| Outpass Approval | ❌ | ✅ | ✅ | ❌ | ❌ |
| Gate Verification | ❌ | ❌ | ❌ | ❌ | ✅ |
| Complaint Filing | ✅ | ❌ | ❌ | ❌ | ❌ |
| Complaint Assignment | ❌ | ✅ | ✅ | ❌ | ❌ |
| Task Management | ❌ | ❌ | ❌ | ✅ | ❌ |
| User Management | ❌ | ❌ | ✅ | ❌ | ❌ |
| Visitor Logging | ❌ | ❌ | ❌ | ❌ | ✅ |
| AI Risk Alerts | ❌ | ⚠️ | ✅ | ❌ | ✅ |

✅ Full Access | ⚠️ View Only | ❌ No Access

---

## 📞 Support

For issues or questions:
1. Check [SETUP_GUIDE.md](SETUP_GUIDE.md)
2. Review [Troubleshooting](#troubleshooting) section
3. Check terminal logs for errors
4. Inspect browser console (F12)

---

## 📄 License

This project is developed for educational purposes.

---

## 🙏 Acknowledgments

- React community for excellent documentation
- Flask for lightweight backend framework
- MySQL for robust database management
- XAMPP for simplified development environment

---

## 📧 Contact

**Project:** HostelConnect  
**Version:** 1.0.0  
**Status:** Active Development  

---

**Made with ❤️ for better hostel management**

🚀 **Happy Coding!**
