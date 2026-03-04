import React, { useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { logout, getCurrentUser } from '../utils/auth';
import ChangePassword from './ChangePassword';
import ProfileModal from './ProfileModal';
import '../styles/unified-sidebar.css';

/**
 * Unified Sidebar Component
 * 
 * 🎯 Features:
 * - Role-based menu rendering
 * - Reads user info from localStorage
 * - Dynamic profile display
 * - Logout functionality
 * - Active menu highlighting
 * - Responsive design
 * 
 * @param {string} role - User role (optional, auto-detected from localStorage)
 * 
 * @example
 * <Sidebar role="admin" />
 * // or
 * <Sidebar /> // Auto-detects role from localStorage
 */
const Sidebar = ({ role: propRole }) => {
  const navigate = useNavigate();
  const user = getCurrentUser();
  const role = propRole || user?.role;
  const [showChangePassword, setShowChangePassword] = useState(false);
  const [showProfile, setShowProfile] = useState(false);

  const handleSignOut = async () => {
    await logout();
    navigate('/login', { replace: true });
  };

  // Menu configuration for each role
  const menuConfig = {
    admin: {
      logo: '🏛️',
      title: 'HostelConnect',
      basePath: '/admin',
      items: [
        { path: '/admin/dashboard', icon: '📊', label: 'Dashboard' },
        { path: '/admin/users', icon: '👥', label: 'User Management' },
        { path: '/admin/wardens', icon: '👨‍💼', label: 'Wardens' },
        { path: '/admin/students', icon: '🎓', label: 'Students' },
        { path: '/admin/registrations', icon: '📝', label: 'Registrations' },
        { path: '/admin/technicians', icon: '🔧', label: 'Technicians' },
        { path: '/admin/security', icon: '🔐', label: 'Security' },
        { path: '/admin/hostel-blocks', icon: '🏢', label: 'Hostel Blocks' },
        { path: '/admin/academic-settings', icon: '🎓', label: 'Academic Settings' },
        { path: '/admin/room-utilities', icon: '🔧', label: 'Room Utilities' },
        { path: '/admin/reports', icon: '📈', label: 'Reports' },
      ],
      profile: {
        initial: user?.name?.charAt(0).toUpperCase() || 'A',
        name: user?.name || 'System Administrator',
        subtitle: user?.email || 'admin@hostelconnect.edu',
      }
    },
    warden: {
      logo: '🏛️',
      title: 'HostelConnect',
      basePath: '/warden',
      items: [
        { path: '/warden/dashboard', icon: '📊', label: 'Dashboard' },
        { path: '/warden/agentic-alerts', icon: '🚨', label: 'Agentic AI Alerts' },
        { path: '/warden/outpass', icon: '✅', label: 'Outpass Approvals' },
        { path: '/warden/leave', icon: '📝', label: 'Leave Approvals' },
        { path: '/warden/complaints', icon: '⚠️', label: 'Complaints' },
        { path: '/warden/registrations', icon: '🧾', label: 'Registrations' },
        { path: '/warden/mess', icon: '🍽️', label: 'Mess Menu' },
        { path: '/warden/rooms', icon: '🛏️', label: 'Rooms' },
        { path: '/warden/room-change-requests', icon: '🔄', label: 'Room Change Requests' },
        { path: '/warden/technicians', icon: '🔧', label: 'Technicians' },
        { path: '/warden/students', icon: '🎓', label: 'Students' },
        { path: '/warden/academic-settings', icon: '🎓', label: 'Academic Settings' },
      ],
      profile: {
        initial: user?.name?.charAt(0).toUpperCase() || 'W',
        name: user?.name || 'Warden',
        subtitle: 'Warden',
      }
    },
    student: {
      logo: '🏢',
      title: 'HostelConnect',
      basePath: '/student',
      items: [
        { path: '/student/dashboard', icon: '📊', label: 'Dashboard' },
        { path: '/student/outpass', icon: '🛂', label: 'Outpass' },
        { path: '/student/leave', icon: '📝', label: 'Leave Request' },
        { path: '/student/complaints', icon: '⚠️', label: 'Complaints' },
        { path: '/student/mess', icon: '🍽️', label: 'Mess Menu' },
        { path: '/student/parcels', icon: '📦', label: 'Parcels' },
        { path: '/student/room', icon: '🛏️', label: 'Room Details' },
      ],
      profile: {
        initial: user?.name?.charAt(0).toUpperCase() || 'S',
        name: user?.name || 'Student',
        subtitle: 'Student',
      }
    },
    technician: {
      logo: '🔧',
      title: 'HostelConnect',
      basePath: '/technician',
      items: [
        { path: '/technician/dashboard', icon: '📊', label: 'Dashboard' },
        { path: '/technician/assigned-tasks', icon: '📋', label: 'Assigned Tasks' },
        { path: '/technician/task-history', icon: '📜', label: 'Task History' },
      ],
      profile: {
        initial: user?.name?.charAt(0).toUpperCase() || 'T',
        name: user?.name || 'Technician',
        subtitle: user?.email || 'technician@hostelhub.edu',
      }
    },
    security: {
      logo: '🔐',
      title: 'HostelConnect',
      basePath: '/security',
      items: [
        { path: '/security/dashboard', icon: '📊', label: 'Dashboard' },
        { path: '/security/outpass', icon: '🚪', label: 'Outpass Gate' },
        { path: '/security/parcels', icon: '📦', label: 'Parcels' },
        { path: '/security/visitors', icon: '🧾', label: 'Visitors' },
        { path: '/security/logs', icon: '🗓️', label: 'Daily Logs' },
      ],
      profile: {
        initial: user?.name?.charAt(0).toUpperCase() || 'S',
        name: user?.name || 'Security Guard',
        subtitle: user?.email || 'security@hostelhub.edu',
      }
    }
  };

  // Get configuration for current role
  const config = menuConfig[role];

  // If no valid role, return null (shouldn't happen with ProtectedRoute)
  if (!config) {
    console.error(`Invalid role: ${role}. Sidebar not rendered.`);
    return null;
  }

  return (
    <aside className="unified-sidebar">
      {/* Header Section */}
      <div className="sidebar-header">
        <div className="sidebar-logo">{config.logo}</div>
        <div className="sidebar-title">{config.title}</div>
      </div>

      {/* Navigation Menu */}
      <nav className="sidebar-menu">
        <ul>
          {config.items.map((item) => (
            <li key={item.path}>
              <NavLink
                to={item.path}
                className={({ isActive }) => 
                  isActive ? 'sidebar-item active' : 'sidebar-item'
                }
              >
                {item.icon} <span>{item.label}</span>
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>

      {/* Footer Section */}
      <div className="sidebar-footer">
        <div className="sidebar-profile-card">
          <div className="sidebar-avatar-circle">
            {config.profile.initial}
          </div>
          <div className="sidebar-profile-info">
            <div className="sidebar-profile-name">{config.profile.name}</div>
            <div className="sidebar-profile-subtitle">{config.profile.subtitle}</div>
          </div>
        </div>
        <button 
          className="sidebar-view-profile-btn" 
          onClick={() => setShowProfile(true)}
        >
          👤 View Profile
        </button>
        <button 
          className="sidebar-change-password-btn" 
          onClick={() => setShowChangePassword(true)}
        >
          🔒 Change Password
        </button>
        <button className="sidebar-logout-btn" onClick={handleSignOut}>
          Sign Out
        </button>
      </div>

      {/* Profile Modal */}
      {showProfile && (
        <ProfileModal onClose={() => setShowProfile(false)} />
      )}

      {/* Change Password Modal */}
      {showChangePassword && (
        <ChangePassword 
          userId={user?.userId} 
          onClose={() => setShowChangePassword(false)} 
        />
      )}
    </aside>
  );
};

export default Sidebar;
