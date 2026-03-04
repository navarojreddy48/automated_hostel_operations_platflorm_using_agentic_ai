import React, { useState, useMemo, useEffect } from 'react';
import '../../styles/admin-technicians.css';

const AdminTechnicians = () => {
  // State for technicians data from database
  const [technicians, setTechnicians] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  // Fetch technicians from database on component mount
  useEffect(() => {
    fetchTechnicians();
  }, []);

  const fetchTechnicians = async () => {
    setLoading(true);
    try {
      const res = await fetch('http://localhost:5000/api/admin/users?role=technician');
      const data = await res.json();
      
      if (data.success && Array.isArray(data.data)) {
        setTechnicians(data.data);
      }
      setLoading(false);
    } catch (error) {
      console.error('Error fetching technicians:', error);
      alert('Failed to fetch technicians from database');
      setLoading(false);
    }
  };

  // State management
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');
  const [showAddModal, setShowAddModal] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [selectedTechnician, setSelectedTechnician] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    technicianId: '',
    category: '',
    phone: '',
    email: '',
    status: 'Active'
  });

  // Password form data
  const [passwordFormData, setPasswordFormData] = useState({
    password: '',
    confirmPassword: '',
  });

  // Filter technicians
  const filteredTechnicians = useMemo(() => {
    return technicians.filter(tech => {
      const matchesStatus = statusFilter === 'All' || tech.status === statusFilter.toLowerCase();
      const matchesCategory = categoryFilter === 'All' || tech.category === categoryFilter;
      const matchesSearch = 
        tech.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        tech.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        tech.id?.toString().includes(searchTerm);
      
      return matchesStatus && matchesCategory && matchesSearch;
    });
  }, [technicians, searchTerm, categoryFilter, statusFilter]);

  // Handlers
  const handleAddTechnician = () => {
    resetForm();
    setSelectedTechnician(null);
    setShowAddModal(true);
  };

  const handleViewProfile = (technician) => {
    setSelectedTechnician(technician);
    setShowProfileModal(true);
  };

  const handleEditTechnician = (technician) => {
    setSelectedTechnician(technician);
    setFormData({
      name: technician.name,
      technicianId: technician.id,
      category: technician.category,
      phone: technician.phone,
      email: technician.email,
      status: technician.status
    });
    setShowAddModal(true);
  };

  const handleDeleteClick = (technician) => {
    setSelectedTechnician(technician);
    setShowDeleteConfirm(true);
  };

  const handleChangePasswordClick = (technician) => {
    setSelectedTechnician(technician);
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

    if (!confirm(`Change password for ${selectedTechnician.name}?`)) {
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch(`http://localhost:5000/api/admin/user/${selectedTechnician.id}/password`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password: passwordFormData.password })
      });
      
      const data = await res.json();
      
      if (data.success) {
        alert(data.message);
        setShowPasswordModal(false);
        setSelectedTechnician(null);
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

  const handleSaveTechnician = async () => {
    // Validation
    if (!formData.name || !formData.email) {
      alert('Please fill in name and email');
      return;
    }

    setSubmitting(true);
    try {
      if (selectedTechnician) {
        alert('Edit functionality coming soon');
      } else {
        // Add new technician
        const payload = {
          name: formData.name,
          email: formData.email,
          password: 'tech123', // Default password
          role: 'technician',
          phone: formData.phone || null,
        };

        const res = await fetch('http://localhost:5000/api/admin/user', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });

        const data = await res.json();
        if (data.success) {
          alert(`Added ${formData.name} successfully!`);
          await fetchTechnicians();
          setShowAddModal(false);
          resetForm();
        } else {
          alert(data.message || 'Failed to add technician');
        }
      }
    } catch (error) {
      console.error('Error saving technician:', error);
      alert('Failed to save technician');
    } finally {
      setSubmitting(false);
    }
  };

  const handleToggleStatus = async (technician) => {
    try {
      const newStatus = technician.status === 'active' ? 'inactive' : 'active';
      const res = await fetch(`http://localhost:5000/api/admin/user/${technician.id}/status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus }),
      });

      const data = await res.json();
      if (data.success) {
        await fetchTechnicians();
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
      const res = await fetch(`http://localhost:5000/api/admin/user/${selectedTechnician.id}`, {
        method: 'DELETE',
      });

      const data = await res.json();
      if (data.success) {
        alert(`${selectedTechnician.name} has been deleted successfully`);
        await fetchTechnicians();
        setShowDeleteConfirm(false);
        setSelectedTechnician(null);
      } else {
        alert(data.message || 'Failed to delete technician');
      }
    } catch (error) {
      console.error('Error deleting technician:', error);
      alert('Failed to delete technician');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({
      name: '',
      technicianId: '',
      category: '',
      phone: '',
      email: '',
      status: 'Active'
    });
    setSelectedTechnician(null);
  };

  const handleCloseModal = () => {
    setShowAddModal(false);
    resetForm();
  };

  return (
    <div className="admin-technicians-page">
      {/* Page Header */}
      <div className="page-header">
        <div className="header-content">
          <h1 className="page-title">Technicians</h1>
          <p className="page-subtitle">Manage maintenance technicians</p>
        </div>
        <button className="btn-primary btn-add" onClick={handleAddTechnician}>
          âž• Add Technician
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
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
        >
          <option value="All">All Categories</option>
          <option value="Electrical">Electrical</option>
          <option value="Plumbing">Plumbing</option>
          <option value="Internet">Internet</option>
          <option value="Carpentry">Carpentry</option>
          <option value="Cleaning">Cleaning</option>
          <option value="Other">Other</option>
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
        Showing {filteredTechnicians.length} of {technicians.length} technicians
      </div>

      {/* Technicians Table or Empty State */}
      {loading ? (
        <div className="empty-state-container">
          <div className="empty-state">
            <div className="empty-icon">⏳</div>
            <h3>Loading technicians...</h3>
            <p>Fetching data from database</p>
          </div>
        </div>
      ) : filteredTechnicians.length > 0 ? (
        <div className="table-container">
          <table className="technicians-table">
            <thead>
              <tr>
                <th>Technician Name</th>
                <th>Staff ID</th>
                <th>Email</th>
                <th>Category / Skill</th>
                <th>Phone Number</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredTechnicians.map((tech) => (
                <tr key={tech.id}>
                  <td>
                    <div className="tech-cell">
                      <div className="tech-avatar">
                        {tech.name.charAt(0)}
                      </div>
                      <div className="tech-info">
                        <div className="tech-name">{tech.name}</div>
                      </div>
                    </div>
                  </td>
                  <td className="staff-id-cell">{tech.staff_id || 'N/A'}</td>
                  <td>{tech.email}</td>
                  <td>
                    <span className="category-badge">{tech.category || 'General'}</span>
                  </td>
                  <td>{tech.phone || 'N/A'}</td>
                  <td>
                    <span className={`status-badge ${tech.status === 'active' ? 'badge-active' : 'badge-inactive'}`}>
                      {tech.status === 'active' ? '🟢 Active' : '🔴 Inactive'}
                    </span>
                  </td>
                  <td>
                    <div className="actions-cell">
                      <button 
                        className="btn-action btn-view"
                        onClick={() => handleViewProfile(tech)}
                        title="View Profile"
                      >
                        👁️
                      </button>
                      <button 
                        className="btn-action btn-edit"
                        onClick={() => handleEditTechnician(tech)}
                        title="Edit"
                      >
                        ✏️
                      </button>
                      <button 
                        className="btn-action btn-password"
                        onClick={() => handleChangePasswordClick(tech)}
                        title="Change Password"
                      >
                        🔐
                      </button>
                      <button 
                        className={`btn-action ${tech.status === 'active' ? 'btn-deactivate' : 'btn-activate'}`}
                        onClick={() => handleToggleStatus(tech)}
                        title={tech.status === 'active' ? 'Deactivate' : 'Activate'}
                      >
                        {tech.status === 'active' ? '⏸️' : '▶️'}
                      </button>
                      <button 
                        className="btn-action btn-delete"
                        onClick={() => handleDeleteClick(tech)}
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
            <div className="empty-icon">🧑‍🔧</div>
            <h3>No technicians found</h3>
            <p>
              {searchTerm || categoryFilter !== 'All' || statusFilter !== 'All'
                ? 'Try adjusting your filters'
                : 'No technicians added yet'}
            </p>
          </div>
        </div>
      )}

      {/* Add/Edit Modal */}
      {showAddModal && (
        <div className="modal-overlay" onClick={handleCloseModal}>
          <div className="modal-content modal-lg" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{selectedTechnician ? 'Edit Technician' : 'Add Technician'}</h2>
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
                    placeholder="Enter technician name"
                  />
                </div>
                <div className="form-group">
                  <label>Technician ID</label>
                  <input
                    type="text"
                    name="technicianId"
                    className="form-input"
                    value={formData.technicianId}
                    onChange={handleFormChange}
                    placeholder="Auto-generated"
                    disabled={!!selectedTechnician}
                  />
                </div>
              </div>
              
              <div className="form-group">
                <label>Category / Skill *</label>
                <select
                  name="category"
                  className="form-select"
                  value={formData.category}
                  onChange={handleFormChange}
                >
                  <option value="">Select Category</option>
                  <option value="Electrical">Electrical</option>
                  <option value="Plumbing">Plumbing</option>
                  <option value="Internet">Internet</option>
                  <option value="Carpentry">Carpentry</option>
                  <option value="Cleaning">Cleaning</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div className="form-group-row">
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
                <div className="form-group">
                  <label>Email (Optional)</label>
                  <input
                    type="email"
                    name="email"
                    className="form-input"
                    value={formData.email}
                    onChange={handleFormChange}
                    placeholder="email@example.com"
                  />
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
                onClick={handleSaveTechnician}
                disabled={!formData.name || !formData.category || !formData.phone}
              >
                {selectedTechnician ? 'Update Technician' : 'Add Technician'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* View Profile Modal */}
      {showProfileModal && selectedTechnician && (
        <div className="modal-overlay" onClick={() => setShowProfileModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Technician Profile</h2>
              <button className="btn-close" onClick={() => setShowProfileModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="profile-section">
                <div className="profile-avatar-large">
                  {selectedTechnician.name.charAt(0)}
                </div>
                <div className="profile-main-info">
                  <h3>{selectedTechnician.name}</h3>
                  <p className="profile-id">Staff ID: {selectedTechnician.staff_id || 'N/A'}</p>
                  <span className={`status-badge ${selectedTechnician.status === 'Active' ? 'badge-active' : 'badge-inactive'}`}>
                    {selectedTechnician.status}
                  </span>
                </div>
              </div>
              
              <div className="profile-details">
                <div className="detail-row">
                  <span className="detail-label">Category / Skill</span>
                  <span className="detail-value">{selectedTechnician.category}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Phone</span>
                  <span className="detail-value">{selectedTechnician.phone}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Email</span>
                  <span className="detail-value">{selectedTechnician.email}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Assigned Complaints</span>
                  <span className="detail-value">{selectedTechnician.assignedComplaints} active</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Complaints Resolved</span>
                  <span className="detail-value">{selectedTechnician.complaintsResolved} total</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Joining Date</span>
                  <span className="detail-value">
                    {new Date(selectedTechnician.joiningDate).toLocaleDateString('en-US', {
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
      {showDeleteConfirm && selectedTechnician && (
        <div className="modal-overlay" onClick={() => setShowDeleteConfirm(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Confirm Delete</h2>
              <button className="btn-close" onClick={() => setShowDeleteConfirm(false)}>×</button>
            </div>
            <div className="modal-body">
              <div className="confirm-icon">⚠️</div>
              <p className="confirm-text">
                Are you sure you want to remove <strong>{selectedTechnician.name}</strong> from technicians?
              </p>
              <p className="confirm-subtext">This action cannot be undone.</p>
            </div>
            <div className="modal-footer">
              <button className="btn-secondary" onClick={() => setShowDeleteConfirm(false)}>
                Cancel
              </button>
              <button className="btn-danger" onClick={handleConfirmDelete}>
                Delete Technician
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Change Password Modal */}
      {showPasswordModal && selectedTechnician && (
        <div className="modal-overlay" onClick={() => setShowPasswordModal(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Change Password</h2>
              <button className="btn-close" onClick={() => setShowPasswordModal(false)}>✕</button>
            </div>

            <div className="modal-body">
              <p className="modal-info">Changing password for: <strong>{selectedTechnician.name}</strong></p>
              
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

export default AdminTechnicians;

