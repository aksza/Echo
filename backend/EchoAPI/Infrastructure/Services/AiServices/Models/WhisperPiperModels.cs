using System.Text.Json.Serialization;

namespace EchoAPI.Infrastructure.Services.AiServices.Models
{
    // ============ WHISPER SERVICE MODELS (STT) ============

    /// <summary>
    /// Transcription segment with timing information
    /// </summary>
    public class TranscriptionSegment
    {
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [JsonPropertyName("start")]
        public double Start { get; set; }

        [JsonPropertyName("end")]
        public double End { get; set; }

        [JsonPropertyName("text")]
        public string Text { get; set; } = string.Empty;
    }

    /// <summary>
    /// Response from Whisper transcription
    /// </summary>
    public class TranscriptionResponse
    {
        [JsonPropertyName("text")]
        public string Text { get; set; } = string.Empty;

        [JsonPropertyName("language")]
        public string Language { get; set; } = string.Empty;

        [JsonPropertyName("duration")]
        public double? Duration { get; set; }

        [JsonPropertyName("segments")]
        public List<TranscriptionSegment>? Segments { get; set; }
    }

    // ============ PIPER SERVICE MODELS (TTS) ============

    /// <summary>
    /// Request for text-to-speech synthesis
    /// </summary>
    public class SynthesisRequest
    {
        [JsonPropertyName("text")]
        public string Text { get; set; } = string.Empty;

        [JsonPropertyName("language")]
        public string? Language { get; set; }

        [JsonPropertyName("voice")]
        public string? Voice { get; set; }
    }

    /// <summary>
    /// Response from text-to-speech synthesis (metadata only)
    /// </summary>
    public class SynthesisResponse
    {
        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        [JsonPropertyName("audio_duration")]
        public double? AudioDuration { get; set; }

        [JsonPropertyName("sample_rate")]
        public int SampleRate { get; set; }

        [JsonPropertyName("text_length")]
        public int TextLength { get; set; }
    }

    // ============ SHARED HEALTH CHECK ============

    /// <summary>
    /// Health check response from Whisper service
    /// </summary>
    public class WhisperHealthResponse
    {
        [JsonPropertyName("status")]
        public string Status { get; set; } = string.Empty;

        [JsonPropertyName("service")]
        public string Service { get; set; } = string.Empty;

        [JsonPropertyName("model_loaded")]
        public bool ModelLoaded { get; set; }

        [JsonPropertyName("model_name")]
        public string ModelName { get; set; } = string.Empty;
    }

    /// <summary>
    /// Health check response from Piper service
    /// </summary>
    public class PiperHealthResponse
    {
        [JsonPropertyName("status")]
        public string Status { get; set; } = string.Empty;

        [JsonPropertyName("service")]
        public string Service { get; set; } = string.Empty;

        [JsonPropertyName("voice_model_loaded")]
        public bool VoiceModelLoaded { get; set; }
    }
}
