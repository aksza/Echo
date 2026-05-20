using EchoAPI.Core.Config;
using EchoAPI.Core.Interfaces.Services;
using EchoAPI.Infrastructure.Services.AiServices.Models;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Net.Http.Json;
using System.Text.Json;

namespace EchoAPI.Infrastructure.Services.AiServices
{
    /// <summary>
    /// Client for Phi3 language model service
    /// </summary>
    public class Phi3ServiceClient : IPhi3ServiceClient
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<Phi3ServiceClient> _logger;
        private readonly Phi3ServiceSettings _settings;

        public Phi3ServiceClient(
            HttpClient httpClient,
            IOptions<AiServicesSettings> aiSettings,
            ILogger<Phi3ServiceClient> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _settings = aiSettings.Value.Phi3Service;
        }

        /// <inheritdoc/>
        public async Task<ChatResponse> ChatAsync(
            string message,
            string? conversationId = null,
            string? systemPrompt = null,
            double? temperature = null,
            int? maxTokens = null)
        {
            if (string.IsNullOrWhiteSpace(message))
                throw new ArgumentException("Message cannot be empty", nameof(message));

            if (!_settings.Enabled)
                throw new InvalidOperationException("Phi3 service is disabled");

            // Force short conversational responses
            var shortResponseRules = """
                IMPORTANT RESPONSE RULES:
                - Keep responses VERY short.
                - Maximum 1-2 sentences.
                - Prefer natural conversational replies.
                - Do not give long explanations.
                - Do not teach grammar unless explicitly asked.
                - Keep answers under 30 words whenever possible.
                - Sound like a real conversation partner.
                """;

            var finalPrompt = string.IsNullOrWhiteSpace(systemPrompt)
                ? shortResponseRules
                : $"{systemPrompt}\n\n{shortResponseRules}";

            var request = new ChatRequest
            {
                Message = message,
                ConversationId = conversationId,
                SystemPrompt = finalPrompt,

                //  Better defaults for conversation
                Temperature = temperature ?? 0.7,

                // Prevent giant responses
                MaxTokens = maxTokens ?? 60
            };

            _logger.LogInformation(
                "Sending chat request. ConversationId: {ConversationId}, Message length: {Length}",
                conversationId ?? "new",
                message.Length);

            try
            {
                var response = await _httpClient.PostAsJsonAsync("chat", request);
                response.EnsureSuccessStatusCode();

                var chatResponse =
                    await response.Content.ReadFromJsonAsync<ChatResponse>();

                if (chatResponse == null)
                    throw new InvalidOperationException(
                        "Failed to deserialize chat response");

                _logger.LogInformation(
                    "Chat response received. ConversationId: {ConversationId}, Tokens: {Tokens}",
                    chatResponse.ConversationId,
                    chatResponse.TokensUsed);

                return chatResponse;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "HTTP error calling Phi3 service");

                throw new InvalidOperationException(
                    "Failed to communicate with Phi3 service",
                    ex);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Failed to deserialize Phi3 response");

                throw new InvalidOperationException(
                    "Invalid response from Phi3 service",
                    ex);
            }
        }

        /// <inheritdoc/>
        public async Task<CorrectionResponse> CorrectTextAsync(
            string text,
            string targetLanguage = "en",
            bool provideExplanation = true)
        {
            if (string.IsNullOrWhiteSpace(text))
                throw new ArgumentException("Text cannot be empty", nameof(text));

            if (!_settings.Enabled)
                throw new InvalidOperationException("Phi3 service is disabled");

            var request = new CorrectionRequest
            {
                Text = text,
                TargetLanguage = targetLanguage,
                ProvideExplanation = provideExplanation
            };

            _logger.LogInformation(
                "Sending correction request. Language: {Language}, Text length: {Length}",
                targetLanguage,
                text.Length);

            try
            {
                var response =
                    await _httpClient.PostAsJsonAsync("correct", request);

                response.EnsureSuccessStatusCode();

                var correctionResponse =
                    await response.Content.ReadFromJsonAsync<CorrectionResponse>();

                if (correctionResponse == null)
                    throw new InvalidOperationException(
                        "Failed to deserialize correction response");

                _logger.LogInformation(
                    "Correction response received. Corrections count: {Count}",
                    correctionResponse.Corrections.Count);

                return correctionResponse;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(
                    ex,
                    "HTTP error calling Phi3 correction endpoint");

                throw new InvalidOperationException(
                    "Failed to communicate with Phi3 service",
                    ex);
            }
            catch (JsonException ex)
            {
                _logger.LogError(
                    ex,
                    "Failed to deserialize correction response");

                throw new InvalidOperationException(
                    "Invalid response from Phi3 service",
                    ex);
            }
        }

        /// <inheritdoc/>
        public async Task DeleteConversationAsync(string conversationId)
        {
            if (string.IsNullOrWhiteSpace(conversationId))
                throw new ArgumentException(
                    "ConversationId cannot be empty",
                    nameof(conversationId));

            if (!_settings.Enabled)
            {
                _logger.LogWarning(
                    "Phi3 service is disabled, skipping conversation deletion");

                return;
            }

            _logger.LogInformation(
                "Deleting conversation: {ConversationId}",
                conversationId);

            try
            {
                var response =
                    await _httpClient.DeleteAsync(
                        $"conversation/{conversationId}");

                response.EnsureSuccessStatusCode();

                _logger.LogInformation(
                    "Conversation deleted: {ConversationId}",
                    conversationId);
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(
                    ex,
                    "HTTP error deleting conversation: {ConversationId}",
                    conversationId);

                // Best-effort cleanup
            }
        }

        /// <inheritdoc/>
        public async Task<Phi3HealthResponse> HealthCheckAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("health");

                response.EnsureSuccessStatusCode();

                var healthResponse =
                    await response.Content.ReadFromJsonAsync<Phi3HealthResponse>();

                if (healthResponse == null)
                    throw new InvalidOperationException(
                        "Failed to deserialize health response");

                return healthResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check failed for Phi3 service");

                return new Phi3HealthResponse
                {
                    Status = "unhealthy",
                    Service = "phi3-service",
                    ModelLoaded = false,
                    ModelName = "unknown"
                };
            }
        }
    }
}