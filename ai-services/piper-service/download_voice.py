"""Script to download Piper voice models"""
import urllib.request
import os
from pathlib import Path


def download_voice(language="en_US", voice="lessac", quality="medium"):
    """
    Download Piper voice model
    
    Args:
        language: Language code (e.g., en_US, hu_HU)
        voice: Voice name
        quality: Quality level (low, medium, high)
    """
    # Create voices directory
    voices_dir = Path("voices")
    voices_dir.mkdir(exist_ok=True)
    
    # Construct URLs
    base_url = "https://huggingface.co/rhasspy/piper-voices/resolve/main"
    lang_parts = language.split("_")
    
    model_name = f"{language}-{voice}-{quality}"
    voice_url = f"{base_url}/{lang_parts[0]}/{language}/{voice}/{quality}/{model_name}.onnx"
    config_url = f"{base_url}/{lang_parts[0]}/{language}/{voice}/{quality}/{model_name}.onnx.json"
    
    voice_path = voices_dir / f"{model_name}.onnx"
    config_path = voices_dir / f"{model_name}.onnx.json"
    
    # Download voice model
    print(f"Downloading {model_name} voice model...")
    try:
        urllib.request.urlretrieve(voice_url, voice_path)
        print(f"✓ Voice model downloaded: {voice_path}")
    except Exception as e:
        print(f"✗ Failed to download voice model: {e}")
        return False
    
    # Download config
    print("Downloading voice config...")
    try:
        urllib.request.urlretrieve(config_url, config_path)
        print(f"✓ Voice config downloaded: {config_path}")
    except Exception as e:
        print(f"✗ Failed to download config: {e}")
        return False
    
    print(f"\n✓ Successfully downloaded {model_name}")
    print(f"Update your .env file with: VOICE_MODEL_PATH={voice_path}")
    return True


if __name__ == "__main__":
    print("Piper Voice Downloader")
    print("=" * 50)
    
    # Download English voice
    download_voice("en_US", "lessac", "medium")
    
    # Uncomment to download additional voices:
    # download_voice("hu_HU", "berta", "medium")  # Hungarian
    # download_voice("de_DE", "thorsten", "medium")  # German
