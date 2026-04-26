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
    /// Client for Piper text-to-speech service
    /// </summary>
    public class PiperServiceClient : IPiperServiceClient
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<PiperServiceClient> _logger;
        private readonly PiperServiceSettings _settings;

        public PiperServiceClient(
            HttpClient httpClient,
            IOptions<AiServicesSettings> aiSettings,
            ILogger<PiperServiceClient> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _settings = aiSettings.Value.PiperService;
        }

        /// <inheritdoc/>
        public async Task<Stream> SynthesizeToStreamAsync(string text, string? language = null)
        {
            if (string.IsNullOrWhiteSpace(text))
                throw new ArgumentException("Text cannot be empty", nameof(text));

            if (!_settings.Enabled)
                throw new InvalidOperationException("Piper service is disabled");

            if (text.Length > _settings.MaxTextLength)
            {
                throw new ArgumentException(
                    $"Text too long ({text.Length} chars). Maximum: {_settings.MaxTextLength}");
            }

            _logger.LogInformation(
                "Synthesizing text to audio. Length: {Length}, Language: {Language}",
                text.Length,
                language ?? _settings.DefaultLanguage);

            try
            {
                var request = new SynthesisRequest
                {
                    Text = text,
                    Language = language ?? _settings.DefaultLanguage
                };

                var response = await _httpClient.PostAsJsonAsync("synthesize/audio", request);
                response.EnsureSuccessStatusCode();

                // Return the audio stream directly
                var audioStream = await response.Content.ReadAsStreamAsync();

                _logger.LogInformation("Audio synthesis successful. Text length: {Length}", text.Length);

                return audioStream;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "HTTP error calling Piper service");
                throw new InvalidOperationException("Failed to communicate with Piper service", ex);
            }
        }

        /// <inheritdoc/>
        public async Task<SynthesisResponse> SynthesizeAsync(string text, string? language = null)
        {
            if (string.IsNullOrWhiteSpace(text))
                throw new ArgumentException("Text cannot be empty", nameof(text));

            if (!_settings.Enabled)
                throw new InvalidOperationException("Piper service is disabled");

            if (text.Length > _settings.MaxTextLength)
            {
                throw new ArgumentException(
                    $"Text too long ({text.Length} chars). Maximum: {_settings.MaxTextLength}");
            }

            _logger.LogInformation(
                "Getting synthesis metadata. Text length: {Length}, Language: {Language}",
                text.Length,
                language ?? _settings.DefaultLanguage);

            try
            {
                var request = new SynthesisRequest
                {
                    Text = text,
                    Language = language ?? _settings.DefaultLanguage
                };

                var response = await _httpClient.PostAsJsonAsync("synthesize", request);
                response.EnsureSuccessStatusCode();

                var synthesisResponse = await response.Content.ReadFromJsonAsync<SynthesisResponse>();

                if (synthesisResponse == null)
                    throw new InvalidOperationException("Failed to deserialize synthesis response");

                _logger.LogInformation(
                    "Synthesis metadata received. Duration: {Duration}s",
                    synthesisResponse.AudioDuration);

                return synthesisResponse;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "HTTP error calling Piper service");
                throw new InvalidOperationException("Failed to communicate with Piper service", ex);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Failed to deserialize Piper response");
                throw new InvalidOperationException("Invalid response from Piper service", ex);
            }
        }

        /// <inheritdoc/>
        public async Task<PiperHealthResponse> HealthCheckAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("health");
                response.EnsureSuccessStatusCode();

                var healthResponse = await response.Content.ReadFromJsonAsync<PiperHealthResponse>();

                if (healthResponse == null)
                    throw new InvalidOperationException("Failed to deserialize health response");

                return healthResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check failed for Piper service");
                return new PiperHealthResponse
                {
                    Status = "unhealthy",
                    Service = "piper-service",
                    VoiceModelLoaded = false
                };
            }
        }
    }
}
