import React, { useState, useEffect, useMemo } from 'react';
import '../../styles/warden-registrations.css';

const Registrations = () => {
  const [registrations, setRegistrations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('pending');
  const [selectedRegistration, setSelectedRegistration] = useState(null);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);
  const [rejectionReason, setRejectionReason] = useState('');
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [showApproveModal, setShowApproveModal] = useState(false);
  const [paymentStatus, setPaymentStatus] = useState('pending');

  // Fetch all registrations (pending, approved, rejected)
  useEffect(() => {
    fetchRegistrations();
  }, []);

  const fetchRegistrations = async () => {
    setLoading(true);
    try {
      const [pendingRes, approvedRes, rejectedRes] = await Promise.all([
        fetch('http://localhost:5000/api/warden/registrations/pending'),
        fetch('http://localhost:5000/api/warden/registrations/approved'),
        fetch('http://localhost:5000/api/warden/registrations/rejected')
      ]);

      const pendingData = await pendingRes.json();
      const approvedData = await approvedRes.json();
      const rejectedData = await rejectedRes.json();

      const allRegistrations = [
        ...(pendingData.data || []),
        ...(approvedData.data || []),
        ...(rejectedData.data || [])
      ];

      setRegistrations(allRegistrations);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching registrations:', error);
      setLoading(false);
    }
  };

  // Filter registrations based on search and status
  const filteredRegistrations = useMemo(() => {
    return registrations.filter(reg => {
      const matchesSearch = 
        reg.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        reg.roll_number?.toLowerCase().includes(searchTerm.toLowerCase());
      
      const matchesStatus = selectedStatus === 'all' || reg.registration_status === selectedStatus;
      
      return matchesSearch && matchesStatus;
    });
  }, [registrations, searchTerm, selectedStatus]);

  // Handle approve registration
  const handleApproveRegistration = async () => {
    if (!selectedRegistration) return;
    
    setSubmitting(true);
    try {
      const res = await fetch(`http://localhost:5000/api/admin/registrations/${selectedRegistration.student_id}/approve`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fee_status: paymentStatus })
      });

      const data = await res.json();

      if (data.success) {
        alert(`Approved registration for ${selectedRegistration.name}`);
        setIsDetailsModalOpen(false);
        setShowApproveModal(false);
        setSelectedRegistration(null);
        setPaymentStatus('pending');
        await fetchRegistrations();
      } else {
        alert(data.message || 'Failed to approve registration');
      }
    } catch (error) {
      console.error('Error approving registration:', error);
      alert('Failed to approve registration');
    } finally {
      setSubmitting(false);
    }
  };

  // Handle reject registration
  const handleRejectRegistration = async () => {
    if (!selectedRegistration || !rejectionReason.trim()) {
      alert('Please enter a rejection reason');
      return;
    }
    
    setSubmitting(true);
    try {
      const res = await fetch(`http://localhost:5000/api/admin/registrations/${selectedRegistration.student_id}/reject`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rejection_reason: rejectionReason })
      });

      const data = await res.json();

      if (data.success) {
        alert(`Rejected registration for ${selectedRegistration.name}`);
        setIsDetailsModalOpen(false);
        setShowRejectModal(false);
        setSelectedRegistration(null);
        setRejectionReason('');
        await fetchRegistrations();
      } else {
        alert(data.message || 'Failed to reject registration');
      }
    } catch (error) {
      console.error('Error rejecting registration:', error);
      alert('Failed to reject registration');
    } finally {
      setSubmitting(false);
    }
  };

  // Open details modal
  const handleViewDetails = (registration) => {
    setSelectedRegistration(registration);
    setRejectionReason('');
    setPaymentStatus(registration.fee_status || 'pending');
    setIsDetailsModalOpen(true);
  };

  // Format year to ensure consistent display
  const formatYear = (year) => {
    if (!year) return 'N/A';
    if (year.includes('Year')) return year;
    return `${year} Year`;
  };

  return (
    <div className="registrations-page">
      {/* Page Header */}
      <div className="registrations-header">
        <div>
          <h1>Student Registrations</h1>
          <p className="registrations-subtitle">Verify and approve hostel registrations</p>
        </div>
      </div>

      {/* Filter Buttons */}
      <div className="filter-buttons">
        <button 
          className={`filter-btn ${selectedStatus === 'all' ? 'active' : ''}`}
          onClick={() => setSelectedStatus('all')}
        >
          All ({registrations.length})
        </button>
        <button 
          className={`filter-btn ${selectedStatus === 'pending' ? 'active' : ''}`}
          onClick={() => setSelectedStatus('pending')}
        >
          Pending ({registrations.filter(r => r.registration_status === 'pending').length})
        </button>
        <button 
          className={`filter-btn ${selectedStatus === 'approved' ? 'active' : ''}`}
          onClick={() => setSelectedStatus('approved')}
        >
          Approved ({registrations.filter(r => r.registration_status === 'approved').length})
        </button>
        <button 
          className={`filter-btn ${selectedStatus === 'rejected' ? 'active' : ''}`}
          onClick={() => setSelectedStatus('rejected')}
        >
          Rejected ({registrations.filter(r => r.registration_status === 'rejected').length})
        </button>
      </div>

      {/* Search */}
      <div className="search-section">
        <input
          type="text"
          placeholder="Search by student name or roll number..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="search-input"
        />
      </div>

      {/* Registrations Grid */}
      {loading ? (
        <div className="loading-state">
          <div className="loading-spinner"></div>
          <p>Loading registrations...</p>
        </div>
      ) : selectedStatus === 'all' && registrations.length === 0 ? (
        <div className="empty-state">
          <h3>No registrations found</h3>
          <p>No student registrations in the system.</p>
        </div>
      ) : filteredRegistrations.length > 0 ? (
        <div className="registrations-grid">
          {filteredRegistrations.map((reg) => (
            <div key={reg.student_id} className="registration-card">
              <div className="card-header">
                <div>
                  <h3>{reg.name}</h3>
                  <p className="roll-number">{reg.roll_number}</p>
                </div>
                <span className={`status-badge status-${reg.registration_status}`}>
                  {reg.registration_status.charAt(0).toUpperCase() + reg.registration_status.slice(1)}
                </span>
              </div>

              <div className="card-details">
                <div className="detail-row">
                  <span className="label">Branch:</span>
                  <span className="value">{reg.branch}</span>
                </div>
                <div className="detail-row">
                  <span className="label">Year:</span>
                  <span className="value">{formatYear(reg.year)}</span>
                </div>
                <div className="detail-row">
                  <span className="label">Email:</span>
                  <span className="value">{reg.email}</span>
                </div>
                <div className="detail-row">
                  <span className="label">Phone:</span>
                  <span className="value">{reg.phone}</span>
                </div>
                <div className="detail-row">
                  <span className="label">Fee Status:</span>
                  <span className={`fee-badge ${reg.fee_status === 'paid' ? 'fee-paid' : 'fee-pending'}`}>
                    {reg.fee_status ? reg.fee_status.charAt(0).toUpperCase() + reg.fee_status.slice(1) : 'Pending'}
                  </span>
                </div>
              </div>

              <div className="card-actions">
                <button 
                  className="view-details-btn"
                  onClick={() => handleViewDetails(reg)}
                >
                  View Details
                </button>
                {reg.registration_status === 'pending' && (
                  <>
                    <button 
                      className="approve-btn"
                      onClick={handleApproveRegistration}
                      disabled={submitting}
                    >
                      ✓ Approve
                    </button>
                    <button 
                      className="reject-btn"
                      onClick={() => {
                        setSelectedRegistration(reg);
                        setShowRejectModal(true);
                      }}
                      disabled={submitting}
                    >
                      ✕ Reject
                    </button>
                  </>
                )}
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="empty-state">
          <h3>No {selectedStatus} registrations</h3>
          <p>No student registrations match your current filter.</p>
        </div>
      )}

      {/* View Details Modal */}
      {isDetailsModalOpen && selectedRegistration && (
        <div className="modal-overlay" onClick={() => setIsDetailsModalOpen(false)}>
          <div className="modal-content modal-large" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div>
                <h2>Registration Details</h2>
              </div>
              <button className="modal-close" onClick={() => setIsDetailsModalOpen(false)}>
                ×
              </button>
            </div>

            <div className="modal-body">
              {/* Student Information */}
              <div className="detail-section">
                <h3>Student Information</h3>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">Full Name</span>
                    <span className="detail-value">{selectedRegistration.name}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Roll Number</span>
                    <span className="detail-value">{selectedRegistration.roll_number}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Branch</span>
                    <span className="detail-value">{selectedRegistration.branch}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Year</span>
                    <span className="detail-value">{selectedRegistration.year}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Email</span>
                    <span className="detail-value">{selectedRegistration.email}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Phone</span>
                    <span className="detail-value">{selectedRegistration.phone}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Parent Name</span>
                    <span className="detail-value">{selectedRegistration.parent_name}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Parent Phone</span>
                    <span className="detail-value">{selectedRegistration.parent_phone}</span>
                  </div>
                  <div className="detail-item full-width">
                    <span className="detail-label">Address</span>
                    <span className="detail-value">{selectedRegistration.address}</span>
                  </div>
                </div>
              </div>

              {/* Fee Payment Details */}
              <div className="detail-section">
                <h3>Fee Payment Details</h3>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">Payment Status</span>
                    <span className={`fee-badge ${selectedRegistration.fee_status === 'paid' ? 'fee-paid' : 'fee-pending'}`}>
                      {selectedRegistration.fee_status ? selectedRegistration.fee_status.charAt(0).toUpperCase() + selectedRegistration.fee_status.slice(1) : 'Pending'}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Registration Status</span>
                    <span className={`status-badge status-${selectedRegistration.registration_status}`}>
                      {selectedRegistration.registration_status ? selectedRegistration.registration_status.charAt(0).toUpperCase() + selectedRegistration.registration_status.slice(1) : 'Pending'}
                    </span>
                  </div>
                </div>
              </div>

              {/* Hostel Preferences */}
              <div className="detail-section">
                <h3>Hostel Preferences</h3>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">Preferred Block</span>
                    <span className="detail-value">{selectedRegistration.preferred_block || 'Not specified'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Preferred Floor</span>
                    <span className="detail-value">{selectedRegistration.floor_preference || 'Not specified'}</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="modal-footer">
              {selectedRegistration.registration_status === 'pending' ? (
                <>
                  <button 
                    className="btn-secondary" 
                    onClick={() => setIsDetailsModalOpen(false)}
                    disabled={submitting}
                  >
                    Cancel
                  </button>
                  <div className="action-buttons">
                    <button 
                      className="btn-reject" 
                      onClick={() => {
                        setShowRejectModal(true);
                      }}
                      disabled={submitting}
                    >
                      ✕ Reject
                    </button>
                    <button 
                      className="btn-approve" 
                      onClick={() => setShowApproveModal(true)}
                      disabled={submitting}
                    >
                      ✓ Approve
                    </button>
                  </div>
                </>
              ) : (
                <button className="btn-secondary" onClick={() => setIsDetailsModalOpen(false)}>
                  Close
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Approve Confirmation Modal */}
      {showApproveModal && selectedRegistration && (
        <div className="modal-overlay" onClick={() => setShowApproveModal(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Approve Registration</h2>
              <button className="modal-close" onClick={() => setShowApproveModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <p style={{ marginBottom: '20px' }}>Approve registration for <strong>{selectedRegistration.name}</strong>?</p>
              
              <div className="form-group">
                <label className="form-label">Payment Status</label>
                <select 
                  className="form-select"
                  value={paymentStatus}
                  onChange={(e) => setPaymentStatus(e.target.value)}
                >
                  <option value="pending">Pending</option>
                  <option value="paid">Paid</option>
                  <option value="overdue">Overdue</option>
                </select>
              </div>
            </div>
            <div className="modal-footer">
              <button 
                className="btn-secondary" 
                onClick={() => setShowApproveModal(false)}
                disabled={submitting}
              >
                Cancel
              </button>
              <button 
                className="btn-primary" 
                onClick={handleApproveRegistration}
                disabled={submitting}
              >
                {submitting ? 'Processing...' : 'Confirm Approval'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Reject Confirmation Modal */}
      {showRejectModal && selectedRegistration && (
        <div className="modal-overlay" onClick={() => setShowRejectModal(false)}>
          <div className="modal-content modal-sm" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Reject Registration</h2>
              <button className="modal-close" onClick={() => setShowRejectModal(false)}>×</button>
            </div>
            <div className="modal-body">
              <p>Please provide a reason for rejecting this registration:</p>
              <textarea
                className="remarks-input"
                placeholder="Enter rejection reason..."
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                rows="4"
                style={{ width: '100%', marginTop: '10px' }}
              />
            </div>
            <div className="modal-footer">
              <button 
                className="btn-secondary"
                onClick={() => setShowRejectModal(false)}
                disabled={submitting}
              >
                Cancel
              </button>
              <button 
                className="btn-danger"
                onClick={handleRejectRegistration}
                disabled={submitting || !rejectionReason.trim()}
              >
                {submitting ? 'Rejecting...' : 'Confirm Reject'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

// Helper function to format date
const formatDate = (dateString) => {
  const date = new Date(dateString);
  const options = { month: 'short', day: 'numeric', year: 'numeric' };
  return date.toLocaleDateString('en-GB', options);
};

export default Registrations;


