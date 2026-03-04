# College Leave Flow - Quick Reference Guide

## 🔄 Complete Flow Visualization

```
STUDENT VIEW
═══════════════════════════════════════════════════════════════════

1. SUBMIT REQUEST
   ├─ Navigate to Student Dashboard → Leave Requests
   ├─ Click "+ Request Leave"
   ├─ Fill form:
   │  ├─ Leave Type: Select from dropdown
   │  ├─ From Date: Pick from calendar
   │  ├─ To Date: Pick from calendar
   │  └─ Reason: Type detailed reason
   ├─ Click "Submit Request"
   └─ Status: PENDING ⏳

2. VIEW CALENDAR & HISTORY
   ├─ Calendar shows:
   │  ├─ Approved leave days (green highlight)
   │  └─ Monthly navigation
   └─ Request History shows:
      ├─ Pending requests
      ├─ Approved requests
      └─ Rejected requests

3. RECEIVE EMAIL
   ├─ If APPROVED ✅
   │  ├─ Subject: "✅ Your Leave Request Has Been Approved"
   │  ├─ Shows: Leave dates, type, total days
   │  ├─ Contains: Warden's remark (if any)
   │  └─ Lists: Important reminders
   │
   └─ If REJECTED ❌
      ├─ Subject: "❌ Your Leave Request Has Been Rejected"
      ├─ Shows: Leave dates, type
      ├─ Contains: Rejection reason
      └─ Lists: Appeal/resubmit options

4. DURING APPROVED LEAVE
   ├─ No outpass needed
   ├─ Stay in hostel
   ├─ Security staff sees status
   └─ Marked as "Not Attending College"


WARDEN VIEW
═══════════════════════════════════════════════════════════════════

1. VIEW PENDING REQUESTS
   ├─ Navigate to Warden Dashboard → Leave Approvals
   ├─ See all pending requests from students
   ├─ For each request shows:
   │  ├─ Student name & roll number
   │  ├─ Room & block
   │  ├─ Leave type
   │  ├─ Date range
   │  ├─ Total days
   │  └─ Request date
   └─ Reason visible (expandable if long)

2. REVIEW HISTORY (Optional)
   ├─ Click "📜 View Previous Leaves" button
   ├─ Modal shows:
   │  ├─ Total leaves (all time)
   │  ├─ Last 30 days breakdown
   │  ├─ Leave frequency summary
   │  └─ Recent leave history
   └─ Close and continue

3. MAKE DECISION

   ✅ APPROVE:
   ├─ Click "✅ Approve" button
   ├─ Optional: Type remark (max 500 chars)
   ├─ Click "Confirm"
   ├─ Backend actions:
   │  ├─ Status changes to APPROVED
   │  ├─ Timestamp recorded
   │  └─ Email sent to student ✉️
   └─ Request removed from pending list
   
   ❌ REJECT:
   ├─ Click "❌ Reject" button
   ├─ Required: Type rejection reason
   ├─ Click "Confirm"
   ├─ Backend actions:
   │  ├─ Status changes to REJECTED
   │  ├─ Reason stored
   │  ├─ Timestamp recorded
   │  └─ Email sent to student ✉️
   └─ Request removed from pending list

4. CHECK AI ALERTS
   ├─ View leave alerts dashboard (if available)
   ├─ See high-frequency leave students
   ├─ Risk levels: HIGH, MEDIUM
   ├─ Suggestions:
   │  ├─ Consider counseling
   │  ├─ Check medical docs
   │  ├─ Contact family
   │  └─ Offer support
   └─ Take suggested actions


SECURITY STAFF VIEW
═══════════════════════════════════════════════════════════════════

1. VIEW STUDENT STATUS
   ├─ Check "Not Attending College" list
   ├─ See approved leave students during period
   ├─ Verify dates and times
   └─ Grant access to hostel premises

2. NO OUTPASS NEEDED
   ├─ Student has approved leave
   ├─ No need to process outpass
   ├─ Accept as "in hostel, not attending college"
   └─ Log entry accordingly


DATABASE RECORDS
═══════════════════════════════════════════════════════════════════

leave_requests table stores:
├─ id: Unique identifier
├─ student_id: Reference to student
├─ leave_type: medical|personal|family_emergency|vacation|other
├─ leave_reason: Text reason
├─ from_date: Start date (YYYY-MM-DD)
├─ to_date: End date (YYYY-MM-DD)
├─ total_days: Auto-calculated
├─ status: pending|approved|rejected|cancelled
├─ approved_by: Warden user ID
├─ approved_at: Timestamp of decision
├─ rejection_reason: If rejected
├─ created_at: Submission timestamp
└─ updated_at: Last update timestamp
```

---

## 📋 Status Reference

| Status | Student Sees | Warden Sees | Storage |
|--------|-------------|-----------|---------|
| **PENDING** | 🔔 Waiting | Needs review | Pending list |
| **APPROVED** | ✅ Confirmed | Processed | Calendar, history |
| **REJECTED** | ❌ Declined | Processed | History |
| **CANCELLED** | — (removed) | — (removed) | Archive |

---

## 📧 Email Templates Summary

### Approval Email
```
From: HostelConnect System
To: student@email.com
Subject: ✅ Your Leave Request Has Been Approved

Content:
- Confirmation message
- Leave details (dates, type, days)
- Important reminders
- Warden's remark (if any)
- Link to dashboard
```

### Rejection Email
```
From: HostelConnect System
To: student@email.com
Subject: ❌ Your Leave Request Has Been Rejected

Content:
- Rejection notification
- Leave details
- Reason for rejection
- Next steps to take
- Appeal/resubmit information
```

---

## 🤖 Agentic AI Monitoring

### Alert Triggers
```
HIGH RISK (⚠️):
├─ 5+ approved leaves in 30 days
├─ 15+ total leave days in 30 days
└─ Multiple rejection patterns

MEDIUM RISK:
├─ 4+ approved leaves in 30 days
├─ 2+ pending requests
└─ 2+ rejected requests
```

### AI Suggestions
```
Risk Metrics:
├─ approved_count: Number of approved leaves
├─ pending_count: Waiting for approval
├─ rejected_count: How many rejected
├─ total_leave_days: Sum of approved days
└─ Recent leaves: Types and days

Suggested Actions:
├─ Schedule counseling session
├─ Request medical documentation
├─ Check attendance with faculty
├─ Offer wellness support
└─ Contact family if needed
```

---

## 🔧 API Quick Reference

### Submit Leave (Student)
```http
POST /api/student/leave
Content-Type: application/json

{
  "student_id": 1,
  "leave_type": "medical",
  "from_date": "2026-02-10",
  "to_date": "2026-02-12",
  "reason": "Medical checkup"
}

Response: { "success": true, "id": 123 }
```

### Get Pending (Warden)
```http
GET /api/warden/leaves/pending
Content-Type: application/json

Response: {
  "success": true,
  "data": [
    {
      "id": 123,
      "student_name": "John Doe",
      "from_date": "2026-02-10",
      "status": "pending"
    }
  ]
}
```

### Approve Leave (Warden)
```http
POST /api/warden/leave/123/approve
Content-Type: application/json

{
  "approved_by": 5,
  "remark": "Approved - take care"
}

Response: { "success": true, "message": "Leave approved" }
Email: Sent to student immediately
```

### Reject Leave (Warden)
```http
POST /api/warden/leave/123/reject
Content-Type: application/json

{
  "approved_by": 5,
  "rejection_reason": "Conflicting dates"
}

Response: { "success": true, "message": "Leave rejected" }
Email: Sent to student immediately
```

### Get Leave Alerts (AI)
```http
GET /api/warden/leave-alerts
Content-Type: application/json

Response: {
  "success": true,
  "alert_count": 3,
  "data": [
    {
      "roll_number": "21R21A6701",
      "student_name": "John Doe",
      "approved_count": 5,
      "total_leave_days": 18,
      "risk_level": "high",
      "ai_suggestions": [
        "⚠️ Very high frequency",
        "📅 Extended leave days"
      ]
    }
  ]
}
```

---

## ✅ Implementation Checklist

### Backend
- [x] Database schema with leave_requests table
- [x] Student leave submission endpoint
- [x] Warden leave approval endpoint
- [x] Warden leave rejection endpoint
- [x] Student leave history endpoint
- [x] Warden leave history endpoint
- [x] Leave alerts (AI monitoring) endpoint
- [x] Email templates for approval/rejection
- [x] Email sending functionality
- [x] Date calculations (total_days)

### Frontend
- [x] Student leave request form
- [x] Interactive calendar for student
- [x] Request history display
- [x] Warden approval interface
- [x] Student history modal (warden)
- [x] Email template rendering
- [x] Status badge colors
- [x] Error handling & validation
- [x] Loading states

### Features
- [x] Real-time leave fetching
- [x] Calendar view (monthly)
- [x] High-frequency detection
- [x] AI risk assessment
- [x] Email notifications
- [x] Rejection tracking
- [x] Audit trail (timestamps)
- [x] Student email display updates

---

## 🎯 User Experience Flow

```
STUDENT JOURNEY:
Request Leave → Wait for Warden → Receive Email Notification
     ↓                                        ↓
View in Calendar                    See Approval/Rejection
     ↓                                        ↓
During Leave: Stay in Hostel        Email Contains Details
Security Sees Status                Warden's Remarks (if any)

WARDEN JOURNEY:
Receive Request → Review Details → Check History
     ↓                                    ↓
Approve/Reject → Add Remark/Reason → Email Sent
     ↓                                    ↓
Monitor Alerts → Take Action → Follow Up
```

---

## 🚨 Common Scenarios

### Scenario 1: Medical Leave Approval
1. Student submits: Medical leave for 2026-02-10 to 2026-02-12
2. Warden sees request, clicks "View Previous Leaves"
3. No recent leaves, approves with remark: "Get well soon"
4. Student receives email with approval & dates
5. Calendar shows Feb 10-12 highlighted
6. Status updated to visible for security

### Scenario 2: High-Frequency Alert
1. AI detects: Student has 5 leaves in 30 days (18 days total)
2. Alert appears in warden dashboard: "Risk Level: HIGH"
3. Warden clicks to view full alert details
4. Suggestions: "Consider counseling session"
5. Warden schedules meeting with student
6. Takes appropriate supportive action

### Scenario 3: Rejection & Resubmission
1. Student submits vacation leave for busy period
2. Warden denies: "Conflicting with exam schedule"
3. Student receives rejection email with reason
4. Student understands issue, resubmits for later dates
5. Warden approves revised dates
6. System accepts resubmission normally

---

## 📱 Mobile Support
- Calendar responsive on mobile
- Form inputs mobile-friendly
- Email templates responsive
- Warden dashboard works on tablet
- Touch-friendly buttons

---

## 🔒 Security Features
- Authentication required (students & wardens)
- Role-based access control
- Data validation on frontend & backend
- SQL injection protection
- Email verification
- Audit trail for all approvals
- Timestamp tracking

---

## 📊 Reporting
Available reports:
- Student leave history
- High-frequency leave patterns
- Monthly leave statistics
- Seasonal trends
- Approval/rejection rates
- AI alert history

---

## 📞 Support
For issues or questions:
1. Check documentation in COLLEGE_LEAVE_FLOW_IMPLEMENTATION.md
2. Review API endpoints
3. Verify database records
4. Check email logs
5. Contact development team

---

Last Updated: February 9, 2026
Version: 1.0 (Complete Implementation)
