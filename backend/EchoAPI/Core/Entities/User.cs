using EchoAPI.Core.Enums;
using EchoAPI.Core.Interfaces.Entities;
using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Core.Entities
{
    public class User : ISoftDeletable
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        [EmailAddress]
        [MaxLength(255)]
        public string Email { get; set; } = null!;

        [Required]
        public string PasswordHash { get; set; } = null!;

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsDeleted { get; set; } = false;
        public DateTime? LastLogin { get; set; }

        [Required]
        public LanguageLevel Level { get; set; }

        [Required]
        [MaxLength(2)]
        public string NativeLanguage { get; set; } = null!;

        [Required]
        [MaxLength(2)]
        public string TargetLanguage { get; set; } = null!;

        [MaxLength(500)]
        public string? LearningGoals { get; set; }

        public bool AllowLearningDataSharing { get; set; } = false;

        // Navigation
        public UserSettings? Settings { get; set; }
        public ICollection<Session> Sessions { get; set; } = new List<Session>();
        public ICollection<Mistake> Mistakes { get; set; } = new List<Mistake>();
        public ICollection<Vocabulary> Vocabulary { get; set; } = new List<Vocabulary>();
    }
}
