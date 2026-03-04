import React, { useState, useMemo, useEffect } from 'react';
import '../../styles/admin-security.css';

const AdminSecurity = () => {
  // State for security staff from database
  const [securityStaff, setSecurityStaff] = useState([]);
  const [hostelBlocks, setHostelBlocks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  // Fetch data on component mount
  useEffect(() => {
    fetchData();
    fetchHostelBlocks();
  }, []);

  const fetchHostelBlocks = async () => {
    try {
      const res = await fetch('http://localhost:5000/api/admin/hostel-blocks');
      const data = await res.json();
      
      if (data.success && Array.isArray(data.data)) {
        setHostelBlocks(data.data);
      }
    } catch (error) {
      console.error('Error fetching hostel blocks:', error);
    }
  };

  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch security staff
      const staffRes = await fetch('http://localhost:5000/api/admin/users?role=security');
      const staffData = await staffRes.json();
      
      if (staffData.success && Array.isArray(staffData.data)) {
        const normalized = staffData.data.map((staff) => ({
          ...staff,
          staff_id: staff.security_employee_id || staff.employee_id || staff.id,
          gate: staff.gate_assigned || staff.gate || '',
          shift: staff.shift_timing || staff.shift || '',
          phone: staff.security_phone || staff.phone || '',
        }));
        setSecurityStaff(normalized);
      }

      setLoading(false);
    } catch (error) {
      console.error('Error fetching data:', error);
      alert('Failed to fetch data from database');
      setLoading(false);
    }
  };
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    staffId: '',
    phone: '',
    gate: '',
    shift: '',
    status: 'Active'
  });

  // Password form data
  const [passwordFormData, setPasswordFormData] = useState({
    password: '',
    confirmPassword: '',
  });

  // State management
  const [searchTerm, setSearchTerm] = useState('');
  const [shiftFilter, setShiftFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');
  const [showAddModal, setShowAddModal] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [selectedStaff, setSelectedStaff] = useState(null);

  // Filter security staff
  const filteredStaff = useMemo(() => {
    return securityStaff.filter(staff => {
      const matchesStatus = statusFilter === 'All' || staff.status === statusFilter.toLowerCase();
      const matchesShift = shiftFilter === 'All' || staff.shift === shiftFilter;
      const matchesSearch = 
        staff.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        staff.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        staff.id?.toString().includes(searchTerm) ||
        staff.staff_id?.toString().includes(searchTerm);
      
      return matchesStatus && matchesShift && matchesSearch;
    });
  }, [securityStaff, searchTerm, shiftFilter, statusFilter]);

  // Handlers
  const handleAddStaff = () => {
    resetForm();
    setSelectedStaff(null);
    setShowAddModal(true);
  };

  const handleViewProfile = (staff) => {
    setSelectedStaff(staff);
    setShowProfileModal(true);
  };

  const handleEditStaff = (staff) => {
    setSelectedStaff(staff);
    setFormData({
      name: staff.name,
      email: staff.email || '',
      staffId: staff.staff_id || staff.id,
      phone: staff.phone,
      gate: staff.gate || '',
      shift: staff.shift || '',
      status: staff.status === 'inactive' ? 'Inactive' : 'Active'
    });
    setShowAddModal(true);
  };

  const handleDeleteClick = (staff) => {
    setSelectedStaff(staff);
    setShowDeleteConfirm(true);
  };

  const handleChangePasswordClick = (staff) => {
    setSelectedStaff(staff);
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

    if (!confirm(`Change password for ${selectedStaff.name}?`)) {
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch(`http://localhost:5000/api/admin/user/${selectedStaff.id}/password`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: passwordFormData.password })
      });
      
      const data = await res.json();
      
      if (data.success) {
        alert(data.message);
        setShowPasswordModal(false);
        setSelectedStaff(null);
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
      [name]: value
    }));
  };

  const handleSaveStaff = async () => {
    // Validation
    if (!formData.name || !formData.email || !formData.phone || !formData.gate || !formData.shift) {
      alert('Please fill in all required fields');
      return;
    }

    setSubmitting(true);
    try {
      if (selectedStaff) {
        const payload = {
          name: formData.name,
          email: formData.email,
          phone: formData.phone,
          gate: formData.gate,
          shift: formData.shift,
          staffId: formData.staffId
        };

        const res = await fetch(`http://localhost:5000/api/admin/user/${selectedStaff.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        const data = await res.json();
        if (data.success) {
          const desiredStatus = formData.status === 'Active' ? 'active' : 'inactive';
          if (selectedStaff.status !== desiredStatus) {
            await fetch(`http://localhost:5000/api/admin/user/${selectedStaff.id}/status`, {
              method: 'PUT',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ status: desiredStatus })
            });
          }

          alert(`Updated ${formData.name} successfully!`);
          await fetchData();
          setShowAddModal(false);
          resetForm();
        } else {
          alert(data.message || 'Failed to update security staff');
        }
      } else {
        const payload = {
          name: formData.name,
          email: formData.email,
          password: 'security123',
          role: 'security',
          phone: formData.phone,
          staffId: formData.staffId,
          gate: formData.gate,
          shift: formData.shift
        };

        const res = await fetch('http://localhost:5000/api/admin/user', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        const data = await res.json();
        if (data.success) {
          if (formData.status === 'Inactive') {
            await fetch(`http://localhost:5000/api/admin/user/${data.id}/status`, {
              method: 'PUT',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ status: 'inactive' })
            });
          }

          alert(`Added ${formData.name} successfully!`);
          await fetchData();
          setShowAddModal(false);
          resetForm();
        } else {
          alert(data.message || 'Failed to add security staff');
        }
      }
    } catch (error) {
      console.error('Error saving security staff:', error);
      alert('Failed to save security staff');
    } finally {
      setSubmitting(false);
    }
  };

  const handleToggleStatus = async (staff) => {
    try {
      const newStatus = staff.status === 'active' ? 'inactive' : 'active';
      const res = await fetch(`http://localhost:5000/api/admin/user/${staff.id}/status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus })
      });

      const data = await res.json();
      if (data.success) {
        await fetchData();
      } else {
        alert(data.message || 'Failed to update status');
      }
    } catch (error) {
      console.error('Error toggling status:', error);
      alert('Failed to update status');
    }
  };

  const handleConfirmDelete = async () => {
    setSubmitting(true);
    try {
      const res = await fetch(`http://localhost:5000/api/admin/user/${selectedStaff.id}`, {
        method: 'DELETE'
      });

      const data = await res.json();
      if (data.success) {
        alert(`${selectedStaff.name} has been deleted`);
        await fetchData();
        setShowDeleteConfirm(false);
        setSelectedStaff(null);
      } else {
        alert(data.message || 'Failed to delete staff');
      }
    } catch (error) {
      console.error('Error deleting staff:', error);
      alert('Failed to delete staff');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      email: '',
      staffId: '',
      phone: '',
      gate: '',
      shift: '',
      status: 'Active'
    });
    setSelectedStaff(null);
  };

  const handleCloseModal = () => {
    setShowAddModal(false);
    resetForm();
  };

  return (
    <div className="admin-security-page">
      {/* Page Header */}
      <div className="page-header">
        <div className="header-content">
          <h1 className="page-title">Security Staff</h1>
          <p className="page-subtitle">Manage hostel security personnel</p>
        </div>
        <button className="btn-primary btn-add" onClick={handleAddStaff}>
          âž• Add Security Staff
        </button>
      </div>

      {/* Search & Filter Section */}
      <div className="search-filter-section">
        <div className="search-box">
          <span className="search-icon">🔍</span>
          <input
            type="text"
            placeholder="Search by name or ID..."
            className="search-input"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        
        <select 
          className="filter-select"
          value={shiftFilter}
          onChange={(e) => setShiftFilter(e.target.value)}
        >
          <option value="All">All Shifts</option>
          <option value="Morning">Morning</option>
          <option value="Evening">Evening</option>
          <option value="Night">Night</option>
        </select>

        <select 
          className="filter-select"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
        >
          <option value="All">All Status</option>
          <option value="Active">Active</option>
          <option value="Inactive">Inactive</option>
        </select>
      </div>

      {/* Results Info */}
      <div className="results-info">
        Showing {filteredStaff.length} of {securityStaff.length} security staff
      </div>

      {/* Security Staff Table or Empty State */}
      {filteredStaff.length > 0 ? (
        <div className="table-container">
          <table className="security-table">
            <thead>
              <tr>
                <th>Staff Name</th>
                <th>Staff ID</th>
                <th>Phone</th>
                <th>Assigned Gate/Area</th>
                <th>Shift Timing</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredStaff.map((staff) => (
                <tr key={staff.id}>
                  <td>
                    <div className="staff-cell">
                      <div className="staff-avatar">
                        {staff.name.charAt(0)}
                      </div>
                      <div className="staff-info">
                        <div className="staff-name">{staff.name}</div>
                      </div>
                    </div>
                  </td>
                  <td className="staff-id">{staff.staff_id || staff.id}</td>
                  <td>{staff.phone}</td>
                  <td>
                    <span className="gate-badge">{staff.gate}</span>
                  </td>
                  <td>
                    <span className="shift-badge">{staff.shift}</span>
                  </td>
                  <td>
                    <span className={`status-badge ${staff.status === 'active' ? 'badge-active' : 'badge-inactive'}`}>
                      {staff.status === 'active' ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td>
                    <div className="actions-cell">
                      <button 
                        className="btn-action btn-view"
                        onClick={() => handleViewProfile(staff)}
                        title="View Profile"
                      >
                        👁️
                      </button>
                      <button 
                        className="btn-action btn-edit"
                        onClick={() => handleEditStaff(staff)}
                        title="Edit"
                      >
                        ✏️
                      </button>
                      <button 
                        className="btn-action btn-password"
                        onClick={() => handleChangePasswordClick(staff)}
                        title="Change Password"
                      >
                        🔐
                      </button>
                      <button 
                        className={`btn-action ${staff.status === 'active' ? 'btn-deactivate' : 'btn-activate'}`}
                        onClick={() => handleToggleStatus(staff)}
                        title={staff.status === 'active' ? 'Deactivate' : 'Activate'}
                      >
                        {staff.status === 'active' ? '⏸️' : '▶️'}
                      </button>
                      <button 
                        className="btn-action btn-delete"
                        onClick={() => handleDeleteClick(staff)}
                        title="Delete"
                      >
                        🗑️
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="empty-state-container">
          <div className="empty-state">
            <div className="empty-icon">🛡️</div>
            <h3>No security staff found</h3>
            <p>
              {searchTerm || shiftFilter !== 'All' || statusFilter !== 'All'
                ? 'Try adjusting your filters'
                : 'No security staff added yet'}
            </p>
          </div>
        </div>
      )}

      {/* Add/Edit Modal */}
      {showAddModal && (
        <div className="modal-overlay" onClick={handleCloseModal}>
          <div className="modal-content modal-lg" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{selectedStaff ? 'Edit Security Staff' : 'Add Security Staff'}</h2>
              <button className="btn-close" onClick={handleCloseModal}>×</button>
            </div>
            <div className="modal-body">
              <div className="form-group-row">
                <div className="form-group">
                  <label>Name *</label>
                  <input
                    type="text"
                    name="name"
                    className="form-input"
                    value={formData.name}
                    onChange={handleFormChange}
                    placeholder="Enter staff name"
                  />
                </div>
                <div className="form-group">
                  <label>Staff ID</label>
                  <input
                    type="text"
                    name="staffId"
                    className="form-input"
                    value={formData.staffId}
                    onChange={handleFormChange}
                    placeholder="Auto-generated"
                    disabled={!!selectedStaff}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Email *</label>
                <input
                  type="email"
                  name="email"
                  className="form-input"
                  value={formData.email}
                  onChange={handleFormChange}
                  placeholder="security@hostel.edu"
                />
              </div>
              
              <div className="form-group">
                <label>Phone Number *</label>
                <input
                  type="tel"
                  name="phone"
                  className="form-input"
                  value={formData.phone}
                  onChange={handleFormChange}
                  placeholder="+91 XXXXX XXXXX"
                />
              </div>

              <div className="form-group-row">
                <div className="form-group">
                  <label>Assigned Gate/Area *</label>
                  <select
                    name="gate"
                    className="form-select"
                    value={formData.gate}
                    onChange={handleFormChange}
                  >
                    <option value="">Select Gate/Area</option>
                    {hostelBlocks.map((block) => (
                      <option key={block.id} value={block.block_name}>
                        {block.block_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="form-group">
                  <label>Shift Timing *</label>
                  <select
                    name="shift"
                    className="form-select"
                    value={formData.shift}
                    onChange={handleFormChange}
                  >
                    <option value="">Select Shift</option>
                    <option value="Morning">Morning (6 AM - 2 PM)</option>
                    <option value="Evening">Evening (2 PM - 10 PM)</option>
                    <option value="Night">Night (10 PM - 6 AM)</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Status</label>
                <select
                  name="status"
                  className="form-select"
                  value={formData.status}
                  onChange={handleFormChange}
                >
                  <option value="Active">Active</option>
                  <option value="Inactive">Inactive</option>
                </select>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn-secondary" onClick={handleCloseModal}>
                Cancel
              </button>
              <button 
                className="btn-primary" 
                onClick={handleSaveStaff}
                disabled={!formData.name || !formData.email || !formData.phone || !formData.gate || !formData.shift}
              >
                {selectedStaff ? 'Update Staff' : 'Add Staff'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* View Profile Modal */}
      {showProfileModal && selectedStaff && (
        <div className="modal-overlay" onClick={() => setShowProfileModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Security Staff Profile</h2>
              <button className="btn-close" onClick={() => setShowProfileModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="profile-section">
                <div className="profile-avatar-large">
                  {selectedStaff.name.charAt(0)}
                </div>
                <div className="profile-main-info">
                  <h3>{selectedStaff.name}</h3>
                  <p className="profile-id">Staff ID: {selectedStaff.staff_id || 'N/A'}</p>
                  <span className={`status-badge ${selectedStaff.status === 'active' ? 'badge-active' : 'badge-inactive'}`}>
                    {selectedStaff.status === 'active' ? 'Active' : 'Inactive'}
                  </span>
                </div>
              </div>
              
              <div className="profile-details">
                <div className="detail-row">
                  <span className="detail-label">Phone</span>
                  <span className="detail-value">{selectedStaff.phone}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Assigned Gate/Area</span>
                  <span className="detail-value">{selectedStaff.gate}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Shift Timing</span>
                  <span className="detail-value">{selectedStaff.shift}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Address</span>
                  <span className="detail-value">{selectedStaff.address}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Joining Date</span>
                  <span className="detail-value">
                    {new Date(selectedStaff.joiningDate).toLocaleDateString('en-US', {
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}
                  </span>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn-secondary" onClick={() => setShowProfileModal(false)}>
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && selectedStaff && (
        <div className="modal-overlay" onClick={() => setShowDeleteConfirm(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Confirm Delete</h2>
              <button className="btn-close" onClick={() => setShowDeleteConfirm(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="confirm-icon">⚠️</div>
              <p className="confirm-text">
                Are you sure you want to remove <strong>{selectedStaff.name}</strong> from security staff?
              </p>
              <p className="confirm-subtext">This action cannot be undone.</p>
            </div>
            <div className="modal-footer">
              <button className="btn-secondary" onClick={() => setShowDeleteConfirm(false)}>
                Cancel
              </button>
              <button className="btn-danger" onClick={handleConfirmDelete}>
                Delete Staff
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Change Password Modal */}
      {showPasswordModal && selectedStaff && (
        <div className="modal-overlay" onClick={() => setShowPasswordModal(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Change Password</h2>
              <button className="btn-close" onClick={() => setShowPasswordModal(false)}>✕</button>
            </div>

            <div className="modal-body">
              <p className="modal-info">Changing password for: <strong>{selectedStaff.name}</strong></p>
              
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

export default AdminSecurity;

