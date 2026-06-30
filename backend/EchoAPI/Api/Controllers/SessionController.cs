using EchoAPI.Api.DTOs.Response;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/sessions")]
    [Authorize]
    public class SessionsController : ControllerBase
    {
        private readonly SessionHistoryService _sessionHistoryService;

        public SessionsController(SessionHistoryService sessionHistoryService)
        {
            _sessionHistoryService = sessionHistoryService;
        }

        [HttpGet("my")]
        public async Task<ActionResult<IEnumerable<SessionHistoryResponse>>> GetMySessions()
        {
            var userId = GetCurrentUserId();

            var sessions = await _sessionHistoryService.GetMySessionsAsync(userId);

            return Ok(sessions);
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