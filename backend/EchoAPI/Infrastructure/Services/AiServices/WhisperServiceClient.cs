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
    /// Client for Whisper speech-to-text service
    /// </summary>
    public class WhisperServiceClient : IWhisperServiceClient
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<WhisperServiceClient> _logger;
        private readonly WhisperServiceSettings _settings;

        public WhisperServiceClient(
            HttpClient httpClient,
            IOptions<AiServicesSettings> aiSettings,
            ILogger<WhisperServiceClient> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _settings = aiSettings.Value.WhisperService;
        }

        /// <inheritdoc/>
        public async Task<TranscriptionResponse> TranscribeAsync(
            Stream audioStream,
            string fileName,
            string? language = null,
            bool returnSegments = false)
        {
            if (audioStream == null || audioStream.Length == 0)
                throw new ArgumentException("Audio stream cannot be empty", nameof(audioStream));

            if (!_settings.Enabled)
                throw new InvalidOperationException("Whisper service is disabled");

            // Check file size
            var fileSizeMB = audioStream.Length / (1024.0 * 1024.0);
            if (fileSizeMB > _settings.MaxFileSizeMB)
            {
                throw new ArgumentException(
                    $"Audio file too large ({fileSizeMB:F2}MB). Maximum: {_settings.MaxFileSizeMB}MB");
            }

            _logger.LogInformation(
                "Transcribing audio file: {FileName}, Size: {SizeMB:F2}MB, Language: {Language}",
                fileName,
                fileSizeMB,
                language ?? "auto-detect");

            try
            {
                using var content = new MultipartFormDataContent();
                
                // Add audio file
                var streamContent = new StreamContent(audioStream);
                streamContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(
                    GetContentType(fileName));
                content.Add(streamContent, "file", fileName);

                // Add optional parameters
                if (!string.IsNullOrEmpty(language))
                {
                    content.Add(new StringContent(language), "language");
                }

                if (returnSegments)
                {
                    content.Add(new StringContent("true"), "return_segments");
                }

                var response = await _httpClient.PostAsync("transcribe", content);
                response.EnsureSuccessStatusCode();

                var transcriptionResponse = await response.Content.ReadFromJsonAsync<TranscriptionResponse>();

                if (transcriptionResponse == null)
                    throw new InvalidOperationException("Failed to deserialize transcription response");

                _logger.LogInformation(
                    "Transcription successful. Text length: {Length}, Language: {Language}, Duration: {Duration}s",
                    transcriptionResponse.Text.Length,
                    transcriptionResponse.Language,
                    transcriptionResponse.Duration);

                return transcriptionResponse;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "HTTP error calling Whisper service");
                throw new InvalidOperationException("Failed to communicate with Whisper service", ex);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Failed to deserialize Whisper response");
                throw new InvalidOperationException("Invalid response from Whisper service", ex);
            }
        }

        /// <inheritdoc/>
        public async Task<WhisperHealthResponse> HealthCheckAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("health");
                response.EnsureSuccessStatusCode();

                var healthResponse = await response.Content.ReadFromJsonAsync<WhisperHealthResponse>();

                if (healthResponse == null)
                    throw new InvalidOperationException("Failed to deserialize health response");

                return healthResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check failed for Whisper service");
                return new WhisperHealthResponse
                {
                    Status = "unhealthy",
                    Service = "whisper-service",
                    ModelLoaded = false,
                    ModelName = "unknown"
                };
            }
        }

        private static string GetContentType(string fileName)
        {
            var extension = Path.GetExtension(fileName).ToLowerInvariant();
            return extension switch
            {
                ".wav" => "audio/wav",
                ".mp3" => "audio/mpeg",
                ".ogg" => "audio/ogg",
                ".webm" => "audio/webm",
                ".m4a" => "audio/mp4",
                ".flac" => "audio/flac",
                _ => "application/octet-stream"
            };
        }
    }
}
