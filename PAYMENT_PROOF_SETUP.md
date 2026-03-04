# Payment Proof Feature - Setup Guide

## ✅ FEATURE IMPLEMENTED: Payment Receipt Upload & Viewing

### What's New:

1. **Students can now**:
   - Upload payment proof documents (images or PDFs) during registration
   - Supported formats: JPG, PNG, PDF (max 10MB)
   - File uploads automatically during selection, no manual submit needed

2. **Wardens can now**:
   - View payment proof documents in registration details
   - Download receipts for verification
   - See warning if no payment proof uploaded

3. **Backend**:
   - Secure file upload API endpoint
   - Files stored in `uploaded_files/` directory
   - Download endpoint with security validation
   - Automatic fee status update when receipt uploaded

---

## 🚀 Setup Steps:

### Step 1: Update Database

Run this SQL command in MySQL:

```sql
USE hostelconnect_db;
ALTER TABLE students ADD COLUMN payment_proof_url VARCHAR(500) AFTER emergency_contact;
```

**OR** use the migration file:
```powershell
cd d:\hostel\backend
mysql -u root -p hostelconnect_db < migrate_payment_proof.sql
```

### Step 2: Verify Directory Structure

The backend will auto-create the uploads folder, but you can manually create it:

```powershell
mkdir d:\hostel\uploaded_files
```

### Step 3: Start Backend

```powershell
cd d:\hostel\backend
python app.py
```

Check for this message:
```
Email mode: SMTP
 * Running on http://localhost:5000
```

### Step 4: Start Frontend

```powershell
cd d:\hostel\frontend
npm run dev
```

### Step 5: Test the Feature

1. **Student Side:**
   - Go to: http://localhost:5173/student-registration
   - Fill personal info (Step 1)
   - Select hostel (Step 2)
   - **Upload receipt in Step 3** (optional but recommended)
   - You'll see "✓ Receipt uploaded successfully" when done
   - Submit registration

2. **Warden Side:**
   - Login as warden
   - Go to Registrations page
   - Click "View Details" on pending registration
   - Scroll to "Fee Payment Details"
   - You'll see either:
     - Payment proof with "View/Download" button (if uploaded)
     - Warning message (if not uploaded)

---

## 📁 File Structure:

```
hostel/
├── uploaded_files/           # Payment proofs stored here
│   └── [hex_filename_original.pdf]
├── backend/
│   ├── app.py                # Upload/download endpoints added
│   ├── migrate_payment_proof.sql  # DB migration script
│   └── database_schema.sql   # Updated with payment_proof_url
└── frontend/src/
    └── pages/
        ├── student/
        │   └── StudentRegistration.jsx  # File upload UI
        └── warden/
            └── Registrations.jsx        # View/download UI
```

---

## 🔒 Security Features:

- ✅ File type validation (only PDF, JPG, PNG allowed)
- ✅ File size limit (10MB max)
- ✅ Secure filename generation (prevents overwrite)
- ✅ Path traversal protection
- ✅ Files stored outside webroot

---

## 🐛 Troubleshooting:

### "No file provided" error:
- Ensure file input has `name="file"` attribute
- Check network tab for form data structure

### File not uploading:
- Check backend console for errors
- Verify `uploaded_files/` folder exists and is writable
- Ensure file size is under 10MB

### Can't download file:
- Verify file exists in `uploaded_files/` folder
- Check file path in database matches actual filename
- Ensure backend endpoint `/api/files/payment-proof/<filename>` is running

### Database error:
- Run the migration SQL command
- Check if `payment_proof_url` column exists:
  ```sql
  DESCRIBE students;
  ```

---

## 📊 Database Schema:

students table now includes:

| Column | Type | Description |
|--------|------|-------------|
| payment_proof_url | VARCHAR(500) | Path to uploaded receipt file |
| fee_status | ENUM | Auto-set to 'paid' if receipt uploaded |

---

## 🎯 API Endpoints:

### Upload Payment Proof
```http
POST /api/upload/payment-proof
Content-Type: multipart/form-data

file: [binary data]
```

**Response:**
```json
{
  "success": true,
  "file_path": "/api/files/payment-proof/abc123_receipt.pdf",
  "filename": "receipt.pdf"
}
```

### Download Payment Proof
```http
GET /api/files/payment-proof/<filename>
```

Returns the file as download.

---

## ✅ Testing Checklist:

- [ ] Database migration completed
- [ ] Backend starts without errors
- [ ] Upload folder created
- [ ] Can upload PDF receipt
- [ ] Can upload JPG/PNG receipt
- [ ] Receipt shown in warden page
- [ ] Can download receipt
- [ ] Warning shown if no receipt
- [ ] Large files (>10MB) rejected
- [ ] Invalid file types rejected

---

## 🎨 UI Features:

**Student Registration:**
- Upload progress indicator ("⏳ Uploading...")
- Success confirmation ("✓ receipt.pdf")
- Disabled during upload (prevents double-upload)
- Accept attribute limits file picker to allowed types

**Warden View:**
- Clear document icon
- Blue "View/Download" button
- Opens in new tab
- Red warning if missing
- Inline styling for visibility

---

All features are now ready to use! 🎉
