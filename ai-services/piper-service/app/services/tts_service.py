import wave
import io
import logging
from pathlib import Path
from typing import Optional
from piper.voice import PiperVoice

logger = logging.getLogger(__name__)


class TTSService:
    """Text-to-Speech service using Piper"""
    
    def __init__(self, model_path: str):
        """
        Initialize TTS service
        
        Args:
            model_path: Path to the Piper voice model (.onnx file)
        """
        self.model_path = Path(model_path)
        self.voice: Optional[PiperVoice] = None
        self._load_model()
    
    def _load_model(self):
        """Load the Piper voice model"""
        try:
            if not self.model_path.exists():
                raise FileNotFoundError(f"Voice model not found: {self.model_path}")
            
            logger.info(f"Loading voice model from {self.model_path}")
            self.voice = PiperVoice.load(str(self.model_path))
            logger.info("Voice model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load voice model: {e}")
            raise
    
    def is_model_loaded(self) -> bool:
        """Check if the voice model is loaded"""
        return self.voice is not None
    
    def synthesize(self, text: str) -> bytes:
        """
        Convert text to speech
        
        Args:
            text: Text to convert to speech
            
        Returns:
            WAV audio data as bytes
            
        Raises:
            ValueError: If model is not loaded or text is invalid
        """
        if not self.voice:
            raise ValueError("Voice model not loaded")
        
        if not text or not text.strip():
            raise ValueError("Text cannot be empty")
        
        try:
            logger.info(f"Synthesizing text: {text[:50]}...")
            
            # Create in-memory WAV file
            wav_buffer = io.BytesIO()
            
            with wave.open(wav_buffer, "wb") as wav_file:
                self.voice.synthesize_wav(text, wav_file)
            
            # Get the audio data
            audio_data = wav_buffer.getvalue()
            
            logger.info(f"Synthesis complete. Audio size: {len(audio_data)} bytes")
            return audio_data
            
        except Exception as e:
            logger.error(f"Synthesis failed: {e}")
            raise
    
    def get_sample_rate(self) -> int:
        """Get the sample rate of the voice model"""
        if not self.voice:
            raise ValueError("Voice model not loaded")
        return self.voice.config.sample_rate
    
    def get_audio_duration(self, audio_data: bytes) -> float:
        """
        Calculate audio duration from WAV data
        
        Args:
            audio_data: WAV audio data
            
        Returns:
            Duration in seconds
        """
        try:
            wav_buffer = io.BytesIO(audio_data)
            with wave.open(wav_buffer, "rb") as wav_file:
                frames = wav_file.getnframes()
                rate = wav_file.getframerate()
                duration = frames / float(rate)
                return round(duration, 2)
        except Exception as e:
            logger.warning(f"Could not calculate duration: {e}")
            return 0.0
