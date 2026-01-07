from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from typing import Optional
import logging

from app.models import (
    TranscriptionRequest,
    TranscriptionResponse,
    TranscriptionSegment,
    HealthResponse,
    ErrorResponse
)
from app.services import WhisperService
from app.core import get_settings

logger = logging.getLogger(__name__)
router = APIRouter()

# Global Whisper service instance (will be initialized on startup)
whisper_service: WhisperService = None


def get_whisper_service() -> WhisperService:
    """Dependency to get Whisper service instance"""
    if whisper_service is None:
        raise HTTPException(status_code=503, detail="Whisper service not initialized")
    return whisper_service


@router.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe_audio(
    file: UploadFile = File(..., description="Audio file to transcribe"),
    language: Optional[str] = Form(None, description="Language code (e.g., en, hu)"),
    task: str = Form("transcribe", description="Task: transcribe or translate"),
    return_segments: bool = Form(False, description="Return detailed segments"),
    service: WhisperService = Depends(get_whisper_service)
):
    """
    Transcribe audio file to text
    
    Supports various audio formats: wav, mp3, m4a, ogg, etc.
    """
    try:
        # Validate file
        if not file.filename:
            raise HTTPException(status_code=400, detail="No file provided")
        
        # Read audio file
        logger.info(f"Received file: {file.filename}")
        audio_bytes = await file.read()
        
        # Check file size
        settings = get_settings()
        max_size = settings.max_audio_size_mb * 1024 * 1024
        if len(audio_bytes) > max_size:
            raise HTTPException(
                status_code=400,
                detail=f"File too large. Max size: {settings.max_audio_size_mb}MB"
            )
        
        # Use default language if not specified
        if not language:
            language = settings.default_language if settings.default_language else None
        
        # Transcribe
        result = service.transcribe_bytes(
            audio_bytes=audio_bytes,
            filename=file.filename,
            language=language,
            task=task,
            return_segments=return_segments
        )
        
        # Prepare response
        response = TranscriptionResponse(
            text=result["text"],
            language=result["language"],
            segments=[
                TranscriptionSegment(**seg)
                for seg in result.get("segments", [])
            ] if return_segments else None
        )
        
        return response
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Transcription error: {e}")
        raise HTTPException(status_code=500, detail="Transcription failed")


@router.get("/health", response_model=HealthResponse)
async def health_check(service: WhisperService = Depends(get_whisper_service)):
    """
    Check service health status
    """
    model_info = service.get_model_info()
    
    return HealthResponse(
        status="healthy",
        service=get_settings().service_name,
        model_loaded=service.is_model_loaded(),
        model_name=model_info["model_name"]
    )


@router.get("/models")
async def list_models(service: WhisperService = Depends(get_whisper_service)):
    """
    List available Whisper models
    """
    return {
        "available_models": service.get_available_models(),
        "current_model": service.model_name,
        "device": service.device
    }
