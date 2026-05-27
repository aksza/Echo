using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Core.Entities
{
    public class PracticeSession
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid UserId { get; set; }

        [Required]
        public DateTime StartedAt { get; set; } = DateTime.UtcNow;

        public DateTime? EndedAt { get; set; }

        public int TotalItems { get; set; }

        public int CorrectCount { get; set; }

        public int IncorrectCount { get; set; }

        public int SkippedCount { get; set; }

        public bool IsCompleted { get; set; } = false;

        public User User { get; set; } = null!;

        public ICollection<PracticeSessionItem> Items { get; set; } = new List<PracticeSessionItem>();
    }
}