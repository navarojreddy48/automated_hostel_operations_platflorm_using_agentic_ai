import React, { useEffect, useState } from 'react';
import StudentLayout from '../../components/StudentLayout';
import { getCurrentUser } from '../../utils/auth';
import '../../styles/student-room.css';

const Room = () => {
  const currentUser = getCurrentUser();
  const [showModal, setShowModal] = useState(false);
  const [roomData, setRoomData] = useState({
    roomNumber: '—',
    block: '—',
    floor: '—',
    roomType: '—',
    capacity: { current: 0, total: 0 },
    amenities: [],
    status: '—',
    rent: null
  });
  const [roommates, setRoommates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [blocks, setBlocks] = useState([]);
  const [formData, setFormData] = useState({
    preferredRoom: '',
    preferredBlock: '',
    detailedReason: ''
  });

  const fetchRoomDetails = async () => {
    try {
      if (!currentUser?.userId) {
        setError('Unable to load room details. Please sign in again.');
        setLoading(false);
        return;
      }

      setLoading(true);
      
      // Fetch room details
      const response = await fetch(`http://localhost:5000/api/student/room/${currentUser.userId}`);
      const data = await response.json();

      if (!data.success) {
        throw new Error(data.message || 'Failed to load room details');
      }

      const room = data.data?.room || {};
      const roommatesList = Array.isArray(data.data?.roommates) ? data.data.roommates : [];
      const amenitiesList = room.amenities
        ? room.amenities.split(',').map((item) => item.trim()).filter(Boolean)
        : [];

      setRoomData({
        roomNumber: room.room_number || '—',
        block: room.block_name || '—',
        floor: room.floor ?? '—',
        roomType: room.room_type || '—',
        capacity: {
          current: room.occupied_count ?? 0,
          total: room.capacity ?? 0
        },
        amenities: amenitiesList,
        status: room.status || '—',
        rent: room.rent_per_month ?? null
      });
      setRoommates(roommatesList);
      setError('');
      
      // Fetch blocks from database
      try {
        const blocksResponse = await fetch('http://localhost:5000/api/blocks');
        const blocksData = await blocksResponse.json();
        if (blocksData.success && Array.isArray(blocksData.data)) {
          setBlocks(blocksData.data);
          // Set first block as default if available
          if (blocksData.data.length > 0) {
            setFormData(prev => ({ ...prev, preferredBlock: blocksData.data[0].name }));
          }
        }
      } catch (blockError) {
        console.error('Error fetching blocks:', blockError);
      }
    } catch (err) {
      console.error('Error loading room details:', err);
      setError(err.message || 'Failed to load room details');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRoomDetails();
  }, [currentUser?.userId]);

  const guidelines = [
    'Maintain cleanliness and hygiene',
    'No loud music after 10 PM',
    'Switch off electrical appliances',
    'Report maintenance issues immediately',
    'Visitors must be registered at security',
  ];

  const roomTypeLabel = roomData.roomType && roomData.roomType !== '—'
    ? `${roomData.roomType.charAt(0).toUpperCase() + roomData.roomType.slice(1)} room`
    : '—';

  const handleSubmitRequest = async () => {
    if (!currentUser?.userId) {
      alert('Please sign in again.');
      return;
    }

    if (!formData.preferredBlock || !formData.detailedReason.trim()) {
      alert('Please fill in the required fields.');
      return;
    }

    try {
      const response = await fetch('http://localhost:5000/api/student/room-change', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: currentUser.userId,
          preferredRoom: formData.preferredRoom,
          preferredBlock: formData.preferredBlock,
          detailedReason: formData.detailedReason
        })
      });
      const data = await response.json();

      if (data.success) {
        alert('Room change request submitted successfully.');
        setFormData({
          preferredRoom: '',
          preferredBlock: blocks.length > 0 ? blocks[0].name : '',
          detailedReason: ''
        });
        setShowModal(false);
      } else {
        alert(data.message || 'Failed to submit request');
      }
    } catch (error) {
      console.error('Error submitting room change request:', error);
      alert('Failed to submit request');
    }
  };

  const handleFormChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <StudentLayout>
      <header className="room-header">
        <div>
          <h1 className="room-title">Room Details</h1>
          <p className="room-subtitle">Your accommodation information</p>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button 
            className="request-room-change-btn" 
            onClick={() => fetchRoomDetails()}
            style={{ backgroundColor: '#6366f1' }}
          >
            🔄 Refresh
          </button>
          <button className="request-room-change-btn" onClick={() => setShowModal(true)}>
            + Request Room Change
          </button>
        </div>
      </header>

      {loading && (
        <div className="room-content">
          <section className="room-overview-card">
            <div className="room-number">Loading...</div>
          </section>
        </div>
      )}

      {!loading && error && (
        <div className="room-content">
          <section className="room-overview-card">
            <div className="room-number">—</div>
            <p style={{ marginTop: '12px', color: '#ef4444' }}>{error}</p>
          </section>
        </div>
      )}

      {!loading && !error && (
      <div className="room-content">
        <section className="room-overview-card">
          <div className="room-number">{roomData.roomNumber}</div>
          <div className="room-meta">
            <span className="zone-badge">{roomTypeLabel}</span>
          </div>
          <div className="room-info-grid">
            <div className="room-info-item">
              <span className="info-icon">🏢</span>
              <span className="info-label">Block</span>
              <span className="info-value">{roomData.block}</span>
            </div>
            <div className="room-info-item">
              <span className="info-icon">📍</span>
              <span className="info-label">Floor</span>
              <span className="info-value">{roomData.floor}</span>
            </div>
            <div className="room-info-item">
              <span className="info-icon">👥</span>
              <span className="info-label">Capacity</span>
              <span className="info-value">
                {roomData.capacity.current}/{roomData.capacity.total}
              </span>
            </div>
            <div className="room-info-item">
              <span className="info-icon">✅</span>
              <span className="info-label">Status</span>
              <span className="info-value">{roomData.status}</span>
            </div>
            {roomData.rent !== null && (
              <div className="room-info-item">
                <span className="info-icon">💰</span>
                <span className="info-label">Rent / Month</span>
                <span className="info-value">₹{roomData.rent}</span>
              </div>
            )}
          </div>
        </section>

        <section className="roommate-card">
          <h2 className="card-title">Roommate</h2>
          {roommates.length > 0 ? (
            roommates.map((roommate) => (
              <div className="roommate-content" key={roommate.user_id}>
                <div className="roommate-avatar">
                  {roommate.name?.split(' ').map((n) => n[0]).join('') || 'S'}
                </div>
                <div className="roommate-info">
                  <div className="roommate-name">{roommate.name}</div>
                  <div className="roommate-branch">{roommate.branch || '—'}</div>
                  <div className="roommate-year">{roommate.year || '—'}</div>
                </div>
              </div>
            ))
          ) : (
            <div className="roommate-content">
              <div className="roommate-info">
                <div className="roommate-name">No roommate assigned</div>
              </div>
            </div>
          )}
        </section>

        <section className="amenities-card">
          <h2 className="card-title">Amenities</h2>
          <div className="amenities-grid">
            {roomData.amenities.length > 0 ? (
              roomData.amenities.map((amenity) => (
                <div key={amenity} className="amenity-chip">
                  <span className="amenity-icon">✅</span>
                  <span className="amenity-name">{amenity}</span>
                </div>
              ))
            ) : (
              <div className="amenity-chip">
                <span className="amenity-name">No amenities listed</span>
              </div>
            )}
          </div>
        </section>

        <section className="guidelines-card">
          <h2 className="card-title">Room Guidelines</h2>
          <ul className="guidelines-list">
            {guidelines.map((guideline, index) => (
              <li key={index}>{guideline}</li>
            ))}
          </ul>
        </section>
      </div>
      )}

      {showModal && (
        <div className="request-modal-overlay" onClick={() => setShowModal(false)}>
          <div className="request-modal-container" onClick={(e) => e.stopPropagation()}>
            <div className="request-modal-header">
              <h2>Request Room Change</h2>
              <button
                className="request-modal-close"
                onClick={() => setShowModal(false)}
              >
                ✕
              </button>
            </div>

            <div className="request-modal-body">
              {/* Current Room Information */}
              <div className="form-section">
                <h3>Current Room Information</h3>
                <div className="form-group-row">
                  <div className="form-group">
                    <label className="request-label">Current Room</label>
                    <input
                      type="text"
                      className="request-input"
                      value={roomData.roomNumber}
                      disabled
                      readOnly
                    />
                  </div>
                  <div className="form-group">
                    <label className="request-label">Current Block</label>
                    <input
                      type="text"
                      className="request-input"
                      value={`Block ${roomData.block}`}
                      disabled
                      readOnly
                    />
                  </div>
                </div>
              </div>

              {/* Requested Room Preferences */}
              <div className="form-section">
                <h3>Requested Room Preferences</h3>
                <div className="form-group-row">
                  <div className="form-group">
                    <label className="request-label">Preferred Room Number</label>
                    <input
                      type="text"
                      name="preferredRoom"
                      className="request-input"
                      placeholder="e.g., 104, 203, etc."
                      value={formData.preferredRoom}
                      onChange={handleFormChange}
                    />
                  </div>
                  <div className="form-group">
                    <label className="request-label">Preferred Block</label>
                    <select
                      name="preferredBlock"
                      className="request-input"
                      value={formData.preferredBlock}
                      onChange={handleFormChange}
                    >
                      <option value="">Select a block</option>
                      {blocks.map((block) => (
                        <option key={block.id} value={block.name}>
                          {block.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>

              {/* Detailed Reason */}
              <div className="form-section">
                <h3>Reason for Room Change</h3>
                <label className="request-label">Detailed Reason</label>
                <textarea
                  name="detailedReason"
                  className="request-textarea"
                  placeholder="Please describe in detail why you need a room change. Include any specific issues or preferences..."
                  value={formData.detailedReason}
                  onChange={handleFormChange}
                  rows={6}
                />
              </div>
            </div>

            <div className="request-modal-footer">
              <button
                className="request-btn-cancel"
                onClick={() => setShowModal(false)}
              >
                Cancel
              </button>
              <button
                className="request-btn-submit"
                onClick={handleSubmitRequest}
              >
                Submit Request
              </button>
            </div>
          </div>
        </div>
      )}
    </StudentLayout>
  );
};

export default Room;

