from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings"""
    
    # Service Configuration
    service_name: str = "piper-service"
    service_host: str = "0.0.0.0"
    service_port: int = 8001
    
    # Voice Model Configuration
    voice_model_path: str = "voices/en_US-lessac-medium.onnx"
    default_language: str = "en_US"
    
    # Performance
    max_text_length: int = 5000
    sample_rate: int = 22050
    
    # Logging
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()
