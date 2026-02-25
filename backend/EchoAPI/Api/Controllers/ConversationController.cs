using EchoAPI.Api.DTOs;
using EchoAPI.Application.Services;
using EchoAPI.Core.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EchoAPI.Api.Controllers
{
    /// <summary>
    /// Controller for voice-based conversations and corrections
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ConversationController : ControllerBase
    {
        private readonly ConversationOrchestrator _orchestrator;
        private readonly IAudioStorageService _audioStorage;
        private readonly ILogger<ConversationController> _logger;

        public ConversationController(
            ConversationOrchestrator orchestrator,
            IAudioStorageService audioStorage,
            ILogger<ConversationController> logger)
        {
            _orchestrator = orchestrator;
            _audioStorage = audioStorage;
            _logger = logger;
        }

        /// <summary>
        /// Process a voice message: transcribe, generate AI response, and synthesize audio
        /// </summary>
        /// <param name="request">Voice conversation request with audio file and optional parameters</param>
        /// <returns>Voice conversation response with audio URL</returns>
        /// <response code="200">Returns conversation result with audio response</response>
        /// <response code="400">Invalid request or file format</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="413">File too large</response>
        /// <response code="503">AI service unavailable</response>
        [HttpPost("voice-message")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ApiResponse<VoiceConversationResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status413PayloadTooLarge)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status503ServiceUnavailable)]
        [RequestSizeLimit(26_214_400)] // 25MB
        public async Task<ActionResult<ApiResponse<VoiceConversationResponse>>> SendVoiceMessage(
            [FromForm] VoiceConversationRequest request)
        {
            if (request.AudioFile == null || request.AudioFile.Length == 0)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse("Audio file is required"));
            }

            try
            {
                _logger.LogInformation(
                    "Processing voice message. File: {FileName}, Size: {SizeMB:F2}MB, ConversationId: {ConversationId}",
                    request.AudioFile.FileName,
                    request.AudioFile.Length / (1024.0 * 1024.0),
                    request.ConversationId ?? "new");

                // Get base URL for audio URLs
                var baseUrl = $"{Request.Scheme}://{Request.Host}";

                // Process voice message
                using var audioStream = request.AudioFile.OpenReadStream();
                var result = await _orchestrator.ProcessVoiceMessageAsync(
                    audioStream,
                    request.AudioFile.FileName,
                    request.ConversationId,
                    request.Language,
                    request.SystemPrompt);

                // Build response
                var response = new VoiceConversationResponse
                {
                    UserTranscription = result.UserTranscription,
                    DetectedLanguage = result.DetectedLanguage,
                    AiResponse = result.AiResponse,
                    ConversationId = result.ConversationId,
                    AudioUrl = _audioStorage.GetAudioUrl(result.AudioFilePath, baseUrl),
                    TokensUsed = result.TokensUsed,
                    AudioDuration = result.AudioDuration,
                    Timestamp = DateTime.UtcNow
                };

                return Ok(ApiResponse<VoiceConversationResponse>.SuccessResponse(response));
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid voice message request");
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex, "AI service error");
                return StatusCode(
                    StatusCodes.Status503ServiceUnavailable,
                    ApiResponse<object>.ErrorResponse("AI service is currently unavailable"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error processing voice message");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An unexpected error occurred"));
            }
        }

        /// <summary>
        /// Process voice for language correction: transcribe, correct, and synthesize corrected audio
        /// </summary>
        /// <param name="request">Voice correction request with audio file and parameters</param>
        /// <returns>Voice correction response with corrected audio URL</returns>
        /// <response code="200">Returns corrections with corrected audio</response>
        /// <response code="400">Invalid request or file format</response>
        /// <response code="401">Unauthorized</response>
        [HttpPost("voice-correction")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ApiResponse<VoiceCorrectionResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [RequestSizeLimit(26_214_400)] // 25MB
        public async Task<ActionResult<ApiResponse<VoiceCorrectionResponse>>> CorrectVoice(
            [FromForm] VoiceCorrectionRequest request)
        {
            if (request.AudioFile == null || request.AudioFile.Length == 0)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse("Audio file is required"));
            }

            try
            {
                _logger.LogInformation(
                    "Processing voice for correction. File: {FileName}, Language: {Language}",
                    request.AudioFile.FileName,
                    request.TargetLanguage);

                var baseUrl = $"{Request.Scheme}://{Request.Host}";

                using var audioStream = request.AudioFile.OpenReadStream();
                var result = await _orchestrator.ProcessVoiceForCorrectionAsync(
                    audioStream,
                    request.AudioFile.FileName,
                    request.TargetLanguage,
                    request.ProvideExplanation);

                var response = new VoiceCorrectionResponse
                {
                    OriginalText = result.OriginalText,
                    CorrectedText = result.CorrectedText,
                    Explanation = result.Explanation,
                    CorrectedAudioUrl = _audioStorage.GetAudioUrl(result.CorrectedAudioPath, baseUrl),
                    Corrections = result.Corrections.Select(c => new CorrectionDetailDto
                    {
                        Original = c.Original,
                        Corrected = c.Corrected,
                        Type = c.Type,
                        Explanation = c.Explanation
                    }).ToList()
                };

                return Ok(ApiResponse<VoiceCorrectionResponse>.SuccessResponse(response));
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid voice correction request");
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error processing voice correction");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An unexpected error occurred"));
            }
        }

        /// <summary>
        /// Get an audio file
        /// </summary>
        /// <param name="fileName">Audio filename</param>
        /// <returns>Audio file stream</returns>
        [HttpGet("audio/{fileName}")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(FileStreamResult), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAudio(string fileName)
        {
            try
            {
                var filePath = $"audio/{fileName}";
                var audioStream = await _audioStorage.GetAudioAsync(filePath);

                return File(audioStream, "audio/wav", fileName);
            }
            catch (FileNotFoundException)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Audio file not found"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving audio file: {FileName}", fileName);
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("Failed to retrieve audio file"));
            }
        }
    }
}
