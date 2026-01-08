using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Core.Entities
{
    public class MistakeCategory
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = null!;

        // Navigation
        public ICollection<Mistake> Mistakes { get; set; } = new List<Mistake>();
    }
}
