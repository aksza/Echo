namespace EchoAPI.Core.Entities
{
    public class Message
    {
        public Guid Id { get; set; }

        public Guid SessionId { get; set; }
        public string Sender { get; set; } = null!; // user, ai
        public string Text { get; set; } = null!;
        public DateTime Timestamp { get; set; }

        // Navigation
        public Session Session { get; set; } = null!;
        public ICollection<Mistake> Mistakes { get; set; } = new List<Mistake>();
    }
}
