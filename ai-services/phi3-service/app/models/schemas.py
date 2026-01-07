from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from enum import Enum


class MessageRole(str, Enum):
    """Message role enum"""
    SYSTEM = "system"
    USER = "user"
    ASSISTANT = "assistant"


class Message(BaseModel):
    """Chat message model"""
    role: MessageRole = Field(..., description="Role of the message sender")
    content: str = Field(..., description="Message content")


class ChatRequest(BaseModel):
    """Chat request model"""
    
    message: str = Field(..., description="User message", max_length=2000)
    conversation_id: Optional[str] = Field(None, description="Conversation ID for context")
    system_prompt: Optional[str] = Field(None, description="Custom system prompt")
    temperature: Optional[float] = Field(None, ge=0.0, le=2.0, description="Sampling temperature")
    max_tokens: Optional[int] = Field(None, ge=1, le=2048, description="Max tokens to generate")
    
    @validator('message')
    def message_not_empty(cls, v):
        if not v or not v.strip():
            raise ValueError('Message cannot be empty')
        return v.strip()


class ChatResponse(BaseModel):
    """Chat response model"""
    
    response: str = Field(..., description="Assistant's response")
    conversation_id: str = Field(..., description="Conversation ID")
    tokens_used: Optional[int] = Field(None, description="Number of tokens used")


class ConversationHistory(BaseModel):
    """Conversation history model"""
    
    conversation_id: str = Field(..., description="Conversation ID")
    messages: List[Message] = Field(..., description="List of messages")
    created_at: str = Field(..., description="Creation timestamp")
    updated_at: str = Field(..., description="Last update timestamp")


class CorrectionRequest(BaseModel):
    """Language correction request"""
    
    text: str = Field(..., description="Text to correct", max_length=1000)
    target_language: str = Field("en", description="Target language code")
    provide_explanation: bool = Field(True, description="Provide explanation for corrections")


class CorrectionResponse(BaseModel):
    """Language correction response"""
    
    original_text: str = Field(..., description="Original text")
    corrected_text: str = Field(..., description="Corrected text")
    corrections: List[Dict[str, str]] = Field(..., description="List of corrections made")
    explanation: Optional[str] = Field(None, description="Explanation of corrections")


class HealthResponse(BaseModel):
    """Health check response"""
    
    status: str = Field(..., description="Service status")
    service: str = Field(..., description="Service name")
    model_loaded: bool = Field(..., description="Whether model is loaded")
    model_name: str = Field(..., description="Loaded model name")


class ErrorResponse(BaseModel):
    """Error response model"""
    
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(None, description="Detailed error information")
