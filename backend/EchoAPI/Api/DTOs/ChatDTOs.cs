using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Api.DTOs
{
    /// <summary>
    /// Request to send a chat message
    /// </summary>
    public class SendChatRequest
    {
        /// <summary>
        /// User message text
        /// </summary>
        [Required(ErrorMessage = "Message is required")]
        [MaxLength(2000, ErrorMessage = "Message cannot exceed 2000 characters")]
        public string Message { get; set; } = string.Empty;

        /// <summary>
        /// Optional conversation ID to continue existing conversation
        /// </summary>
        public string? ConversationId { get; set; }

        /// <summary>
        /// Optional custom system prompt for this conversation
        /// </summary>
        [MaxLength(500, ErrorMessage = "System prompt cannot exceed 500 characters")]
        public string? SystemPrompt { get; set; }

        /// <summary>
        /// Optional temperature (0.0-2.0). Higher = more creative
        /// </summary>
        [Range(0.0, 2.0, ErrorMessage = "Temperature must be between 0.0 and 2.0")]
        public double? Temperature { get; set; }

        /// <summary>
        /// Optional max tokens to generate
        /// </summary>
        [Range(1, 2048, ErrorMessage = "MaxTokens must be between 1 and 2048")]
        public int? MaxTokens { get; set; }
    }

    /// <summary>
    /// Response containing chat message
    /// </summary>
    public class ChatMessageResponse
    {
        /// <summary>
        /// AI assistant response text
        /// </summary>
        public string Response { get; set; } = string.Empty;

        /// <summary>
        /// Conversation ID for continuing this conversation
        /// </summary>
        public string ConversationId { get; set; } = string.Empty;

        /// <summary>
        /// Number of tokens used in generation
        /// </summary>
        public int? TokensUsed { get; set; }

        /// <summary>
        /// Timestamp of response
        /// </summary>
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Request to correct text
    /// </summary>
    public class CorrectTextRequest
    {
        /// <summary>
        /// Text to correct
        /// </summary>
        [Required(ErrorMessage = "Text is required")]
        [MaxLength(1000, ErrorMessage = "Text cannot exceed 1000 characters")]
        public string Text { get; set; } = string.Empty;

        /// <summary>
        /// Target language code (e.g., "en", "es", "fr")
        /// </summary>
        [MaxLength(10)]
        public string TargetLanguage { get; set; } = "en";

        /// <summary>
        /// Whether to include explanations for corrections
        /// </summary>
        public bool ProvideExplanation { get; set; } = true;
    }

    /// <summary>
    /// Response containing text corrections
    /// </summary>
    public class TextCorrectionResponse
    {
        /// <summary>
        /// Original text
        /// </summary>
        public string OriginalText { get; set; } = string.Empty;

        /// <summary>
        /// Corrected text
        /// </summary>
        public string CorrectedText { get; set; } = string.Empty;

        /// <summary>
        /// List of individual corrections
        /// </summary>
        public List<CorrectionDetailDto> Corrections { get; set; } = new();

        /// <summary>
        /// Overall explanation of corrections
        /// </summary>
        public string? Explanation { get; set; }

        /// <summary>
        /// Whether any corrections were made
        /// </summary>
        public bool HasCorrections => Corrections.Any();
    }

    /// <summary>
    /// Individual correction detail
    /// </summary>
    public class CorrectionDetailDto
    {
        /// <summary>
        /// Original incorrect text
        /// </summary>
        public string Original { get; set; } = string.Empty;

        /// <summary>
        /// Corrected text
        /// </summary>
        public string Corrected { get; set; } = string.Empty;

        /// <summary>
        /// Type of error (e.g., "grammar", "spelling", "vocabulary")
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// Explanation of the correction
        /// </summary>
        public string Explanation { get; set; } = string.Empty;
    }

    /// <summary>
    /// Generic API response wrapper
    /// </summary>
    public class ApiResponse<T>
    {
        /// <summary>
        /// Whether the request was successful
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Response data
        /// </summary>
        public T? Data { get; set; }

        /// <summary>
        /// Error message if unsuccessful
        /// </summary>
        public string? Error { get; set; }

        /// <summary>
        /// Timestamp of response
        /// </summary>
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        public static ApiResponse<T> SuccessResponse(T data) => new()
        {
            Success = true,
            Data = data
        };

        public static ApiResponse<T> ErrorResponse(string error) => new()
        {
            Success = false,
            Error = error
        };
    }
}
