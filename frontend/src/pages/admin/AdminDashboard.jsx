import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import '../../styles/admin-dashboard.css';

const AdminDashboard = () => {
  const navigate = useNavigate();
  const [metrics, setMetrics] = useState({
    totalStudents: 0,
    totalWardens: 0,
    totalTechnicians: 0,
    totalSecurity: 0,
    pendingComplaints: 0,
    totalRooms: 0,
    occupiedRooms: 0,
  });
  const [loading, setLoading] = useState(true);

  // Fetch dashboard metrics
  useEffect(() => {
    const fetchMetrics = async () => {
      try {
        // Fetch dashboard stats
        const dashboardRes = await fetch('http://localhost:5000/api/admin/dashboard');
        const dashboardData = await dashboardRes.json();
        
        // Fetch all users to count by role
        const usersRes = await fetch('http://localhost:5000/api/admin/users');
        const usersData = await usersRes.json();
        
        let totalStudents = 0;
        let totalWardens = 0;
        let totalTechnicians = 0;
        let totalSecurity = 0;
        
        if (usersData.success && Array.isArray(usersData.data)) {
          totalStudents = usersData.data.filter(u => u.role === 'student').length;
          totalWardens = usersData.data.filter(u => u.role === 'warden').length;
          totalTechnicians = usersData.data.filter(u => u.role === 'technician').length;
          totalSecurity = usersData.data.filter(u => u.role === 'security').length;
        }
        
        if (dashboardData.success && dashboardData.data) {
          setMetrics({
            totalStudents,
            totalWardens,
            totalTechnicians,
            totalSecurity,
            pendingComplaints: dashboardData.data.active_complaints || 0,
            totalRooms: dashboardData.data.total_rooms || 0,
            occupiedRooms: dashboardData.data.occupied_rooms || 0,
          });
        }
        
        setLoading(false);
      } catch (error) {
        console.error('Error fetching metrics:', error);
        setLoading(false);
      }
    };
    
    fetchMetrics();
  }, []);
  
  // Dummy data for recent activities
  const recentActivities = [
    { id: 1, type: 'complaint', action: 'New complaint from Rahul Kumar', room: '204-A', time: '2 mins ago', status: 'pending' },
    { id: 2, type: 'registration', action: 'Student registration approved', name: 'Priya Singh', time: '15 mins ago', status: 'approved' },
    { id: 3, type: 'leave', action: 'Leave request submitted', name: 'Amit Patel', duration: '3 days', time: '45 mins ago', status: 'pending' },
    { id: 4, type: 'outpass', action: 'Outpass granted', name: 'Vishnu Sharma', time: '1 hour ago', status: 'approved' },
    { id: 5, type: 'complaint', action: 'Complaint resolved', room: '105-B', time: '2 hours ago', status: 'resolved' },
  ];

  // Dummy data for pending approvals
  const pendingApprovals = [
    { id: 1, type: 'Registration', name: 'Sneha Gupta', date: '2026-02-08', priority: 'high' },
    { id: 2, type: 'Leave Request', name: 'Arjun Verma', date: '2026-02-07', priority: 'medium' },
    { id: 3, type: 'Complaint', description: 'Water leakage in room 301', date: '2026-02-08', priority: 'critical' },
    { id: 4, type: 'Room Change', name: 'Nikita Das', date: '2026-02-06', priority: 'low' },
  ];

  // System status with real data
  const systemStatus = [
    { label: 'Server Status', value: 'Online', color: 'green' },
    { label: 'Active Students', value: metrics.totalStudents.toString(), color: 'blue' },
    { label: 'Pending Complaints', value: metrics.pendingComplaints.toString(), color: metrics.pendingComplaints > 0 ? 'orange' : 'green' },
    { label: 'Room Occupancy', value: `${metrics.occupiedRooms}/${metrics.totalRooms}`, color: 'green' },
  ];

  const getStatusBadgeClass = (status) => {
    switch(status) {
      case 'approved': return 'badge-approved';
      case 'pending': return 'badge-pending';
      case 'resolved': return 'badge-resolved';
      case 'critical': return 'badge-critical';
      case 'high': return 'badge-high';
      case 'medium': return 'badge-medium';
      case 'low': return 'badge-low';
      default: return 'badge-default';
    }
  };

  const getColorClass = (color) => {
    switch(color) {
      case 'green': return 'status-green';
      case 'blue': return 'status-blue';
      case 'orange': return 'status-orange';
      default: return 'status-gray';
    }
  };

  return (
    <div className="admin-dashboard-page">
      <header className="admin-header">
        <div className="header-left">
          <h1 className="admin-welcome">Admin Dashboard</h1>
          <p className="admin-sub">System administration, monitoring and user management</p>
        </div>
        {loading && <div style={{ fontSize: '14px', color: '#6b7280' }}>Loading...</div>}
      </header>

      {/* Key Metrics Section */}
      <section className="metrics-section">
        <div className="metrics-grid">
          <div className="metric-card students-card">
            <div className="metric-header">
              <span className="metric-icon">🎓</span>
              <span className="metric-label">Total Students</span>
            </div>
            <div className="metric-value">{metrics.totalStudents}</div>
            <div className="metric-sub">Active registrations</div>
          </div>

          <div className="metric-card wardens-card">
            <div className="metric-header">
              <span className="metric-icon">👨‍💼</span>
              <span className="metric-label">Wardens</span>
            </div>
            <div className="metric-value">{metrics.totalWardens}</div>
            <div className="metric-sub">Managing blocks</div>
          </div>

          <div className="metric-card technicians-card">
            <div className="metric-header">
              <span className="metric-icon">🔧</span>
              <span className="metric-label">Technicians</span>
            </div>
            <div className="metric-value">{metrics.totalTechnicians}</div>
            <div className="metric-sub">Maintenance staff</div>
          </div>

          <div className="metric-card security-card">
            <div className="metric-header">
              <span className="metric-icon">🛡️</span>
              <span className="metric-label">Security</span>
            </div>
            <div className="metric-value">{metrics.totalSecurity}</div>
            <div className="metric-sub">Security personnel</div>
          </div>
        </div>
      </section>

      {/* System Status Section */}
      <section className="system-status-section">
        <h2>System Status</h2>
        <div className="status-grid">
          {systemStatus.map((status, idx) => (
            <div key={idx} className={`status-card ${getColorClass(status.color)}`}>
              <div className="status-label">{status.label}</div>
              <div className="status-value">{status.value}</div>
              <div className={`status-indicator ${getColorClass(status.color)}`}></div>
            </div>
          ))}
        </div>
      </section>

      {/* Management Cards Section */}
      <section className="management-section">
        <h2>Quick Access</h2>
        <div className="management-grid">
          <div className="mgmt-card primary" onClick={() => navigate('/admin/users')}>
            <div className="mgmt-icon">👥</div>
            <div className="mgmt-title">All Users</div>
            <div className="mgmt-count">{metrics.totalStudents + metrics.totalWardens + metrics.totalTechnicians + metrics.totalSecurity}</div>
            <div className="mgmt-desc">Manage accounts</div>
          </div>

          <div className="mgmt-card" onClick={() => navigate('/admin/students')}>
            <div className="mgmt-icon">🎓</div>
            <div className="mgmt-title">Students</div>
            <div className="mgmt-count">{metrics.totalStudents}</div>
            <div className="mgmt-desc">Review & manage</div>
          </div>

          <div className="mgmt-card" onClick={() => navigate('/admin/wardens')}>
            <div className="mgmt-icon">👨‍💼</div>
            <div className="mgmt-title">Wardens</div>
            <div className="mgmt-count">{metrics.totalWardens}</div>
            <div className="mgmt-desc">Add or update</div>
          </div>

          <div className="mgmt-card" onClick={() => navigate('/admin/technicians')}>
            <div className="mgmt-icon">🔧</div>
            <div className="mgmt-title">Technicians</div>
            <div className="mgmt-count">{metrics.totalTechnicians}</div>
            <div className="mgmt-desc">Manage staff</div>
          </div>

          <div className="mgmt-card" onClick={() => navigate('/admin/security')}>
            <div className="mgmt-icon">🔐</div>
            <div className="mgmt-title">Security</div>
            <div className="mgmt-count">{metrics.totalSecurity}</div>
            <div className="mgmt-desc">Manage team</div>
          </div>
        </div>
      </section>

      {/* Recent Activities & Pending Approvals */}
      <section className="activities-section">
        <div className="activity-card">
          <div className="card-header">
            <h3>📊 Recent Activities</h3>
            <span className="header-badge">{recentActivities.length} actions</span>
          </div>
          <div className="activity-list">
            {recentActivities.map((activity) => (
              <div key={activity.id} className="activity-item">
                <div className="activity-icon">
                  {activity.type === 'complaint' && '⚠️'}
                  {activity.type === 'registration' && '✅'}
                  {activity.type === 'leave' && '📅'}
                  {activity.type === 'outpass' && '🚪'}
                </div>
                <div className="activity-details">
                  <div className="activity-action">{activity.action}</div>
                  <div className="activity-meta">{activity.time}</div>
                </div>
                <span className={`activity-status ${getStatusBadgeClass(activity.status)}`}>
                  {activity.status}
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="activity-card pending-card">
          <div className="card-header">
            <h3>⏳ Pending Approvals</h3>
            <span className="header-badge critical">{pendingApprovals.length} pending</span>
          </div>
          <div className="pending-list">
            {pendingApprovals.map((approval) => (
              <div key={approval.id} className="pending-item">
                <div className="pending-type">{approval.type}</div>
                <div className="pending-info">
                  <div className="pending-name">{approval.name || approval.description}</div>
                  <div className="pending-date">{approval.date}</div>
                </div>
                <span className={`pending-priority ${getStatusBadgeClass(approval.priority)}`}>
                  {approval.priority}
                </span>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
};

export default AdminDashboard;

