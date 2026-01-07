namespace EchoAPI.Core.Entities
{
    public class Session
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }
        public DateTime StartedAt { get; set; }
        public DateTime? EndedAt { get; set; }

        public string SessionType { get; set; } = null!; // conversation, placement-test

        // Navigation
        public User User { get; set; } = null!;
        public ICollection<Message> Messages { get; set; } = new List<Message>();
    }
}
