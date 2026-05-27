using EchoAPI.Api.DTOs.Practice;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/practice")]
    [Authorize]
    public class PracticeController : ControllerBase
    {
        private readonly PracticeService _practiceService;

        public PracticeController(PracticeService practiceService)
        {
            _practiceService = practiceService;
        }

        [HttpPost("mistakes/start")]
        public async Task<ActionResult<StartPracticeSessionResponse>> StartMistakePractice(
            [FromQuery] int count = 5)
        {
            var userId = GetCurrentUserId();

            var response = await _practiceService.StartMistakePracticeSessionAsync(
                userId,
                count);

            return Ok(response);
        }

        [HttpPost("mistakes/text-answer")]
        public async Task<ActionResult<PracticeAnswerResponse>> SubmitTextAnswer(
            [FromBody] PracticeTextAnswerRequest request)
        {
            var userId = GetCurrentUserId();

            var response = await _practiceService.SubmitTextAnswerAsync(
                userId,
                request);

            return Ok(response);
        }

        [HttpPost("mistakes/voice-answer")]
        [Consumes("multipart/form-data")]
        [RequestSizeLimit(26_214_400)]
        public async Task<ActionResult<PracticeAnswerResponse>> SubmitVoiceAnswer(
            [FromForm] PracticeVoiceAnswerRequest request)
        {
            var userId = GetCurrentUserId();

            var response = await _practiceService.SubmitVoiceAnswerAsync(
                userId,
                request);

            return Ok(response);
        }

        [HttpPost("mistakes/skip")]
        public async Task<ActionResult<PracticeAnswerResponse>> SkipMistake(
            [FromBody] PracticeSkipRequest request)
        {
            var userId = GetCurrentUserId();

            var response = await _practiceService.SkipItemAsync(
                userId,
                request);

            return Ok(response);
        }

        [HttpPost("mistakes/end")]
        public async Task<ActionResult<PracticeSummaryResponse>> EndPracticeSession(
            [FromBody] EndPracticeSessionRequest request)
        {
            var userId = GetCurrentUserId();

            var response = await _practiceService.EndSessionAsync(
                userId,
                request.SessionId);

            return Ok(response);
        }

        [HttpGet("mistakes/summary/{sessionId}")]
        public async Task<ActionResult<PracticeSummaryResponse>> GetSummary(
            Guid sessionId)
        {
            var userId = GetCurrentUserId();

            var response = await _practiceService.GetSummaryAsync(
                userId,
                sessionId);

            return Ok(response);
        }

        private Guid GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("sub")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (userIdClaim == null)
            {
                throw new UnauthorizedAccessException("User id claim is missing.");
            }

            return Guid.Parse(userIdClaim);
        }
    }
}