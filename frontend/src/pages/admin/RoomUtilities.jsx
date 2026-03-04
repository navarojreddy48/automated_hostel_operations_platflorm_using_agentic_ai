import { useState } from 'react';
import '../../styles/admin-room-utilities.css';

const RoomUtilities = () => {
  const [loading, setLoading] = useState(false);
  const [verifyResult, setVerifyResult] = useState(null);
  const [recalculateResult, setRecalculateResult] = useState(null);

  const handleVerifyOccupancy = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:5000/api/admin/rooms/verify-occupancy');
      const data = await response.json();
      setVerifyResult(data);
    } catch (error) {
      console.error('Error verifying occupancy:', error);
      alert('Failed to verify occupancy');
    } finally {
      setLoading(false);
    }
  };

  const handleRecalculateOccupancy = async () => {
    if (!confirm('This will recalculate occupancy counts for all rooms. Continue?')) {
      return;
    }
    
    setLoading(true);
    try {
      const response = await fetch('http://localhost:5000/api/admin/rooms/recalculate-occupancy', {
        method: 'POST'
      });
      const data = await response.json();
      if (data.success) {
        setRecalculateResult(data);
        alert(data.message);
        // Re-verify after recalculation
        handleVerifyOccupancy();
      } else {
        alert('Failed: ' + data.message);
      }
    } catch (error) {
      console.error('Error recalculating occupancy:', error);
      alert('Failed to recalculate occupancy');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="room-utilities-container">
      <header className="utilities-header">
        <h1>Room Utilities</h1>
        <p>Administrative tools for room management</p>
      </header>

      <div className="utilities-grid">
        {/* Verify Occupancy Card */}
        <div className="utility-card">
          <div className="card-icon">🔍</div>
          <h2>Verify Occupancy</h2>
          <p>Check if room occupancy counts match actual student assignments</p>
          <button 
            className="btn-primary"
            onClick={handleVerifyOccupancy}
            disabled={loading}
          >
            {loading ? 'Verifying...' : 'Verify Now'}
          </button>

          {verifyResult && (
            <div className={`result-box ${verifyResult.has_issues ? 'warning' : 'success'}`}>
              {verifyResult.has_issues ? (
                <>
                  <h3>⚠️ Issues Found</h3>
                  <p>{verifyResult.discrepancies.length} rooms have incorrect occupancy counts</p>
                  <div className="discrepancies-list">
                    {verifyResult.discrepancies.map((disc, idx) => (
                      <div key={idx} className="discrepancy-item">
                        <strong>Room {disc.room_number}</strong> in {disc.block_name}
                        <br />
                        Stored: {disc.stored_count} | Actual: {disc.actual_count} | Capacity: {disc.capacity}
                      </div>
                    ))}
                  </div>
                </>
              ) : (
                <>
                  <h3>✅ All Clear</h3>
                  <p>All room occupancy counts are correct</p>
                </>
              )}
            </div>
          )}
        </div>

        {/* Recalculate Occupancy Card */}
        <div className="utility-card">
          <div className="card-icon">🔄</div>
          <h2>Recalculate Occupancy</h2>
          <p>Fix all room occupancy counts by counting actual student assignments</p>
          <button 
            className="btn-warning"
            onClick={handleRecalculateOccupancy}
            disabled={loading}
          >
            {loading ? 'Processing...' : 'Recalculate All'}
          </button>

          {recalculateResult && (
            <div className="result-box success">
              <h3>✅ Done</h3>
              <p>{recalculateResult.message}</p>
            </div>
          )}
        </div>
      </div>

      <div className="info-section">
        <h3>💡 When to Use These Tools</h3>
        <ul>
          <li><strong>Verify Occupancy:</strong> Run regularly to check for data inconsistencies</li>
          <li><strong>Recalculate Occupancy:</strong> Use when you notice incorrect room capacities displayed</li>
          <li>These tools automatically run on server startup to ensure data integrity</li>
        </ul>
      </div>
    </div>
  );
};

export default RoomUtilities;

