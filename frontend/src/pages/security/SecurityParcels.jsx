import React, { useState, useEffect } from 'react';
import '../../styles/security-dashboard.css';

const SecurityParcels = () => {
  const buildDefaultParcel = () => ({
    roll_number: '',
    courier_name: '',
    sender_name: '',
    sender_contact: '',
    parcel_type: 'package',
    tracking_number: '',
    received_date: new Date().toISOString().split('T')[0],
    remarks: ''
  });

  const [selectedParcel, setSelectedParcel] = useState(null);
  const [showDetails, setShowDetails] = useState(false);
  const [parcels, setParcels] = useState([]);
  const [searchRollNumber, setSearchRollNumber] = useState('');
  const [loading, setLoading] = useState(false);
  const [currentTime] = useState(new Date().toLocaleString());
  const [showAddForm, setShowAddForm] = useState(false);
  const [newParcel, setNewParcel] = useState(buildDefaultParcel);
  const [addingParcel, setAddingParcel] = useState(false);
  const [actionLoading, setActionLoading] = useState({});
  const [alertModal, setAlertModal] = useState({
    open: false,
    title: '',
    message: ''
  });

  useEffect(() => {
    fetchParcels();
  }, []);

  const openAlertModal = (title, message) => {
    setAlertModal({ open: true, title, message });
  };

  // Fallback: route any native alert raised within this page flow to the in-app modal.
  useEffect(() => {
    const originalAlert = window.alert;
    window.alert = (message) => {
      setAlertModal({ open: true, title: 'Notice', message: String(message || '') });
    };

    return () => {
      window.alert = originalAlert;
    };
  }, []);

  const closeAlertModal = () => {
    setAlertModal({ open: false, title: '', message: '' });
  };

  const fetchParcels = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:5000/api/security/parcels');
      const data = await response.json();
      if (data.success) {
        setParcels(data.data || []);
      }
    } catch (error) {
      console.error('Error fetching parcels:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearchRollNumber = async () => {
    if (!searchRollNumber.trim()) {
      fetchParcels();
      return;
    }

    setLoading(true);
    try {
      const response = await fetch(
        `/api/security/parcels?roll_number=${searchRollNumber.trim()}`
      );
      const data = await response.json();
      if (data.success) {
        setParcels(data.data || []);
      } else {
        openAlertModal('No Results', 'No parcels found for this roll number.');
        setParcels([]);
      }
    } catch (error) {
      console.error('Error searching parcels:', error);
      openAlertModal('Search Failed', 'Error searching parcels.');
    } finally {
      setLoading(false);
    }
  };

  const handleMarkNotified = async (id) => {
    const actionKey = `notify-${id}`;
    if (actionLoading[actionKey]) return;
    setActionLoading((prev) => ({ ...prev, [actionKey]: true }));
    try {
      const response = await fetch(`http://localhost:5000/api/security/parcel/${id}/notify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ notified_at: new Date().toISOString() })
      });
      const data = await response.json();
      if (data.success) {
        setParcels((prev) =>
          prev.map((item) =>
            item.id === id ? { ...item, status: 'notified' } : item
          )
        );
        openAlertModal('Success', 'Student notified successfully.');
      }
    } catch (error) {
      console.error('Error marking notified:', error);
      openAlertModal('Action Failed', 'Error marking parcel as notified.');
    } finally {
      setActionLoading((prev) => ({ ...prev, [actionKey]: false }));
    }
  };

  const handleMarkCollected = async (id) => {
    const actionKey = `collect-${id}`;
    if (actionLoading[actionKey]) return;
    setActionLoading((prev) => ({ ...prev, [actionKey]: true }));
    try {
      const response = await fetch(`http://localhost:5000/api/security/parcel/${id}/collect`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ collected_at: new Date().toISOString() })
      });
      const data = await response.json();
      if (data.success) {
        setParcels((prev) =>
          prev.map((item) =>
            item.id === id ? { ...item, status: 'collected' } : item
          )
        );
        openAlertModal('Success', 'Parcel marked as collected.');
      }
    } catch (error) {
      console.error('Error marking collected:', error);
      openAlertModal('Action Failed', 'Error marking parcel as collected.');
    } finally {
      setActionLoading((prev) => ({ ...prev, [actionKey]: false }));
    }
  };

  const handleViewDetails = (parcel) => {
    setSelectedParcel(parcel);
    setShowDetails(true);
  };

  const closeDetails = () => {
    setShowDetails(false);
    setSelectedParcel(null);
  };

  const handleAddParcel = async (e) => {
    e.preventDefault();

    if (!newParcel.roll_number.trim()) {
      openAlertModal('Validation', 'Please enter student roll number.');
      return;
    }

    if (!newParcel.courier_name.trim()) {
      openAlertModal('Validation', 'Please enter courier name.');
      return;
    }

    setAddingParcel(true);
    try {
      const response = await fetch('http://localhost:5000/api/security/parcel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newParcel)
      });

      const data = await response.json();

      if (data.success) {
        openAlertModal(
          'Parcel Added Successfully',
          `Student: ${data.parcel.student_name}\nRoom: ${data.parcel.room_number || 'N/A'}`
        );
        setNewParcel(buildDefaultParcel());
        setShowAddForm(false);
        await fetchParcels();
      } else {
        openAlertModal('Error', data.message || 'Failed to add parcel.');
      }
    } catch (error) {
      console.error('Error adding parcel:', error);
      openAlertModal('Error', 'Error adding parcel. Please try again.');
    } finally {
      setAddingParcel(false);
    }
  };

  const handleNewParcelChange = (e) => {
    const { name, value } = e.target;
    setNewParcel(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleClearParcelForm = () => {
    setNewParcel(buildDefaultParcel());
  };


  const getStatusClass = (status) => `parcel-${(status || 'received').toLowerCase()}`;

  const normalizedSearch = searchRollNumber.trim().toLowerCase();
  const filteredParcels = parcels.filter((parcel) => {
    if (!normalizedSearch) return true;

    const rollNumber = (parcel.roll_number || '').toLowerCase();
    const studentName = (parcel.student_name || '').toLowerCase();
    const trackingNumber = (parcel.tracking_number || '').toLowerCase();

    return (
      rollNumber.includes(normalizedSearch) ||
      studentName.includes(normalizedSearch) ||
      trackingNumber.includes(normalizedSearch)
    );
  });

  return (
    <>
      <header className="parcel-header">
        <div className="header-content">
          <h1 className="security-title-main">Parcel Management</h1>
          <p className="security-subtitle">Log and track student parcel arrivals</p>
        </div>
        <div className="parcel-header-actions">
          <button
            className="btn-action primary parcel-header-btn"
            onClick={() => setShowAddForm(true)}
          >
            + Add New Parcel
          </button>
        </div>
      </header>

      {showAddForm && (
        <div className="modal-overlay" onClick={() => setShowAddForm(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Log New Parcel</h2>
              <button className="modal-close" onClick={() => setShowAddForm(false)}>×</button>
            </div>
            <div className="modal-body">
              <form onSubmit={handleAddParcel}>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Student Roll Number *</label>
                    <input 
                      type="text"
                      name="roll_number"
                      placeholder="e.g. CS2021043"
                      value={newParcel.roll_number}
                      onChange={handleNewParcelChange}
                      required
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Courier Name *</label>
                    <input 
                      type="text"
                      name="courier_name"
                      placeholder="e.g. FedEx, DHL, Flipkart"
                      value={newParcel.courier_name}
                      onChange={handleNewParcelChange}
                      required
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Sender Name</label>
                    <input 
                      type="text"
                      name="sender_name"
                      placeholder="Optional"
                      value={newParcel.sender_name}
                      onChange={handleNewParcelChange}
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Sender Contact</label>
                    <input 
                      type="text"
                      name="sender_contact"
                      placeholder="Optional"
                      value={newParcel.sender_contact}
                      onChange={handleNewParcelChange}
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Parcel Type</label>
                    <select 
                      name="parcel_type"
                      value={newParcel.parcel_type}
                      onChange={handleNewParcelChange}
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    >
                      <option value="package">Package</option>
                      <option value="document">Document</option>
                      <option value="box">Box</option>
                      <option value="other">Other</option>
                    </select>
                  </div>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Tracking Number</label>
                    <input 
                      type="text"
                      name="tracking_number"
                      placeholder="Optional"
                      value={newParcel.tracking_number}
                      onChange={handleNewParcelChange}
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '15px', marginBottom: '15px' }}>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Received Date</label>
                    <input 
                      type="date"
                      name="received_date"
                      value={newParcel.received_date}
                      onChange={handleNewParcelChange}
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>
                  <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>Remarks</label>
                    <textarea 
                      name="remarks"
                      placeholder="Optional notes about the parcel"
                      value={newParcel.remarks}
                      onChange={handleNewParcelChange}
                      rows="2"
                      style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', fontFamily: 'inherit' }}
                    />
                  </div>
                </div>
              </form>
            </div>
            <div className="modal-footer">
              <button
                className="btn-action primary"
                onClick={handleAddParcel}
                disabled={addingParcel}
              >
                {addingParcel && <span className="btn-spinner" />}
                {addingParcel ? 'Adding...' : '✓ Add Parcel'}
              </button>
              <button
                className="btn-action danger"
                type="button"
                onClick={handleClearParcelForm}
                disabled={addingParcel}
              >
                Clear
              </button>
              <button
                className="btn-action"
                onClick={() => setShowAddForm(false)}
                disabled={addingParcel}
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

          {filteredParcels.length > 0 ? (
            <section className="parcel-table">
              <table>
                <thead>
                  <tr>
                    <th>Parcel ID</th>
                    <th>Student</th>
                    <th>Block</th>
                    <th>Room</th>
                    <th>Courier</th>
                    <th>Received Time</th>
                    <th>Status</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredParcels.map((parcel) => (
                    <tr key={parcel.id}>
                      <td className="mono">{parcel.id}</td>
                      <td>
                        <div className="student-name">{parcel.student_name}</div>
                        <div className="student-id">{parcel.roll_number}</div>
                      </td>
                      <td>{parcel.display_block || parcel.block_name || parcel.preferred_block || 'Not Assigned'}</td>
                      <td>{parcel.display_room || parcel.room_number || 'Pending Assignment'}</td>
                      <td>{parcel.courier || 'Not specified'}</td>
                      <td>{parcel.received_date ? new Date(parcel.received_date).toLocaleString() : parcel.received_at || '—'}</td>
                      <td>
                        <span className={`status-badge ${getStatusClass(parcel.status)}`}>
                          {parcel.status?.charAt(0).toUpperCase() + parcel.status?.slice(1) || 'Received'}
                        </span>
                      </td>
                      <td>
                        <div className="action-buttons">
                          <button className="btn-action" onClick={() => handleViewDetails(parcel)}>
                            View Details
                          </button>
                          {(!parcel.status || parcel.status === 'received') && (
                            <button
                              className="btn-action primary"
                              onClick={() => handleMarkNotified(parcel.id)}
                              disabled={actionLoading[`notify-${parcel.id}`]}
                            >
                              {actionLoading[`notify-${parcel.id}`] && <span className="btn-spinner" />}
                              Mark Notified
                            </button>
                          )}
                          {parcel.status === 'notified' && (
                            <button
                              className="btn-action primary"
                              onClick={() => handleMarkCollected(parcel.id)}
                              disabled={actionLoading[`collect-${parcel.id}`]}
                            >
                              {actionLoading[`collect-${parcel.id}`] && <span className="btn-spinner" />}
                              Mark Collected
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </section>
          ) : (
            <div className="empty-state">
              <span className="empty-icon">📦</span>
              <p className="empty-message">
                {loading ? 'Loading parcels...' : searchRollNumber ? 'No parcels found for this roll number' : 'No parcels recorded'}
              </p>
            </div>
          )}

      {showDetails && selectedParcel && (
        <div className="modal-overlay" onClick={closeDetails}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Parcel Details</h2>
              <button className="modal-close" onClick={closeDetails}>×</button>
            </div>
            <div className="modal-body">
              <div className="details-grid">
                <div>
                  <div className="detail-label">Student</div>
                  <div className="detail-value">{selectedParcel.student_name}</div>
                  <div className="detail-sub">{selectedParcel.roll_number}</div>
                </div>
                <div>
                  <div className="detail-label">Block</div>
                  <div className="detail-value">{selectedParcel.display_block || selectedParcel.block_name || selectedParcel.preferred_block || 'Not Assigned'}</div>
                  <div className="detail-sub">Preferred block shown when not allocated</div>
                </div>
                <div>
                  <div className="detail-label">Room</div>
                  <div className="detail-value">{selectedParcel.display_room || selectedParcel.room_number || 'Pending Assignment'}</div>
                  <div className="detail-sub">ID: {selectedParcel.id}</div>
                </div>
                <div>
                  <div className="detail-label">Courier</div>
                  <div className="detail-value">{selectedParcel.courier || 'Not specified'}</div>
                  <div className="detail-sub">Type: {selectedParcel.parcel_type || 'Not specified'}</div>
                </div>
                <div>
                  <div className="detail-label">Status</div>
                  <div className="detail-value">{selectedParcel.status?.charAt(0).toUpperCase() + selectedParcel.status?.slice(1) || 'Received'}</div>
                  <div className="detail-sub">
                    Received: {selectedParcel.received_date 
                      ? new Date(selectedParcel.received_date).toLocaleString() 
                      : selectedParcel.received_at 
                      ? new Date(selectedParcel.received_at).toLocaleString() 
                      : '—'
                    }
                  </div>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              {(!selectedParcel.status || selectedParcel.status === 'received') && (
                <button
                  className="btn-primary"
                  onClick={() => {
                    handleMarkNotified(selectedParcel.id);
                    setShowDetails(false);
                  }}
                  disabled={actionLoading[`notify-${selectedParcel.id}`]}
                >
                  {actionLoading[`notify-${selectedParcel.id}`] && <span className="btn-spinner" />}
                  Mark Notified
                </button>
              )}
              {selectedParcel.status === 'notified' && (
                <button
                  className="btn-primary"
                  onClick={() => {
                    handleMarkCollected(selectedParcel.id);
                    setShowDetails(false);
                  }}
                  disabled={actionLoading[`collect-${selectedParcel.id}`]}
                >
                  {actionLoading[`collect-${selectedParcel.id}`] && <span className="btn-spinner" />}
                  Mark Collected
                </button>
              )}
              <button className="btn-secondary" onClick={closeDetails}>Close</button>
            </div>
          </div>
        </div>
      )}

      {alertModal.open && (
        <div className="modal-overlay" onClick={closeAlertModal}>
          <div className="modal-content" style={{ maxWidth: '480px' }} onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>{alertModal.title}</h2>
              <button className="modal-close" onClick={closeAlertModal}>×</button>
            </div>
            <div className="modal-body">
              <p style={{ margin: 0, whiteSpace: 'pre-line', lineHeight: 1.6 }}>{alertModal.message}</p>
            </div>
            <div className="modal-footer">
              <button className="btn-primary" onClick={closeAlertModal}>OK</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default SecurityParcels;

