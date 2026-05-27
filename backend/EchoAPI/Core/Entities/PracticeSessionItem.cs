using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Core.Entities
{
    public class PracticeSessionItem
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid PracticeSessionId { get; set; }

        [Required]
        public Guid MistakeId { get; set; }

        [Required]
        [MaxLength(500)]
        public string OriginalText { get; set; } = string.Empty;

        [Required]
        [MaxLength(500)]
        public string CorrectedText { get; set; } = string.Empty;

        public string? UserAnswer { get; set; }

        public string? TranscribedAnswer { get; set; }

        public bool? IsCorrect { get; set; }

        public int? Score { get; set; }

        public string? Feedback { get; set; }

        public int AttemptCount { get; set; } = 0;

        public bool Skipped { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? CompletedAt { get; set; }

        public PracticeSession PracticeSession { get; set; } = null!;

        public Mistake Mistake { get; set; } = null!;
    }
}