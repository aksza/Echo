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

            var userIdClaims = User.FindFirst("sub")?
                .Value
                ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (userIdClaims == null) {
                return Unauthorized("User ID claim is missing.");
            }

            var userId = Guid.Parse(userIdClaims);


            var result = await _assessmentService.AssessTextAndSaveAsync(userId, request.Text);

            return Ok(result);
        }
    }
}
