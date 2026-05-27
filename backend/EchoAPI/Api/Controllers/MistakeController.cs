using EchoAPI.Api.DTOs.Response;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/mistakes")]
    [Authorize]
    public class MistakesController : ControllerBase
    {
        private readonly MistakeService _mistakeService;

        public MistakesController(MistakeService mistakeService)
        {
            _mistakeService = mistakeService;
        }

        [HttpGet("my")]
        public async Task<ActionResult<List<MistakeResponse>>> GetMyMistakes()
        {
            var userId = GetCurrentUserId();

            var mistakes = await _mistakeService.GetUserMistakesAsync(userId);

            return Ok(mistakes);
        }

        [HttpGet("my/{mistakeId}")]
        public async Task<ActionResult<MistakeResponse>> GetMyMistakeById(
            Guid mistakeId)
        {
            var userId = GetCurrentUserId();

            var mistake = await _mistakeService.GetUserMistakeByIdAsync(
                userId,
                mistakeId);

            if (mistake == null)
            {
                return NotFound();
            }

            return Ok(mistake);
        }

        [HttpDelete("my/{mistakeId}")]
        public async Task<IActionResult> DeleteMyMistake(
            Guid mistakeId)
        {
            var userId = GetCurrentUserId();

            await _mistakeService.DeleteUserMistakeAsync(
                userId,
                mistakeId);

            return NoContent();
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