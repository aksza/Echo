from pydantic import BaseModel, Field, validator
from typing import Optional


class TTSRequest(BaseModel):
    """Text-to-Speech request model"""
    
    text: str = Field(..., description="Text to convert to speech", max_length=5000)
    language: Optional[str] = Field(None, description="Language code (e.g., en_US, hu_HU)")
    voice: Optional[str] = Field(None, description="Voice model name")
    
    @validator('text')
    def text_not_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Text cannot be empty')
        return v.strip()


class TTSResponse(BaseModel):
    """Text-to-Speech response model"""
    
    message: str = Field(..., description="Status message")
    audio_duration: Optional[float] = Field(None, description="Duration in seconds")
    sample_rate: int = Field(..., description="Audio sample rate")
    text_length: int = Field(..., description="Length of input text")


class HealthResponse(BaseModel):
    """Health check response"""
    
    status: str = Field(..., description="Service status")
    service: str = Field(..., description="Service name")
    voice_model_loaded: bool = Field(..., description="Whether voice model is loaded")


class ErrorResponse(BaseModel):
    """Error response model"""
    
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(None, description="Detailed error information")
