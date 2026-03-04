# 🔐 Quick Reference: Route Protection

## 🎯 How to Protect a New Route

### Single Route Protection
```jsx
import ProtectedRoute from './components/ProtectedRoute';

<Route 
  path="/student/new-page" 
  element={
    <ProtectedRoute allowedRoles={['student']}>
      <NewPage />
    </ProtectedRoute>
  } 
/>
```

### Multi-Route Protection (Layout Pattern)
```jsx
<Route 
  path="/student" 
  element={
    <ProtectedRoute allowedRoles={['student']}>
      <StudentLayout />
    </ProtectedRoute>
  }
>
  <Route path="dashboard" element={<Dashboard />} />
  <Route path="profile" element={<Profile />} />
  {/* All child routes automatically protected */}
</Route>
```

---

## 🔑 Auth Functions Cheat Sheet

```javascript
import { 
  isAuthenticated,    // Check if logged in
  getCurrentUser,     // Get user object
  getUserRole,        // Get role string
  getDashboardPath,   // Get dashboard URL
  hasRole,           // Check specific role
  hasAnyRole,        // Check multiple roles
  login,             // Login user
  logout             // Logout user
} from './utils/auth';
```

### Common Usage Patterns

```javascript
// Check authentication
if (isAuthenticated()) {
  // User is logged in
}

// Get current user
const user = getCurrentUser();
// Returns: { userId: 1, name: "John", role: "student" }

// Get user role
const role = getUserRole();
// Returns: "student" | "warden" | "admin" | "technician" | "security"

// Check if user has specific role
if (hasRole('admin')) {
  // Show admin features
}

// Check multiple roles
if (hasAnyRole(['admin', 'warden'])) {
  // Show features for admins OR wardens
}

// Get user's dashboard path
const dashboardUrl = getDashboardPath();
navigate(dashboardUrl);
```

---

## 🎨 Conditional Rendering by Role

### Method 1: Simple conditional
```jsx
const MyComponent = () => {
  const role = getUserRole();
  
  return (
    <div>
      {role === 'admin' && <AdminFeature />}
      {role === 'warden' && <WardenFeature />}
      {role === 'student' && <StudentFeature />}
    </div>
  );
};
```

### Method 2: Switch statement
```jsx
const MyComponent = () => {
  const role = getUserRole();
  
  const renderContent = () => {
    switch (role) {
      case 'admin':
        return <AdminView />;
      case 'warden':
        return <WardenView />;
      case 'student':
        return <StudentView />;
      default:
        return <DefaultView />;
    }
  };
  
  return <div>{renderContent()}</div>;
};
```

### Method 3: Component map
```jsx
const roleComponents = {
  admin: AdminDashboard,
  warden: WardenDashboard,
  student: StudentDashboard,
  technician: TechnicianDashboard,
  security: SecurityDashboard
};

const DynamicDashboard = () => {
  const role = getUserRole();
  const Component = roleComponents[role];
  return Component ? <Component /> : <DefaultView />;
};
```

---

## 🚪 Role & Route Mapping

| Role | Allowed Routes | Dashboard |
|------|----------------|-----------|
| student | `/student/*` | `/student/dashboard` |
| warden | `/warden/*` | `/warden/dashboard` |
| admin | `/admin/*` | `/admin/dashboard` |
| technician | `/technician/*` | `/technician/dashboard` |
| security | `/security/*` | `/security/dashboard` |

**Public Routes (no auth):** `/`, `/login`, `/student-registration`

---

## 🧪 Quick Test Commands

Open browser console and run:

```javascript
// Test 1: Check auth status
localStorage.getItem('isAuthenticated')
// Should return: "true" or null

// Test 2: View user data
JSON.parse(localStorage.getItem('hostelUser'))
// Should return: { userId, name, role }

// Test 3: Logout
localStorage.clear()
// Then refresh - should redirect to login

// Test 4: Mock login
localStorage.setItem('hostelUser', JSON.stringify({
  userId: 1, 
  name: 'Test User', 
  role: 'student'
}));
localStorage.setItem('isAuthenticated', 'true');
// Refresh - should show student dashboard
```

---

## ⚠️ Common Mistakes to Avoid

❌ **Don't forget to wrap routes**
```jsx
// WRONG - No protection
<Route path="/admin/dashboard" element={<AdminDashboard />} />

// CORRECT - Protected
<Route 
  path="/admin/dashboard" 
  element={
    <ProtectedRoute allowedRoles={['admin']}>
      <AdminDashboard />
    </ProtectedRoute>
  } 
/>
```

❌ **Don't trust props from URL**
```jsx
// WRONG - User can manipulate URL params
const AdminPanel = () => {
  const { role } = useParams(); // Don't trust this!
  return <div>Admin for {role}</div>;
};

// CORRECT - Always check localStorage
const AdminPanel = () => {
  const role = getUserRole(); // Get from localStorage
  return <div>Admin for {role}</div>;
};
```

❌ **Don't skip ProtectedRoute on nested routes**
```jsx
// WRONG - Parent protected but not children
<Route path="/admin" element={<ProtectedRoute allowedRoles={['admin']}><AdminLayout /></ProtectedRoute>}>
  <Route path="users" element={<Users />} />
  <Route path="settings" element={<ProtectedRoute allowedRoles={['admin']}><Settings /></ProtectedRoute>} />
</Route>

// CORRECT - Only protect parent (children inherit)
<Route path="/admin" element={<ProtectedRoute allowedRoles={['admin']}><AdminLayout /></ProtectedRoute>}>
  <Route path="users" element={<Users />} />
  <Route path="settings" element={<Settings />} />
</Route>
```

---

## 🔧 Debugging Tips

### Issue: Redirect loop
```javascript
// Check in console:
console.log('Auth:', localStorage.getItem('isAuthenticated'));
console.log('User:', localStorage.getItem('hostelUser'));
console.log('Role:', getUserRole());
console.log('Path:', getDashboardPath());
```

### Issue: Wrong dashboard showing
```javascript
// Verify role matches expected
const user = JSON.parse(localStorage.getItem('hostelUser'));
console.log('Current role:', user.role);
console.log('Expected roles:', allowedRoles);
```

### Issue: Can't access route
```javascript
// Check if route is protected
// 1. Go to frontend/src/App.jsx
// 2. Find your route
// 3. Verify it's wrapped with <ProtectedRoute>
// 4. Verify allowedRoles includes your role
```

---

## 📱 Demo Credentials

Use these for testing (after running demo user creation):

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@hostel.edu | admin123 |
| Warden | warden@hostel.edu | warden123 |
| Student | student@hostel.edu | student123 |
| Technician | tech@hostel.edu | tech123 |
| Security | security@hostel.edu | security123 |

---

## ✅ Pre-Deployment Checklist

- [ ] All dashboard routes wrapped with `<ProtectedRoute>`
- [ ] `allowedRoles` specified for each protected route
- [ ] Login redirects to correct dashboard
- [ ] Logout clears localStorage
- [ ] Page refresh doesn't break authentication
- [ ] Direct URL access is blocked for wrong roles
- [ ] 404 page doesn't require authentication
- [ ] Console warnings visible in development
- [ ] Production build doesn't log sensitive data

---

**Need more details?** See [AUTH_GUIDE.md](AUTH_GUIDE.md) for comprehensive documentation.
