using EchoAPI.Core.Interfaces.Entities;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EchoAPI.Core.Entities
{
    public class VocabularyPracticeHistory : ISoftDeletable
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid VocabularyId { get; set; }

        public bool IsDeleted { get; set; } = false;

        [Required]
        public DateTime PracticedAt { get; set; } = DateTime.UtcNow;

        [Range(0, int.MaxValue)]
        public int? ResponseTimeMs { get; set; } // in milliseconds

        public bool Success { get; set; }

        // Navigation
        public Vocabulary Vocabulary { get; set; } = null!;
    }
}
