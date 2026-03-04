# College Holiday Mode with OTP Verification - Implementation Guide

## 🎯 Overview
Complete backend implementation of College Holiday Mode allowing students to request outpass approval via Parent OTP verification during holidays, bypassing manual warden approval.

---

## 📦 What's Implemented

### Backend Changes

#### 1. **Database Schema Updates**
New migration file: `backend/migrations/2026_02_18_add_holiday_mode_otp.sql`

**New Columns in `outpasses` table:**
- `approval_method` - ENUM('manual', 'otp') - How outpass should be approved
- `otp_code` - VARCHAR(6) - 6-digit OTP sent to parent
- `otp_sent_at` - DATETIME - When OTP was sent
- `otp_verified_at` - DATETIME - When OTP was verified
- `otp_attempts` - INT - Number of verification attempts (max 5)
- `holiday_mode_request` - TINYINT(1) - Flag for holiday mode requests

**New Status Values:**
- `pending_otp` - Waiting for student to complete OTP verification
- `approved_otp` - Auto-approved after successful OTP verification

**New Table: `system_settings`**
- Stores global settings like `college_holiday_mode`
- Tracks who updated settings and when

#### 2. **New API Endpoints**

**Holiday Mode Management:**
```
GET  /api/system/holiday-mode       - Get current holiday mode status
POST /api/system/holiday-mode       - Enable/disable holiday mode (warden only)
```

**OTP Operations:**
```
POST /api/student/outpass/{id}/send-otp    - Send OTP to parent email
POST /api/student/outpass/{id}/verify-otp  - Verify OTP and auto-approve
```

#### 3. **Updated Endpoints**

**Modified: `/api/student/outpass` (POST)**
- Now accepts `approval_method` ('manual' or 'otp')
- Accepts `holiday_mode` flag
- Sets initial status based on approval method

**Modified: `/api/warden/outpasses/pending` (GET)**
- Now returns outpasses with status 'pending' OR 'pending_otp'

**Modified: `/api/warden/outpasses/approved` (GET)**
- Now includes 'approved_otp' status in results

**Modified: `/api/warden/recent-activities` (GET)**
- Includes OTP-approved outpasses in activity feed

---

## 🚀 Installation & Setup

### Step 1: Apply Database Migration

```bash
cd backend
python apply_holiday_mode_migration.py
```

Expected output:
```
==================================================
Holiday Mode & OTP Migration
==================================================
Connecting to database...
Reading migration file: migrations/2026_02_18_add_holiday_mode_otp.sql

Executing 8 SQL statements...

[1/8] Executing...
✓ Success
...
==================================================
✅ Migration applied successfully!
==================================================
```

### Step 2: Verify Email Configuration

Ensure SMTP settings are configured in `backend/app.py`:
```python
SMTP_CONFIG = {
    'smtp_server': 'smtp.gmail.com',
    'smtp_port': 587,
    'sender_email': 'your-email@gmail.com',
    'sender_password': 'your-app-password',
    'use_tls': True
}
```

### Step 3: Restart Backend Server

```bash
cd backend
python app.py
```

### Step 4: Refresh Frontend

```bash
# If development server is running, just reload browser
# Otherwise:
cd frontend
npm run dev
```

---

## 📖 User Workflows

### For Wardens:

1. **Enable Holiday Mode**
   - Navigate to Warden → Outpass Approvals
   - Toggle "College Holiday Mode" switch ON
   - Badge appears: "🎄 Holiday Mode Active"

2. **View OTP-Based Requests**
   - See status badges:
     - 🔐 **Pending OTP Verification** - Student completing OTP process
     - ✅ **Approved via Parent OTP** - Auto-approved (no action needed)
     - 📋 **Pending Manual Approval** - Needs warden approval
   - OTP-approved outpasses show info message (cannot modify)

3. **Disable Holiday Mode**
   - Toggle switch OFF
   - System returns to normal approval workflow

### For Students:

1. **Request Outpass During Holiday Mode**
   - Click "New Request" on Student Outpass page
   - See yellow box: "🎄 Holiday Mode Active"
   - **Select Approval Method:**
     - ✅ Option 1: OTP Verification via Parent
     - ✅ Option 2: Manual Approval by Warden
   - Fill other details and submit

2. **OTP Verification Process** (if Option 1 selected)
   - Status shows: 🔐 **Pending OTP**
   - Click "📱 Send OTP to Parent"
   - OTP sent to parent email (confirmation alert)
   - Click "🔐 Enter OTP" button
   - Enter 6-digit OTP received by parent
   - Click "Verify OTP"
   - Auto-approved! Status: ✅ **Approved (Parent OTP)**

3. **Manual Approval Process** (if Option 2 selected)
   - Request goes to warden normally
   - Wait for warden approval
   - Status: ⏳ **Pending**

### For Parents:

1. **Receive OTP Email**
   - Subject: "🔐 Outpass OTP Verification - [Student Name]"
   - Contains:
     - Student details
     - Destination & dates
     - 6-digit OTP code (large, centered)
     - Valid for 30 minutes
   
2. **Share OTP with Student**
   - If approved: Share OTP with your ward
   - If not approved: Do NOT share OTP, contact warden

---

## 🔒 Security Features

1. **OTP Expiry**: OTP valid for 30 minutes only
2. **Attempt Limit**: Max 5 verification attempts per outpass
3. **Single-Use**: OTP becomes invalid after successful verification
4. **Email-Only**: OTP sent to registered parent email
5. **Audit Trail**: All OTP events logged with timestamps

---

## 🧪 Testing Guide

### Test Scenario 1: OTP Approval Flow

```
1. Login as Warden
   → Enable Holiday Mode

2. Login as Student
   → Create outpass
   → Select "OTP Verification"
   → Submit

3. Check parent email
   → Copy 6-digit OTP

4. Back to Student
   → Click "Send OTP to Parent"
   → Click "Enter OTP"
   → Paste OTP
   → Click "Verify OTP"
   → ✅ Auto-approved!

5. Login as Warden
   → See approved_otp status
   → Cannot modify
```

### Test Scenario 2: Manual Approval During Holiday Mode

```
1. Holiday Mode: ON (from warden)
2. Student selects "Manual Approval"
3. Request appears as "Pending Manual Approval" for warden
4. Warden approves/rejects normally
```

### Test Scenario 3: Normal Mode (Holiday Mode OFF)

```
1. Holiday Mode: OFF
2. Student creates outpass
3. No approval method selection shown
4. Normal warden approval workflow
```

---

## 📊 Database Queries (For Testing)

**Check holiday mode status:**
```sql
SELECT * FROM system_settings WHERE setting_key = 'college_holiday_mode';
```

**View OTP outpasses:**
```sql
SELECT id, student_id, destination, status, approval_method, otp_code, otp_sent_at, otp_verified_at
FROM outpasses
WHERE approval_method = 'otp'
ORDER BY created_at DESC;
```

**View OTP attempts:**
```sql
SELECT id, destination, status, otp_attempts, otp_sent_at, otp_verified_at
FROM outpasses
WHERE approval_method = 'otp' AND otp_attempts > 0;
```

---

## ⚠️ Important Notes

1. **Parent Email Required**: Students must have `parent_email` in database
2. **SMTP Must Work**: Email sending must be configured
3. **Holiday Mode Sync**: Frontend polls backend every 5 seconds
4. **Migration Idempotent**: Safe to run multiple times
5. **Backward Compatible**: Existing outpasses not affected

---

## 🐛 Troubleshooting

**Issue: OTP email not received**
- Check SMTP configuration in app.py
- Verify parent email in student record
- Check spam/junk folder
- Review backend console for email errors

**Issue: OTP verification fails**
- Ensure OTP is exactly 6 digits
- Check if OTP expired (30 min limit)
- Verify attempts < 5
- Check database otp_code matches

**Issue: Holiday mode toggle doesn't work**
- Run migration script
- Check system_settings table exists
- Verify warden has userId
- Check backend console for errors

**Issue: Approval method not showing**
- Ensure holiday mode is ON (backend)
- Clear browser cache
- Check frontend console for errors
- Verify API endpoint returns holidayMode: true

---

## 📝 API Response Examples

**GET /api/system/holiday-mode:**
```json
{
  "success": true,
  "holidayMode": true
}
```

**POST /api/student/outpass (with holiday mode):**
```json
{
  "success": true,
  "id": 123,
  "message": "Outpass request submitted",
  "status": "pending_otp"
}
```

**POST /api/student/outpass/123/send-otp:**
```json
{
  "success": true,
  "message": "OTP sent to parent contact",
  "email_sent": true,
  "parent_contact": "parent@example.com"
}
```

**POST /api/student/outpass/123/verify-otp:**
```json
{
  "success": true,
  "message": "OTP verified successfully! Outpass approved.",
  "status": "approved_otp"
}
```

---

## 🎉 Feature Summary

✅ **Warden Side:**
- Holiday Mode toggle with persistent state
- Visual badges for OTP vs Manual requests
- Cannot modify OTP-approved outpasses
- Activity log shows OTP approvals

✅ **Student Side:**
- Approval method selection (holiday mode only)
- OTP sending and verification UI
- Real-time status updates
- Parent contact verification

✅ **Backend:**
- Complete OTP generation & verification
- Email delivery to parents
- Security controls (expiry, attempts)
- Audit trail of all actions

✅ **Database:**
- New columns for OTP workflow
- System settings table
- Extended status enum
- Full backward compatibility

---

**Implementation Date:** February 18, 2026  
**Status:** ✅ Production Ready  
**Backend Integration:** ✅ Complete
