from pydantic import BaseModel, Field, validator
from typing import Optional, List


class TranscriptionSegment(BaseModel):
    """Transcription segment with timing"""
    
    id: int = Field(..., description="Segment ID")
    start: float = Field(..., description="Start time in seconds")
    end: float = Field(..., description="End time in seconds")
    text: str = Field(..., description="Transcribed text")


class TranscriptionRequest(BaseModel):
    """Speech-to-text request model"""
    
    language: Optional[str] = Field(None, description="Language code (e.g., en, hu, de)")
    task: str = Field("transcribe", description="Task type: transcribe or translate")
    return_segments: bool = Field(False, description="Return detailed segments with timestamps")
    
    @validator('task')
    def validate_task(cls, v):
        if v not in ['transcribe', 'translate']:
            raise ValueError('Task must be either "transcribe" or "translate"')
        return v


class TranscriptionResponse(BaseModel):
    """Speech-to-text response model"""
    
    text: str = Field(..., description="Full transcribed text")
    language: str = Field(..., description="Detected or specified language")
    duration: Optional[float] = Field(None, description="Audio duration in seconds")
    segments: Optional[List[TranscriptionSegment]] = Field(None, description="Detailed segments")


class HealthResponse(BaseModel):
    """Health check response"""
    
    status: str = Field(..., description="Service status")
    service: str = Field(..., description="Service name")
    model_loaded: bool = Field(..., description="Whether Whisper model is loaded")
    model_name: str = Field(..., description="Loaded model name")


class ErrorResponse(BaseModel):
    """Error response model"""
    
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(None, description="Detailed error information")
