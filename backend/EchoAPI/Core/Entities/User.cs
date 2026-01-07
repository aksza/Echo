namespace EchoAPI.Core.Entities
{
    public class User
    {
        public Guid Id { get; set; }

        public string Email { get; set; } = null!;
        public string PasswordHash { get; set; } = null!;

        public DateTime CreatedAt { get; set; }
        public DateTime? LastLogin { get; set; }

        // Navigation
        public UserProfile? Profile { get; set; }
        public UserSettings? Settings { get; set; }
        public ICollection<Session> Sessions { get; set; } = new List<Session>();
        public ICollection<Mistake> Mistakes { get; set; } = new List<Mistake>();
        public ICollection<Vocabulary> Vocabulary { get; set; } = new List<Vocabulary>();
    }
}
