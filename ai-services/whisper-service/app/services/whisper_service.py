from faster_whisper import WhisperModel
import logging
import tempfile
import os
from pathlib import Path
from typing import Optional, Dict, Any, List

logger = logging.getLogger(__name__)


class WhisperService:
    """Speech-to-Text service using Faster Whisper"""
    
    def __init__(self, model_name: str = "base", device: str = "cpu"):
        """
        Initialize Whisper service
        
        Args:
            model_name: Whisper model name (tiny, base, small, medium, large)
            device: Device to run on (cpu or cuda)
        """
        self.model_name = model_name
        self.device = device
        self.compute_type = "int8" if device == "cpu" else "float16"
        self.model: Optional[WhisperModel] = None
        self._load_model()
    
    def _load_model(self):
        """Load the Faster Whisper model"""
        try:
            logger.info(f"Loading Faster-Whisper model: {self.model_name} on {self.device}")
            self.model = WhisperModel(
                self.model_name,
                device=self.device,
                compute_type=self.compute_type
            )
            logger.info("Faster-Whisper model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load Faster-Whisper model: {e}")
            raise
    
    def is_model_loaded(self) -> bool:
        """Check if the model is loaded"""
        return self.model is not None
    
    def transcribe(
        self,
        audio_path: str,
        language: Optional[str] = None,
        task: str = "transcribe",
        return_segments: bool = False
    ) -> Dict[str, Any]:
        """
        Transcribe audio file using Faster Whisper
        
        Args:
            audio_path: Path to audio file
            language: Language code (None for auto-detection)
            task: "transcribe" or "translate" (to English)
            return_segments: Whether to return detailed segments
            
        Returns:
            Dictionary with transcription results
            
        Raises:
            ValueError: If model is not loaded or audio file is invalid
        """
        if not self.model:
            raise ValueError("Whisper model not loaded")
        
        if not os.path.exists(audio_path):
            raise ValueError(f"Audio file not found: {audio_path}")
        
        try:
            logger.info(f"Transcribing audio: {audio_path}")
            logger.info(f"Language: {language or 'auto-detect'}, Task: {task}")
            
            # Transcribe with Faster Whisper
            segments_iter, info = self.model.transcribe(
                audio_path,
                language=language,
                task=task,
                vad_filter=True,  # Voice activity detection
                beam_size=5
            )
            
            # Convert iterator to list
            segments_list = list(segments_iter)
            
            # Combine all segments into full text
            full_text = " ".join([seg.text.strip() for seg in segments_list])
            
            # Prepare response
            response = {
                "text": full_text,
                "language": info.language if hasattr(info, 'language') else (language or "unknown")
            }
            
            # Add segments if requested
            if return_segments:
                response["segments"] = [
                    {
                        "id": i,
                        "start": seg.start,
                        "end": seg.end,
                        "text": seg.text.strip()
                    }
                    for i, seg in enumerate(segments_list)
                ]
            
            logger.info(f"Transcription complete. Length: {len(response['text'])} chars")
            return response
            
        except Exception as e:
            logger.error(f"Transcription failed: {e}")
            raise
    
    def transcribe_bytes(
        self,
        audio_bytes: bytes,
        filename: str,
        language: Optional[str] = None,
        task: str = "transcribe",
        return_segments: bool = False
    ) -> Dict[str, Any]:
        """
        Transcribe audio from bytes
        
        Args:
            audio_bytes: Audio file bytes
            filename: Original filename (for extension)
            language: Language code
            task: transcribe or translate
            return_segments: Return detailed segments
            
        Returns:
            Dictionary with transcription results
        """
        # Get file extension
        ext = Path(filename).suffix or ".wav"
        
        # Create temporary file
        with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp_file:
            tmp_file.write(audio_bytes)
            tmp_path = tmp_file.name
        
        try:
            # Transcribe
            result = self.transcribe(
                tmp_path,
                language=language,
                task=task,
                return_segments=return_segments
            )
            return result
        finally:
            # Clean up temporary file
            try:
                os.unlink(tmp_path)
            except Exception as e:
                logger.warning(f"Failed to delete temporary file: {e}")
    
    def get_available_models(self) -> list:
        """Get list of available Whisper models"""
        return ["tiny", "base", "small", "medium", "large"]
    
    def get_model_info(self) -> Dict[str, str]:
        """Get information about the loaded model"""
        return {
            "model_name": self.model_name,
            "device": self.device,
            "status": "loaded" if self.is_model_loaded() else "not_loaded"
        }
