using EchoAPI.Api.DTOs;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/learning-summary")]
    [Authorize]
    public class LearningSummaryController : ControllerBase
    {
        private readonly LearningSummaryService _learningSummaryService;

        public LearningSummaryController(
            LearningSummaryService learningSummaryService)
        {
            _learningSummaryService = learningSummaryService;
        }

        [HttpGet("me")]
        public async Task<ActionResult<ApiResponse<LearningSummaryResponse>>> GetMySummary()
        {
            var userId = GetCurrentUserId();

            var response = await _learningSummaryService.GetMySummaryAsync(userId);

            return Ok(ApiResponse<LearningSummaryResponse>.SuccessResponse(response));
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