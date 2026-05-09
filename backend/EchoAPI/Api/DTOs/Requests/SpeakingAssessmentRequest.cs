using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Api.DTOs.Requests
{
    public class SpeakingAssessmentRequest
    {
        [Required]
        public IFormFile AudioFile { get; set; } = null!;

        public string TargetLanguage { get; set; } = "en";
    }
}
