using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/conversation")]
    [Authorize]
    public class ConversationSpeechController : ControllerBase
    {
        private readonly IPiperServiceClient _piperClient;
        private readonly IAudioStorageService _audioStorage;
        private readonly ILogger<ConversationSpeechController> _logger;

        public ConversationSpeechController(
            IPiperServiceClient piperClient,
            IAudioStorageService audioStorage,
            ILogger<ConversationSpeechController> logger)
        {
            _piperClient = piperClient;
            _audioStorage = audioStorage;
            _logger = logger;
        }

        [HttpPost("speak-text")]
        public async Task<ActionResult<SpeakTextResponse>> SpeakText(
            [FromBody] SpeakTextRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Text))
            {
                return BadRequest("Text is required.");
            }

            try
            {
                var baseUrl = $"{Request.Scheme}://{Request.Host}";

                var audioStream = await _piperClient.SynthesizeToStreamAsync(
                    request.Text,
                    request.Language);

                var audioFileName = $"selected_{DateTime.UtcNow:yyyyMMddHHmmssfff}.wav";

                var savedAudioPath = await _audioStorage.SaveAudioAsync(
                    audioStream,
                    audioFileName);

                var response = new SpeakTextResponse
                {
                    Text = request.Text,
                    AudioUrl = _audioStorage.GetAudioUrl(savedAudioPath, baseUrl),
                    Timestamp = DateTime.UtcNow
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to synthesize selected text.");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    "Failed to synthesize selected text.");
            }
        }
    }
}