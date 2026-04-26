using EchoAPI.Api.DTOs;
using EchoAPI.Core.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EchoAPI.Api.Controllers
{
    /// <summary>
    /// Chat endpoints for AI conversation
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ChatController : ControllerBase
    {
        private readonly IPhi3ServiceClient _phi3Client;
        private readonly ILogger<ChatController> _logger;

        public ChatController(
            IPhi3ServiceClient phi3Client,
            ILogger<ChatController> logger)
        {
            _phi3Client = phi3Client;
            _logger = logger;
        }

        /// <summary>
        /// Send a chat message and get AI response
        /// </summary>
        /// <param name="request">Chat message request</param>
        /// <returns>AI response</returns>
        /// <response code="200">Returns AI response</response>
        /// <response code="400">Invalid request</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="503">AI service unavailable</response>
        [HttpPost("send")]
        [ProducesResponseType(typeof(ApiResponse<ChatMessageResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status503ServiceUnavailable)]
        public async Task<ActionResult<ApiResponse<ChatMessageResponse>>> SendMessage(
            [FromBody] SendChatRequest request)
        {
            try
            {
                _logger.LogInformation(
                    "Chat request from user. ConversationId: {ConversationId}",
                    request.ConversationId ?? "new");

                var response = await _phi3Client.ChatAsync(
                    message: request.Message,
                    conversationId: request.ConversationId,
                    systemPrompt: request.SystemPrompt,
                    temperature: request.Temperature,
                    maxTokens: request.MaxTokens
                );

                var chatResponse = new ChatMessageResponse
                {
                    Response = response.Response,
                    ConversationId = response.ConversationId,
                    TokensUsed = response.TokensUsed,
                    Timestamp = DateTime.UtcNow
                };

                return Ok(ApiResponse<ChatMessageResponse>.SuccessResponse(chatResponse));
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid chat request");
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
                _logger.LogError(ex, "Unexpected error in chat");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An unexpected error occurred"));
            }
        }

        /// <summary>
        /// Correct text and get language corrections
        /// </summary>
        /// <param name="request">Text correction request</param>
        /// <returns>Corrections and explanations</returns>
        /// <response code="200">Returns corrections</response>
        /// <response code="400">Invalid request</response>
        /// <response code="401">Unauthorized</response>
        [HttpPost("correct")]
        [ProducesResponseType(typeof(ApiResponse<TextCorrectionResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<ApiResponse<TextCorrectionResponse>>> CorrectText(
            [FromBody] CorrectTextRequest request)
        {
            try
            {
                _logger.LogInformation(
                    "Correction request. Language: {Language}, Text length: {Length}",
                    request.TargetLanguage,
                    request.Text.Length);

                var response = await _phi3Client.CorrectTextAsync(
                    text: request.Text,
                    targetLanguage: request.TargetLanguage,
                    provideExplanation: request.ProvideExplanation
                );

                var correctionResponse = new TextCorrectionResponse
                {
                    OriginalText = response.OriginalText,
                    CorrectedText = response.CorrectedText,
                    Explanation = response.Explanation,
                    Corrections = response.Corrections.Select(c => new CorrectionDetailDto
                    {
                        Original = c.Original,
                        Corrected = c.Corrected,
                        Type = c.Type,
                        Explanation = c.Explanation
                    }).ToList()
                };

                return Ok(ApiResponse<TextCorrectionResponse>.SuccessResponse(correctionResponse));
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid correction request");
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in text correction");
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("An unexpected error occurred"));
            }
        }

        /// <summary>
        /// Delete a conversation from memory (privacy/cleanup)
        /// </summary>
        /// <param name="conversationId">Conversation ID to delete</param>
        /// <response code="200">Conversation deleted</response>
        /// <response code="400">Invalid conversation ID</response>
        /// <response code="401">Unauthorized</response>
        [HttpDelete("conversation/{conversationId}")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult<ApiResponse<object>>> DeleteConversation(string conversationId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(conversationId))
                {
                    return BadRequest(ApiResponse<object>.ErrorResponse("Conversation ID is required"));
                }

                _logger.LogInformation("Deleting conversation: {ConversationId}", conversationId);

                await _phi3Client.DeleteConversationAsync(conversationId);

                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    message = "Conversation deleted successfully",
                    conversationId
                }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting conversation: {ConversationId}", conversationId);
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    ApiResponse<object>.ErrorResponse("Failed to delete conversation"));
            }
        }

        /// <summary>
        /// Check AI service health
        /// </summary>
        /// <returns>Health status</returns>
        [HttpGet("health")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        public async Task<ActionResult<ApiResponse<object>>> HealthCheck()
        {
            try
            {
                var health = await _phi3Client.HealthCheckAsync();

                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    status = health.Status,
                    service = health.Service,
                    modelLoaded = health.ModelLoaded,
                    modelName = health.ModelName
                }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check failed");
                return Ok(ApiResponse<object>.ErrorResponse("AI service is unhealthy"));
            }
        }
    }
}
