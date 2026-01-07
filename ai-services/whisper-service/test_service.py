"""Test script for Whisper Service"""
import requests
import json
from pathlib import Path

BASE_URL = "http://localhost:8002"

def test_health():
    """Test health endpoint"""
    print("Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/stt/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_models():
    """Test models endpoint"""
    print("Testing models endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/stt/models")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_transcribe(audio_file: str):
    """Test transcribe endpoint"""
    print(f"Testing transcribe endpoint with: {audio_file}")
    
    if not Path(audio_file).exists():
        print(f"✗ Audio file not found: {audio_file}")
        print("Please provide a valid audio file to test transcription.")
        return
    
    with open(audio_file, "rb") as f:
        files = {"file": f}
        data = {
            "language": "en",
            "return_segments": True
        }
        response = requests.post(
            f"{BASE_URL}/api/v1/stt/transcribe",
            files=files,
            data=data
        )
    
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"Transcribed text: {result['text']}")
        print(f"Language: {result['language']}")
        if result.get('segments'):
            print(f"\nSegments ({len(result['segments'])}):")
            for seg in result['segments'][:3]:  # Show first 3
                print(f"  [{seg['start']:.2f}s - {seg['end']:.2f}s]: {seg['text']}")
    else:
        print(f"Error: {response.text}")
    print()

if __name__ == "__main__":
    print("="*50)
    print("Whisper Service Test")
    print("="*50)
    print()
    
    try:
        test_health()
        test_models()
        
        # Test with audio file if available
        # You can specify your own audio file here
        test_audio = "../../../test.mp3"  # Update this path
        if Path(test_audio).exists():
            test_transcribe(test_audio)
        else:
            print("ℹ To test transcription, update the audio file path in test_service.py")
        
        print("✓ Basic tests completed!")
    except requests.exceptions.ConnectionError:
        print("✗ Error: Could not connect to service. Make sure it's running on port 8002")
    except Exception as e:
        print(f"✗ Error: {e}")
