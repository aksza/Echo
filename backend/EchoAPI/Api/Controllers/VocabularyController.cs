using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/vocabulary")]
    [Authorize]
    public class VocabularyController : ControllerBase
    {
        private readonly VocabularyService _vocabularyService;

        public VocabularyController(VocabularyService vocabularyService)
        {
            _vocabularyService = vocabularyService;
        }

        [HttpPost("add")]
        public async Task<ActionResult<VocabularyResponse>> AddVocabulary(
            [FromBody] AddVocabularyRequest request)
        {
            var userId = GetCurrentUserId();

            var vocabularyResponse = await _vocabularyService.AddVocabularyAsync(
                userId,
                request);

            return CreatedAtAction(
                nameof(GetUserVocabularies),
                new { id = vocabularyResponse.Id },
                vocabularyResponse);
        }

        [HttpGet("vocabularies")]
        public async Task<ActionResult<IEnumerable<VocabularyResponse>>> GetUserVocabularies()
        {
            var userId = GetCurrentUserId();

            var vocabularies = await _vocabularyService.GetUserVocabulariesAsync(userId);

            return Ok(vocabularies);
        }

        [HttpPut("{vocabularyId}")]
        public async Task<ActionResult<VocabularyResponse>> UpdateVocabulary(
            Guid vocabularyId,
            [FromBody] EditVocabularyRequest request)
        {
            var userId = GetCurrentUserId();

            var updatedVocabulary = await _vocabularyService.EditVocabularyAsync(
                userId,
                vocabularyId,
                request);

            return Ok(updatedVocabulary);
        }

        [HttpDelete("{vocabularyId}")]
        public async Task<IActionResult> DeleteVocabulary(Guid vocabularyId)
        {
            var userId = GetCurrentUserId();

            await _vocabularyService.DeleteVocabularyAsync(
                userId,
                vocabularyId);

            return NoContent();
        }

        [HttpPost("translate")]
        public async Task<ActionResult<TranslateTextResponse>> TranslateText(
            [FromBody] TranslateTextRequest request)
        {
            var response = await _vocabularyService.TranslateTextAsync(request);

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