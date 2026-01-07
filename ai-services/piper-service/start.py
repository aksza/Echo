"""Startup script for Piper TTS Service"""
import sys
import os
from pathlib import Path

# Add current directory to Python path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))
os.chdir(current_dir)

if __name__ == "__main__":
    import uvicorn
    
    # Now import app
    from app.main import app
    from app.core import get_settings
    
    settings = get_settings()
    
    print(f"Starting {settings.service_name} on {settings.service_host}:{settings.service_port}")
    
    uvicorn.run(
        app,
        host=settings.service_host,
        port=settings.service_port,
        log_level="info"
    )
