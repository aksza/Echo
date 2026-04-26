using EchoAPI.Core.Config;
using Microsoft.Extensions.Options;

namespace EchoAPI.Core.Interfaces.Services
{
    /// <summary>
    /// Interface for audio file storage operations
    /// </summary>
    public interface IAudioStorageService
    {
        /// <summary>
        /// Save audio stream to storage
        /// </summary>
        /// <param name="audioStream">Audio data stream</param>
        /// <param name="fileName">Filename (will be sanitized)</param>
        /// <returns>Relative file path</returns>
        Task<string> SaveAudioAsync(Stream audioStream, string fileName);

        /// <summary>
        /// Get audio file stream
        /// </summary>
        /// <param name="filePath">Relative file path</param>
        /// <returns>Audio stream</returns>
        Task<Stream> GetAudioAsync(string filePath);

        /// <summary>
        /// Delete audio file
        /// </summary>
        /// <param name="filePath">Relative file path</param>
        Task DeleteAudioAsync(string filePath);

        /// <summary>
        /// Delete old audio files based on retention policy
        /// </summary>
        Task CleanupOldFilesAsync();

        /// <summary>
        /// Get full URL for audio file
        /// </summary>
        /// <param name="filePath">Relative file path</param>
        /// <param name="baseUrl">Base URL of the application</param>
        /// <returns>Full URL</returns>
        string GetAudioUrl(string filePath, string baseUrl);
    }
}
