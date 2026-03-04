import React, { useState, useMemo, useEffect } from 'react';
import '../../styles/admin-users.css';

const AdminUsers = () => {
  // State for users data
  const [students, setStudents] = useState([]);
  const [wardens, setWardens] = useState([]);
  const [technicians, setTechnicians] = useState([]);
  const [security, setSecurity] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  // Fetch users on component mount and when tab changes
  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      console.log('Fetching users from API...');
      const res = await fetch('http://localhost:5000/api/admin/users');
      const data = await res.json();
      console.log('API Response:', data);
      
      if (data.success && Array.isArray(data.data)) {
        // Separate users by role
        const studentList = data.data.filter(u => u.role === 'student');
        const wardenList = data.data.filter(u => u.role === 'warden');
        const techList = data.data.filter(u => u.role === 'technician');
        const secList = data.data.filter(u => u.role === 'security');
        
        console.log (`Found: ${studentList.length} students, ${wardenList.length} wardens, ${techList.length} technicians, ${secList.length} security`);
        
        setStudents(studentList);
        setWardens(wardenList);
        setTechnicians(techList);
        setSecurity(secList);
      }
      
      setLoading(false);
    } catch (error) {
      console.error('Error fetching users:', error);
      alert('Failed to fetch users from database. Check if backend is running.');
      setLoading(false);
    }
  };

  // State management
  const [activeTab, setActiveTab] = useState('Students');
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [roleFilter, setRoleFilter] = useState('All');
  
  // Modals
  const [showAddModal, setShowAddModal] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  
  // Form data
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    rollNumber: '',
    branch: '',
    year: '',
  });

  // Password form data
  const [passwordFormData, setPasswordFormData] = useState({
    password: '',
    confirmPassword: '',
  });

  // Get current user list based on active tab
  const getCurrentUsers = () => {
    switch(activeTab) {
      case 'Students': return students;
      case 'Wardens': return wardens;
      case 'Technicians': return technicians;
      case 'Security': return security;
      default: return [];
    }
  };

  // Get role-specific options
  const getRoleOptions = (tab) => {
    switch(tab) {
      case 'Technicians':
        return ['Electrical', 'Plumbing', 'Carpentry', 'Internet', 'Cleaning'];
      case 'Security':
        return ['Morning (6AM-2PM)', 'Evening (2PM-10PM)', 'Night (10PM-6AM)'];
      default:
        return [];
    }
  };

  // Filter users based on search and status
  const filteredUsers = useMemo(() => {
    let filtered = getCurrentUsers();
    
    if (statusFilter !== 'All') {
      // Convert filter to lowercase to match API response
      const normalizedFilter = statusFilter.toLowerCase();
      filtered = filtered.filter(user => user.status === normalizedFilter);
    }
    
    if (searchTerm) {
      filtered = filtered.filter(user =>
        user.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (user.roll_number && user.roll_number.toLowerCase().includes(searchTerm.toLowerCase())) ||
        user.id?.toString().includes(searchTerm)
      );
    }
    
    return filtered;
  }, [searchTerm, statusFilter, activeTab, students, wardens, technicians, security]);

  // Handle modal actions
  const handleAddUser = () => {
    resetForm();
    setShowAddModal(true);
  };

  const handleViewProfile = (user) => {
    setSelectedUser(user);
    setShowProfileModal(true);
  };

  const handleEditUser = (user) => {
    setSelectedUser(user);
    setFormData({
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: '',
      roleSpecific: '',
    });
    setShowAddModal(true);
  };

  const handleDeleteClick = (user) => {
    setSelectedUser(user);
    setShowDeleteConfirm(true);
  };

  const handleChangePasswordClick = (user) => {
    setSelectedUser(user);
    setPasswordFormData({ password: '', confirmPassword: '' });
    setShowPasswordModal(true);
  };

  const handlePasswordFormChange = (e) => {
    const { name, value } = e.target;
    setPasswordFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleChangePassword = async () => {
    if (!passwordFormData.password || !passwordFormData.confirmPassword) {
      alert('Please enter password in both fields');
      return;
    }

    if (passwordFormData.password !== passwordFormData.confirmPassword) {
      alert('Passwords do not match');
      return;
    }

    if (passwordFormData.password.length < 4) {
      alert('Password must be at least 4 characters long');
      return;
    }

    if (!confirm(`Change password for ${selectedUser.name}?`)) {
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch(`http://localhost:5000/api/admin/user/${selectedUser.id}/password`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: passwordFormData.password })
      });
      
      const data = await res.json();
      
      if (data.success) {
        alert(data.message);
        setShowPasswordModal(false);
        setSelectedUser(null);
        setPasswordFormData({ password: '', confirmPassword: '' });
      } else {
        alert(data.message || 'Failed to change password');
      }
    } catch (error) {
      console.error('Error changing password:', error);
      alert('Failed to change password');
    } finally {
      setSubmitting(false);
    }
  };

  const handleFormChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSaveUser = async () => {
    if (!formData.name || !formData.email) {
      alert('Please fill in all required fields');
      return;
    }
    
    // Determine role from activeTab
    const role = activeTab.toLowerCase().slice(0, -1); // Remove 's' from plural
    const roleMap = {
      'student': 'student',
      'warden': 'warden',
      'technician': 'technician',
      'securit': 'security' // Handle "security" special case
    };
    
    const userRole = roleMap[role] || role;
    
    setSubmitting(true);
    try {
      const payload = {
        name: formData.name,
        email: formData.email,
        phone: formData.phone,
        role: userRole,
        password: 'default123' // Default password
      };
      
      // Add student-specific fields
      if (userRole === 'student') {
        payload.roll_number = formData.rollNumber;
        payload.branch = formData.branch;
        payload.year = formData.year;
      }
      
      const res = await fetch('http://localhost:5000/api/admin/user', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      
      const data = await res.json();
      
      if (data.success) {
        // Refresh user list
        await fetchUsers();
        setShowAddModal(false);
        resetForm();
      } else {
        alert(data.message || 'Failed to create user');
      }
    } catch (error) {
      console.error('Error creating user:', error);
      alert('Failed to create user');
    } finally {
      setSubmitting(false);
    }
  };

  const handleToggleStatus = async (user) => {
    const newStatus = user.status === 'active' ? 'inactive' : 'active';
    
    try {
      const res = await fetch(`http://localhost:5000/api/admin/user/${user.id}/status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus })
      });
      
      const data = await res.json();
      
      if (data.success) {
        // Refresh user list
        await fetchUsers();
      } else {
        alert(data.message || 'Failed to update status');
      }
    } catch (error) {
      console.error('Error updating status:', error);
      alert('Failed to update status');
    }
  };

  const handleConfirmDelete = async () => {
    if (!selectedUser) return;
    
    setSubmitting(true);
    try {
      const res = await fetch(`http://localhost:5000/api/admin/user/${selectedUser.id}`, {
        method: 'DELETE'
      });
      
      const data = await res.json();
      
      if (data.success) {
        // Refresh user list
        await fetchUsers();
        setShowDeleteConfirm(false);
        setSelectedUser(null);
      } else {
        alert(data.message || 'Failed to delete user');
      }
    } catch (error) {
      console.error('Error deleting user:', error);
      alert('Failed to delete user');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      email: '',
      phone: '',
      rollNumber: '',
      branch: '',
      year: '',
    });
    setSelectedUser(null);
  };

  const handleCloseModal = () => {
    setShowAddModal(false);
    resetForm();
  };

  // Render table based on active tab
  const renderUsersTable = () => {
    if (loading) {
      return (
        <div className="empty-state-container">
          <div className="empty-state">
            <div className="empty-icon">⏳</div>
            <h3>Loading users...</h3>
            <p>Fetching data from database</p>
          </div>
        </div>
      );
    }
    
    if (filteredUsers.length === 0) {
      return (
        <div className="empty-state-container">
          <div className="empty-state">
            <div className="empty-icon">👥</div>
            <h3>No users found</h3>
            <p>No {activeTab.toLowerCase()} users match your search criteria</p>
          </div>
        </div>
      );
    }

    return (
      <div className="table-container">
        <table className="users-table">
          <thead>
            <tr>
              <th>Name</th>
              {activeTab === 'Students' && (
                <>
                  <th>Roll Number</th>
                  <th>Branch</th>
                  <th>Year</th>
                </>
              )}
              {activeTab === 'Wardens' && (
                <>
                  <th>Email</th>
                  <th>Phone</th>
                  <th>Joined</th>
                </>
              )}
              {activeTab === 'Technicians' && (
                <>
                  <th>Category</th>
                  <th>Email</th>
                  <th>Phone</th>
                </>
              )}
              {activeTab === 'Security' && (
                <>
                  <th>Shift</th>
                  <th>Email</th>
                  <th>Phone</th>
                </>
              )}
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.map((user) => (
              <tr key={user.id}>
                <td>
                  <div className="user-cell">
                    <div className="user-avatar">
                      {user.name.charAt(0).toUpperCase()}
                    </div>
                    <div className="user-info">
                      <div className="user-name">{user.name}</div>
                      <div className="user-id">{user.id}</div>
                    </div>
                  </div>
                </td>
                {activeTab === 'Students' && (
                  <>
                    <td>{user.roll_number || 'N/A'}</td>
                    <td>{user.branch || 'N/A'}</td>
                    <td>{user.year || 'N/A'}</td>
                  </>
                )}
                {activeTab === 'Wardens' && (
                  <>
                    <td>{user.email}</td>
                    <td>{user.phone || 'N/A'}</td>
                    <td>{user.created_at ? new Date(user.created_at).toLocaleDateString() : 'N/A'}</td>
                  </>
                )}
                {activeTab === 'Technicians' && (
                  <>
                    <td><span className="category-badge">{user.category || 'N/A'}</span></td>
                    <td>{user.email}</td>
                    <td>{user.phone || 'N/A'}</td>
                  </>
                )}
                {activeTab === 'Security' && (
                  <>
                    <td><span className="shift-badge">{user.shift || 'N/A'}</span></td>
                    <td>{user.email}</td>
                    <td>{user.phone || 'N/A'}</td>
                  </>
                )}
                <td>
                  <span className={`status-badge ${user.status === 'active' ? 'badge-active' : 'badge-inactive'}`}>
                    {user.status === 'active' ? '🟢 Active' : '🔴 Inactive'}
                  </span>
                </td>
                <td>
                  <div className="actions-cell">
                    {/* View button - All tabs */}
                    <button
                      className="btn-action btn-view"
                      onClick={() => handleViewProfile(user)}
                      title="View Profile"
                    >
                      👁️
                    </button>

                    {/* Edit button - Wardens, Technicians, Security only */}
                    {(activeTab === 'Wardens' || activeTab === 'Technicians' || activeTab === 'Security') && (
                      <button
                        className="btn-action btn-edit"
                        onClick={() => handleEditUser(user)}
                        title="Edit"
                      >
                        ✏️
                      </button>
                    )}

                    {/* Change Password button - All tabs */}
                    <button
                      className="btn-action btn-password"
                      onClick={() => handleChangePasswordClick(user)}
                      title="Change Password"
                    >
                      🔐
                    </button>

                    {/* Toggle Status button - Wardens, Technicians, Security only */}
                    {(activeTab === 'Wardens' || activeTab === 'Technicians' || activeTab === 'Security') && (
                      <button
                        className={`btn-action ${user.status === 'Active' ? 'btn-deactivate' : 'btn-activate'}`}
                        onClick={() => handleToggleStatus(user)}
                        title={user.status === 'Active' ? 'Deactivate' : 'Activate'}
                      >
                        {user.status === 'Active' ? '⏹️' : '▶️'}
                      </button>
                    )}

                    {/* Delete button - Wardens, Technicians, Security only */}
                    {(activeTab === 'Wardens' || activeTab === 'Technicians' || activeTab === 'Security') && (
                      <button
                        className="btn-action btn-delete"
                        onClick={() => handleDeleteClick(user)}
                        title="Delete"
                      >
                        🗑️
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  return (
    <div className="admin-users-page">
      {/* Page Header */}
      <div className="page-header">
        <div className="header-content">
          <h1 className="page-title">User Management</h1>
          <p className="page-subtitle">Manage system users and roles</p>
        </div>
        {activeTab !== 'Students' && (
          <button className="btn-primary btn-add" onClick={handleAddUser}>
            âž• Add User
          </button>
        )}
      </div>

      {/* Tabs */}
      <div className="tabs-section">
        <div className="tabs-container">
          {['Students', 'Wardens', 'Technicians', 'Security'].map((tab) => (
            <button
              key={tab}
              className={`tab-button ${activeTab === tab ? 'active' : ''}`}
              onClick={() => {
                setActiveTab(tab);
                setSearchTerm('');
                setStatusFilter('All');
              }}
            >
              {tab === 'Students' && '🎓'}
              {tab === 'Wardens' && '👨‍💼'}
              {tab === 'Technicians' && '🔧'}
              {tab === 'Security' && '🛡️'}
              <span>{tab}</span>
              <span className="tab-count">({getCurrentUsers().length})</span>
            </button>
          ))}
        </div>
      </div>

      {/* Search & Filter */}
      <div className="search-filter-section">
        <div className="search-box">
          <input
            type="text"
            placeholder="Search by name or ID..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
          <span className="search-icon">🔍</span>
        </div>

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="filter-select"
        >
          <option>All</option>
          <option>Active</option>
          <option>Inactive</option>
        </select>
      </div>

      {/* Results Info */}
      <div className="results-info">
        <span>Showing {filteredUsers.length} of {getCurrentUsers().length} users</span>
      </div>

      {/* Users Table */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '3rem', color: '#6b7280' }}>
          <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>⏳</div>
          <div>Loading users...</div>
        </div>
      ) : (
        renderUsersTable()
      )}

      {/* Add User Modal */}
      {showAddModal && (
        <div className="modal-overlay" onClick={handleCloseModal}>
          <div className="modal-content modal-lg" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{selectedUser ? 'Edit User' : `Add ${activeTab.slice(0, -1)}`}</h2>
              <button className="btn-close" onClick={handleCloseModal}>✕</button>
            </div>

            <div className="modal-body">
              <div className="form-group">
                <label>Name *</label>
                <input
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleFormChange}
                  placeholder="Enter full name"
                  className="form-input"
                />
              </div>

              <div className="form-group-row">
                <div className="form-group">
                  <label>Email *</label>
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleFormChange}
                    placeholder="Enter email"
                    className="form-input"
                  />
                </div>
                <div className="form-group">
                  <label>Phone</label>
                  <input
                    type="tel"
                    name="phone"
                    value={formData.phone}
                    onChange={handleFormChange}
                    placeholder="Enter phone"
                    className="form-input"
                  />
                </div>
              </div>

              {(activeTab === 'Technicians' || activeTab === 'Security') && (
                <div className="form-group">
                  <label>{activeTab === 'Technicians' ? 'Category' : 'Shift'} *</label>
                  <select
                    name="roleSpecific"
                    value={formData.roleSpecific}
                    onChange={handleFormChange}
                    className="form-select"
                  >
                    <option value="">Select {activeTab === 'Technicians' ? 'category' : 'shift'}</option>
                    {getRoleOptions(activeTab).map((option) => (
                      <option key={option} value={option}>{option}</option>
                    ))}
                  </select>
                </div>
              )}

              {activeTab === 'Students' && (
                <>
                  <div className="form-group">
                    <label>Roll Number *</label>
                    <input
                      type="text"
                      name="rollNumber"
                      value={formData.rollNumber}
                      onChange={handleFormChange}
                      placeholder="Enter roll number"
                      className="form-input"
                    />
                  </div>
                  <div className="form-group-row">
                    <div className="form-group">
                      <label>Branch</label>
                      <input
                        type="text"
                        name="branch"
                        value={formData.branch}
                        onChange={handleFormChange}
                        placeholder="e.g., CSE, ECE, ME"
                        className="form-input"
                      />
                    </div>
                    <div className="form-group">
                      <label>Year</label>
                      <input
                        type="number"
                        name="year"
                        value={formData.year}
                        onChange={handleFormChange}
                        placeholder="e.g., 1, 2, 3, 4"
                        className="form-input"
                        min="1"
                        max="4"
                      />
                    </div>
                  </div>
                </>
              )}

              {activeTab === 'Wardens' && (
                <>
                  <div className="form-group-row">
                    <div className="form-group">
                      <label>Hostel *</label>
                      <select name="role" value={formData.role} onChange={handleFormChange} className="form-select">
                        <option value="">Select hostel</option>
                        <option value="Main Hostel">Main Hostel</option>
                        <option value="Girls Hostel">Girls Hostel</option>
                      </select>
                    </div>
                    <div className="form-group">
                      <label>Block *</label>
                      <select name="roleSpecific" value={formData.roleSpecific} onChange={handleFormChange} className="form-select">
                        <option value="">Select block</option>
                        <option value="Block A">Block A</option>
                        <option value="Block B">Block B</option>
                        <option value="Block C">Block C</option>
                        <option value="Block D">Block D</option>
                      </select>
                    </div>
                  </div>
                </>
              )}
            </div>

            <div className="modal-footer">
              <button className="btn-secondary" onClick={handleCloseModal}>Cancel</button>
              <button
                className="btn-primary"
                onClick={handleSaveUser}
                disabled={
                  submitting ||
                  !formData.name || 
                  !formData.email ||
                  (activeTab === 'Students' && !formData.rollNumber)
                }
              >
                {submitting ? 'Creating...' : (selectedUser ? 'Update User' : 'Create User')}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* View Profile Modal */}
      {showProfileModal && selectedUser && (
        <div className="modal-overlay" onClick={() => setShowProfileModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>User Profile</h2>
              <button className="btn-close" onClick={() => setShowProfileModal(false)}>✕</button>
            </div>

            <div className="modal-body">
              <div className="profile-section">
                <div className="profile-avatar-large">
                  {selectedUser.name.charAt(0).toUpperCase()}
                </div>
                <div className="profile-main-info">
                  <h3>{selectedUser.name}</h3>
                  <p className="profile-id">{selectedUser.id}</p>
                  <span className={`status-badge ${selectedUser.status === 'active' ? 'badge-active' : 'badge-inactive'}`}>
                    {selectedUser.status === 'active' ? '🟢 Active' : '🔴 Inactive'}
                  </span>
                </div>
              </div>

              <div className="profile-details">
                <div className="detail-row">
                  <span className="detail-label">Email</span>
                  <span className="detail-value">{selectedUser.email}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Phone</span>
                  <span className="detail-value">{selectedUser.phone || 'N/A'}</span>
                </div>

                {activeTab === 'Students' && (
                  <>
                    <div className="detail-row">
                      <span className="detail-label">Roll Number</span>
                      <span className="detail-value">{selectedUser.roll_number || 'N/A'}</span>
                    </div>
                    <div className="detail-row">
                      <span className="detail-label">Branch</span>
                      <span className="detail-value">{selectedUser.branch || 'N/A'}</span>
                    </div>
                    <div className="detail-row">
                      <span className="detail-label">Year</span>
                      <span className="detail-value">{selectedUser.year}</span>
                    </div>
                  </>
                )}

                {activeTab === 'Wardens' && (
                  <>
                    <div className="detail-row">
                      <span className="detail-label">Hostel</span>
                      <span className="detail-value">{selectedUser.hostel}</span>
                    </div>
                    <div className="detail-row">
                      <span className="detail-label">Block</span>
                      <span className="detail-value">{selectedUser.block}</span>
                    </div>
                  </>
                )}

                {activeTab === 'Technicians' && (
                  <div className="detail-row">
                    <span className="detail-label">Category</span>
                    <span className="detail-value">{selectedUser.category}</span>
                  </div>
                )}

                {activeTab === 'Security' && (
                  <div className="detail-row">
                    <span className="detail-label">Shift</span>
                    <span className="detail-value">{selectedUser.shift}</span>
                  </div>
                )}

                <div className="detail-row">
                  <span className="detail-label">Created</span>
                  <span className="detail-value">2026-02-08</span>
                </div>
              </div>
            </div>

            <div className="modal-footer">
              <button className="btn-secondary" onClick={() => setShowProfileModal(false)}>Close</button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && selectedUser && (
        <div className="modal-overlay" onClick={() => setShowDeleteConfirm(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Confirm Delete</h2>
              <button className="btn-close" onClick={() => setShowDeleteConfirm(false)}>✕</button>
            </div>

            <div className="modal-body">
              <div className="confirm-icon">⚠️</div>
              <p className="confirm-text">
                Are you sure you want to delete <strong>{selectedUser.name}</strong>?
              </p>
              <p className="confirm-subtext">This action cannot be undone.</p>
            </div>

            <div className="modal-footer">
              <button 
                className="btn-secondary" 
                onClick={() => setShowDeleteConfirm(false)}
                disabled={submitting}
              >
                Cancel
              </button>
              <button 
                className="btn-danger" 
                onClick={handleConfirmDelete}
                disabled={submitting}
              >
                {submitting ? 'Deleting...' : 'Delete User'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Change Password Modal */}
      {showPasswordModal && selectedUser && (
        <div className="modal-overlay" onClick={() => setShowPasswordModal(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Change Password</h2>
              <button className="btn-close" onClick={() => setShowPasswordModal(false)}>✕</button>
            </div>

            <div className="modal-body">
              <p className="modal-info">Changing password for: <strong>{selectedUser.name}</strong></p>
              
              <div className="form-group">
                <label>New Password</label>
                <input
                  type="password"
                  className="form-input"
                  name="password"
                  value={passwordFormData.password}
                  onChange={handlePasswordFormChange}
                  placeholder="Enter new password"
                />
              </div>

              <div className="form-group">
                <label>Confirm Password</label>
                <input
                  type="password"
                  className="form-input"
                  name="confirmPassword"
                  value={passwordFormData.confirmPassword}
                  onChange={handlePasswordFormChange}
                  placeholder="Re-enter password"
                />
              </div>

              {passwordFormData.password && passwordFormData.confirmPassword && passwordFormData.password !== passwordFormData.confirmPassword && (
                <div className="error-message">Passwords do not match</div>
              )}
            </div>

            <div className="modal-footer">
              <button 
                className="btn-secondary" 
                onClick={() => setShowPasswordModal(false)}
                disabled={submitting}
              >
                Cancel
              </button>
              <button 
                className="btn-primary" 
                onClick={handleChangePassword}
                disabled={submitting || !passwordFormData.password || !passwordFormData.confirmPassword}
              >
                {submitting ? 'Changing...' : 'Change Password'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminUsers;

