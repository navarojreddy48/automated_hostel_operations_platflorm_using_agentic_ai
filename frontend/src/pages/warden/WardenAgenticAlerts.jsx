import React, { useEffect, useState } from 'react';
import '../../styles/warden-dashboard.css';

const WardenAgenticAlerts = () => {
  const [complaintAlerts, setComplaintAlerts] = useState([]);
  const [outpassAlerts, setOutpassAlerts] = useState([]);
  const [leaveAlerts, setLeaveAlerts] = useState([]);
  const [securityAlerts, setSecurityAlerts] = useState([]);
  const [securityUnreadCount, setSecurityUnreadCount] = useState(0);
  const [securityUnreadOnly, setSecurityUnreadOnly] = useState(true);
  const [securityMonitor, setSecurityMonitor] = useState({ status_summary: {}, weekly_insights: {} });
  const [loading, setLoading] = useState(true);
  const [activeType, setActiveType] = useState('complaints');
  const [showParentDetails, setShowParentDetails] = useState({});
  const [acknowledgingAlertId, setAcknowledgingAlertId] = useState(null);
  const [acknowledgingAll, setAcknowledgingAll] = useState(false);

  const fetchAlerts = async () => {
    setLoading(true);
    try {
      const [complaintRes, outpassRes, leaveRes, securityRes, securityMonitorRes] = await Promise.all([
        fetch('http://localhost:5000/api/warden/complaints/agentic-alerts?limit=100'),
        fetch('http://localhost:5000/api/warden/outpasses/alerts'),
        fetch('http://localhost:5000/api/warden/leaves/agentic-alerts?limit=100'),
        fetch(`http://localhost:5000/api/warden/security/agentic-alerts?limit=100&unread_only=${securityUnreadOnly}`),
        fetch('http://localhost:5000/api/warden/security/agentic-monitor')
      ]);

      const complaintData = await complaintRes.json();
      const outpassData = await outpassRes.json();
      const leaveData = await leaveRes.json();
      const securityData = await securityRes.json();
      const securityMonitorData = await securityMonitorRes.json();

      setComplaintAlerts(Array.isArray(complaintData.data) ? complaintData.data : []);
      setOutpassAlerts(Array.isArray(outpassData.data) ? outpassData.data : []);
      setLeaveAlerts(Array.isArray(leaveData.data) ? leaveData.data : []);
      setSecurityAlerts(Array.isArray(securityData.data) ? securityData.data : []);
      setSecurityUnreadCount(Number(securityData.unread_count) || 0);
      setSecurityMonitor(securityMonitorData?.data || { status_summary: {}, weekly_insights: {} });
    } catch (error) {
      console.error('Error fetching agentic AI alerts:', error);
      setComplaintAlerts([]);
      setOutpassAlerts([]);
      setLeaveAlerts([]);
      setSecurityAlerts([]);
      setSecurityUnreadCount(0);
      setSecurityMonitor({ status_summary: {}, weekly_insights: {} });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAlerts();
    const poller = setInterval(fetchAlerts, 60000);
    return () => clearInterval(poller);
  }, [securityUnreadOnly]);

  const toggleParentDetails = (id) => {
    setShowParentDetails((previous) => ({ ...previous, [id]: !previous[id] }));
  };

  const acknowledgeSecurityAlert = async (alertId) => {
    try {
      setAcknowledgingAlertId(alertId);
      const response = await fetch(`http://localhost:5000/api/warden/security/agentic-alerts/${alertId}/acknowledge`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await response.json();
      if (!response.ok || !data.success) {
        alert(data?.message || 'Failed to acknowledge alert');
        return;
      }
      await fetchAlerts();
    } catch (error) {
      console.error('Error acknowledging security alert:', error);
      alert('Failed to acknowledge alert');
    } finally {
      setAcknowledgingAlertId(null);
    }
  };

  const acknowledgeAllSecurityAlerts = async () => {
    try {
      setAcknowledgingAll(true);
      const response = await fetch('http://localhost:5000/api/warden/security/agentic-alerts/acknowledge-all', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      const data = await response.json();
      if (!response.ok || !data.success) {
        alert(data?.message || 'Failed to acknowledge alerts');
        return;
      }
      await fetchAlerts();
    } catch (error) {
      console.error('Error acknowledging all security alerts:', error);
      alert('Failed to acknowledge alerts');
    } finally {
      setAcknowledgingAll(false);
    }
  };

  const alerts = activeType === 'complaints'
    ? complaintAlerts
    : activeType === 'outpasses'
      ? outpassAlerts
      : activeType === 'security'
        ? securityAlerts
        : leaveAlerts;

  const getSeverityTagClass = (severity) => {
    if (severity === 'critical' || severity === 'high') return 'rejected';
    if (severity === 'medium') return 'pending';
    return 'approved';
  };

  return (
    <div className="leave-page">
      <div className="leave-header">
        <h1>Agentic AI Alerts</h1>
        <p>View autonomous alerts for complaints, leaves, outpasses, and security monitoring.</p>
      </div>

      <div className="leave-filters" style={{ marginBottom: '16px' }}>
        <button
          className={`filter-btn ${activeType === 'complaints' ? 'active' : ''}`}
          onClick={() => setActiveType('complaints')}
        >
          Complaint Alerts ({complaintAlerts.length})
        </button>
        <button
          className={`filter-btn ${activeType === 'leaves' ? 'active' : ''}`}
          onClick={() => setActiveType('leaves')}
        >
          Leave Alerts ({leaveAlerts.length})
        </button>
        <button
          className={`filter-btn ${activeType === 'outpasses' ? 'active' : ''}`}
          onClick={() => setActiveType('outpasses')}
        >
          Outpass Alerts ({outpassAlerts.length})
        </button>
        <button
          className={`filter-btn ${activeType === 'security' ? 'active' : ''}`}
          onClick={() => setActiveType('security')}
        >
          Security Alerts ({securityUnreadCount})
        </button>
      </div>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
        <div className="leave-meta">Total Alerts: {alerts.length}</div>
        <button className="action-btn primary" onClick={fetchAlerts} disabled={loading}>
          {loading ? 'Refreshing...' : 'Refresh Alerts'}
        </button>
      </div>

      {loading ? (
        <div className="leave-page"><p>Loading agentic AI alerts...</p></div>
      ) : alerts.length === 0 ? (
        <div className="leave-empty">
          <div className="leave-empty-card">
            <div className="leave-empty-icon" aria-hidden="true">📭</div>
            <h3>No active alerts found</h3>
            <p>No overdue alert notifications have been generated yet.</p>
          </div>
        </div>
      ) : (
        <div className="leave-list">
          {activeType === 'complaints' ? (
            alerts.map((alert) => (
              <article className="leave-card" key={alert.id}>
                <div className="leave-card-top">
                  <div>
                    <div className="leave-name">{alert.title || 'Complaint Alert'}</div>
                    <div className="leave-meta">
                      {alert.complaint_id ? `Complaint #${alert.complaint_id}` : 'System alert'}
                    </div>
                  </div>
                  <div className="leave-tags">
                    <span className={`tag ${getSeverityTagClass(alert.severity)}`}>
                      {(alert.severity || 'medium').toUpperCase()}
                    </span>
                    <span className={`tag ${getSeverityTagClass(alert.severity)}`}>
                      {(alert.alert_type || 'alert').replace('_', ' ').toUpperCase()}
                    </span>
                  </div>
                </div>

                <div className="leave-reason" style={{ background: '#eff6ff', borderColor: '#bfdbfe' }}>
                  <div className="leave-label" style={{ color: '#1e40af' }}>AI Alert Message</div>
                  <div className="leave-value" style={{ color: '#1e3a8a' }}>{alert.message || 'No message'}</div>
                </div>

                <div className="leave-grid">
                  <div>
                    <div className="leave-label">Alert Type</div>
                    <div className="leave-value">{(alert.alert_type || 'N/A').replace('_', ' ')}</div>
                  </div>
                  <div>
                    <div className="leave-label">Severity</div>
                    <div className="leave-value">{(alert.severity || 'N/A').toUpperCase()}</div>
                  </div>
                  <div>
                    <div className="leave-label">Complaint Status</div>
                    <div className="leave-value">{alert.complaint_status || 'N/A'}</div>
                  </div>
                  <div>
                    <div className="leave-label">Last Updated</div>
                    <div className="leave-value">
                      {alert.updated_at ? new Date(alert.updated_at).toLocaleString() : 'N/A'}
                    </div>
                  </div>
                </div>
              </article>
            ))
          ) : activeType === 'security' ? (
            <>
              <div style={{ display: 'flex', justifyContent: 'space-between', gap: '8px', marginBottom: '12px' }}>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button
                    className={`filter-btn ${securityUnreadOnly ? 'active' : ''}`}
                    onClick={() => setSecurityUnreadOnly(true)}
                  >
                    Unread Only
                  </button>
                  <button
                    className={`filter-btn ${!securityUnreadOnly ? 'active' : ''}`}
                    onClick={() => setSecurityUnreadOnly(false)}
                  >
                    All Alerts
                  </button>
                </div>
                <button
                  className="action-btn primary"
                  onClick={acknowledgeAllSecurityAlerts}
                  disabled={acknowledgingAll || securityAlerts.length === 0}
                >
                  {acknowledgingAll ? 'Acknowledging...' : 'Acknowledge All'}
                </button>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '12px', marginBottom: '12px' }}>
                <div className="leave-reason" style={{ marginBottom: 0 }}>
                  <div className="leave-label">Missing Students</div>
                  <div className="leave-value">{securityMonitor?.status_summary?.missing_students || 0}</div>
                </div>
                <div className="leave-reason" style={{ marginBottom: 0 }}>
                  <div className="leave-label">Late Returns</div>
                  <div className="leave-value">{securityMonitor?.status_summary?.late_returns || 0}</div>
                </div>
                <div className="leave-reason" style={{ marginBottom: 0 }}>
                  <div className="leave-label">Unauthorized Attempts</div>
                  <div className="leave-value">{securityMonitor?.status_summary?.unauthorized_exit_attempts || 0}</div>
                </div>
                <div className="leave-reason" style={{ marginBottom: 0 }}>
                  <div className="leave-label">High-Risk Students</div>
                  <div className="leave-value">{securityMonitor?.status_summary?.high_risk_students || 0}</div>
                </div>
              </div>

              {alerts.map((alert) => (
                <article className="leave-card" key={alert.id}>
                  <div className="leave-card-top">
                    <div>
                      <div className="leave-name">{alert.title || 'Security Alert'}</div>
                      <div className="leave-meta">
                        {alert.student_name ? `${alert.student_name} (${alert.roll_number || 'N/A'})` : 'Security event'}
                      </div>
                    </div>
                    <div className="leave-tags">
                      <span className={`tag ${getSeverityTagClass(alert.severity)}`}>
                        {(alert.severity || 'medium').toUpperCase()}
                      </span>
                      <span className={`tag ${getSeverityTagClass(alert.severity)}`}>
                        {(alert.alert_type || 'alert').replace('_', ' ').toUpperCase()}
                      </span>
                    </div>
                  </div>

                  <div className="leave-reason" style={{ background: '#fff1f2', borderColor: '#fecdd3' }}>
                    <div className="leave-label" style={{ color: '#9f1239' }}>Security Alert Message</div>
                    <div className="leave-value" style={{ color: '#881337' }}>{alert.message || 'No message'}</div>
                  </div>

                  <div className="leave-grid">
                    <div>
                      <div className="leave-label">Alert Type</div>
                      <div className="leave-value">{(alert.alert_type || 'N/A').replace('_', ' ')}</div>
                    </div>
                    <div>
                      <div className="leave-label">Severity</div>
                      <div className="leave-value">{(alert.severity || 'N/A').toUpperCase()}</div>
                    </div>
                    <div>
                      <div className="leave-label">Outpass ID</div>
                      <div className="leave-value">{alert.related_outpass_id ? `OP-${alert.related_outpass_id}` : 'N/A'}</div>
                    </div>
                    <div>
                      <div className="leave-label">Updated At</div>
                      <div className="leave-value">{alert.updated_at ? new Date(alert.updated_at).toLocaleString() : 'N/A'}</div>
                    </div>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '12px' }}>
                    <button
                      className="action-btn primary"
                      onClick={() => acknowledgeSecurityAlert(alert.id)}
                      disabled={acknowledgingAlertId === alert.id || alert.is_read === 1}
                    >
                      {alert.is_read === 1 ? 'Acknowledged' : acknowledgingAlertId === alert.id ? 'Acknowledging...' : 'Acknowledge'}
                    </button>
                  </div>
                </article>
              ))}
            </>
          ) : activeType === 'outpasses' ? (
            alerts.map((request) => {
              const parentDetailsVisible = showParentDetails[request.id];
              return (
                <article className="leave-card" key={request.id}>
                  <div className="leave-card-top">
                    <div>
                      <div className="leave-name">{request.student_name || 'N/A'}</div>
                      <div className="leave-meta">
                        {request.roll_number || 'N/A'} - Room {request.room_number || 'N/A'}
                      </div>
                    </div>
                    <div className="leave-tags">
                      <span className={`tag ${request.status}`}>{request.status}</span>
                      {request.monitor_state && (
                        <span className={`tag ${request.monitor_state === 'overdue' ? 'rejected' : request.monitor_state === 'grace_period' ? 'pending' : 'approved'}`}>
                          {request.monitor_state.replace('_', ' ').toUpperCase()}
                        </span>
                      )}
                    </div>
                  </div>

                  <div className="leave-reason" style={{ background: '#fee2e2', borderColor: '#fca5a5' }}>
                    <div className="leave-label" style={{ color: '#991b1b' }}>Outpass Alert</div>
                    <div className="leave-value" style={{ color: '#7f1d1d' }}>
                      {request.alert_to_student && 'Student email sent'}
                      {request.alert_to_student && request.alert_to_parent && ' - '}
                      {request.alert_to_parent && 'Parent email sent'}
                      {request.alert_sent_at && ` - ${new Date(request.alert_sent_at).toLocaleString()}`}
                    </div>
                  </div>

                  <div className="leave-reason">
                    <div className="leave-label">Parent/Guardian Information</div>
                    <button className="link-btn" type="button" onClick={() => toggleParentDetails(request.id)}>
                      {parentDetailsVisible ? 'Hide Parent Details' : 'Show Parent Details'}
                    </button>
                    {parentDetailsVisible && (
                      <div className="leave-value" style={{ marginTop: '8px' }}>
                        <div style={{ display: 'grid', gridTemplateColumns: 'auto 1fr', gap: '8px', padding: '12px', background: '#f9fafb', borderRadius: '6px' }}>
                          <strong>Parent Name:</strong>
                          <span>{request.parent_name || 'Not provided'}</span>
                          <strong>Parent Phone:</strong>
                          <span>{request.parent_phone || 'Not provided'}</span>
                          <strong>Parent Email:</strong>
                          <span>{request.parent_email || 'Not provided'}</span>
                        </div>
                      </div>
                    )}
                  </div>
                </article>
              );
            })
          ) : (
            alerts.map((alert) => (
              <article className="leave-card" key={alert.id}>
                <div className="leave-card-top">
                  <div>
                    <div className="leave-name">{alert.title || 'Leave Alert'}</div>
                    <div className="leave-meta">
                      {alert.student_name ? `${alert.student_name} (${alert.roll_number || 'N/A'})` : 'System alert'}
                    </div>
                  </div>
                  <div className="leave-tags">
                    <span className={`tag ${getSeverityTagClass(alert.severity)}`}>
                      {(alert.severity || 'medium').toUpperCase()}
                    </span>
                    <span className={`tag ${getSeverityTagClass(alert.severity)}`}>
                      {(alert.alert_type || 'alert').replace('_', ' ').toUpperCase()}
                    </span>
                  </div>
                </div>

                <div className="leave-reason" style={{ background: '#fff7ed', borderColor: '#fed7aa' }}>
                  <div className="leave-label" style={{ color: '#9a3412' }}>Leave Alert Message</div>
                  <div className="leave-value" style={{ color: '#7c2d12' }}>{alert.message || 'No message'}</div>
                </div>

                <div className="leave-grid">
                  <div>
                    <div className="leave-label">Alert Type</div>
                    <div className="leave-value">{(alert.alert_type || 'N/A').replace('_', ' ')}</div>
                  </div>
                  <div>
                    <div className="leave-label">Severity</div>
                    <div className="leave-value">{(alert.severity || 'N/A').toUpperCase()}</div>
                  </div>
                  <div>
                    <div className="leave-label">Leave Status</div>
                    <div className="leave-value">{alert.leave_status || 'N/A'}</div>
                  </div>
                  <div>
                    <div className="leave-label">Updated At</div>
                    <div className="leave-value">{alert.updated_at ? new Date(alert.updated_at).toLocaleString() : 'N/A'}</div>
                  </div>
                </div>
              </article>
            ))
          )}
        </div>
      )}
    </div>
  );
};

export default WardenAgenticAlerts;


