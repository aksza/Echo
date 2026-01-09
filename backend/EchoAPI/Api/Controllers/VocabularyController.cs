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
    }
}
