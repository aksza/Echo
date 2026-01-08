using EchoAPI.Core.Enums;
using EchoAPI.Core.Interfaces.Entities;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EchoAPI.Core.Entities
{
    public class Mistake : ISoftDeletable
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid UserId { get; set; }
        
        public bool IsDeleted { get; set; } = false;

        [Required]
        [MaxLength(500)]
        public string OriginalText { get; set; } = null!;

        [Required]
        [MaxLength(500)]
        public string CorrectedText { get; set; } = null!;

        public string? Explanation { get; set; }

        [Required]
        public Guid MistakeCategoryId { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ImprovementLevel Improvement { get; set; } // e.g., 1-5 scale indicating improvement

        // Navigation
        public User User { get; set; } = null!;
        public MistakeCategory MistakeCategory { get; set; } = null!;
    }

}
