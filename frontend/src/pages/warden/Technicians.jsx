import { useEffect, useMemo, useState } from 'react';
import '../../styles/warden-technicians.css';

const Technicians = () => {
  const [technicians, setTechnicians] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('All');
  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState('add'); // 'add' or 'edit'
  const [selectedTech, setSelectedTech] = useState(null);
  const [deletingId, setDeletingId] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    employee_id: '',
    specialization: '',
    phone: '',
    alternate_phone: '',
    availability_status: 'available',
    expertise_areas: ''
  });
  const [formError, setFormError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchTechnicians();
  }, []);

  const fetchTechnicians = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await fetch('http://localhost:5000/api/warden/technicians');
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      const data = await response.json();
      
      if (data.success && Array.isArray(data.data)) {
        const normalized = data.data.map((tech) => {
          const availability = (tech.availability_status || '').toLowerCase();
          const isActive = availability === 'available' || availability === 'busy';
          return {
            id: tech.id,
            name: tech.name || 'N/A',
            staff_id: tech.staff_id || 'N/A',
            role: tech.specialization || 'General',
            phone: tech.phone || 'N/A',
            email: tech.email || 'N/A',
            assignedComplaints: tech.assigned_complaints || 0,
            status: isActive ? 'Active' : 'Inactive',
            availabilityStatus: availability || 'unknown'
          };
        });
        setTechnicians(normalized);
      } else {
        setError('Failed to load technicians data');
      }
    } catch (error) {
      console.error('Error fetching technicians:', error);
      setError(`Failed to load technicians: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const openAddModal = () => {
    setModalMode('add');
    setFormData({
      name: '',
      email: '',
      password: '',
      employee_id: '',
      specialization: '',
      phone: '',
      alternate_phone: '',
      availability_status: 'available',
      expertise_areas: ''
    });
    setFormError('');
    setShowModal(true);
  };

  const openEditModal = (tech) => {
    setModalMode('edit');
    setSelectedTech(tech);
    setFormData({
      name: tech.name,
      email: tech.email,
      password: '',
      employee_id: '',
      specialization: tech.role,
      phone: tech.phone,
      alternate_phone: '',
      availability_status: tech.availabilityStatus,
      expertise_areas: ''
    });
    setFormError('');
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setSelectedTech(null);
    setFormError('');
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setFormError('');
    setSubmitting(true);

    try {
      const url = modalMode === 'add' 
        ? '/api/warden/technicians'
        : `/api/warden/technicians/${selectedTech.id}`;
      
      const method = modalMode === 'add' ? 'POST' : 'PUT';
      
      const payload = modalMode === 'add' ? formData : {
        name: formData.name,
        email: formData.email,
        specialization: formData.specialization,
        phone: formData.phone,
        alternate_phone: formData.alternate_phone,
        availability_status: formData.availability_status,
        expertise_areas: formData.expertise_areas,
        ...(formData.password && { password: formData.password })
      };

      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      const data = await response.json();

      if (data.success) {
        await fetchTechnicians();
        closeModal();
      } else {
        setFormError(data.message || 'Operation failed');
      }
    } catch (error) {
      setFormError('Request failed: ' + error.message);
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (techId) => {
    if (!confirm('Are you sure you want to delete this technician? This action cannot be undone.')) {
      return;
    }
    setDeletingId(techId);
    try {
      const response = await fetch(`http://localhost:5000/api/warden/technicians/${techId}`, {
        method: 'DELETE'
      });

      const data = await response.json();

      if (data.success) {
        await fetchTechnicians();
      } else {
        alert('Failed to delete technician: ' + data.message);
      }
    } catch (error) {
      alert('Request failed: ' + error.message);
    } finally {
      setDeletingId(null);
    }
  };

  const handleStatusToggle = async (techId, currentStatus) => {
    const newStatus = currentStatus === 'available' ? 'off_duty' : 'available';

    try {
      const response = await fetch(`http://localhost:5000/api/warden/technicians/${techId}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ availability_status: newStatus })
      });

      const data = await response.json();

      if (data.success) {
        await fetchTechnicians();
      } else {
        alert('Failed to update status: ' + data.message);
      }
    } catch (error) {
      alert('Request failed: ' + error.message);
    }
  };

  const roles = useMemo(() => {
    const uniqueRoles = Array.from(new Set(technicians.map((tech) => tech.role)));
    return ['All', ...uniqueRoles];
  }, [technicians]);

  // Filter technicians
  const getFilteredTechnicians = () => {
    return technicians.filter((tech) => {
      const query = searchTerm.toLowerCase();
      const searchMatch =
        tech.name.toLowerCase().includes(query) ||
        tech.email.toLowerCase().includes(query) ||
        tech.phone.toLowerCase().includes(query);
      const roleMatch = roleFilter === 'All' || tech.role === roleFilter;
      return searchMatch && roleMatch;
    });
  };

  const filteredTechnicians = getFilteredTechnicians();

  if (loading) {
    return (
      <div className="technicians-page">
        <div className="loading-state">
          <div className="spinner"></div>
          <p>Loading technicians...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="technicians-page">
      {/* Page Header */}
      <div className="page-header">
        <div>
          <h1>Technicians</h1>
          <p className="page-subtitle">Manage hostel maintenance staff</p>
        </div>
        <button className="add-btn" onClick={openAddModal}>
          âž• Add Technician
        </button>
      </div>

      {/* Error Alert */}
      {error && (
        <div className="error-alert">
          <p>{error}</p>
        </div>
      )}

      {/* Search & Filter Section */}
      <div className="search-filter-section">
        <div className="search-box">
          <input
            type="text"
            placeholder="Search by name, email, or phone..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>

        <div className="role-filter">
          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            className="filter-select"
          >
            {roles.map(role => (
              <option key={role} value={role}>{role}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Technicians List */}
      {filteredTechnicians.length > 0 ? (
        <div className="technicians-table-container">
          <table className="technicians-table">
            <thead>
              <tr>
                <th>Staff ID</th>
                <th>Name</th>
                <th>Role</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Complaints</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredTechnicians.map(tech => (
                <tr key={tech.id}>
                  <td className="staff-id-cell">
                    <span className="staff-id-badge">{tech.staff_id}</span>
                  </td>
                  <td className="cell-name">
                    <div className="name-cell">
                      <div className="avatar">{tech.name.charAt(0)}</div>
                      <span className="name">{tech.name}</span>
                    </div>
                  </td>
                  <td>
                    <span className="role-badge">{tech.role}</span>
                  </td>
                  <td>{tech.phone}</td>
                  <td className="email-cell">{tech.email}</td>
                  <td>
                    <span className="complaint-badge">{tech.assignedComplaints}</span>
                  </td>
                  <td>
                    <span className={`status-badge ${tech.status.toLowerCase()}`}>
                      {tech.status}
                    </span>
                  </td>
                  <td className="actions-cell">
                    <button 
                      className="btn-action btn-view" 
                      onClick={() => openEditModal(tech)}
                      title="View details"
                    >
                      👁️
                    </button>
                    <button 
                      className="btn-action btn-edit" 
                      onClick={() => openEditModal(tech)}
                      title="Edit technician"
                    >
                      ✏️
                    </button>
                    <button 
                      className="btn-action btn-password" 
                      onClick={() => handleStatusToggle(tech.id, tech.availabilityStatus)}
                      title={tech.availabilityStatus === 'available' ? 'Deactivate' : 'Activate'}
                    >
                      {tech.availabilityStatus === 'available' ? '🔴' : '🟢'}
                    </button>
                    <button 
                      className="btn-action btn-delete" 
                      onClick={() => handleDelete(tech.id)}
                      title="Delete technician"
                      disabled={deletingId === tech.id}
                    >
                      {deletingId === tech.id ? '⏳' : '🗑️'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="empty-state">
          <div className="empty-icon">🔧</div>
          <h3>No technicians found</h3>
          <p>{searchTerm || roleFilter !== 'All' ? 'No technicians match your search or filter.' : 'No technicians available. Add one to get started.'}</p>
          <button className="add-btn" onClick={openAddModal}>âž• Add First Technician</button>
        </div>
      )}

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="modal-overlay" onClick={closeModal}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{modalMode === 'add' ? 'Add New Technician' : 'Edit Technician'}</h2>
              <button className="modal-close" onClick={closeModal}>×</button>
            </div>
            <form onSubmit={handleSubmit} className="modal-body">
              {formError && <div className="form-error">{formError}</div>}
              
              <div className="form-grid">
                <div className="form-group">
                  <label>Name *</label>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                <div className="form-group">
                  <label>Email *</label>
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                {modalMode === 'add' ? (
                  <>
                    <div className="form-group">
                      <label>Password *</label>
                      <input
                        type="password"
                        name="password"
                        value={formData.password}
                        onChange={handleInputChange}
                        required
                      />
                    </div>

                    <div className="form-group">
                      <label>Employee ID *</label>
                      <input
                        type="text"
                        name="employee_id"
                        value={formData.employee_id}
                        onChange={handleInputChange}
                        required
                      />
                    </div>
                  </>
                ) : (
                  <div className="form-group">
                    <label>New Password (leave blank to keep current)</label>
                    <input
                      type="password"
                      name="password"
                      value={formData.password}
                      onChange={handleInputChange}
                      placeholder="Enter new password to change"
                    />
                  </div>
                )}

                <div className="form-group">
                  <label>Specialization *</label>
                  <select
                    name="specialization"
                    value={formData.specialization}
                    onChange={handleInputChange}
                    required
                  >
                    <option value="">Select Specialization</option>
                    <option value="Electrical">Electrical</option>
                    <option value="Plumbing">Plumbing</option>
                    <option value="Carpentry">Carpentry</option>
                    <option value="HVAC">HVAC (Heating/Cooling)</option>
                    <option value="WiFi">WiFi</option>
                  </select>
                </div>

                <div className="form-group">
                  <label>Phone *</label>
                  <input
                    type="tel"
                    name="phone"
                    value={formData.phone}
                    onChange={handleInputChange}
                    required
                  />
                </div>

                <div className="form-group">
                  <label>Alternate Phone</label>
                  <input
                    type="tel"
                    name="alternate_phone"
                    value={formData.alternate_phone}
                    onChange={handleInputChange}
                  />
                </div>

                <div className="form-group">
                  <label>Availability Status</label>
                  <select
                    name="availability_status"
                    value={formData.availability_status}
                    onChange={handleInputChange}
                  >
                    <option value="available">Available</option>
                    <option value="busy">Busy</option>
                    <option value="on_leave">On Leave</option>
                    <option value="off_duty">Off Duty</option>
                  </select>
                </div>

                <div className="form-group full-width">
                  <label>Expertise Areas</label>
                  <textarea
                    name="expertise_areas"
                    value={formData.expertise_areas}
                    onChange={handleInputChange}
                    placeholder="e.g., Electrical repairs, Lighting, Power issues"
                    rows={2}
                  />
                </div>
              </div>

              <div className="modal-footer">
                <button type="button" className="btn-secondary" onClick={closeModal}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={submitting}>
                  {submitting && <span className="btn-spinner" />}
                  {submitting ? 'Saving...' : (modalMode === 'add' ? 'Add Technician' : 'Save Changes')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Technicians;

