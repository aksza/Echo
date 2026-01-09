using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EchoAPI.Api.Controllers
{
    [ApiController]
    [Route("api/vocabulary")]
    public class VocabularyController : ControllerBase
    {
        private readonly VocabularyService _vocabularyService;

        public VocabularyController(VocabularyService vocabularyService)
        {
            _vocabularyService = vocabularyService;
        }

        [HttpPost("add")]
        [Authorize]
        public async Task<IActionResult> AddVocabulary([FromBody] AddVocabularyRequest request)
        {
            //jwt-bol userid
            var userIdClaim = User.FindFirst("sub")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if(userIdClaim == null) 
                return Unauthorized();

            var userId = Guid.Parse(userIdClaim);
            var vocabularyResponse = await _vocabularyService.AddVocabularyAsync(userId,request);

            return CreatedAtAction(nameof(AddVocabulary), vocabularyResponse);
        }

        [HttpGet("vocabularies")]
        [Authorize]
        public async Task<IActionResult> GetUserVocabularies()
        {
            var userIdClaim = User.FindFirst("sub")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userIdClaim == null)
                return Unauthorized();
            
            var userId = Guid.Parse(userIdClaim);
            var vocabularies = await _vocabularyService.GetUserVocabulariesAsync(userId);
            
            return Ok(vocabularies);
        }

        [HttpPut("{vocabularyId}")]
        [Authorize]
        public async Task<IActionResult> UpdateVocabulary(Guid vocabularyId, [FromBody] EditVocabularyRequest request)
        {
            var userIdClaim = User.FindFirst("sub")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userIdClaim == null)
                return Unauthorized();

            var userId = Guid.Parse(userIdClaim);

            var updatedVocabulary = await _vocabularyService.EditVocabularyAsync(vocabularyId, request);
            return Ok(updatedVocabulary);
        }

        [HttpDelete("{vocabularyId}")]
        [Authorize]
        public async Task<IActionResult> DeleteVocabulary(Guid vocabularyId)
        {
            var userIdClaim = User.FindFirst("sub")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userIdClaim == null)
                return Unauthorized();

            var userId = Guid.Parse(userIdClaim);

            await _vocabularyService.DeleteVocabularyAsync(vocabularyId);
            return NoContent();
        }
    }
}
