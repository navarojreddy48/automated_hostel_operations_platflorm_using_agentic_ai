import React, { useState, useEffect } from 'react';
import '../../styles/admin-reports.css';

const AdminReports = () => {
  const [loading, setLoading] = useState(true);
  
  // Analytics data
  const [analyticsData, setAnalyticsData] = useState({
    totalStudents: 0,
    totalRooms: 0,
    occupiedRooms: 0,
    vacantRooms: 0,
    totalComplaints: 0,
    pendingComplaints: 0,
    totalOutpasses: 0,
    activeOutpasses: 0
  });

  // Chart data
  const [roomOccupancyData, setRoomOccupancyData] = useState([]);
  const [complaintsData, setComplaintsData] = useState([]);
  const [outpassData, setOutpassData] = useState([]);

  // Fetch all reports data
  useEffect(() => {
    fetchReportsData();
  }, []);

  const fetchReportsData = async () => {
    setLoading(true);
    try {
      // Fetch analytics data
      const analyticsRes = await fetch('http://localhost:5000/api/admin/reports/analytics');
      const analyticsJson = await analyticsRes.json();
      if (analyticsJson.success) {
        setAnalyticsData({
          totalStudents: analyticsJson.data.total_students || 0,
          totalRooms: analyticsJson.data.total_rooms || 0,
          occupiedRooms: analyticsJson.data.occupied_rooms || 0,
          vacantRooms: analyticsJson.data.vacant_rooms || 0,
          totalComplaints: analyticsJson.data.total_complaints || 0,
          pendingComplaints: analyticsJson.data.pending_complaints || 0,
          totalOutpasses: analyticsJson.data.total_outpasses || 0,
          activeOutpasses: analyticsJson.data.active_outpasses || 0
        });
      }

      // Fetch room occupancy trend
      const occupancyRes = await fetch('http://localhost:5000/api/admin/reports/room-occupancy-trend');
      const occupancyJson = await occupancyRes.json();
      if (occupancyJson.success) {
        setRoomOccupancyData(occupancyJson.data);
      }

      // Fetch complaints by category
      const complaintsRes = await fetch('http://localhost:5000/api/admin/reports/complaints-by-category');
      const complaintsJson = await complaintsRes.json();
      if (complaintsJson.success) {
        setComplaintsData(complaintsJson.data);
      }

      // Fetch outpass trend
      const outpassRes = await fetch('http://localhost:5000/api/admin/reports/outpass-trend');
      const outpassJson = await outpassRes.json();
      if (outpassJson.success) {
        setOutpassData(outpassJson.data);
      }
    } catch (error) {
      console.error('Error fetching reports data:', error);
    } finally {
      setLoading(false);
    }
  };

  // Reports list
  const [reports, setReports] = useState([
    {
      id: 1,
      name: 'Monthly Occupancy Report',
      description: 'Room occupancy statistics for the current month',
      lastUpdated: new Date().toISOString().split('T')[0],
      status: 'Ready',
      type: 'occupancy'
    },
    {
      id: 2,
      name: 'Complaint Summary Report',
      description: 'Overview of all complaints by category and status',
      lastUpdated: new Date().toISOString().split('T')[0],
      status: 'Ready',
      type: 'complaints'
    },
    {
      id: 3,
      name: 'Outpass Activity Report',
      description: 'Student outpass requests and approvals',
      lastUpdated: new Date().toISOString().split('T')[0],
      status: 'Ready',
      type: 'outpass'
    },
    {
      id: 4,
      name: 'Student Registration Report',
      description: 'New student registrations and demographic data',
      lastUpdated: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      status: 'Ready',
      type: 'registration'
    },
    {
      id: 5,
      name: 'Staff Performance Report',
      description: 'Technician and staff activity metrics',
      lastUpdated: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      status: 'Ready',
      type: 'staff'
    },
    {
      id: 6,
      name: 'Mess Feedback Report',
      description: 'Student feedback and ratings for mess services',
      lastUpdated: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      status: 'Ready',
      type: 'mess'
    }
  ]);

  // Filter state
  const [dateRange, setDateRange] = useState('last-30-days');
  const [reportType, setReportType] = useState('all');
  const [viewingReport, setViewingReport] = useState(null);
  const [generatingReport, setGeneratingReport] = useState(false);

  const handleGenerateReport = async () => {
    const reportTypes = ['Monthly Occupancy Report', 'Complaint Summary Report', 'Outpass Activity Report'];
    const selectedType = reportTypes[Math.floor(Math.random() * reportTypes.length)];
    
    setGeneratingReport(true);
    
    // Simulate report generation delay
    setTimeout(() => {
      const newReport = {
        id: reports.length + 1,
        name: `${selectedType} - ${new Date().toLocaleDateString()}`,
        description: `Auto-generated report for ${dateRange}`,
        lastUpdated: new Date().toISOString().split('T')[0],
        status: 'Ready',
        type: reportType === 'all' ? 'general' : reportType
      };
      
      setReports([newReport, ...reports]);
      setGeneratingReport(false);
    }, 1500);
  };

  const handleViewReport = (report) => {
    setViewingReport(report);
  };

  const handleDownloadReport = (report) => {
    // Generate CSV or PDF content based on report type
    const csvContent = generateReportContent(report);
    const element = document.createElement('a');
    const file = new Blob([csvContent], { type: 'text/csv' });
    element.href = URL.createObjectURL(file);
    element.download = `${report.name.replace(/\s+/g, '_')}_${new Date().getTime()}.csv`;
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  };

  const generateReportContent = (report) => {
    let content = `Report: ${report.name}\n`;
    content += `Generated: ${new Date().toLocaleString()}\n`;
    content += `Type: ${report.type}\n\n`;
    content += `---REPORT CONTENT---\n\n`;
    
    if (report.type === 'occupancy' || report.name.includes('Occupancy')) {
      content += `Room Occupancy Data\n`;
      content += `Total Rooms,${analyticsData.totalRooms}\n`;
      content += `Occupied Rooms,${analyticsData.occupiedRooms}\n`;
      content += `Vacant Rooms,${analyticsData.vacantRooms}\n`;
      content += `Occupancy Rate,${analyticsData.totalRooms > 0 ? ((analyticsData.occupiedRooms / analyticsData.totalRooms) * 100).toFixed(2) : 0}%\n`;
    } else if (report.type === 'complaints' || report.name.includes('Complaint')) {
      content += `Complaint Statistics\n`;
      content += `Total Complaints,${analyticsData.totalComplaints}\n`;
      content += `Pending Complaints,${analyticsData.pendingComplaints}\n`;
      content += `Resolution Rate,${analyticsData.totalComplaints > 0 ? (((analyticsData.totalComplaints - analyticsData.pendingComplaints) / analyticsData.totalComplaints) * 100).toFixed(2) : 0}%\n`;
    } else if (report.type === 'outpass' || report.name.includes('Outpass')) {
      content += `Outpass Statistics\n`;
      content += `Total Outpasses,${analyticsData.totalOutpasses}\n`;
      content += `Active Outpasses,${analyticsData.activeOutpasses}\n`;
      content += `Approval Rate,${analyticsData.totalOutpasses > 0 ? ((analyticsData.activeOutpasses / analyticsData.totalOutpasses) * 100).toFixed(2) : 0}%\n`;
    } else {
      content += `General Statistics\n`;
      content += `Total Students,${analyticsData.totalStudents}\n`;
      content += `Total Rooms,${analyticsData.totalRooms}\n`;
      content += `Total Complaints,${analyticsData.totalComplaints}\n`;
      content += `Total Outpasses,${analyticsData.totalOutpasses}\n`;
    }
    
    return content;
  };

  return (
    <div className="admin-reports-page">
      {/* Page Header */}
      <div className="page-header">
        <div className="header-content">
          <h1 className="page-title">Reports & Analytics</h1>
          <p className="page-subtitle">Overview of hostel operations and activity</p>
        </div>
        <button 
          className="refresh-btn"
          onClick={fetchReportsData}
          disabled={loading}
          style={{
            padding: '10px 20px',
            backgroundColor: '#6366f1',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            cursor: loading ? 'not-allowed' : 'pointer',
            opacity: loading ? 0.6 : 1
          }}
        >
          {loading ? '🔄 Loading...' : '🔄 Refresh Data'}
        </button>
      </div>

      {/* Filters Section */}
      <div className="filters-section">
        <div className="filter-group">
          <label>Date Range</label>
          <select 
            className="filter-select"
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value)}
          >
            <option value="last-7-days">Last 7 Days</option>
            <option value="last-30-days">Last 30 Days</option>
            <option value="last-3-months">Last 3 Months</option>
            <option value="last-6-months">Last 6 Months</option>
            <option value="custom">Custom Range</option>
          </select>
        </div>
        <div className="filter-group">
          <label>Report Type</label>
          <select 
            className="filter-select"
            value={reportType}
            onChange={(e) => setReportType(e.target.value)}
          >
            <option value="all">All Reports</option>
            <option value="occupancy">Occupancy</option>
            <option value="complaints">Complaints</option>
            <option value="outpass">Outpass</option>
            <option value="staff">Staff</option>
          </select>
        </div>
      </div>

      {/* Analytics Summary Cards */}
      <div className="analytics-cards">
        <div className="analytics-card card-blue">
          <div className="card-icon">👥</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.totalStudents}</div>
            <div className="card-label">Total Students</div>
          </div>
        </div>

        <div className="analytics-card card-purple">
          <div className="card-icon">🏠</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.totalRooms}</div>
            <div className="card-label">Total Rooms</div>
          </div>
        </div>

        <div className="analytics-card card-green">
          <div className="card-icon">✅</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.occupiedRooms}</div>
            <div className="card-label">Occupied Rooms</div>
          </div>
        </div>

        <div className="analytics-card card-orange">
          <div className="card-icon">🔓</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.vacantRooms}</div>
            <div className="card-label">Vacant Rooms</div>
          </div>
        </div>

        <div className="analytics-card card-red">
          <div className="card-icon">📋</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.totalComplaints}</div>
            <div className="card-label">Total Complaints</div>
          </div>
        </div>

        <div className="analytics-card card-yellow">
          <div className="card-icon">⏳</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.pendingComplaints}</div>
            <div className="card-label">Pending Complaints</div>
          </div>
        </div>

        <div className="analytics-card card-cyan">
          <div className="card-icon">🎫</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.totalOutpasses}</div>
            <div className="card-label">Total Outpasses</div>
          </div>
        </div>

        <div className="analytics-card card-pink">
          <div className="card-icon">🔄</div>
          <div className="card-content">
            <div className="card-value">{analyticsData.activeOutpasses}</div>
            <div className="card-label">Active Outpasses</div>
          </div>
        </div>
      </div>

      {/* Charts Section */}
      <div className="charts-section">
        {/* Room Occupancy Chart */}
        <div className="chart-container">
          <div className="chart-header">
            <h3>Room Occupancy Trend</h3>
            <span className="chart-subtitle">Last 6 Months</span>
          </div>
          <div className="chart-body">
            <div className="bar-chart">
              {roomOccupancyData.map((item, index) => (
                <div key={index} className="bar-item">
                  <div className="bar-wrapper">
                    <div 
                      className="bar"
                      style={{ height: `${item.occupancy}%` }}
                      title={`${item.occupancy}%`}
                    >
                      <span className="bar-value">{item.occupancy}%</span>
                    </div>
                  </div>
                  <div className="bar-label">{item.month}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Complaints by Category Chart */}
        <div className="chart-container">
          <div className="chart-header">
            <h3>Complaints by Category</h3>
            <span className="chart-subtitle">Current Month</span>
          </div>
          <div className="chart-body">
            <div className="pie-chart-wrapper">
              <div className="pie-chart">
                {complaintsData.map((item, index) => (
                  <div 
                    key={index}
                    className="pie-segment"
                    style={{ 
                      '--segment-color': item.color,
                      '--segment-percent': `${(item.count / 156) * 100}%`
                    }}
                  ></div>
                ))}
              </div>
              <div className="pie-legend">
                {complaintsData.map((item, index) => (
                  <div key={index} className="legend-item">
                    <span 
                      className="legend-color" 
                      style={{ backgroundColor: item.color }}
                    ></span>
                    <span className="legend-label">{item.category}</span>
                    <span className="legend-value">{item.count}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Outpass Requests Chart */}
        <div className="chart-container chart-wide">
          <div className="chart-header">
            <h3>Outpass Requests by Month</h3>
            <span className="chart-subtitle">Last 6 Months</span>
          </div>
          <div className="chart-body">
            <div className="line-chart">
              <div className="chart-grid">
                {[0, 1, 2, 3, 4].map((i) => (
                  <div key={i} className="grid-line"></div>
                ))}
              </div>
              <div className="line-plot">
                {outpassData.map((item, index) => {
                  const height = (item.count / 200) * 100;
                  return (
                    <div key={index} className="plot-point">
                      <div 
                        className="point"
                        style={{ bottom: `${height}%` }}
                        title={`${item.month}: ${item.count}`}
                      >
                        <span className="point-value">{item.count}</span>
                      </div>
                      <div className="point-label">{item.month}</div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Reports Table */}
      <div className="reports-table-section">
        <div className="section-header">
          <h2>Available Reports</h2>
          <button 
            className="btn-primary"
            onClick={handleGenerateReport}
            disabled={generatingReport}
          >
            {generatingReport ? '⏳ Generating...' : '📥 Generate New Report'}
          </button>
        </div>

        <div className="table-container">
          <table className="reports-table">
            <thead>
              <tr>
                <th>Report Name</th>
                <th>Description</th>
                <th>Last Updated</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {reports.map((report) => (
                <tr key={report.id}>
                  <td>
                    <div className="report-name">
                      <span className="report-icon">📊</span>
                      {report.name}
                    </div>
                  </td>
                  <td className="report-description">{report.description}</td>
                  <td>
                    {new Date(report.lastUpdated).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric'
                    })}
                  </td>
                  <td>
                    <span className={`status-badge ${report.status === 'Ready' ? 'badge-ready' : 'badge-processing'}`}>
                      {report.status}
                    </span>
                  </td>
                  <td>
                    <div className="actions-cell">
                      <button 
                        className="btn-action btn-view"
                        onClick={() => handleViewReport(report)}
                        title="View Report"
                      >
                        👁️
                      </button>
                      <button 
                        className="btn-action btn-download"
                        onClick={() => handleDownloadReport(report)}
                        title="Download Report"
                        disabled={report.status !== 'Ready'}
                      >
                        📥
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Report Viewer Modal */}
      {viewingReport && (
        <div className="modal-overlay" onClick={() => setViewingReport(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>{viewingReport.name}</h3>
              <button 
                className="modal-close"
                onClick={() => setViewingReport(null)}
              >
                ✕
              </button>
            </div>
            <div className="modal-body">
              <div className="report-preview">
                <div className="preview-section">
                  <h4>Report Details</h4>
                  <div className="detail-row">
                    <span className="detail-label">Report Name:</span>
                    <span className="detail-value">{viewingReport.name}</span>
                  </div>
                  <div className="detail-row">
                    <span className="detail-label">Description:</span>
                    <span className="detail-value">{viewingReport.description}</span>
                  </div>
                  <div className="detail-row">
                    <span className="detail-label">Last Updated:</span>
                    <span className="detail-value">
                      {new Date(viewingReport.lastUpdated).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric'
                      })}
                    </span>
                  </div>
                  <div className="detail-row">
                    <span className="detail-label">Status:</span>
                    <span className={`status-badge ${viewingReport.status === 'Ready' ? 'badge-ready' : 'badge-processing'}`}>
                      {viewingReport.status}
                    </span>
                  </div>
                </div>

                <div className="preview-section">
                  <h4>Report Content</h4>
                  <div className="content-preview">
                    {viewingReport.type === 'occupancy' || viewingReport.name.includes('Occupancy') ? (
                      <>
                        <div className="stat-row">
                          <span>Total Rooms:</span>
                          <strong>{analyticsData.totalRooms}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Occupied Rooms:</span>
                          <strong>{analyticsData.occupiedRooms}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Vacant Rooms:</span>
                          <strong>{analyticsData.vacantRooms}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Occupancy Rate:</span>
                          <strong>{analyticsData.totalRooms > 0 ? ((analyticsData.occupiedRooms / analyticsData.totalRooms) * 100).toFixed(2) : 0}%</strong>
                        </div>
                      </>
                    ) : viewingReport.type === 'complaints' || viewingReport.name.includes('Complaint') ? (
                      <>
                        <div className="stat-row">
                          <span>Total Complaints:</span>
                          <strong>{analyticsData.totalComplaints}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Pending Complaints:</span>
                          <strong>{analyticsData.pendingComplaints}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Resolved Complaints:</span>
                          <strong>{analyticsData.totalComplaints - analyticsData.pendingComplaints}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Resolution Rate:</span>
                          <strong>{analyticsData.totalComplaints > 0 ? (((analyticsData.totalComplaints - analyticsData.pendingComplaints) / analyticsData.totalComplaints) * 100).toFixed(2) : 0}%</strong>
                        </div>
                      </>
                    ) : viewingReport.type === 'outpass' || viewingReport.name.includes('Outpass') ? (
                      <>
                        <div className="stat-row">
                          <span>Total Outpasses:</span>
                          <strong>{analyticsData.totalOutpasses}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Active Outpasses:</span>
                          <strong>{analyticsData.activeOutpasses}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Completed Outpasses:</span>
                          <strong>{analyticsData.totalOutpasses - analyticsData.activeOutpasses}</strong>
                        </div>
                      </>
                    ) : (
                      <>
                        <div className="stat-row">
                          <span>Total Students:</span>
                          <strong>{analyticsData.totalStudents}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Total Rooms:</span>
                          <strong>{analyticsData.totalRooms}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Total Complaints:</span>
                          <strong>{analyticsData.totalComplaints}</strong>
                        </div>
                        <div className="stat-row">
                          <span>Total Outpasses:</span>
                          <strong>{analyticsData.totalOutpasses}</strong>
                        </div>
                      </>
                    )}
                  </div>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button 
                className="btn-secondary"
                onClick={() => setViewingReport(null)}
              >
                Close
              </button>
              <button 
                className="btn-primary"
                onClick={() => {
                  handleDownloadReport(viewingReport);
                  setViewingReport(null);
                }}
              >
                📥 Download Report
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminReports;

