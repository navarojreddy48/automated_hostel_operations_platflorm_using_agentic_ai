import React, { useMemo, useState, useEffect } from 'react';
import '../../styles/security-dashboard.css';

const SecurityDashboard = () => {
  const [activeTab, setActiveTab] = useState('visitors');
  const [searchQuery, setSearchQuery] = useState('');
  const [visitors, setVisitors] = useState([]);
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [checkingOutId, setCheckingOutId] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch active visitors
        const visitorRes = await fetch('http://localhost:5000/api/security/visitors/active');
        const visitorData = await visitorRes.json();
        if (visitorData.success && Array.isArray(visitorData.data)) {
          setVisitors(visitorData.data);
        }
        
        // Fetch security logs
        const logRes = await fetch('http://localhost:5000/api/security/logs');
        const logData = await logRes.json();
        if (logData.success && Array.isArray(logData.data)) {
          setLogs(logData.data);
        }
        
        setLoading(false);
      } catch (error) {
        console.error('Error fetching security data:', error);
        setLoading(false);
      }
    };
    
    fetchData();
  }, []);

  const handleCheckout = async (visitorId) => {
    setCheckingOutId(visitorId);
    try {
      const res = await fetch(`http://localhost:5000/api/security/visitor/${visitorId}/checkout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await res.json();
      if (data.success) {
        // Optimistically update the UI - remove checked out visitor
        setVisitors(prev => prev.filter(v => v.id !== visitorId));
      }
    } catch (error) {
      console.error('Error checking out visitor:', error);
    } finally {
      setCheckingOutId(null);
    }
  };

  const filteredVisitors = useMemo(() => {
    if (!searchQuery.trim()) return visitors;
    const query = searchQuery.toLowerCase();
    return visitors.filter((item) =>
      [item.visitor_name, item.id_number, item.student_name || '']
        .join(' ')
        .toLowerCase()
        .includes(query)
    );
  }, [searchQuery, visitors]);

  // Calculate summary statistics
  const inside = visitors.filter(v => v.status === 'inside').length;
  const exited = visitors.filter(v => v.status === 'exited').length;
  const overstayed = visitors.filter(v => v.status === 'overstayed').length;
  const visitorCount = visitors.length;
  const logCount = logs.length;

  const getStatusClass = (status) => status ? status.toLowerCase().replace(/\s+/g, '-') : 'unknown';

  return (
    <>
        <main className="security-main">
          {/* HEADER */}
          <header className="security-header">
            <div>
              <h1 className="security-title-main">Visitor & Access Log</h1>
              <p className="security-subtitle">
                Monitor active visitors and security logs
              </p>
            </div>
          </header>

          {/* SUMMARY STATUS CARDS */}
          <section className="security-summary-cards">
            <div className="security-status-card awaiting">
              <div className="card-content">
                <div className="card-label">Visitors Inside</div>
                <div className="card-value">{inside}</div>
              </div>
              <div className="card-icon">👥</div>
            </div>

            <div className="security-status-card out">
              <div className="card-content">
                <div className="card-label">Exited</div>
                <div className="card-value">{exited}</div>
              </div>
              <div className="card-icon">🚪</div>
            </div>

            <div className="security-status-card returned">
              <div className="card-content">
                <div className="card-label">Overstayed</div>
                <div className="card-value">{overstayed}</div>
              </div>
              <div className="card-icon">⚠️</div>
            </div>

            <div className="security-status-card parcels">
              <div className="card-content">
                <div className="card-label">Total Visitors</div>
                <div className="card-value">{visitorCount}</div>
              </div>
              <div className="card-icon">📋</div>
            </div>
          </section>

          {/* SEARCH BAR */}
          <div className="search-container">
            <input
              type="text"
              className="search-input"
              placeholder="Search by name, roll number, or room..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            <span className="search-icon">🔍</span>
          </div>

          {/* TAB SWITCHER */}
          <div className="tab-switcher">
            <button
              className={`tab-button ${activeTab === 'visitors' ? 'active' : ''}`}
              onClick={() => setActiveTab('visitors')}
            >
              <span className="tab-label">Visitors</span>
              <span className="tab-badge">{visitorCount}</span>
            </button>
            <button
              className={`tab-button ${activeTab === 'logs' ? 'active' : ''}`}
              onClick={() => setActiveTab('logs')}
            >
              <span className="tab-label">Logs</span>
              <span className="tab-badge">{logCount}</span>
            </button>
          </div>

          {/* MAIN CONTENT AREA */}
          <section className="security-content-area">
            {activeTab === 'visitors' && (
              <>
                {loading ? (
                  <div style={{ textAlign: 'center', padding: '2rem', color: '#6b7280' }}>Loading visitors...</div>
                ) : filteredVisitors.length > 0 ? (
                  <div className="security-list">
                    {filteredVisitors.map((visitor) => (
                      <div key={visitor.id} className="security-card">
                        <div className="card-main">
                          <div className="card-title">{visitor.visitor_name}</div>
                          <div className="card-subtitle">
                            {visitor.id_type}: {visitor.id_number}
                          </div>
                          <div style={{ marginTop: '8px', fontSize: '13px', color: '#6b7280' }}>
                            <div>📍 {visitor.student_name || 'N/A'}</div>
                            <div>📱 {visitor.phone}</div>
                            {visitor.purpose && <div>🎯 {visitor.purpose}</div>}
                          </div>
                        </div>
                        <div className="card-details">
                          <div className="detail-item">
                            <span className="detail-label">Entry:</span>
                            <span className="detail-value">
                              {visitor.entry_time && new Date(visitor.entry_time).toLocaleTimeString()}
                            </span>
                          </div>
                          <div className="detail-item">
                            <span className={`detail-status ${getStatusClass(visitor.status)}`}>
                              {visitor.status?.toUpperCase() || 'INSIDE'}
                            </span>
                          </div>
                          {visitor.status === 'inside' && (
                            <button 
                              className="btn-checkout"
                              onClick={() => handleCheckout(visitor.id)}
                              disabled={checkingOutId === visitor.id}
                              style={{
                                marginTop: '8px',
                                padding: '6px 12px',
                                fontSize: '13px',
                                backgroundColor: checkingOutId === visitor.id ? '#9ca3af' : '#10b981',
                                color: 'white',
                                border: 'none',
                                borderRadius: '4px',
                                cursor: checkingOutId === visitor.id ? 'not-allowed' : 'pointer'
                              }}
                            >
                              {checkingOutId === visitor.id && <span className="btn-spinner" />}
                              {checkingOutId === visitor.id ? 'Checking out...' : 'Checkout'}
                            </button>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div style={{ textAlign: 'center', padding: '2rem', color: '#9ca3af' }}>
                    <p>No active visitors at the moment</p>
                  </div>
                )}
              </>
            )}

            {activeTab === 'logs' && (
              <>
                {logs.length > 0 ? (
                  <div className="security-list">
                    {logs.slice(0, 20).map((log, idx) => (
                      <div key={idx} className="security-card">
                        <div className="card-main">
                          <div className="card-title">{log.action || 'Log Entry'}</div>
                          <div className="card-subtitle">{log.details || 'N/A'}</div>
                          <div style={{ marginTop: '8px', fontSize: '13px', color: '#6b7280' }}>
                            Time: {log.timestamp && new Date(log.timestamp).toLocaleString()}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div style={{ textAlign: 'center', padding: '2rem', color: '#9ca3af' }}>
                    <p>No security logs available</p>
                  </div>
                )}
              </>
            )}
          </section>
        </main>
    </>
  );
};

export default SecurityDashboard;

