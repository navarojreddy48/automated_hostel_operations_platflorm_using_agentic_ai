import requests
import json

# Test the send-otp endpoint
outpass_id = 15  # The pending_otp outpass we found earlier

print("=== Testing Send OTP API Endpoint ===\n")
print(f"Outpass ID: {outpass_id}")
print(f"Endpoint: http://localhost:5000/api/student/outpass/{outpass_id}/send-otp\n")

try:
    response = requests.post(
        f'http://localhost:5000/api/student/outpass/{outpass_id}/send-otp',
        headers={'Content-Type': 'application/json'},
        timeout=10
    )
    
    print(f"Status Code: {response.status_code}\n")
    
    try:
        data = response.json()
        print("Response Data:")
        print(json.dumps(data, indent=2))
    except:
        print("Response Body:")
        print(response.text)
    
except Exception as e:
    print(f"❌ ERROR: {type(e).__name__}")
    print(f"Message: {str(e)}")
