import React, { useState, useEffect } from 'react';
import { getCurrentUser } from '../../utils/auth';
import '../../styles/student-outpass.css';

const StudentOutpass = () => {
  const currentUser = getCurrentUser();
  const [showForm, setShowForm] = useState(false);
  const [outpasses, setOutpasses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    reason: '',
    destination: '',
    departureDate: '',
    departureTime: '',
    returnDate: '',
    returnTime: '',
  });
  
  // Holiday Mode states
  const [holidayMode, setHolidayMode] = useState(false);
  const [approvalMethod, setApprovalMethod] = useState(''); // 'otp' or 'manual'
  const [showOtpModal, setShowOtpModal] = useState(false);
  const [otpInput, setOtpInput] = useState('');
  const [currentOutpassForOtp, setCurrentOutpassForOtp] = useState(null);
  const [otpSent, setOtpSent] = useState({});
  const [holidayDateError, setHolidayDateError] = useState('');

  const departureQuickTimes = ['08:00', '09:00', '10:00', '14:00', '17:00'];
  const returnQuickTimes = ['12:00', '16:00', '18:00', '20:00', '21:00'];

  const getTodayDateString = () => {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  };
  
  // Check holiday mode from backend
  useEffect(() => {
    const checkHolidayMode = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/system/holiday-mode');
        const data = await res.json();
        if (data.success) {
          setHolidayMode(data.holidayMode);
        }
      } catch (error) {
        console.error('Error checking holiday mode:', error);
      }
    };
    checkHolidayMode();
    
    // Poll for changes every 5 seconds
    const interval = setInterval(checkHolidayMode, 5000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const fetchOutpasses = async () => {
      try {
        if (!currentUser?.userId) return;
        
        const res = await fetch(`http://localhost:5000/api/student/outpasses/${currentUser.userId}`);
        const data = await res.json();
        if (data.success && Array.isArray(data.data)) {
          setOutpasses(data.data);
          
          // Initialize otpSent state based on otp_sent_at field
          const initialOtpState = {};
          data.data.forEach(outpass => {
            if (outpass.otp_sent_at) {
              initialOtpState[outpass.id] = true;
            }
          });
          setOtpSent(prev => ({ ...prev, ...initialOtpState }));
        }
        setLoading(false);
      } catch (error) {
        console.error('Error fetching outpasses:', error);
        setLoading(false);
      }
    };
    
    fetchOutpasses();
  }, [currentUser?.userId]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));

    if (holidayDateError && name === 'departureDate') {
      setHolidayDateError('');
    }
  };

  const setQuickTime = (fieldName, value) => {
    setFormData((prev) => ({
      ...prev,
      [fieldName]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validation for holiday mode
    if (holidayMode && !approvalMethod) {
      alert('Please select an approval method');
      return;
    }

    if (holidayMode) {
      const today = getTodayDateString();
      if (formData.departureDate !== today) {
        setHolidayDateError('In holiday mode, exit date must be today.');
        return;
      }
    }
    
    setSubmitting(true);
    try {
      const res = await fetch('http://localhost:5000/api/student/outpass', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          student_id: currentUser.userId,
          reason: formData.reason,
          destination: formData.destination,
          departure_date: formData.departureDate,
          departure_time: formData.departureTime,
          return_date: formData.returnDate,
          return_time: formData.returnTime,
          approval_method: approvalMethod || 'manual',
          holiday_mode: holidayMode,
        }),
      });
      const data = await res.json();
      if (data.success) {
        // Refresh outpasses list
        const listRes = await fetch(`http://localhost:5000/api/student/outpasses/${currentUser.userId}`);
        const listData = await listRes.json();
        if (listData.success && Array.isArray(listData.data)) {
          setOutpasses(listData.data);
        }
        
        setFormData({
          reason: '',
          destination: '',
          departureDate: '',
          departureTime: '',
          returnDate: '',
          returnTime: '',
        });
        setApprovalMethod('');
        setHolidayDateError('');
        setShowForm(false);
        alert('Outpass request submitted successfully!');
      } else {
        alert(data.message || 'Failed to submit outpass request');
      }
    } catch (error) {
      console.error('Error submitting outpass:', error);
      alert('Error submitting outpass request');
    } finally {
      setSubmitting(false);
    }
  };
  
  const handleSendOtp = async (outpassId) => {
    try {
      const res = await fetch(`http://localhost:5000/api/student/outpass/${outpassId}/send-otp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      });
      const data = await res.json();
      const payload = data?.data || {};
      const message = data?.message || data?.error?.message;
      
      if (res.status === 429) {
        // Rate limited - OTP already sent recently
        alert(`⏳ ${message || 'OTP already sent recently.'}\nOTP has already been sent to parent email.`);
        setOtpSent(prev => ({ ...prev, [outpassId]: true }));
        return;
      }
      
      if (data.success) {
        setOtpSent(prev => ({ ...prev, [outpassId]: true }));
        alert(`✅ OTP sent successfully to parent email: ${payload.parent_email || payload.parent_contact || 'N/A'}\n\nPlease verify the OTP to complete your outpass request.`);
      } else {
        alert(message || 'Failed to send OTP');
      }
    } catch (error) {
      console.error('Error sending OTP:', error);
      alert('Error sending OTP. Please try again.');
    }
  };
  
  const handleVerifyOtp = async () => {
    if (otpInput.length !== 6) {
      alert('Please enter a valid 6-digit OTP');
      return;
    }
    
    try {
      const res = await fetch(`http://localhost:5000/api/student/outpass/${currentOutpassForOtp?.id}/verify-otp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ otp: otpInput }),
      });
      const data = await res.json();
      const message = data?.message || data?.error?.message;
      
      if (data.success) {
        // Refresh outpasses list
        const listRes = await fetch(`http://localhost:5000/api/student/outpasses/${currentUser.userId}`);
        const listData = await listRes.json();
        if (listData.success && Array.isArray(listData.data)) {
          setOutpasses(listData.data);
        }
        
        setShowOtpModal(false);
        setOtpInput('');
        setCurrentOutpassForOtp(null);
        alert('✅ OTP Verified! Outpass approved via parent verification.');
      } else {
        alert(message || 'Invalid OTP');
      }
    } catch (error) {
      console.error('Error verifying OTP:', error);
      alert('Error verifying OTP');
    }
  };

  const getStatusBadge = (status) => {
    const statusMap = {
      'pending': { color: '#fbbf24', label: '⏳ Pending' },
      'pending_otp': { color: '#3b82f6', label: '🔐 Pending OTP' },
      'approved': { color: '#34d399', label: '✅ Approved' },
      'approved_otp': { color: '#10b981', label: '✅ Approved (Parent OTP)' },
      'rejected': { color: '#f87171', label: '❌ Rejected' },
    };
    return statusMap[status] || { color: '#9ca3af', label: '⚪ ' + status };
  };

  return (
    <>
          {/* HEADER */}
          <header className="outpass-header">
            <div>
              <h1 className="outpass-title">Outpass Requests</h1>
              <p className="outpass-subtitle">Request permission to leave campus temporarily</p>
            </div>
            <button
              className="new-request-btn"
              onClick={() => setShowForm(true)}
            >
              + New Request
            </button>
          </header>

          {/* FORM VIEW */}
          {showForm && (
            <div className="outpass-modal-overlay" onClick={() => setShowForm(false)}>
            <section className="outpass-form-section outpass-modal-card" onClick={(e) => e.stopPropagation()}>
              <div className="form-header">
                <div>
                  <h2 className="form-title">New Outpass Request</h2>
                  <p className="form-subtitle">Fill in the details below to request campus leave</p>
                </div>
                <button
                  className="form-close-btn"
                  onClick={() => setShowForm(false)}
                  title="Close form"
                >
                  ✕
                </button>
              </div>

              <form className="outpass-form" onSubmit={handleSubmit}>
                {/* Reason Field */}
                <div className="form-group">
                  <label htmlFor="reason" className="form-label">
                    Reason for Outpass *
                  </label>
                  <textarea
                    id="reason"
                    name="reason"
                    className="form-textarea"
                    placeholder="Please explain why you need to leave campus..."
                    value={formData.reason}
                    onChange={handleInputChange}
                    rows="4"
                  />
                </div>

                {/* Destination Field */}
                <div className="form-group">
                  <label htmlFor="destination" className="form-label">
                    Destination *
                  </label>
                  <input
                    type="text"
                    id="destination"
                    name="destination"
                    className="form-input"
                    placeholder="Where are you going?"
                    value={formData.destination}
                    onChange={handleInputChange}
                  />
                </div>

                {/* Departure Section */}
                <div className="form-section-title">Departure</div>
                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="departureDate" className="form-label">
                      Date *
                    </label>
                    <input
                      type="date"
                      id="departureDate"
                      name="departureDate"
                      className="form-input"
                      value={formData.departureDate}
                      onChange={handleInputChange}
                      min={holidayMode ? getTodayDateString() : undefined}
                      max={holidayMode ? getTodayDateString() : undefined}
                    />
                    {holidayDateError && (
                      <div style={{ marginTop: '0.5rem', color: '#dc2626', fontSize: '14px', fontWeight: 500 }}>
                        {holidayDateError}
                      </div>
                    )}
                  </div>

                  <div className="form-group">
                    <label htmlFor="departureTime" className="form-label">
                      Time *
                    </label>
                    <input
                      type="time"
                      id="departureTime"
                      name="departureTime"
                      className="form-input"
                      value={formData.departureTime}
                      onChange={handleInputChange}
                    />
                    <div className="quick-time-row">
                      {departureQuickTimes.map((quickTime) => (
                        <button
                          key={`departure-${quickTime}`}
                          type="button"
                          className={`quick-time-btn ${formData.departureTime === quickTime ? 'active' : ''}`}
                          onClick={() => setQuickTime('departureTime', quickTime)}
                        >
                          {quickTime}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Return Section */}
                <div className="form-section-title">Expected Return</div>
                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="returnDate" className="form-label">
                      Date *
                    </label>
                    <input
                      type="date"
                      id="returnDate"
                      name="returnDate"
                      className="form-input"
                      value={formData.returnDate}
                      onChange={handleInputChange}
                    />
                  </div>

                  <div className="form-group">
                    <label htmlFor="returnTime" className="form-label">
                      Time *
                    </label>
                    <input
                      type="time"
                      id="returnTime"
                      name="returnTime"
                      className="form-input"
                      value={formData.returnTime}
                      onChange={handleInputChange}
                    />
                    <div className="quick-time-row">
                      {returnQuickTimes.map((quickTime) => (
                        <button
                          key={`return-${quickTime}`}
                          type="button"
                          className={`quick-time-btn ${formData.returnTime === quickTime ? 'active' : ''}`}
                          onClick={() => setQuickTime('returnTime', quickTime)}
                        >
                          {quickTime}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Holiday Mode - Approval Method Selection */}
                {holidayMode && (
                  <div style={{ marginTop: '1.5rem', padding: '1rem', background: '#fef3c7', border: '1px solid #fbbf24', borderRadius: '8px' }}>
                    <div className="form-section-title" style={{ marginBottom: '0.75rem', color: '#92400e' }}>
                      🎄 Holiday Mode Active - Select Approval Method *
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                      <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', padding: '0.75rem', background: 'white', border: approvalMethod === 'otp' ? '2px solid #3b82f6' : '1px solid #d1d5db', borderRadius: '6px' }}>
                        <input
                          type="radio"
                          name="approvalMethod"
                          value="otp"
                          checked={approvalMethod === 'otp'}
                          onChange={(e) => setApprovalMethod(e.target.value)}
                        />
                        <div>
                          <div style={{ fontWeight: '600' }}>1️⃣ OTP Verification via Parent</div>
                          <div style={{ fontSize: '14px', color: '#6b7280' }}>Instant approval after parent OTP verification</div>
                        </div>
                      </label>
                      <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', padding: '0.75rem', background: 'white', border: approvalMethod === 'manual' ? '2px solid #3b82f6' : '1px solid #d1d5db', borderRadius: '6px' }}>
                        <input
                          type="radio"
                          name="approvalMethod"
                          value="manual"
                          checked={approvalMethod === 'manual'}
                          onChange={(e) => setApprovalMethod(e.target.value)}
                        />
                        <div>
                          <div style={{ fontWeight: '600' }}>2️⃣ Manual Approval by Warden</div>
                          <div style={{ fontSize: '14px', color: '#6b7280' }}>Request goes through normal warden approval</div>
                        </div>
                      </label>
                    </div>
                  </div>
                )}

                {/* Submit Button */}
                <div className="form-actions">
                  <button 
                    type="submit" 
                    className="submit-btn"
                    disabled={submitting}
                    style={{
                      cursor: submitting ? 'not-allowed' : 'pointer',
                      opacity: submitting ? 0.6 : 1
                    }}
                  >
                    {submitting ? 'Submitting...' : 'Submit Request'}
                  </button>
                </div>
              </form>
            </section>
            </div>
          )}

          {/* HISTORY VIEW */}
            <section className="outpass-history-section">
              <h2 className="history-title">Request History</h2>

              {loading ? (
                <div className="history-empty">
                  <span className="history-empty-icon">⏳</span>
                  <p className="history-empty-text">Loading outpass requests...</p>
                </div>
              ) : outpasses.length === 0 ? (
                <div className="history-empty">
                  <span className="history-empty-icon">📋</span>
                  <p className="history-empty-text">No outpass requests yet</p>
                  <p className="history-empty-sub">
                    Click 'New Request' to create your first outpass
                  </p>
                </div>
              ) : (
                <div className="outpass-list">
                  {outpasses.map((outpass) => {
                    const statusInfo = getStatusBadge(outpass.status);
                    
                    // Format departure date and time (backend uses: out_date and out_time)
                    const departureDate = outpass.out_date ? new Date(outpass.out_date).toLocaleDateString('en-GB') : '';
                    const departureTime = outpass.out_time || '';
                    const departureDisplay = departureDate + (departureTime ? ` at ${departureTime}` : '');
                    
                    // Format return date and time (backend uses: expected_return_time as datetime)
                    let returnDisplay = '';
                    if (outpass.expected_return_time) {
                      const returnDateTime = new Date(outpass.expected_return_time);
                      returnDisplay = returnDateTime.toLocaleDateString('en-GB') + ' at ' + returnDateTime.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
                    }
                    
                    return (
                      <div key={outpass.id} className="outpass-item">
                        <div className="outpass-item-left">
                          <div className="outpass-destination">{outpass.destination}</div>
                          <div className="outpass-dates">
                            <span className="outpass-departure">📅 Departure: {departureDisplay}</span>
                            <span className="outpass-return">📅 Return: {returnDisplay}</span>
                          </div>
                          {outpass.reason && (
                            <div className="outpass-reason">{outpass.reason}</div>
                          )}
                          
                          {/* OTP Actions */}
                          {outpass.status === 'pending_otp' && (
                            <div style={{ marginTop: '0.75rem', display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                              {!otpSent[outpass.id] ? (
                                <button
                                  className="submit-btn"
                                  style={{ padding: '0.5rem 1rem', fontSize: '14px' }}
                                  onClick={() => handleSendOtp(outpass.id)}
                                >
                                  📱 Send OTP to Parent
                                </button>
                              ) : (
                                <button
                                  className="submit-btn"
                                  style={{ padding: '0.5rem 1rem', fontSize: '14px', background: '#10b981' }}
                                  onClick={() => {
                                    setCurrentOutpassForOtp(outpass);
                                    setShowOtpModal(true);
                                  }}
                                >
                                  🔐 Enter OTP
                                </button>
                              )}
                            </div>
                          )}
                        </div>
                        <div className="outpass-status" style={{ backgroundColor: statusInfo.color }}>
                          {statusInfo.label}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </section>
          
          {/* OTP Verification Modal */}
          {showOtpModal && currentOutpassForOtp && (
            <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
              <div style={{ background: 'white', borderRadius: '12px', padding: '2rem', minWidth: '400px', maxWidth: '90%' }}>
                <h2 style={{ margin: '0 0 1rem 0', fontSize: '20px', fontWeight: '600' }}>🔐 Enter OTP</h2>
                <div style={{ marginBottom: '1.5rem' }}>
                  <div style={{ fontSize: '14px', color: '#6b7280', marginBottom: '0.5rem' }}>
                    <strong>Student:</strong> {currentUser?.name || 'Student'}
                  </div>
                  <div style={{ fontSize: '14px', color: '#6b7280', marginBottom: '0.5rem' }}>
                    <strong>Parent Contact:</strong> +91-XXXX-XXX-XXX
                  </div>
                  <div style={{ fontSize: '14px', color: '#6b7280' }}>
                    <strong>Destination:</strong> {currentOutpassForOtp.destination}
                  </div>
                </div>
                <div style={{ marginBottom: '1.5rem' }}>
                  <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: '500' }}>Enter 6-digit OTP *</label>
                  <input
                    type="text"
                    maxLength="6"
                    placeholder="000000"
                    value={otpInput}
                    onChange={(e) => setOtpInput(e.target.value.replace(/\D/g, ''))}
                    style={{ width: '100%', padding: '0.75rem', fontSize: '18px', letterSpacing: '0.5rem', textAlign: 'center', border: '2px solid #d1d5db', borderRadius: '8px' }}
                  />
                </div>
                <div style={{ display: 'flex', gap: '0.75rem' }}>
                  <button
                    onClick={() => {
                      setShowOtpModal(false);
                      setOtpInput('');
                      setCurrentOutpassForOtp(null);
                    }}
                    style={{ flex: 1, padding: '0.75rem', background: '#e5e7eb', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '500' }}
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleVerifyOtp}
                    disabled={otpInput.length !== 6}
                    style={{ flex: 1, padding: '0.75rem', background: otpInput.length === 6 ? '#3b82f6' : '#d1d5db', color: 'white', border: 'none', borderRadius: '8px', cursor: otpInput.length === 6 ? 'pointer' : 'not-allowed', fontWeight: '500' }}
                  >
                    Verify OTP
                  </button>
                </div>
              </div>
            </div>
          )}
    </>
  );
};

export default StudentOutpass;


