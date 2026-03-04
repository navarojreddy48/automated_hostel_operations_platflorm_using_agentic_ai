# Outpass Grace Period & Email Notification Implementation

## Overview
Automated outpass monitoring system with dynamic grace periods and one-time email notifications to students and parents.

## Grace Period Rules ✅

### Same-Day Outpass
- **Grace Period**: 3 hours (180 minutes)
- **Criteria**: `out_date` equals return date
- **Example**: Leave at 2:00 PM, return expected at 6:00 PM → Alert sent at 9:00 PM if not returned

### Multi-Day Outpass
- **Grace Period**: 2 days (2880 minutes)
- **Criteria**: `out_date` differs from return date
- **Example**: Leave on Monday, return expected Wednesday 5:00 PM → Alert sent Friday 5:00 PM if not returned

## Email Notification Rules ✅

### Student Email
- **Trigger**: When outpass becomes overdue (after grace period expires)
- **Frequency**: **Once only** (tracked by `overdue_alert_sent_student` flag)
- **Content**: Outpass ID, expected return time, delay minutes, risk level

### Parent Email
- **Trigger**: When outpass becomes overdue (after grace period expires)
- **Frequency**: **Once only** (tracked by `overdue_alert_sent_parent` flag)
- **Content**: Student name, outpass ID, expected return time, delay minutes, risk level

## Database Schema

### Migration File
`backend/migrations/2026_02_17_add_outpass_agentic_monitoring.sql`

### New Columns Added to `outpasses` Table
```sql
monitor_state ENUM('on_time', 'grace_period', 'overdue') DEFAULT 'on_time'
risk_level ENUM('low', 'medium', 'high') DEFAULT 'low'
overdue_alert_sent_student TINYINT(1) DEFAULT 0  -- Prevents duplicate student emails
overdue_alert_sent_parent TINYINT(1) DEFAULT 0   -- Prevents duplicate parent emails
overdue_notified_at DATETIME NULL                 -- Timestamp of first notification
```

## Implementation Details

### Core Function: `get_monitor_state()`
**Location**: `backend/app.py` lines 220-253

**Logic**:
```python
def get_monitor_state(expected_return_time, now_time, out_date=None):
    # Determine if same-day or multi-day
    if out_date and expected_return_time:
        return_date = expected_return_time.date()
        out_date_obj = out_date.date()
        
        if return_date == out_date_obj:
            grace_minutes = 180      # Same-day: 3 hours
        else:
            grace_minutes = 2880     # Multi-day: 2 days
    
    # Return 'grace_period' or 'overdue' based on late_minutes
    if late_minutes <= grace_minutes:
        return 'grace_period', late_minutes
    return 'overdue', late_minutes
```

### Monitoring Cycle: `process_outpass_monitoring_cycle()`
**Location**: `backend/app.py` lines 285-389

**Process**:
1. Query all active outpasses (status = 'exited' or 'overdue', not returned)
2. For each outpass:
   - Calculate monitor state using `get_monitor_state()` with `out_date`
   - If state = 'overdue':
     - Check `overdue_alert_sent_student` flag
     - If 0, send email to student and set flag to 1
     - Check `overdue_alert_sent_parent` flag
     - If 0, send email to parent and set flag to 1
   - Update database with new monitor state and flags
3. Sleep for 60 seconds (configurable via `OUTPASS_MONITOR_INTERVAL_SECONDS`)

### Background Worker
**Function**: `outpass_monitor_worker()`
**Location**: `backend/app.py` lines 391-399
**Behavior**: Runs continuously in daemon thread, executes monitoring cycle every 60 seconds

## Email Templates

### Student Email Subject
`⚠️ Outpass Overdue Alert - OP-{outpass_id}`

### Parent Email Subject
`⚠️ Parent Alert: Delayed Return for {student_name}`

### Email Content Includes
- Expected return time
- Current delay in minutes
- Risk level (low/medium/high)
- Contact instructions for warden office

## Verification Status

✅ **Grace Period Logic**: Correctly differentiates same-day (3hr) vs multi-day (2 days)  
✅ **Student Email Once**: Protected by `overdue_alert_sent_student` flag  
✅ **Parent Email Once**: Protected by `overdue_alert_sent_parent` flag  
✅ **Database Migration**: Columns already exist in live database  
✅ **Syntax Errors**: None - code validated successfully  
✅ **Background Monitoring**: Auto-starts with Flask app  

## Testing Notes

To test the system:
1. Create a test outpass with a past expected return time
2. Wait for monitoring cycle (60 seconds)
3. Verify emails sent to student and parent
4. Confirm no duplicate emails sent in subsequent cycles
5. Check database flags: `overdue_alert_sent_student = 1`, `overdue_alert_sent_parent = 1`

## Configuration

Current settings in `backend/app.py`:
```python
OUTPASS_MONITOR_INTERVAL_SECONDS = 60   # Check every 60 seconds
OUTPASS_GRACE_MINUTES = 30              # Fallback (not used with new logic)
```

The grace period is now calculated dynamically based on `out_date` vs return date.
