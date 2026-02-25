using System.Text.Json.Serialization;

namespace EchoAPI.Infrastructure.Services.AiServices.Models
{
    /// <summary>
    /// Request model for chat completion
    /// </summary>
    public class ChatRequest
    {
        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        [JsonPropertyName("conversation_id")]
        public string? ConversationId { get; set; }

        [JsonPropertyName("system_prompt")]
        public string? SystemPrompt { get; set; }

        [JsonPropertyName("temperature")]
        public double? Temperature { get; set; }

        [JsonPropertyName("max_tokens")]
        public int? MaxTokens { get; set; }
    }

    /// <summary>
    /// Response model from chat completion
    /// </summary>
    public class ChatResponse
    {
        [JsonPropertyName("response")]
        public string Response { get; set; } = string.Empty;

        [JsonPropertyName("conversation_id")]
        public string ConversationId { get; set; } = string.Empty;

        [JsonPropertyName("tokens_used")]
        public int? TokensUsed { get; set; }
    }

    /// <summary>
    /// Request model for text correction
    /// </summary>
    public class CorrectionRequest
    {
        [JsonPropertyName("text")]
        public string Text { get; set; } = string.Empty;

        [JsonPropertyName("target_language")]
        public string TargetLanguage { get; set; } = "en";

        [JsonPropertyName("provide_explanation")]
        public bool ProvideExplanation { get; set; } = true;
    }

    /// <summary>
    /// Response model from text correction
    /// </summary>
    public class CorrectionResponse
    {
        [JsonPropertyName("original_text")]
        public string OriginalText { get; set; } = string.Empty;

        [JsonPropertyName("corrected_text")]
        public string CorrectedText { get; set; } = string.Empty;

        [JsonPropertyName("corrections")]
        public List<CorrectionDetail> Corrections { get; set; } = new();

        [JsonPropertyName("explanation")]
        public string? Explanation { get; set; }
    }

    /// <summary>
    /// Individual correction detail
    /// </summary>
    public class CorrectionDetail
    {
        [JsonPropertyName("original")]
        public string Original { get; set; } = string.Empty;

        [JsonPropertyName("corrected")]
        public string Corrected { get; set; } = string.Empty;

        [JsonPropertyName("type")]
        public string Type { get; set; } = string.Empty;

        [JsonPropertyName("explanation")]
        public string Explanation { get; set; } = string.Empty;
    }

    /// <summary>
    /// Health check response from Phi3 service
    /// </summary>
    public class Phi3HealthResponse
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
}
