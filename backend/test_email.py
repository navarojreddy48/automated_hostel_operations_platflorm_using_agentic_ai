# Test SMTP Email Configuration
# Run this script to verify email credentials are working

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Your credentials
SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587
SENDER_EMAIL = 'hostelconnect05@gmail.com'
SENDER_PASSWORD = 'pnwv tpzk agxx gcxy'

def test_email(recipient_email):
    """Test sending an email"""
    try:
        print("Testing SMTP connection...")
        print(f"Server: {SMTP_SERVER}:{SMTP_PORT}")
        print(f"Sender: {SENDER_EMAIL}")
        print(f"Recipient: {recipient_email}")
        
        # Create message
        message = MIMEMultipart('alternative')
        message['Subject'] = 'HostelConnect - Email Test'
        message['From'] = SENDER_EMAIL
        message['To'] = recipient_email
        
        html_body = """
        <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
            <h2 style="color: #7c3aed;">HostelConnect Email Test</h2>
            <p>If you're reading this, your email configuration is working perfectly!</p>
            <p><strong>Configuration Details:</strong></p>
            <ul>
                <li>Server: smtp.gmail.com</li>
                <li>Port: 587</li>
                <li>Sender: hostelconnect05@gmail.com</li>
                <li>Status: ✅ Active</li>
            </ul>
            <hr style="border: 1px solid #e5e7eb; margin: 20px 0;">
            <p style="color: #64748b; font-size: 0.9rem;">This is a test email from HostelConnect Management System</p>
        </body>
        </html>
        """
        
        part = MIMEText(html_body, 'html')
        message.attach(part)
        
        # Connect and send
        print("\n⏳ Connecting to SMTP server...")
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            print("✓ Connected")
            
            print("⏳ Starting TLS...")
            server.starttls()
            print("✓ TLS enabled")
            
            print("⏳ Logging in...")
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            print("✓ Logged in successfully")
            
            print("⏳ Sending email...")
            server.sendmail(SENDER_EMAIL, recipient_email, message.as_string())
            print("✓ Email sent successfully!")
        
        print(f"\n✅ SUCCESS! Check {recipient_email} for the test email.")
        return True
        
    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
        print("\nPossible issues:")
        print("1. App password might be incorrect")
        print("2. 2-step verification not enabled on Gmail account")
        print("3. Less secure app access needs to be enabled")
        print("4. Network/firewall blocking port 587")
        return False

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1:
        recipient = sys.argv[1]
    else:
        recipient = input("Enter recipient email address to test: ")
    
    test_email(recipient)
