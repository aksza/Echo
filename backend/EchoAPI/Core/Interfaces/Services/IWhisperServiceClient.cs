using EchoAPI.Infrastructure.Services.AiServices.Models;

namespace EchoAPI.Core.Interfaces.Services
{
    /// <summary>
    /// Interface for Whisper speech-to-text service client
    /// </summary>
    public interface IWhisperServiceClient
    {
        /// <summary>
        /// Transcribe audio to text
        /// </summary>
        /// <param name="audioStream">Audio file stream</param>
        /// <param name="fileName">Original filename (for content type detection)</param>
        /// <param name="language">Optional language code (e.g., "en", "hu")</param>
        /// <param name="returnSegments">Whether to return detailed segments with timestamps</param>
        /// <returns>Transcription result</returns>
        Task<TranscriptionResponse> TranscribeAsync(
            Stream audioStream,
            string fileName,
            string? language = null,
            bool returnSegments = false);

        /// <summary>
        /// Check if Whisper service is healthy
        /// </summary>
        /// <returns>Health status</returns>
        Task<WhisperHealthResponse> HealthCheckAsync();
    }
}
