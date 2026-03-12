import React, { useState, useMemo, useEffect } from 'react';
import '../../styles/admin-registrations.css';

const AdminRegistrations = () => {
  // State for students/registrations data from database
  const [registrations, setRegistrations] = useState([]);
  const [loading, setLoading] = useState(true);

  // Fetch registrations from database
  useEffect(() => {
    fetchRegistrations();
  }, []);

  const fetchRegistrations = async () => {
    setLoading(true);
    try {
      const [pendingRes, approvedRes, rejectedRes] = await Promise.all([
        fetch('http://localhost:5000/api/admin/registrations/pending'),
        fetch('http://localhost:5000/api/admin/registrations/approved'),
        fetch('http://localhost:5000/api/admin/registrations/rejected')
      ]);

      const [pendingData, approvedData, rejectedData] = await Promise.all([
        pendingRes.json(),
        approvedRes.json(),
        rejectedRes.json()
      ]);

      const combinedRegistrations = [
        ...(pendingData.success && Array.isArray(pendingData.data) ? pendingData.data : []),
        ...(approvedData.success && Array.isArray(approvedData.data) ? approvedData.data : []),
        ...(rejectedData.success && Array.isArray(rejectedData.data) ? rejectedData.data : [])
      ];

      if (combinedRegistrations.length > 0) {
        setRegistrations(combinedRegistrations);
      } else {
        setRegistrations([]);
      }
      setLoading(false);
    } catch (error) {
      console.error('Error fetching registrations:', error);
      alert('Failed to fetch registrations from database');
      setLoading(false);
    }
  };

  // Old dummy data replaced with database - State management

  // Filter and search states
  const [searchTerm, setSearchTerm] = useState('');
  const [branchFilter, setBranchFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');

  // Modal states
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [showRejectConfirm, setShowRejectConfirm] = useState(false);
  const [selectedRegistration, setSelectedRegistration] = useState(null);

  // Filter registrations
  const filteredRegistrations = useMemo(() => {
    return registrations.filter(reg => {
      const matchesSearch = 
        reg.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        reg.roll_number?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        reg.email?.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchesBranch = branchFilter === 'All' || reg.branch === branchFilter;
      const matchesStatus = statusFilter === 'All' || reg.registration_status === statusFilter.toLowerCase();

      return matchesSearch && matchesBranch && matchesStatus;
    });
  }, [registrations, searchTerm, branchFilter, statusFilter]);

  // Handlers
  const handleViewDetails = (registration) => {
    setSelectedRegistration(registration);
    setShowDetailsModal(true);
  };

  const handleApprove = async (registration) => {
    if (!confirm(`Approve registration for ${registration.name}?`)) {
      return;
    }

    try {
      const res = await fetch(`http://localhost:5000/api/admin/registrations/${registration.student_id}/approve`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' }
      });
      
      const data = await res.json();
      
      if (data.success) {
        alert('Registration approved successfully!');
        fetchRegistrations(); // Refresh the list
        setShowDetailsModal(false);
        setSelectedRegistration(null);
      } else {
        alert(`Failed to approve: ${data.message}`);
      }
    } catch (error) {
      console.error('Error approving registration:', error);
      alert('Failed to approve registration');
    }
  };

  const handleRejectClick = (registration) => {
    setSelectedRegistration(registration);
    setShowRejectConfirm(true);
  };

  const handleConfirmReject = async () => {
    if (!selectedRegistration) return;

    try {
      const res = await fetch(`http://localhost:5000/api/admin/registrations/${selectedRegistration.student_id}/reject`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' }
      });
      
      const data = await res.json();
      
      if (data.success) {
        alert('Registration rejected successfully');
        fetchRegistrations(); // Refresh the list
      } else {
        alert(`Failed to reject: ${data.message}`);
      }
    } catch (error) {
      console.error('Error rejecting registration:', error);
      alert('Failed to reject registration');
    }
    
    setShowRejectConfirm(false);
    setShowDetailsModal(false);
    setSelectedRegistration(null);
  };

  const handleCloseModals = () => {
    setShowDetailsModal(false);
    setShowRejectConfirm(false);
    setSelectedRegistration(null);
  };

  return (
    <div className="admin-registrations-page">
      {/* Page Header */}
      <div className="page-header">
        <div className="header-content">
          <h1 className="page-title">Student Registration Review</h1>
          <p className="page-subtitle">Verify and approve new student registrations</p>
        </div>
      </div>

      {/* Search & Filter Section */}
      <div className="search-filter-section">
        <div className="search-box">
          <span className="search-icon">🔍</span>
          <input
            type="text"
            className="search-input"
            placeholder="Search by name or roll number..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        
        <select
          className="filter-select"
          value={branchFilter}
          onChange={(e) => setBranchFilter(e.target.value)}
        >
          <option value="All">All Branches</option>
          <option value="CSE">CSE</option>
          <option value="ECE">ECE</option>
          <option value="ME">Mechanical</option>
          <option value="EE">Electrical</option>
          <option value="Civil">Civil</option>
        </select>

        <select
          className="filter-select"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
        >
          <option value="All">All Status</option>
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="rejected">Rejected</option>
        </select>
      </div>

      {/* Results Info */}
      <div className="results-info">
        Showing {filteredRegistrations.length} of {registrations.length} registrations
      </div>

      {/* Registrations Table or Empty State */}
      {loading ? (
        <div className="empty-state-container">
          <div className="empty-state">
            <div className="empty-icon">⏳</div>
            <h3>Loading registrations...</h3>
            <p>Fetching data from database</p>
          </div>
        </div>
      ) : filteredRegistrations.length > 0 ? (
        <div className="table-container">
          <table className="registrations-table">
            <thead>
              <tr>
                <th>Student Name</th>
                <th>Roll Number</th>
                <th>Branch</th>
                <th>Year</th>
                <th>Phone</th>
                <th>Submitted Date</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredRegistrations.map((reg) => (
                <tr key={reg.student_id}>
                  <td>
                    <div className="student-cell">
                      <div className="student-avatar">
                        {reg.name.charAt(0).toUpperCase()}
                      </div>
                      <div className="student-info">
                        <span className="student-name">{reg.name}</span>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className="roll-number">{reg.roll_number}</span>
                  </td>
                  <td>
                    <span className="branch-badge">{reg.branch || 'N/A'}</span>
                  </td>
                  <td>{reg.year || 'N/A'}</td>
                  <td>{reg.phone || 'N/A'}</td>
                  <td>{new Date(reg.submitted_date).toLocaleDateString('en-GB')}</td>
                  <td>
                    <span className={`status-badge status-${reg.registration_status.toLowerCase()}`}>
                      {reg.registration_status.charAt(0).toUpperCase() + reg.registration_status.slice(1)}
                    </span>
                  </td>
                  <td>
                    <div className="actions-cell">
                      <button
                        className="btn-action btn-view"
                        onClick={() => handleViewDetails(reg)}
                        title="View Details"
                      >
                        👁
                      </button>
                      {reg.registration_status === 'pending' && (
                        <>
                          <button
                            className="btn-action btn-approve"
                            onClick={() => handleApprove(reg)}
                            title="Approve"
                          >
                            ✓
                          </button>
                          <button
                            className="btn-action btn-reject"
                            onClick={() => handleRejectClick(reg)}
                            title="Reject"
                          >
                            ✕
                          </button>
                        </>
                      )}
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
            <div className="empty-icon">📭</div>
            <h3>No Registration Requests</h3>
            <p>
              {searchTerm || branchFilter !== 'All' || statusFilter !== 'All'
                ? 'Try adjusting your filters to see more results'
                : 'No pending registration requests at the moment'}
            </p>
          </div>
        </div>
      )}

      {/* View Details Modal */}
      {showDetailsModal && selectedRegistration && (
        <div className="modal-overlay" onClick={handleCloseModals}>
          <div className="modal-content modal-details" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Registration Details</h2>
              <button className="btn-close" onClick={handleCloseModals}>×</button>
            </div>
            
            <div className="modal-body">
              {/* Student Info Section */}
              <div className="detail-section">
                <h4>Student Information</h4>
                <div className="detail-row">
                  <span className="detail-label">Full Name:</span>
                  <span className="detail-value">{selectedRegistration.name}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Roll Number:</span>
                  <span className="detail-value">{selectedRegistration.roll_number}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Email:</span>
                  <span className="detail-value">{selectedRegistration.email}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Phone:</span>
                  <span className="detail-value">{selectedRegistration.phone || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Address:</span>
                  <span className="detail-value">{selectedRegistration.address || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Blood Group:</span>
                  <span className="detail-value">{selectedRegistration.blood_group || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Emergency Contact:</span>
                  <span className="detail-value">{selectedRegistration.emergency_contact || 'N/A'}</span>
                </div>
              </div>

              {/* Academic Info Section */}
              <div className="detail-section">
                <h4>Academic Information</h4>
                <div className="detail-row">
                  <span className="detail-label">Branch:</span>
                  <span className="detail-value">{selectedRegistration.branch || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Year:</span>
                  <span className="detail-value">{selectedRegistration.year || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Submitted On:</span>
                  <span className="detail-value">{new Date(selectedRegistration.submitted_date).toLocaleString()}</span>
                </div>
              </div>

              {/* Guardian Info Section */}
              <div className="detail-section">
                <h4>Guardian Information</h4>
                <div className="detail-row">
                  <span className="detail-label">Parent Name:</span>
                  <span className="detail-value">{selectedRegistration.parent_name || 'N/A'}</span>
                </div>
                <div className="detail-row">
                  <span className="detail-label">Parent Phone:</span>
                  <span className="detail-value">{selectedRegistration.parent_phone || 'N/A'}</span>
                </div>
              </div>

              {/* Fee Payment Section */}
              <div className="detail-section">
                <h4>Fee Payment Status</h4>
                <div className="detail-row">
                  <span className="detail-label">Fee Status:</span>
                  <span className="detail-value">
                    <span className={`status-badge status-${selectedRegistration.fee_status}`}>
                      {selectedRegistration.fee_status?.charAt(0).toUpperCase() + selectedRegistration.fee_status?.slice(1)}
                    </span>
                  </span>
                </div>
              </div>

              {/* Current Status */}
              <div className="detail-section">
                <h4>Registration Status</h4>
                <div className="detail-row">
                  <span className="detail-label">Current Status:</span>
                  <span className="detail-value">
                    <span className={`status-badge status-${selectedRegistration.registration_status.toLowerCase()}`}>
                      {selectedRegistration.registration_status.charAt(0).toUpperCase() + selectedRegistration.registration_status.slice(1)}
                    </span>
                  </span>
                </div>
              </div>
            </div>
            
            <div className="modal-footer">
              <button className="btn-secondary" onClick={handleCloseModals}>
                Close
              </button>
              {selectedRegistration.registration_status === 'pending' && (
                <>
                  <button
                    className="btn-danger"
                    onClick={() => {
                      setShowDetailsModal(false);
                      handleRejectClick(selectedRegistration);
                    }}
                  >
                    Reject
                  </button>
                  <button
                    className="btn-primary"
                    onClick={() => handleApprove(selectedRegistration)}
                  >
                    Approve Registration
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Reject Confirmation Modal */}
      {showRejectConfirm && selectedRegistration && (
        <div className="modal-overlay" onClick={handleCloseModals}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Reject Registration</h2>
              <button className="btn-close" onClick={handleCloseModals}>×</button>
            </div>
            
            <div className="modal-body">
              <div className="confirm-icon">⚠️</div>
              <p className="confirm-text">
                Are you sure you want to reject the registration for <strong>{selectedRegistration.name}</strong> ({selectedRegistration.roll_number})?
              </p>
              <p className="confirm-subtext">
                This action cannot be undone. The student will need to reapply.
              </p>
            </div>
            
            <div className="modal-footer">
              <button className="btn-secondary" onClick={handleCloseModals}>
                Cancel
              </button>
              <button className="btn-danger" onClick={handleConfirmReject}>
                Reject Registration
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminRegistrations;


