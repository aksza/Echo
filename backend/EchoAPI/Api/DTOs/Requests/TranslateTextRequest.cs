using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Api.DTOs.Requests
{
    public class TranslateTextRequest
    {
        [Required]
        [MaxLength(200)]
        public string Text { get; set; } = string.Empty;

        [Required]
        [MaxLength(2)]
        public string SourceLanguage { get; set; } = "en";

        [Required]
        [MaxLength(2)]
        public string TargetLanguage { get; set; } = "hu";
    }
}