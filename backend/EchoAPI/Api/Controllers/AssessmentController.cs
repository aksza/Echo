using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

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

            var result = await _assessmentService.AssessTextAsync(request.Text);

            return Ok(result);
        }
    }
}
