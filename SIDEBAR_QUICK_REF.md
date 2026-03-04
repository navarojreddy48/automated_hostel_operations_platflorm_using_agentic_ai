# 🎨 Sidebar Component - Quick Reference

**File:** [frontend/src/components/Sidebar.jsx](frontend/src/components/Sidebar.jsx)  
**Styles:** [frontend/src/styles/unified-sidebar.css](frontend/src/styles/unified-sidebar.css)  
**Status:** ✅ Production-Ready

---

## 🚀 Quick Start

### Using the Sidebar

```javascript
import Sidebar from './components/Sidebar';

// Auto-detect role from localStorage (recommended)
<Sidebar />

// Or specify role explicitly
<Sidebar role="admin" />
<Sidebar role="warden" />
<Sidebar role="student" />
<Sidebar role="technician" />
<Sidebar role="security" />
```

### Creating a Layout Component

```javascript
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';

const MyLayout = () => (
  <div className="my-layout">
    <Sidebar role="myRole" />
    <main style={{ marginLeft: '280px' }}>
      <Outlet />
    </main>
  </div>
);

export default MyLayout;
```

---

## 📋 Menu Items by Role

| Role | Items | Icon Example |
|------|-------|--------------|
| **Admin** | 8 | Dashboard 📊, Users 👥, Reports 📈 |
| **Warden** | 9 | Dashboard 📊, Outpass ✅, Complaints ⚠️ |
| **Student** | 7 | Dashboard 📊, Outpass 🛂, Mess 🍽️ |
| **Technician** | 5 | Dashboard 📊, Complaints 📋, Performance 📈 |
| **Security** | 6 | Dashboard 📊, Outpass 🚪, Parcels 📦 |

---

## 🔧 Common Tasks

### Add a New Menu Item

**Location:** [Sidebar.jsx](frontend/src/components/Sidebar.jsx) → `menuConfig`

```javascript
const menuConfig = {
  student: {
    items: [
      { path: '/student/dashboard', icon: '📊', label: 'Dashboard' },
      { path: '/student/new-feature', icon: '🆕', label: 'New Feature' }, // Add here
    ]
  }
};
```

### Remove a Menu Item

```javascript
// Simply delete the line from items array
{ path: '/student/old-feature', icon: '🗑️', label: 'Old Feature' }, // DELETE this
```

### Change Menu Item Icon

```javascript
// Update the icon property
{ path: '/student/dashboard', icon: '🏠', label: 'Dashboard' }, // Changed icon
```

### Change Active Highlight Color

**Location:** [unified-sidebar.css](frontend/src/styles/unified-sidebar.css)

```css
.sidebar-item.active {
  border-left-color: #fbbf24; /* Change this color */
}
```

### Change Sidebar Width

```css
.unified-sidebar {
  width: 280px; /* Change desktop width */
}

@media (max-width: 1024px) {
  .unified-sidebar {
    width: 240px; /* Change tablet width */
  }
}
```

---

## 🎨 Responsive Breakpoints

| Viewport | Sidebar Width | Labels | Behavior |
|----------|---------------|--------|----------|
| **> 1024px** | 280px | Visible | Fixed full sidebar |
| **768-1024px** | 240px | Visible | Slightly reduced |
| **< 768px** | 70px | Hidden | Collapsed, expands on hover |

---

## 🐛 Troubleshooting

### Sidebar Not Showing
```javascript
// Check localStorage
console.log(localStorage.getItem('hostelUser'));

// Should return: {"userId": 1, "name": "User", "role": "student"}
```

### Wrong Menu Items
```javascript
// Clear storage and login again
localStorage.clear();
// Then login with correct credentials
```

### Active Highlighting Not Working
```javascript
// Ensure using NavLink, not Link
import { NavLink } from 'react-router-dom';

<NavLink 
  to="/path"
  className={({ isActive }) => isActive ? 'sidebar-item active' : 'sidebar-item'}
/>
```

### Main Content Hidden Behind Sidebar
```javascript
// Add margin-left to main content
<main style={{ marginLeft: '280px' }}>
  {/* Content */}
</main>
```

---

## 📊 Menu Configuration Structure

```javascript
menuConfig = {
  [role]: {
    logo: '🏠',                    // Sidebar logo
    title: 'HostelConnect',        // Title below logo
    basePath: '/role',             // Base path for role
    items: [                       // Menu items array
      {
        path: '/role/page',        // Full route path
        icon: '📊',                // Emoji or icon
        label: 'Page Name'         // Display text
      }
    ],
    profile: {                     // Profile section config
      initial: 'U',                // User initial
      name: 'User Name',           // Full name
      subtitle: 'user@email.com'   // Email or role
    }
  }
}
```

---

## 🔒 Security Features

1. **Role-Based Rendering**
   - Only shows menu items for user's role
   - Other role menus completely hidden

2. **Aligned with Route Protection**
   - UI prevention (sidebar) + route guard (ProtectedRoute)
   - Double-layer security

3. **No Unauthorized Links**
   - Admin links not visible to students
   - Tech links not visible to security
   - Complete role isolation

---

## 📱 Mobile Considerations

### Collapsed State (< 768px)
- Width: 70px
- Icons only
- Labels hidden
- Expands on hover to 280px

### Touch Optimization
- Tap targets: 48x48px minimum
- Smooth transitions
- No hover issues on touch devices

---

## ✅ Verification Checklist

Quick testing checklist:

```
□ Login as each role
□ Verify correct menu items show
□ Check active page highlighting
□ Test all navigation links
□ Verify logout button works
□ Test responsive behavior (resize window)
□ Check profile displays correctly
□ Verify no console errors
```

---

## 🎯 Key Files

| File | Purpose | Size |
|------|---------|------|
| [Sidebar.jsx](frontend/src/components/Sidebar.jsx) | Main component | ~150 lines |
| [unified-sidebar.css](frontend/src/styles/unified-sidebar.css) | Styles | ~300 lines |
| [AdminLayout.jsx](frontend/src/components/AdminLayout.jsx) | Admin wrapper | ~15 lines |
| [WardenLayout.jsx](frontend/src/components/WardenLayout.jsx) | Warden wrapper | ~15 lines |
| [StudentLayout.jsx](frontend/src/components/StudentLayout.jsx) | Student wrapper | ~15 lines |
| [TechnicianLayout.jsx](frontend/src/components/TechnicianLayout.jsx) | Technician wrapper | ~15 lines |
| [SecurityLayout.jsx](frontend/src/components/SecurityLayout.jsx) | Security wrapper | ~15 lines |

---

## 💡 Tips

1. **Always use NavLink** for active state
2. **Match paths exactly** in menuConfig and routes
3. **Test all roles** after making changes
4. **Use emojis** for consistent icon style
5. **Keep menu items under 10** per role for UX

---

## 📚 Full Documentation

For detailed information, see:
- [SIDEBAR_GUIDE.md](SIDEBAR_GUIDE.md) - Complete implementation guide
- [SIDEBAR_IMPLEMENTATION_REPORT.md](SIDEBAR_IMPLEMENTATION_REPORT.md) - Verification report

---

**Last Updated:** February 8, 2026  
**Version:** 1.0.0  
**Maintained By:** GitHub Copilot
