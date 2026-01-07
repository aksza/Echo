from fastapi import APIRouter, HTTPException, Depends
from typing import Optional
import logging

from app.models import (
    ChatRequest,
    ChatResponse,
    CorrectionRequest,
    CorrectionResponse,
    HealthResponse,
    ErrorResponse
)
from app.services import Phi3Service
from app.core import get_settings

logger = logging.getLogger(__name__)
router = APIRouter()

# Global Phi3 service instance (will be initialized on startup)
phi3_service: Phi3Service = None


def get_phi3_service() -> Phi3Service:
    """Dependency to get Phi3 service instance"""
    if phi3_service is None:
        raise HTTPException(status_code=503, detail="Phi3 service not initialized")
    return phi3_service


@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    service: Phi3Service = Depends(get_phi3_service)
):
    """
    Chat with the language model
    
    Maintains conversation context if conversation_id is provided.
    """
    try:
        settings = get_settings()
        
        # Use settings defaults if not specified
        temperature = request.temperature if request.temperature is not None else settings.temperature
        max_tokens = request.max_tokens if request.max_tokens is not None else settings.max_new_tokens
        
        # Generate response
        response, conversation_id = service.chat(
            message=request.message,
            conversation_id=request.conversation_id,
            system_prompt=request.system_prompt,
            temperature=temperature,
            max_tokens=max_tokens
        )
        
        return ChatResponse(
            response=response,
            conversation_id=conversation_id,
            tokens_used=None  # Could calculate this if needed
        )
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Chat error: {e}")
        raise HTTPException(status_code=500, detail="Chat failed")


@router.post("/correct", response_model=CorrectionResponse)
async def correct_text(
    request: CorrectionRequest,
    service: Phi3Service = Depends(get_phi3_service)
):
    """
    Correct language mistakes in text
    
    Provides corrections and explanations for language learning.
    """
    try:
        result = service.correct_text(
            text=request.text,
            target_language=request.target_language,
            provide_explanation=request.provide_explanation
        )
        
        return CorrectionResponse(**result)
        
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Correction error: {e}")
        raise HTTPException(status_code=500, detail="Correction failed")


@router.delete("/conversation/{conversation_id}")
async def clear_conversation(
    conversation_id: str,
    service: Phi3Service = Depends(get_phi3_service)
):
    """
    Clear a conversation history
    """
    try:
        service.clear_conversation(conversation_id)
        return {"message": "Conversation cleared", "conversation_id": conversation_id}
    except Exception as e:
        logger.error(f"Error clearing conversation: {e}")
        raise HTTPException(status_code=500, detail="Failed to clear conversation")


@router.get("/health", response_model=HealthResponse)
async def health_check(service: Phi3Service = Depends(get_phi3_service)):
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


@router.get("/info")
async def get_info(service: Phi3Service = Depends(get_phi3_service)):
    """
    Get detailed service information
    """
    return service.get_model_info()
