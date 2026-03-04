import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

# Test SMTP Configuration
SMTP_CONFIG = {
    'smtp_server': 'smtp.gmail.com',
    'smtp_port': 587,
    'sender_email': 'hostelconnect05@gmail.com',
    'sender_password': 'pnwv tpzk agxx gcxy',
    'use_tls': True
}

test_recipient = 'nikhilkanneboina206@gmail.com'
test_otp = '123456'

print("=== Testing OTP Email Sending ===\n")
print(f"From: {SMTP_CONFIG['sender_email']}")
print(f"To: {test_recipient}")
print(f"OTP: {test_otp}\n")

try:
    # Create message
    message = MIMEMultipart('alternative')
    message['Subject'] = "🔐 TEST - Outpass OTP Verification"
    message['From'] = SMTP_CONFIG['sender_email']
    message['To'] = test_recipient
    
    # Email body
    html_body = f"""
    <html>
    <body style="font-family: Arial, sans-serif;">
        <h2>HostelConnect - TEST OTP</h2>
        <p>This is a test OTP email.</p>
        <div style="background: #fef3c7; padding: 20px; text-align: center;">
            <p style="font-size: 32px; font-weight: bold; letter-spacing: 8px;">
                {test_otp}
            </p>
        </div>
    </body>
    </html>
    """
    
    # Attach HTML content
    part = MIMEText(html_body, 'html')
    message.attach(part)
    
    # Send email via SMTP
    print(f"Connecting to {SMTP_CONFIG['smtp_server']}:{SMTP_CONFIG['smtp_port']}...")
    with smtplib.SMTP(SMTP_CONFIG['smtp_server'], SMTP_CONFIG['smtp_port']) as server:
        print("Starting TLS...")
        server.starttls()
        
        print(f"Logging in as {SMTP_CONFIG['sender_email']}...")
        server.login(SMTP_CONFIG['sender_email'], SMTP_CONFIG['sender_password'])
        
        print(f"Sending email to {test_recipient}...")
        server.sendmail(SMTP_CONFIG['sender_email'], test_recipient, message.as_string())
    
    print("\n✅ SUCCESS! Email sent successfully!")
    print("Check the recipient's inbox (and spam folder).")

except Exception as e:
    print(f"\n❌ ERROR: {type(e).__name__}")
    print(f"Message: {str(e)}")
    import traceback
    print("\nFull traceback:")
    print(traceback.format_exc())
