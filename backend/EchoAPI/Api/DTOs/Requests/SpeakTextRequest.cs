using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Api.DTOs.Requests
{
    public class SpeakTextRequest
    {
        [Required]
        [MaxLength(300)]
        public string Text { get; set; } = string.Empty;

        [MaxLength(10)]
        public string Language { get; set; } = "en";
    }
}