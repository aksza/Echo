namespace EchoAPI.Core.Entities
{
    public class Mistake
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }
        public Guid MessageId { get; set; }

        public string OriginalText { get; set; } = null!;
        public string CorrectedText { get; set; } = null!;
        public string Explanation { get; set; } = null!;
        public string Category { get; set; } = null!; // grammar, vocab, etc

        public DateTime CreatedAt { get; set; }

        // Navigation
        public User User { get; set; } = null!;
        public Message Message { get; set; } = null!;
    }
}
