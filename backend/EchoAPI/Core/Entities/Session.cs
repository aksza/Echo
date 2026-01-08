using EchoAPI.Core.Enums;
using EchoAPI.Core.Interfaces.Entities;
using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Core.Entities
{
    public class Session : ISoftDeletable
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        public Guid UserId { get; set; }

        public bool IsDeleted { get; set; } = false;
        [Required]
        public DateTime StartedAt { get; set; } = DateTime.UtcNow;

        public DateTime? EndedAt { get; set; }

        [Required]
        public SessionType SessionType { get; set; }

        [MaxLength(100)]
        public string? Title { get; set; }

        // Navigation
        public User User { get; set; } = null!;
    }
}
