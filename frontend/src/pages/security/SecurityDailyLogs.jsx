import React, { useState, useEffect, useMemo } from 'react';
import '../../styles/security-dashboard.css';

const SecurityDailyLogs = () => {
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [activityFilter, setActivityFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');
  const [selectedLog, setSelectedLog] = useState(null);
  const [showDetails, setShowDetails] = useState(false);
  const [allLogs, setAllLogs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchLogs();
  }, [selectedDate]);

  const fetchLogs = async () => {
    setLoading(true);
    try {
      const url = new URL('http://localhost:5000/api/security/logs');
      url.searchParams.append('date', selectedDate);
      
      const response = await fetch(url.toString());
      const data = await response.json();
      
      if (data.success && Array.isArray(data.data)) {
        const formattedLogs = data.data.map((log) => {
          const timestamp = log.timestamp ? new Date(log.timestamp) : new Date();
          return {
            id: log.id,
            time: timestamp.toLocaleTimeString(),
            date: timestamp.toISOString().split('T')[0],
            type: log.activity_type ? log.activity_type.charAt(0).toUpperCase() + log.activity_type.slice(1) : 'Other',
            description: log.description || 'No description',
            person: log.logged_by_name || 'Security Staff',
            status: log.severity ? log.severity.charAt(0).toUpperCase() + log.severity.slice(1) : 'Low',
            details: log.location ? `Location: ${log.location}` : (log.action_taken || 'N/A'),
            remarks: log.follow_up_required === 'yes' ? 'Follow-up required' : 'No follow-up'
          };
        });
        setAllLogs(formattedLogs);
      } else {
        console.warn('No data or success flag false:', data);
        setAllLogs([]);
      }
    } catch (error) {
      console.error('Error fetching logs:', error);
      setAllLogs([]);
    } finally {
      setLoading(false);
    }
  };

  // Filter logs by date and activity/status filters
  const filteredLogs = useMemo(() => {
    return allLogs.filter((log) => {
      const dateMatch = log.date === selectedDate;
      const activityMatch = activityFilter === 'All' || log.type === activityFilter;
      const statusMatch = statusFilter === 'All' || log.status === statusFilter;
      return dateMatch && activityMatch && statusMatch;
    });
  }, [allLogs, selectedDate, activityFilter, statusFilter]);

  // Calculate summary statistics from filtered logs
  const summaryCards = useMemo(() => {
    return [
      { 
        label: 'Total Outpasses Checked', 
        value: filteredLogs.filter(l => l.type === 'Outpass').length, 
        icon: '🚪' 
      },
      { 
        label: 'Visitors Logged', 
        value: filteredLogs.filter(l => l.type === 'Visitor').length, 
        icon: '🧾' 
      },
      { 
        label: 'Parcels Received', 
        value: filteredLogs.filter(l => l.type === 'Parcel').length, 
        icon: '📦' 
      },
      { 
        label: 'High Priority', 
        value: filteredLogs.filter(l => l.status === 'High' || l.status === 'Critical').length, 
        icon: '⚠️' 
      },
      { 
        label: 'Completed', 
        value: filteredLogs.filter(l => l.status === 'Low' || l.status === 'Medium').length, 
        icon: '✅' 
      }
    ];
  }, [filteredLogs]);

  const hasData = filteredLogs.length > 0;

  const handleViewDetails = (log) => {
    setSelectedLog(log);
    setShowDetails(true);
  };

  const closeDetails = () => {
    setShowDetails(false);
    setSelectedLog(null);
  };

  const getStatusClass = (status) => `log-${status.toLowerCase()}`;

  return (
    <>
      <header className="logs-header">
            <div className="header-content">
              <h1 className="security-title-main">Daily Security Logs</h1>
              <p className="security-subtitle">Overview of hostel security activities</p>
            </div>
            <div className="logs-controls">
              <div className="filter-group">
                <label className="filter-label">Select Date</label>
                <input
                  className="filter-input"
                  type="date"
                  value={selectedDate}
                  onChange={(e) => setSelectedDate(e.target.value)}
                />
              </div>
              <button className="btn-action primary" onClick={fetchLogs}>View Logs</button>
            </div>
          </header>

          <section className="log-summary-cards">
            {summaryCards.map((card) => (
              <div key={card.label} className="log-summary-card">
                <div className="card-content">
                  <div className="card-label">{card.label}</div>
                  <div className="card-value">{card.value}</div>
                </div>
                <div className="card-icon">{card.icon}</div>
              </div>
            ))}
          </section>

          <section className="log-filters">
            <div className="filter-group">
              <label className="filter-label">Activity Type</label>
              <select
                className="filter-select"
                value={activityFilter}
                onChange={(e) => setActivityFilter(e.target.value)}
              >
                <option>All</option>
                <option>Outpass</option>
                <option>Visitor</option>
                <option>Parcel</option>
                <option>Incident</option>
                <option>Patrol</option>
                <option>Emergency</option>
                <option>Other</option>
              </select>
            </div>
            <div className="filter-group">
              <label className="filter-label">Status</label>
              <select
                className="filter-select"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option>All</option>
                <option>Low</option>
                <option>Medium</option>
                <option>High</option>
                <option>Critical</option>
              </select>
            </div>
          </section>

          {loading ? (
            <div style={{ textAlign: 'center', padding: '2rem', color: '#6b7280' }}>Loading security logs...</div>
          ) : hasData ? (
            <section className="log-table">
              <table>
                <thead>
                  <tr>
                    <th>Time</th>
                    <th>Activity Type</th>
                    <th>Description</th>
                    <th>Student / Visitor</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredLogs.map((log) => (
                    <tr key={log.id} onClick={() => handleViewDetails(log)}>
                      <td className="mono">{log.time}</td>
                      <td>{log.type}</td>
                      <td>{log.description}</td>
                      <td>{log.person}</td>
                      <td>
                        <span className={`status-badge ${getStatusClass(log.status)}`}>
                          {log.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </section>
          ) : (
            <div className="empty-state">
              <span className="empty-icon">🗓️</span>
              <p className="empty-message">{loading ? 'Loading...' : 'No security activities recorded for this date'}</p>
            </div>
          )}

      {showDetails && selectedLog && (
        <div className="modal-overlay" onClick={closeDetails}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Log Details</h2>
              <button className="modal-close" onClick={closeDetails}>×</button>
            </div>
            <div className="modal-body">
              <div className="details-grid">
                <div>
                  <div className="detail-label">Time</div>
                  <div className="detail-value">{selectedLog.time}</div>
                  <div className="detail-sub">{selectedLog.id}</div>
                </div>
                <div>
                  <div className="detail-label">Activity</div>
                  <div className="detail-value">{selectedLog.type}</div>
                  <div className="detail-sub">Status: {selectedLog.status}</div>
                </div>
                <div>
                  <div className="detail-label">Person</div>
                  <div className="detail-value">{selectedLog.person}</div>
                  <div className="detail-sub">{selectedLog.description}</div>
                </div>
                <div>
                  <div className="detail-label">Remarks</div>
                  <div className="detail-value">{selectedLog.remarks}</div>
                  <div className="detail-sub">{selectedLog.details}</div>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn-secondary" onClick={closeDetails}>Close</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default SecurityDailyLogs;

