"""Test script for Phi3 Service"""
import requests
import json

BASE_URL = "http://localhost:8003"

def test_health():
    """Test health endpoint"""
    print("Testing health endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/llm/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_info():
    """Test info endpoint"""
    print("Testing info endpoint...")
    response = requests.get(f"{BASE_URL}/api/v1/llm/info")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_chat():
    """Test chat endpoint"""
    print("Testing chat endpoint...")
    
    # First message
    data = {
        "message": "Hello! I want to practice English. Can you help me?",
        "system_prompt": "You are a friendly English language tutor."
    }
    response = requests.post(f"{BASE_URL}/api/v1/llm/chat", json=data)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"User: {data['message']}")
        print(f"Assistant: {result['response']}")
        print(f"Conversation ID: {result['conversation_id']}")
        
        # Continue conversation
        print("\nContinuing conversation...")
        data2 = {
            "message": "What is the past tense of 'go'?",
            "conversation_id": result['conversation_id']
        }
        response2 = requests.post(f"{BASE_URL}/api/v1/llm/chat", json=data2)
        if response2.status_code == 200:
            result2 = response2.json()
            print(f"User: {data2['message']}")
            print(f"Assistant: {result2['response']}")
    else:
        print(f"Error: {response.text}")
    print()

def test_correct():
    """Test correction endpoint"""
    print("Testing correction endpoint...")
    data = {
        "text": "I goed to the store yesterday and buyed some apple.",
        "target_language": "en",
        "provide_explanation": True
    }
    response = requests.post(f"{BASE_URL}/api/v1/llm/correct", json=data)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"Original: {result['original_text']}")
        print(f"Corrected: {result['corrected_text']}")
        print(f"\nCorrections:")
        for corr in result['corrections']:
            print(f"  - {corr.get('correction', corr)}")
        if result.get('explanation'):
            print(f"\nExplanation: {result['explanation']}")
    else:
        print(f"Error: {response.text}")
    print()

if __name__ == "__main__":
    print("="*50)
    print("Phi3 Service Test")
    print("="*50)
    print()
    
    try:
        test_health()
        test_info()
        test_chat()
        test_correct()
        print("✓ All tests completed!")
    except requests.exceptions.ConnectionError:
        print("✗ Error: Could not connect to service. Make sure it's running on port 8003")
    except Exception as e:
        print(f"✗ Error: {e}")
