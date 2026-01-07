from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings"""
    
    # Service Configuration
    service_name: str = "phi3-service"
    service_host: str = "0.0.0.0"
    service_port: int = 8003
    
    # Ollama Configuration
    ollama_base_url: str = "http://localhost:11434"
    model_name: str = "phi3"
    
    # Generation Parameters
    max_new_tokens: int = 512
    temperature: float = 0.7
    top_p: float = 0.9
    
    # Performance
    max_conversation_history: int = 10
    
    # Logging
    log_level: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()
