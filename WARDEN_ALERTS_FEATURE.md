# Warden Alerts Feature - Implementation Guide

## Overview
Wardens can now view all generated overdue alerts in a dedicated "Alerts" tab, showing which outpasses triggered automatic email notifications to students and parents.

## Features Implemented

### 1. Backend API Endpoints

#### **New Endpoint: `/api/warden/outpasses/alerts`**
- **Method**: GET
- **Purpose**: Fetch all outpasses that have generated overdue alerts
- **Filters**: Only outpasses with `overdue_alert_sent_student = 1` OR `overdue_alert_sent_parent = 1`
- **Status**: Shows both 'overdue' and 'returned' outpasses (to see historical alerts)
- **Limit**: Last 100 alerts
- **Sort**: Most recent alerts first (by `overdue_notified_at`)

**Response Data Includes**:
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "student_name": "John Doe",
      "roll_number": "CS21001",
      "room_number": "A-101",
      "block_name": "Block A",
      "status": "overdue",
      "monitor_state": "overdue",
      "late_minutes": 250,
      "alert_to_student": true,
      "alert_to_parent": true,
      "alert_sent_at": "2026-02-17 15:30:00",
      "expected_return_time": "2026-02-17 10:00:00",
      "out_date": "2026-02-17",
      "destination": "Home",
      "reason": "Family emergency"
    }
  ],
  "count": 15
}
```

#### **Updated Endpoint: `/api/warden/outpasses/approved`**
- Now includes statuses: 'approved', 'exited', 'overdue', 'returned'
- Sorts by urgency: overdue → exited → approved → returned
- Adds alert status flags:
  - `has_alert`: Boolean indicating if any alert was sent
  - `alert_sent_at`: Timestamp of when alert was generated

### 2. Frontend UI Updates

#### **New "Alerts" Tab**
Located in: `frontend/src/pages/warden/WardenOutpass.jsx`

**Features**:
- 🚨 Red badge showing alert count when > 0
- Dedicated view for all generated alerts
- Alert banner explaining the view
- Visual indicators for:
  - Which emails were sent (student/parent)
  - When alerts were generated
  - Current delay in minutes
  - Monitor state (overdue/grace period/on time)

#### **Updated Approved Tab**
- Shows yellow warning banner if an outpass has generated an alert
- Displays alert timestamp
- Indicates the outpass has overdue notifications

#### **Alert Information Display**

**In Alerts Tab**:
```
🚨 Alert Generated
✅ Student email sent · ✅ Parent email sent
Alert time: 2/17/2026, 3:30:00 PM · Delay: 250 minutes
```

**In Other Tabs (when `has_alert` is true)**:
```
⚠️ Alert Sent
Overdue alerts have been sent for this outpass on 2/17/2026, 3:30:00 PM
```

### 3. Filter Buttons Layout

```
[All] [Pending] [Approved] [🚨 Alerts (5)] [Rejected]
                              ↑
                         Red badge when alerts exist
```

### 4. Visual Design

**Alert Card Colors**:
- **Alert banner**: Red background (`#fee2e2` with `#fca5a5` border)
- **Warning banner**: Yellow background (`#fef3c7` with `#fcd34d` border)
- **Alert button**: Red when alerts exist, default otherwise

**Status Tags**:
- 'overdue' → Red tag
- 'grace_period' → Yellow tag  
- 'on_time' → Green tag
- 'exited' → Blue tag
- 'returned' → Gray tag

### 5. Data Flow

```
┌─────────────────────────────────────────────────┐
│  Background Monitor (every 60s)                 │
│  Checks active outpasses                        │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│  Grace Period Calculation                       │
│  - Same-day: 3 hours                           │
│  - Multi-day: 2 days                           │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│  Monitor State = 'overdue'?                     │
└───────────────┬─────────────────────────────────┘
                │ YES
                ▼
┌─────────────────────────────────────────────────┐
│  Send Emails (if not already sent)              │
│  - overdue_alert_sent_student = 1              │
│  - overdue_alert_sent_parent = 1               │
│  - overdue_notified_at = NOW()                 │
└───────────────┬─────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────┐
│  Warden Views Alert in "Alerts" Tab             │
│  - See who was notified                         │
│  - See when alerts were sent                    │
│  - See current delay status                     │
└─────────────────────────────────────────────────┘
```

### 6. Usage Instructions for Wardens

1. **View All Alerts**:
   - Click the "🚨 Alerts" button in the filter bar
   - See all outpasses that triggered overdue alerts
   - Red badge shows total alert count

2. **Alert Details Show**:
   - Student name, roll number, room
   - Which notifications were sent (student/parent)
   - Exact time alert was generated
   - Current delay in minutes
   - Expected return time
   - Destination and reason

3. **Monitor Active Overdue Cases**:
   - Alerts tab combines both:
     - Currently overdue outpasses
     - Recently returned but previously overdue

4. **Check Historical Alerts**:
   - Last 100 alerts are available
   - Can see when student eventually returned

### 7. Database Fields Used

```sql
monitor_state            -- Current state: on_time, grace_period, overdue
risk_level              -- Student risk: low, medium, high
overdue_alert_sent_student -- Flag: email sent to student
overdue_alert_sent_parent  -- Flag: email sent to parent
overdue_notified_at        -- Timestamp: when alert was first generated
late_minutes               -- Current delay in minutes
```

### 8. Testing the Feature

**To test alerts generation**:
1. Create an outpass with past expected return time
2. Approve it and mark as "exited" (if using security role)
3. Wait 60 seconds for monitor cycle
4. Check warden's "Alerts" tab
5. Verify alert information is displayed

**To simulate manual test**:
```sql
-- Force generate alerts for testing
UPDATE outpasses 
SET 
  monitor_state = 'overdue',
  overdue_alert_sent_student = 1,
  overdue_alert_sent_parent = 1,
  overdue_notified_at = NOW(),
  late_minutes = 180,
  status = 'overdue'
WHERE id = YOUR_TEST_OUTPASS_ID;
```

### 9. Key Benefits

✅ **Transparency**: Wardens see exactly which alerts were sent  
✅ **Tracking**: Complete audit trail of overdue notifications  
✅ **Proactive**: Easily identify students who need follow-up  
✅ **Real-time**: Updated every 60 seconds automatically  
✅ **Historical**: View up to last 100 alerts for record-keeping  

### 10. Related Files Modified

**Backend**:
- `backend/app.py` (lines 916-1020):
  - Updated `get_approved_outpasses()` to include alert status
  - Added new `get_warden_outpass_alerts()` endpoint

**Frontend**:
- `frontend/src/pages/warden/WardenOutpass.jsx`:
  - Added alerts state and fetching
  - Added "Alerts" filter button with badge
  - Added alert information display in cards
  - Updated filtered requests logic

### 11. Configuration

**Monitor Settings** (in `backend/app.py`):
```python
OUTPASS_MONITOR_INTERVAL_SECONDS = 60  # Check every 60 seconds
```

**Grace Periods** (dynamic in code):
- Same-day: 180 minutes (3 hours)
- Multi-day: 2880 minutes (2 days)

---

## Quick Reference

| Feature | Endpoint | Purpose |
|---------|----------|---------|
| View Alerts | `GET /api/warden/outpasses/alerts` | Get all generated alerts |
| Approved Outpasses | `GET /api/warden/outpasses/approved` | Includes alert status flags |
| Alert Count Badge | UI: Alerts button | Shows number of active alerts |
| Alert Details | UI: Alert card | Full notification history |

---

**Implementation Date**: February 17, 2026  
**Status**: ✅ Complete and Ready for Production
