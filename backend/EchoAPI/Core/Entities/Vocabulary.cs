using EchoAPI.Core.Enums;
using EchoAPI.Core.Interfaces.Entities;
using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Core.Entities
{
    public class Vocabulary : ISoftDeletable
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid UserId { get; set; }

        public bool IsDeleted { get; set; } = false;

        [Required]
        [MaxLength(100)]
        public string Expression { get; set; } = null!;

        [Required]
        [MaxLength(100)]
        public string Translation { get; set; } = null!;

        [MaxLength(255)]
        public string? ExampleSentence { get; set; }

        [Required]
        public VocabularySource AddedFrom { get; set; }  // enum

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        public KnowledgeLevel KnowledgeLevel { get; set; } = KnowledgeLevel.Unknown;

        // Navigation
        public User User { get; set; } = null!;
        public ICollection<VocabularyPracticeHistory> PracticeHistory { get; set; }
            = new List<VocabularyPracticeHistory>();
    }
}
