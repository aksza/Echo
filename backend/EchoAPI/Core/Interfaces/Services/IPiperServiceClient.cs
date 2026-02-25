using EchoAPI.Infrastructure.Services.AiServices.Models;

namespace EchoAPI.Core.Interfaces.Services
{
    /// <summary>
    /// Interface for Piper text-to-speech service client
    /// </summary>
    public interface IPiperServiceClient
    {
        /// <summary>
        /// Synthesize text to speech and return audio stream
        /// </summary>
        /// <param name="text">Text to convert to speech</param>
        /// <param name="language">Optional language/voice code (e.g., "en_US")</param>
        /// <returns>Audio stream (WAV format)</returns>
        Task<Stream> SynthesizeToStreamAsync(string text, string? language = null);

        /// <summary>
        /// Synthesize text to speech and get metadata
        /// </summary>
        /// <param name="text">Text to convert to speech</param>
        /// <param name="language">Optional language/voice code</param>
        /// <returns>Synthesis metadata (no audio)</returns>
        Task<SynthesisResponse> SynthesizeAsync(string text, string? language = null);

        /// <summary>
        /// Check if Piper service is healthy
        /// </summary>
        /// <returns>Health status</returns>
        Task<PiperHealthResponse> HealthCheckAsync();
    }
}
