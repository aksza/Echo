import httpx
import logging
from typing import List, Dict, Optional, Any
from datetime import datetime
import uuid
import json

logger = logging.getLogger(__name__)


class Phi3Service:
    """Language model service using Ollama"""
    
    def __init__(
        self,
        ollama_base_url: str = "http://localhost:11434",
        model_name: str = "phi3",
        max_history: int = 10
    ):
        """
        Initialize Phi-3 service with Ollama
        
        Args:
            ollama_base_url: Ollama API base URL
            model_name: Model name in Ollama
            max_history: Maximum conversation history to keep
        """
        self.ollama_base_url = ollama_base_url.rstrip('/')
        self.model_name = model_name
        self.max_history = max_history
        self.conversations: Dict[str, List[Dict[str, str]]] = {}
        self.client = httpx.Client(timeout=120.0)
        self._check_ollama()
    
    def _check_ollama(self):
        """Check if Ollama is running and model is available"""
        try:
            logger.info(f"Checking Ollama connection at {self.ollama_base_url}")
            response = self.client.get(f"{self.ollama_base_url}/api/tags")
            
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_names = [m['name'] for m in models]
                logger.info(f"Ollama is running. Available models: {model_names}")
                
                if not any(self.model_name in name for name in model_names):
                    logger.warning(f"Model '{self.model_name}' not found. Available: {model_names}")
                    logger.warning(f"Run: ollama pull {self.model_name}")
            else:
                logger.warning(f"Could not connect to Ollama: {response.status_code}")
        except Exception as e:
            logger.error(f"Failed to connect to Ollama: {e}")
            logger.error("Make sure Ollama is running (ollama serve)")
            raise ConnectionError(f"Cannot connect to Ollama at {self.ollama_base_url}")
    
    def is_model_loaded(self) -> bool:
        """Check if Ollama is accessible"""
        try:
            response = self.client.get(f"{self.ollama_base_url}/api/tags")
            return response.status_code == 200
        except:
            return False
    
    def create_conversation(self, system_prompt: Optional[str] = None) -> str:
        """
        Create a new conversation
        
        Args:
            system_prompt: Optional system prompt
            
        Returns:
            Conversation ID
        """
        conversation_id = str(uuid.uuid4())
        
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        else:
            # Default system prompt for language learning
            messages.append({
                "role": "system",
                "content": "You are a helpful language tutor. Help the user learn and practice languages. "
                          "Correct their mistakes gently and provide clear explanations."
            })
        
        self.conversations[conversation_id] = messages
        logger.info(f"Created conversation: {conversation_id}")
        return conversation_id
    
    def get_conversation(self, conversation_id: str) -> List[Dict[str, str]]:
        """Get conversation history"""
        return self.conversations.get(conversation_id, [])
    
    def chat(
        self,
        message: str,
        conversation_id: Optional[str] = None,
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 512
    ) -> tuple[str, str]:
        """
        Generate chat response using Ollama
        
        Args:
            message: User message
            conversation_id: Optional conversation ID
            system_prompt: Optional system prompt
            temperature: Sampling temperature
            max_tokens: Maximum tokens to generate
            
        Returns:
            Tuple of (response, conversation_id)
        """
        # Create or get conversation
        if not conversation_id or conversation_id not in self.conversations:
            conversation_id = self.create_conversation(system_prompt)
        
        # Add user message
        self.conversations[conversation_id].append({
            "role": "user",
            "content": message
        })
        
        # Limit conversation history
        if len(self.conversations[conversation_id]) > self.max_history * 2:
            system_msg = self.conversations[conversation_id][0]
            recent_msgs = self.conversations[conversation_id][-(self.max_history * 2 - 1):]
            self.conversations[conversation_id] = [system_msg] + recent_msgs
        
        try:
            # Prepare messages for Ollama
            messages = self.conversations[conversation_id]
            
            # Call Ollama API
            payload = {
                "model": self.model_name,
                "messages": messages,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens,
                    "top_p": 0.9
                }
            }
            
            response = self.client.post(
                f"{self.ollama_base_url}/api/chat",
                json=payload
            )
            response.raise_for_status()
            
            result = response.json()
            assistant_message = result['message']['content'].strip()
            
            # Add assistant response to conversation
            self.conversations[conversation_id].append({
                "role": "assistant",
                "content": assistant_message
            })
            
            logger.info(f"Generated response for conversation {conversation_id}")
            return assistant_message, conversation_id
            
        except Exception as e:
            logger.error(f"Failed to generate response: {e}")
            raise
    
    def correct_text(
        self,
        text: str,
        target_language: str = "en",
        provide_explanation: bool = True
    ) -> Dict[str, Any]:
        """
        Correct language mistakes in text
        
        Args:
            text: Text to correct
            target_language: Target language
            provide_explanation: Whether to provide explanation
            
        Returns:
            Dictionary with corrections
        """
        # Create correction prompt
        prompt = f"""Correct the following {target_language} text and explain the mistakes:

Text: "{text}"

Provide:
1. The corrected text
2. A list of specific corrections made
3. Brief explanation of why each correction was needed

Format your response as:
CORRECTED: <corrected text>
CORRECTIONS:
- <mistake 1>: <correction 1>
- <mistake 2>: <correction 2>
EXPLANATION: <brief explanation>"""
        
        # Create temporary conversation for correction
        temp_id = self.create_conversation(
            "You are a language correction assistant. Correct mistakes and explain them clearly."
        )
        
        try:
            response, _ = self.chat(prompt, temp_id, max_tokens=512)
            
            # Parse response
            corrected_text = text  # fallback
            corrections = []
            explanation = ""
            
            if "CORRECTED:" in response:
                parts = response.split("CORRECTED:")
                if len(parts) > 1:
                    corrected_part = parts[1].split("CORRECTIONS:")[0].strip()
                    corrected_text = corrected_part
            
            if "CORRECTIONS:" in response:
                parts = response.split("CORRECTIONS:")
                if len(parts) > 1:
                    corr_part = parts[1].split("EXPLANATION:")[0].strip()
                    for line in corr_part.split("\n"):
                        if line.strip().startswith("-"):
                            corrections.append({"correction": line.strip()[1:].strip()})
            
            if "EXPLANATION:" in response:
                parts = response.split("EXPLANATION:")
                if len(parts) > 1:
                    explanation = parts[1].strip()
            
            # Clean up temporary conversation
            del self.conversations[temp_id]
            
            return {
                "original_text": text,
                "corrected_text": corrected_text,
                "corrections": corrections,
                "explanation": explanation if provide_explanation else None
            }
            
        except Exception as e:
            logger.error(f"Failed to correct text: {e}")
            # Clean up on error
            if temp_id in self.conversations:
                del self.conversations[temp_id]
            raise
    
    def clear_conversation(self, conversation_id: str):
        """Clear a conversation"""
        if conversation_id in self.conversations:
            del self.conversations[conversation_id]
            logger.info(f"Cleared conversation: {conversation_id}")
    
    def get_model_info(self) -> Dict[str, Any]:
        """Get model information"""
        return {
            "model_name": self.model_name,
            "ollama_url": self.ollama_base_url,
            "max_history": self.max_history,
            "active_conversations": len(self.conversations),
            "status": "connected" if self.is_model_loaded() else "disconnected"
        }
