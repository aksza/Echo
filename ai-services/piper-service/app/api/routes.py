from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import StreamingResponse
import io
import logging

from app.models import TTSRequest, TTSResponse, HealthResponse, ErrorResponse
from app.services import TTSService
from app.core import get_settings

logger = logging.getLogger(__name__)
router = APIRouter()

# Global TTS service instance (will be initialized on startup)
tts_service: TTSService = None


def get_tts_service() -> TTSService:
    """Dependency to get TTS service instance"""
    if tts_service is None:
        raise HTTPException(status_code=503, detail="TTS service not initialized")
    return tts_service


@router.post("/synthesize", response_model=TTSResponse)
async def synthesize_text(
    request: TTSRequest,
    service: TTSService = Depends(get_tts_service)
):
    """
    Convert text to speech and return audio file
    
    Returns WAV audio file with synthesized speech
    """
    try:
        # Synthesize speech
        audio_data = service.synthesize(request.text)
        
        # Calculate duration
        duration = service.get_audio_duration(audio_data)
        
        # Return response with metadata
        return TTSResponse(
            message="Synthesis successful",
            audio_duration=duration,
            sample_rate=service.get_sample_rate(),
            text_length=len(request.text)
        )
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Synthesis error: {e}")
        raise HTTPException(status_code=500, detail="Synthesis failed")


@router.post("/synthesize/audio", response_class=StreamingResponse)
async def synthesize_audio(
    request: TTSRequest,
    service: TTSService = Depends(get_tts_service)
):
    """
    Convert text to speech and return audio stream
    
    Returns WAV audio file as streaming response
    """
    try:
        # Synthesize speech
        audio_data = service.synthesize(request.text)
        
        # Create streaming response
        audio_stream = io.BytesIO(audio_data)
        
        return StreamingResponse(
            audio_stream,
            media_type="audio/wav",
            headers={
                "Content-Disposition": "attachment; filename=speech.wav"
            }
        )
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Synthesis error: {e}")
        raise HTTPException(status_code=500, detail="Synthesis failed")


@router.get("/health", response_model=HealthResponse)
async def health_check(service: TTSService = Depends(get_tts_service)):
    """
    Check service health status
    """
    return HealthResponse(
        status="healthy",
        service=get_settings().service_name,
        voice_model_loaded=service.is_model_loaded()
    )
