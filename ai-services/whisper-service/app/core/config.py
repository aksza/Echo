from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings"""
    
    # Service Configuration
    service_name: str = "whisper-service"
    service_host: str = "0.0.0.0"
    service_port: int = 8002
    
    # Whisper Model Configuration
    whisper_model: str = "base"  # tiny, base, small, medium, large
    default_language: str = "en"  # empty string for auto-detection
    
    # Performance
    max_audio_size_mb: int = 25
    device: str = "cpu"  # cpu or cuda
    
    # Logging
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()
