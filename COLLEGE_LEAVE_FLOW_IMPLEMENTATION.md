# 🔁 College Leave (Not Attending College) Flow – HostelConnect

## Overview
Complete implementation of the College Leave request flow allowing students to skip college while staying in the hostel, with warden approval, email notifications, and Agentic AI monitoring for high-frequency patterns.

---

## 1️⃣ Student Raises College Leave Request

### Frontend: `frontend/src/pages/student/StudentLeave.jsx`

**Features:**
- ✅ Leave type selection (Medical, Personal, Family Emergency, Vacation, Other)
- ✅ Date range picker (From Date → To Date)
- ✅ Reason/description text area
- ✅ Interactive calendar showing approved leave days
- ✅ Request history with status tracking
- ✅ Real-time data fetching from API

**Form Fields:**
```jsx
{
  leaveType: 'medical' | 'personal' | 'family_emergency' | 'vacation' | 'other',
  fromDate: 'YYYY-MM-DD',
  toDate: 'YYYY-MM-DD',
  reason: 'Detailed reason for leave'
}
```

**API Endpoint:**
```
POST /api/student/leave
{
  student_id: userId,
  leave_type: string,
  from_date: 'YYYY-MM-DD',
  to_date: 'YYYY-MM-DD',
  reason: string
}
```

**Response:**
```json
{
  "success": true,
  "id": 123,
  "message": "Leave request submitted"
}
```

**Initial Status:** `pending`

---

## 2️⃣ Warden Receives Leave Request

### Frontend: `frontend/src/pages/warden/WardenLeave.jsx`

**Dashboard Features:**
- 📋 Displays all pending leave requests
- 👤 Shows student profile (Name, Roll Number, Room, Block)
- 📜 Click "View Previous Leaves" to see:
  - Total leave history (all-time)
  - Last 30 days breakdown
  - Leave frequency patterns
- 📊 Leave request cards with detailed information:
  - Leave Type
  - Date Range (From → To)
  - Total Days
  - Request Date
  - Full Reason (expandable)

**API Endpoint:**
```
GET /api/warden/leaves/pending
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "student_name": "John Doe",
      "roll_number": "21R21A6701",
      "room_number": "301",
      "block_name": "A",
      "leave_type": "medical",
      "from_date": "2026-02-10",
      "to_date": "2026-02-12",
      "total_days": 3,
      "leave_reason": "Medical checkup",
      "status": "pending",
      "created_at": "2026-02-08T10:30:00"
    }
  ]
}
```

---

## 3️⃣ Warden Decision

### Approval Flow

**Warden Action:**
1. Click "✅ Approve" button
2. Optional: Add a remark/note for the student
3. Click "Confirm"

**API Endpoint:**
```
POST /api/warden/leave/<leave_id>/approve
{
  approved_by: wardenUserId,
  remark: "Optional note for student" (optional)
}
```

**Backend Actions:**
- ✅ Update leave status to `approved`
- ✅ Set `approved_by` to warden ID
- ✅ Set `approved_at` timestamp
- 📧 Send approval email to student (see Email Template below)

---

### Rejection Flow

**Warden Action:**
1. Click "❌ Reject" button
2. Required: Enter rejection reason
3. Click "Confirm"

**API Endpoint:**
```
POST /api/warden/leave/<leave_id>/reject
{
  approved_by: wardenUserId,
  rejection_reason: "Required reason for rejection"
}
```

**Backend Actions:**
- ✅ Update leave status to `rejected`
- ✅ Set `approved_by` to warden ID
- ✅ Set `approved_at` timestamp
- ✅ Store `rejection_reason`
- 📧 Send rejection email to student (see Email Template below)

---

## 4️⃣ Approved Leave Processing

### Status Change
When approved:
- Leave status: `pending` → `approved`
- Student marked as: "In Hostel – Not Attending College" (visible to security staff)
- Period: From Date → To Date
- Database field: `status = 'approved'`

### Student Dashboard Updates
- Calendar shows approved leave days (green highlight)
- Request history displays "APPROVED" badge
- Students can view all their approved leaves

### Security Staff Dashboard
- Approved leaves visible in security outpass/attendance section
- Student name appears in "Not Attending College" list during approved period
- No outpass needed during approved leave period (already in hostel)

---

## 5️⃣ Email Notifications

### Approval Email Template

**Subject:** ✅ Your Leave Request Has Been Approved

**Features:**
- 🎨 Green gradient header
- ✓ Status confirmation
- 📋 Detailed leave information:
  - Leave Type
  - From Date
  - To Date
  - Total Days
- ⚠️ Important reminders:
  - Ensure security staff is aware
  - Update mentor/faculty
  - Inform mess for meal adjustments
  - Stay on hostel premises
- 📝 Warden's remark (if provided)
- 📧 Professional footer

**Sent to:** Student email from database

---

### Rejection Email Template

**Subject:** ❌ Your Leave Request Has Been Rejected

**Features:**
- 🎨 Red gradient header
- ✗ Status confirmation
- 📋 Leave request details
- 📝 Rejection reason from warden
- ℹ️ Next steps:
  - Contact warden office
  - Submit revised request if applicable
  - Provide supporting documents
  - Appeal for reconsideration

**Sent to:** Student email from database

---

## 6️⃣ Absenteeism Tracking

### Database Query

**Endpoint:** `GET /api/warden/leave-history/<roll_number>`

**Query Details:**
```sql
SELECT lr.*, au.name as approved_by_name
FROM leave_requests lr
JOIN students s ON lr.student_id = s.id
LEFT JOIN users au ON lr.approved_by = au.id
WHERE s.roll_number = ?
  AND lr.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY lr.created_at DESC
```

**Tracked Metrics:**
- Total leave requests (last 30 days)
- Approved requests count
- Pending requests count
- Rejected requests count
- Total leave days used
- Leave frequency pattern
- Leave types distribution

**Data Visibility:**
- Warden can view in "View Previous Leaves" modal
- Shows historical pattern and recent activity
- Helps identify repeated requests

---

## 7️⃣ Agentic AI Monitoring (Background)

### Leave Frequency Alert System

**Endpoint:** `GET /api/warden/leave-alerts`

**Alert Triggers:**

1. **High Frequency Alert (Risk Level: HIGH)**
   - Threshold: 5+ approved leaves in 30 days
   - AI Suggestion: "⚠️ Very high frequency - Consider counseling session"

2. **Extended Leave Alert (Risk Level: MEDIUM)**
   - Threshold: 15+ total leave days in 30 days
   - AI Suggestion: "📅 Extended total leave days - Monitor health/wellness"

3. **Pending Request Pattern**
   - Threshold: 2+ pending requests
   - AI Suggestion: "⏳ Has pending requests - May indicate patterns"

4. **Repeated Rejection**
   - Threshold: 2+ rejected requests
   - AI Suggestion: "❌ Multiple rejections - May need support"

### Response Format

```json
{
  "success": true,
  "alert_count": 5,
  "data": [
    {
      "id": 7,
      "roll_number": "21R21A6701",
      "student_name": "John Doe",
      "student_email": "john@college.edu",
      "approved_count": 5,
      "pending_count": 1,
      "rejected_count": 0,
      "total_leave_days": 18,
      "last_leave_date": "2026-02-08",
      "recent_leaves": "medical (3d), personal (4d), vacation (5d), family_emergency (3d), other (3d)",
      "risk_level": "high",
      "ai_suggestions": [
        "⚠️ Very high frequency - Consider counseling session",
        "📅 Extended total leave days - Monitor health/wellness"
      ]
    }
  ]
}
```

### Warden Actions Based on Alerts

**Suggested Actions:**
1. **Counseling Session:** Meet student to understand reasons
2. **Health Check:** Verify medical documentation for sick leaves
3. **Academic Review:** Check with faculty about attendance
4. **Support Services:** Offer hostel counseling or wellness programs
5. **Family Contact:** For emergency leaves, consider contacting parents
6. **Documentation:** Request supporting documents for suspicious patterns

---

## Database Schema

### leave_requests Table

```sql
CREATE TABLE leave_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  leave_type ENUM('medical', 'personal', 'family_emergency', 'vacation', 'other') NOT NULL,
  leave_reason TEXT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  total_days INT NOT NULL,
  status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',
  approved_by INT,
  approved_at TIMESTAMP NULL,
  rejection_reason TEXT,
  supporting_documents VARCHAR(255),
  emergency_contact VARCHAR(20),
  destination VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_student_id (student_id),
  INDEX idx_status (status),
  INDEX idx_from_date (from_date),
  INDEX idx_leave_type (leave_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## API Endpoints Summary

### Student Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/student/leaves/<user_id>` | Get all leaves for student |
| POST | `/api/student/leave` | Submit new leave request |

### Warden Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/warden/leaves/pending` | Get all pending leave requests |
| POST | `/api/warden/leave/<leave_id>/approve` | Approve a leave request |
| POST | `/api/warden/leave/<leave_id>/reject` | Reject a leave request |
| GET | `/api/warden/leave-history/<roll_number>` | Get leave history for a student |
| GET | `/api/warden/leave-alerts` | Get high-frequency leave alerts (AI) |

---

## Implementation Files

### Frontend
- `frontend/src/pages/student/Leave.jsx` - Routes to StudentLeave
- `frontend/src/pages/student/StudentLeave.jsx` - Full leave request interface
- `frontend/src/pages/warden/WardenLeave.jsx` - Warden approval interface
- `frontend/src/styles/student-leave.css` - Styling (calendar, forms)

### Backend
- `backend/app.py`
  - `create_leave()` - POST student leave
  - `get_student_leaves()` - GET student leaves
  - `get_pending_leaves()` - GET pending for warden
  - `approve_leave()` - Approve with email
  - `reject_leave()` - Reject with email
  - `get_leave_history()` - History for warden
  - `get_leave_alerts()` - AI alerts for monitoring
  - `send_leave_approval_email()` - Approval email template
  - `send_leave_rejection_email()` - Rejection email template

### Database
- `backend/database_schema.sql`
  - `leave_requests` table with all required fields

---

## Status Lifecycle

```
┌─────────────┐
│   PENDING   │ ← Student submits request
└──────┬──────┘
       │
       ├─→ APPROVED (✅ Warden approves)
       │   └─→ [EMAIL SENT]
       │   └─→ Student marked "Not Attending College"
       │   └─→ Period is active
       │
       └─→ REJECTED (❌ Warden rejects)
           └─→ [EMAIL SENT]
           └─→ Student notified of reason
           └─→ Can resubmit if desired
```

---

## Security Considerations

1. **Authentication:** Only logged-in students can submit leaves
2. **Authorization:** Only wardens can approve/reject leaves
3. **Data Validation:** Date ranges validated on frontend & backend
4. **Email Verification:** Email sent only if address exists in database
5. **Audit Trail:** All approvals/rejections logged with timestamp & approver ID
6. **Role-Based Access:** Student and warden views completely separated

---

## Testing Checklist

- [ ] Student can submit leave request with all types
- [ ] Warden receives request in dashboard
- [ ] Warden can view student's previous leave history
- [ ] Approval sends email with correct details
- [ ] Rejection with reason sends email
- [ ] Approved leaves show on student calendar
- [ ] High-frequency leaves trigger AI alerts
- [ ] Leave history shows last 30 days correctly
- [ ] Date calculations and total days are accurate
- [ ] Email formatting looks professional on all clients
- [ ] Rejected students can resubmit requests
- [ ] Security staff can see "Not Attending College" status

---

## Future Enhancements

1. **Faculty Notification:** Auto-notify department/mentor
2. **Medical Documentation:** Support document uploads for medical leaves
3. **Attendance Integration:** Auto-mark absent in faculty system
4. **SMS Notifications:** Send SMS alerts for urgent responses
5. **Leave Quotas:** Set maximum leaves per semester
6. **Recurring Leaves:** Support repeating leave patterns
7. **Analytics Dashboard:** Month-wise leave statistics
8. **Appeal System:** Allow students to appeal rejections
9. **Emergency Override:** Warden can mark immediate disapproval need
10. **Integration:** Sync with financial system for refunds

---

## Testing Commands

### Create Leave (Student)
```bash
curl -X POST http://localhost:5000/api/student/leave \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": 1,
    "leave_type": "medical",
    "from_date": "2026-02-10",
    "to_date": "2026-02-12",
    "reason": "Medical checkup required"
  }'
```

### Get Pending Leaves (Warden)
```bash
curl http://localhost:5000/api/warden/leaves/pending
```

### Approve Leave (Warden)
```bash
curl -X POST http://localhost:5000/api/warden/leave/1/approve \
  -H "Content-Type: application/json" \
  -d '{
    "approved_by": 5,
    "remark": "Approved - Take care"
  }'
```

### Get Leave Alerts (AI Monitoring)
```bash
curl http://localhost:5000/api/warden/leave-alerts
```

---

## Notes

- Leave periods are inclusive (both from_date and to_date counted as leave days)
- Students remain on hostel premises during approved leave
- No outpass needed during approved leave period
- Email notifications are sent immediately upon approval/rejection
- Warden can access leave history anytime from the modal
- AI alerts automatically calculated based on 30-day rolling window
- All timestamps are stored in UTC and converted to local on display

