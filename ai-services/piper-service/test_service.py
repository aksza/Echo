"""Test script for Piper TTS Service"""
import requests
import json

BASE_URL = "http://localhost:8001"

def test_health():
    """Test health endpoint"""
    print("Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/tts/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_synthesize():
    """Test synthesize endpoint"""
    print("Testing synthesize endpoint...")
    data = {
        "text": "Hello, this is a test of the Piper text to speech service."
    }
    response = requests.post(f"{BASE_URL}/api/v1/tts/synthesize", json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_synthesize_audio():
    """Test synthesize audio endpoint"""
    print("Testing synthesize audio endpoint...")
    data = {
        "text": "This is a test audio file."
    }
    response = requests.post(f"{BASE_URL}/api/v1/tts/synthesize/audio", json=data)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        output_file = "test_output.wav"
        with open(output_file, "wb") as f:
            f.write(response.content)
        print(f"Audio saved to: {output_file}")
        print(f"File size: {len(response.content)} bytes")
    else:
        print(f"Error: {response.text}")
    print()

if __name__ == "__main__":
    print("="*50)
    print("Piper TTS Service Test")
    print("="*50)
    print()
    
    try:
        test_health()
        test_synthesize()
        test_synthesize_audio()
        print("✓ All tests completed!")
    except requests.exceptions.ConnectionError:
        print("✗ Error: Could not connect to service. Make sure it's running on port 8001")
    except Exception as e:
        print(f"✗ Error: {e}")
