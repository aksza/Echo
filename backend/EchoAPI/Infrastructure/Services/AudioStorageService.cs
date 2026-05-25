using EchoAPI.Core.Config;
using EchoAPI.Core.Interfaces.Services;
using Microsoft.Extensions.Options;

namespace EchoAPI.Infrastructure.Services
{
    /// <summary>
    /// Service for managing audio file storage
    /// </summary>
    public class AudioStorageService : IAudioStorageService
    {
        private readonly StorageSettings _settings;
        private readonly ILogger<AudioStorageService> _logger;
        private readonly string _basePath;

        public AudioStorageService(
            IOptions<StorageSettings> settings,
            ILogger<AudioStorageService> logger,
            IWebHostEnvironment environment)
        {
            _settings = settings.Value;
            _logger = logger;
            _basePath = Path.Combine(environment.ContentRootPath, _settings.AudioFilesPath);

            // Ensure directory exists
            if (!Directory.Exists(_basePath))
            {
                Directory.CreateDirectory(_basePath);
                _logger.LogInformation("Created audio storage directory: {Path}", _basePath);
            }
        }

        /// <inheritdoc/>
        public async Task<string> SaveAudioAsync(Stream audioStream, string fileName)
        {
            if (audioStream == null || audioStream.Length == 0)
                throw new ArgumentException("Audio stream cannot be empty", nameof(audioStream));

            // Validate file size
            var fileSizeMB = audioStream.Length / (1024.0 * 1024.0);
            if (fileSizeMB > _settings.MaxAudioFileSizeMB)
            {
                throw new ArgumentException(
                    $"Audio file too large ({fileSizeMB:F2}MB). Maximum: {_settings.MaxAudioFileSizeMB}MB");
            }

            // Sanitize and validate filename
            var extension = Path.GetExtension(fileName).ToLowerInvariant();
            if (!_settings.IsFormatAllowed(extension))
            {
                throw new ArgumentException(
                    $"File format '{extension}' not allowed. Allowed: {string.Join(", ", _settings.AllowedAudioFormats)}");
            }

            // Generate unique filename
            var uniqueFileName = $"{Guid.NewGuid()}{extension}";
            var relativeFilePath = Path.Combine("audio", uniqueFileName);
            var fullPath = Path.Combine(_basePath, uniqueFileName);

            _logger.LogInformation(
                "Saving audio file: {FileName}, Size: {SizeMB:F2}MB",
                uniqueFileName,
                fileSizeMB);

            try
            {
                using var fileStream = new FileStream(fullPath, FileMode.Create, FileAccess.Write);
                audioStream.Position = 0;
                await audioStream.CopyToAsync(fileStream);

                _logger.LogInformation("Audio file saved: {Path}", relativeFilePath);
                return relativeFilePath;
            }
            catch (IOException ex)
            {
                _logger.LogError(ex, "Failed to save audio file: {Path}", fullPath);
                throw new InvalidOperationException("Failed to save audio file", ex);
            }
        }

        /// <inheritdoc/>
        public async Task<Stream> GetAudioAsync(string filePath)
        {
            if (string.IsNullOrWhiteSpace(filePath))
                throw new ArgumentException("File path cannot be empty", nameof(filePath));

            var fileName = Path.GetFileName(filePath);
            var fullPath = Path.Combine(_basePath, fileName);

            if (!File.Exists(fullPath))
            {
                _logger.LogWarning("Audio file not found: {Path}", fullPath);
                throw new FileNotFoundException("Audio file not found", filePath);
            }

            _logger.LogInformation("Reading audio file: {Path}", filePath);

            try
            {
                var fileStream = new FileStream(fullPath, FileMode.Open, FileAccess.Read, FileShare.Read);
                return fileStream;
            }
            catch (IOException ex)
            {
                _logger.LogError(ex, "Failed to read audio file: {Path}", fullPath);
                throw new InvalidOperationException("Failed to read audio file", ex);
            }
        }

        /// <inheritdoc/>
        public async Task DeleteAudioAsync(string filePath)
        {
            if (string.IsNullOrWhiteSpace(filePath))
                return;

            var fileName = Path.GetFileName(filePath);
            var fullPath = Path.Combine(_basePath, fileName);

            if (File.Exists(fullPath))
            {
                try
                {
                    File.Delete(fullPath);
                    _logger.LogInformation("Deleted audio file: {Path}", filePath);
                }
                catch (IOException ex)
                {
                    _logger.LogError(ex, "Failed to delete audio file: {Path}", fullPath);
                    // Don't throw - deletion is best-effort
                }
            }

            await Task.CompletedTask;
        }

        /// <inheritdoc/>
        public async Task CleanupOldFilesAsync()
        {
            if (!Directory.Exists(_basePath))
                return;

            var cutoffDate = DateTime.UtcNow.AddDays(-_settings.RetentionDays);
            var deletedCount = 0;

            _logger.LogInformation(
                "Starting audio cleanup. Retention: {Days} days, Cutoff: {Date}",
                _settings.RetentionDays,
                cutoffDate);

            try
            {
                var files = Directory.GetFiles(_basePath);

                foreach (var filePath in files)
                {
                    var fileInfo = new FileInfo(filePath);
                    if (fileInfo.CreationTimeUtc < cutoffDate)
                    {
                        try
                        {
                            File.Delete(filePath);
                            deletedCount++;
                        }
                        catch (IOException ex)
                        {
                            _logger.LogError(ex, "Failed to delete old file: {Path}", filePath);
                        }
                    }
                }

                _logger.LogInformation("Audio cleanup completed. Deleted {Count} files", deletedCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during audio cleanup");
            }

            await Task.CompletedTask;
        }

        /// <inheritdoc/>
        public string GetAudioUrl(string filePath, string baseUrl)
        {
            if (string.IsNullOrWhiteSpace(filePath))
                throw new ArgumentException("File path cannot be empty", nameof(filePath));

            var fileName = Path.GetFileName(filePath);
            return $"{baseUrl.TrimEnd('/')}/api/conversation/audio/{fileName}";
        }
    }
}
