using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Api.DTOs
{
    /// <summary>
    /// Request for voice conversation
    /// </summary>
    public class VoiceConversationRequest
    {
        /// <summary>
        /// Audio file (wav, mp3, ogg, webm, m4a, flac)
        /// </summary>
        [Required]
        public IFormFile AudioFile { get; set; } = null!;

        /// <summary>
        /// Optional AI conversation ID to continue Phi3 conversation
        /// </summary>
        public string? ConversationId { get; set; }

        /// <summary>
        /// Optional app session ID to continue stored learning session
        /// </summary>
        public Guid? SessionId { get; set; }

        /// <summary>
        /// Optional session type, for example Conversation or LessonConversation
        /// </summary>
        public string? SessionType { get; set; }

        /// <summary>
        /// Optional session title
        /// </summary>
        public string? SessionTitle { get; set; }

        /// <summary>
        /// Optional language code (e.g., "en", "hu")
        /// </summary>
        public string? Language { get; set; }

        /// <summary>
        /// Optional custom system prompt
        /// </summary>
        public string? SystemPrompt { get; set; }
    }

    /// <summary>
    /// Request for voice correction
    /// </summary>
    public class VoiceCorrectionRequest
    {
        /// <summary>
        /// Audio file (wav, mp3, ogg, webm, m4a, flac)
        /// </summary>
        [Required]
        public IFormFile AudioFile { get; set; } = null!;

        /// <summary>
        /// Target language code (default: "en")
        /// </summary>
        public string TargetLanguage { get; set; } = "en";

        /// <summary>
        /// Whether to include explanations (default: true)
        /// </summary>
        public bool ProvideExplanation { get; set; } = true;
    }

    /// <summary>
    /// Response for voice conversation
    /// </summary>
    public class VoiceConversationResponse
    {
        /// <summary>
        /// Transcribed text from user's audio
        /// </summary>
        public string UserTranscription { get; set; } = string.Empty;

        /// <summary>
        /// Detected language from audio
        /// </summary>
        public string DetectedLanguage { get; set; } = string.Empty;

        /// <summary>
        /// AI assistant's text response
        /// </summary>
        public string AiResponse { get; set; } = string.Empty;

        /// <summary>
        /// Conversation ID for continuing the Phi3 conversation
        /// </summary>
        public string ConversationId { get; set; } = string.Empty;

        /// <summary>
        /// App session ID stored in the Sessions table
        /// </summary>
        public Guid SessionId { get; set; }

        /// <summary>
        /// URL to the AI's audio response
        /// </summary>
        public string AudioUrl { get; set; } = string.Empty;

        /// <summary>
        /// Number of tokens used
        /// </summary>
        public int? TokensUsed { get; set; }

        /// <summary>
        /// Original audio duration in seconds
        /// </summary>
        public double? AudioDuration { get; set; }

        /// <summary>
        /// Timestamp of processing
        /// </summary>
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Response for voice correction
    /// </summary>
    public class VoiceCorrectionResponse
    {
        /// <summary>
        /// Original transcribed text
        /// </summary>
        public string OriginalText { get; set; } = string.Empty;

        /// <summary>
        /// Corrected text
        /// </summary>
        public string CorrectedText { get; set; } = string.Empty;

        /// <summary>
        /// List of corrections made
        /// </summary>
        public List<CorrectionDetailDto> Corrections { get; set; } = new();

        /// <summary>
        /// Explanation of corrections
        /// </summary>
        public string? Explanation { get; set; }

        /// <summary>
        /// URL to the corrected audio
        /// </summary>
        public string CorrectedAudioUrl { get; set; } = string.Empty;

        /// <summary>
        /// Whether any corrections were found
        /// </summary>
        public bool HasCorrections => Corrections.Any();
    }
}