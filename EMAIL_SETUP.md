# HostelConnect Email Setup Guide

## Fixed Issues:
✅ **Payment Proof**: Warden page now displays `fee_status` (paid/pending) correctly
✅ **Email Backend**: Updated to support both SMTP and Gmail API with detailed logging

## Email Configuration (Pick ONE)

### Option 1: Gmail SMTP (✓ RECOMMENDED - Easiest)

**Steps:**

1. **Generate Gmail App Password:**
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Copy the app password (16 characters with spaces)

2. **Set Environment Variables in PowerShell:**
   ```powershell
   $env:EMAIL_USE_SMTP = "true"
   $env:SMTP_SERVER = "smtp.gmail.com"
   $env:SMTP_PORT = "587"
   $env:SENDER_EMAIL = "your-email@gmail.com"
   $env:SENDER_PASSWORD = "your-app-password-here"
   ```

3. **Start Backend:**
   ```powershell
   cd d:\hostel\backend
   python app.py
   ```

### Option 2: Gmail API Service Account (Advanced)

Only use if you already have:
- Google Cloud Project with Gmail API enabled
- Service account with delegated domain-wide authority

Set: `$env:EMAIL_USE_SMTP = "false"`

---

## Troubleshooting

**Email not sending?**
1. Check the terminal output for error messages (now has detailed logging)
2. Verify app password is correct (no spaces between characters when pasting)
3. Confirm sender email in code matches the email you generated app password for
4. Check firewall/antivirus isn't blocking port 587

**Authentication failed?**
- Gmail: Ensure 2FA is enabled and you're using App Password (not regular password)
- Check environment variables are set: `Get-ChildItem env: | grep EMAIL`

**Testing Email:**
Run in PowerShell while backend is running:
```powershell
$body = @{
    rejection_reason = "Test email"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/admin/registrations/1/reject" `
  -Method Put -Body $body -ContentType "application/json"
```

---

## Next Steps

1. Configure environment variables (Gmail SMTP recommended)
2. Start backend: `cd backend && python app.py`
3. Approve a pending registration in Warden dashboard
4. Check student email for approval notification
5. Check terminal logs for any errors
