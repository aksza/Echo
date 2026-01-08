using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Core.Entities
{
    public class UserSettings
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid UserId { get; set; }

        [MaxLength(50)]
        public string? TtsVoice { get; set; }

        [MaxLength(10)]
        public string? SttLanguage { get; set; }

        [MaxLength(30)]
        public string? LlmStyle { get; set; }

        [Range(1, 5)]
        public int? ResponseSpeed { get; set; } = 3; // 1-5 scale

        // Navigation
        public User User { get; set; } = null!;
    }
}
