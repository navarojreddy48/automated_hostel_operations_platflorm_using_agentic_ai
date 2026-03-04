import requests
import json

# Test creating a new technician via the add_technician endpoint
print("Testing technician creation with auto-generated staff_id...")

data = {
    "name": "Test Technician",
    "email": "test.tech@hostel.edu",
    "password": "test123",
    "employee_id": "EMP999",
    "specialization": "Testing",
    "phone": "9999999999"
}

try:
    response = requests.post("http://localhost:5000/api/warden/technicians", json=data)
    print(f"Status: {response.status_code}")
    result = response.json()
    print(json.dumps(result, indent=2))
except Exception as e:
    print(f"Error: {e}")
