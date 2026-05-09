using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/assessment")]
    [Authorize]
    public class AssessmentController : ControllerBase
    {
        private readonly AssessmentService _assessmentService;

        public AssessmentController(AssessmentService assessmentService)
        {
            _assessmentService = assessmentService;
        }

        [HttpPost("text")]
        public async Task<ActionResult<AssessmentResponse>> AssessText(
            [FromBody] TextAssessmentRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Text))
            {
                return BadRequest("Text cannot be empty.");
            }

            var userId = GetCurrentUserId();


            var result = await _assessmentService.AssessTextAndSaveAsync(userId, request.Text);

            return Ok(result);
        }

        [HttpPost("speaking")]
        [Consumes("multipart/form-data")]
        [RequestSizeLimit(26_214_400)] // 25MB
        public async Task<ActionResult<AssessmentResponse>> AssessSpeaking(
            [FromForm] SpeakingAssessmentRequest request)
        {
            if(request.AudioFile == null || request.AudioFile.Length == 0)
            {
                return BadRequest("Audio file is required.");
            }

            var userId = GetCurrentUserId();

            using var audioStream = request.AudioFile.OpenReadStream();

            var result = await _assessmentService.AssessSpeakingAndSaveAsync(
                userId,
                audioStream,
                request.AudioFile.FileName,
                request.TargetLanguage);

            return Ok(result);
        }

        private Guid GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("sub")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userIdClaim == null)
            {
                throw new UnauthorizedAccessException("User ID claim not found.");
            }

            return Guid.Parse(userIdClaim);
        }
    }
}
