using EchoAPI.Infrastructure.Services.AiServices.Models;

namespace EchoAPI.Core.Interfaces.Services
{
    /// <summary>
    /// Interface for Phi3 language model service client
    /// </summary>
    public interface IPhi3ServiceClient
    {
        /// <summary>
        /// Send a chat message and get AI response
        /// </summary>
        /// <param name="message">User message</param>
        /// <param name="conversationId">Optional conversation ID for context</param>
        /// <param name="systemPrompt">Optional custom system prompt</param>
        /// <param name="temperature">Optional temperature (0.0-2.0)</param>
        /// <param name="maxTokens">Optional max tokens to generate</param>
        /// <returns>Chat response with conversation ID</returns>
        Task<ChatResponse> ChatAsync(
            string message,
            string? conversationId = null,
            string? systemPrompt = null,
            double? temperature = null,
            int? maxTokens = null);

        /// <summary>
        /// Correct text and get language corrections
        /// </summary>
        /// <param name="text">Text to correct</param>
        /// <param name="targetLanguage">Target language code (default: "en")</param>
        /// <param name="provideExplanation">Whether to provide explanation</param>
        /// <returns>Correction response with corrections list</returns>
        Task<CorrectionResponse> CorrectTextAsync(
            string text,
            string targetLanguage = "en",
            bool provideExplanation = true);

        /// <summary>
        /// Delete a conversation from server memory
        /// </summary>
        /// <param name="conversationId">Conversation ID to delete</param>
        Task DeleteConversationAsync(string conversationId);

        /// <summary>
        /// Check if Phi3 service is healthy
        /// </summary>
        /// <returns>Health status</returns>
        Task<Phi3HealthResponse> HealthCheckAsync();
    }
}
