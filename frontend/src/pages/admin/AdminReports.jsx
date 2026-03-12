import React, { useState, useEffect } from 'react';
import { jsPDF } from 'jspdf';
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
        name: `${selectedType} - ${new Date().toLocaleDateString('en-GB')}`,
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

  const getReportConfig = (report) => {
    const reportName = (report?.name || '').toLowerCase();
    const reportType = (report?.type || '').toLowerCase();

    if (reportType === 'occupancy' || reportName.includes('occupancy')) {
      const totalRooms = analyticsData.totalRooms || 0;
      const occupiedRooms = analyticsData.occupiedRooms || 0;
      const vacantRooms = analyticsData.vacantRooms || 0;
      const occupancyRate = totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0;

      return {
        sectionTitle: 'Room Occupancy Data',
        rows: [
          { label: 'Total Rooms', value: totalRooms.toString(), indicator: 'building' },
          { label: 'Occupied Rooms', value: occupiedRooms.toString(), indicator: 'success' },
          { label: 'Vacant Rooms', value: vacantRooms.toString(), indicator: 'warning' },
          { label: 'Occupancy Rate', value: `${occupancyRate.toFixed(2)}%`, indicator: 'rate' }
        ],
        progress: {
          title: 'Occupancy Progress',
          value: occupancyRate,
          display: `${occupancyRate.toFixed(2)}%`,
          color: [37, 99, 235]
        }
      };
    }

    if (reportType === 'complaints' || reportName.includes('complaint')) {
      const totalComplaints = analyticsData.totalComplaints || 0;
      const pendingComplaints = analyticsData.pendingComplaints || 0;
      const resolvedComplaints = Math.max(0, totalComplaints - pendingComplaints);
      const resolutionRate = totalComplaints > 0 ? (resolvedComplaints / totalComplaints) * 100 : 0;

      return {
        sectionTitle: 'Complaint Statistics',
        rows: [
          { label: 'Total Complaints', value: totalComplaints.toString(), indicator: 'info' },
          { label: 'Pending Complaints', value: pendingComplaints.toString(), indicator: 'warning' },
          { label: 'Resolved Complaints', value: resolvedComplaints.toString(), indicator: 'success' },
          { label: 'Resolution Rate', value: `${resolutionRate.toFixed(2)}%`, indicator: 'rate' }
        ],
        progress: {
          title: 'Resolution Progress',
          value: resolutionRate,
          display: `${resolutionRate.toFixed(2)}%`,
          color: [22, 163, 74]
        }
      };
    }

    if (reportType === 'outpass' || reportName.includes('outpass')) {
      const totalOutpasses = analyticsData.totalOutpasses || 0;
      const activeOutpasses = analyticsData.activeOutpasses || 0;
      const completedOutpasses = Math.max(0, totalOutpasses - activeOutpasses);
      const completionRate = totalOutpasses > 0 ? (completedOutpasses / totalOutpasses) * 100 : 0;

      return {
        sectionTitle: 'Outpass Statistics',
        rows: [
          { label: 'Total Outpasses', value: totalOutpasses.toString(), indicator: 'info' },
          { label: 'Active Outpasses', value: activeOutpasses.toString(), indicator: 'warning' },
          { label: 'Completed Outpasses', value: completedOutpasses.toString(), indicator: 'success' },
          { label: 'Completion Rate', value: `${completionRate.toFixed(2)}%`, indicator: 'rate' }
        ],
        progress: {
          title: 'Outpass Completion Progress',
          value: completionRate,
          display: `${completionRate.toFixed(2)}%`,
          color: [14, 165, 233]
        }
      };
    }

    const totalStudents = analyticsData.totalStudents || 0;
    const totalRooms = analyticsData.totalRooms || 0;
    const occupancyRate = totalRooms > 0 ? ((analyticsData.occupiedRooms || 0) / totalRooms) * 100 : 0;

    return {
      sectionTitle: 'General Statistics',
      rows: [
        { label: 'Total Students', value: totalStudents.toString(), indicator: 'info' },
        { label: 'Total Rooms', value: totalRooms.toString(), indicator: 'building' },
        { label: 'Total Complaints', value: (analyticsData.totalComplaints || 0).toString(), indicator: 'warning' },
        { label: 'Total Outpasses', value: (analyticsData.totalOutpasses || 0).toString(), indicator: 'rate' }
      ],
      progress: {
        title: 'Occupancy Overview',
        value: occupancyRate,
        display: `${occupancyRate.toFixed(2)}%`,
        color: [99, 102, 241]
      }
    };
  };

  const handleDownloadReport = (report) => {
    const pdf = new jsPDF({ unit: 'pt', format: 'a4' });
    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();
    const marginX = 42;
    const contentWidth = pageWidth - marginX * 2;

    const reportConfig = getReportConfig(report);
    const generatedAt = new Date().toLocaleString();

    const drawBuildingIcon = (x, y) => {
      pdf.setDrawColor(37, 99, 235);
      pdf.setFillColor(219, 234, 254);
      pdf.rect(x, y - 9, 10, 10, 'FD');
      pdf.rect(x + 3, y - 13, 4, 4, 'FD');
      pdf.line(x + 2, y - 6, x + 8, y - 6);
      pdf.line(x + 2, y - 3, x + 8, y - 3);
    };

    const drawIndicator = (x, y, color) => {
      pdf.setFillColor(color[0], color[1], color[2]);
      pdf.circle(x + 5, y - 4, 4, 'F');
    };

    const getIndicatorColor = (indicatorType) => {
      if (indicatorType === 'success') return [22, 163, 74];
      if (indicatorType === 'warning') return [249, 115, 22];
      if (indicatorType === 'info') return [37, 99, 235];
      return [59, 130, 246];
    };

    // Light report background panel
    pdf.setFillColor(248, 250, 252);
    pdf.roundedRect(marginX - 8, 92, contentWidth + 16, pageHeight - 175, 10, 10, 'F');

    // Header section
    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(22);
    pdf.setTextColor(17, 24, 39);
    pdf.text(report?.name || 'Monthly Occupancy Report', marginX, 56);

    pdf.setFont('helvetica', 'normal');
    pdf.setFontSize(11);
    pdf.setTextColor(71, 85, 105);
    pdf.text('Hostel Management System', marginX, 74);

    pdf.setFontSize(10);
    pdf.setTextColor(51, 65, 85);
    pdf.text(`Generated: ${generatedAt}`, pageWidth - marginX, 58, { align: 'right' });

    pdf.setDrawColor(203, 213, 225);
    pdf.setLineWidth(1);
    pdf.line(marginX, 84, pageWidth - marginX, 84);

    // Summary card section
    const cardX = marginX + 18;
    const cardY = 122;
    const cardWidth = contentWidth - 36;
    const headerHeight = 38;
    const rowHeight = 34;
    const rows = reportConfig.rows;
    const cardHeight = headerHeight + rows.length * rowHeight + 22;

    pdf.setFillColor(255, 255, 255);
    pdf.setDrawColor(203, 213, 225);
    pdf.setLineWidth(1);
    pdf.roundedRect(cardX, cardY, cardWidth, cardHeight, 12, 12, 'FD');

    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(14);
    pdf.setTextColor(15, 23, 42);
    pdf.text(reportConfig.sectionTitle, cardX + 18, cardY + 24);

    const tableTop = cardY + headerHeight;
    pdf.setDrawColor(226, 232, 240);
    pdf.line(cardX + 14, tableTop, cardX + cardWidth - 14, tableTop);

    let rowY = tableTop + 23;
    rows.forEach((row, index) => {
      if (row.indicator === 'building') {
        drawBuildingIcon(cardX + 20, rowY);
      } else if (row.indicator === 'rate') {
        pdf.setDrawColor(59, 130, 246);
        pdf.setLineWidth(1.2);
        pdf.circle(cardX + 25, rowY - 4, 4);
      } else {
        drawIndicator(cardX + 20, rowY, getIndicatorColor(row.indicator));
      }

      pdf.setFont('helvetica', 'bold');
      pdf.setFontSize(11);
      pdf.setTextColor(30, 41, 59);
      pdf.text(row.label, cardX + 36, rowY);

      pdf.setFont('helvetica', 'normal');
      pdf.setFontSize(11);
      pdf.setTextColor(15, 23, 42);
      pdf.text(row.value, cardX + cardWidth - 20, rowY, { align: 'right' });

      if (index < rows.length - 1) {
        pdf.setDrawColor(241, 245, 249);
        pdf.line(cardX + 14, rowY + 10, cardX + cardWidth - 14, rowY + 10);
      }

      rowY += rowHeight;
    });

    // Occupancy progress bar
    const progressTitleY = cardY + cardHeight + 34;
    const progressX = cardX;
    const progressY = progressTitleY + 14;
    const progressWidth = cardWidth;
    const progressHeight = 14;
    const fillWidth = Math.max(0, Math.min(progressWidth, (reportConfig.progress.value / 100) * progressWidth));

    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(12);
    pdf.setTextColor(30, 41, 59);
    pdf.text(reportConfig.progress.title, progressX, progressTitleY);

    pdf.setFillColor(226, 232, 240);
    pdf.roundedRect(progressX, progressY, progressWidth, progressHeight, 7, 7, 'F');
    pdf.setFillColor(reportConfig.progress.color[0], reportConfig.progress.color[1], reportConfig.progress.color[2]);
    pdf.roundedRect(progressX, progressY, fillWidth, progressHeight, 7, 7, 'F');

    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(10);
    pdf.setTextColor(15, 23, 42);
    pdf.text(reportConfig.progress.display, progressX + progressWidth, progressY + 11, { align: 'right' });

    // Footer section
    const footerLineY = pageHeight - 54;
    pdf.setDrawColor(203, 213, 225);
    pdf.line(marginX, footerLineY, pageWidth - marginX, footerLineY);

    pdf.setFont('helvetica', 'normal');
    pdf.setFontSize(9);
    pdf.setTextColor(71, 85, 105);
    pdf.text('Generated by HostelConnect - Automated Hostel Operations Platform', pageWidth / 2, footerLineY + 16, { align: 'center' });
    pdf.text('Page 1', pageWidth / 2, footerLineY + 30, { align: 'center' });

    const safeFileName = (report?.name || 'Monthly Occupancy Report').replace(/[^a-zA-Z0-9]+/g, '_').replace(/^_|_$/g, '');
    pdf.save(`${safeFileName || 'report'}_${new Date().getTime()}.pdf`);
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
                    {new Date(report.lastUpdated).toLocaleDateString('en-GB', {
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
                      {new Date(viewingReport.lastUpdated).toLocaleDateString('en-GB', {
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


