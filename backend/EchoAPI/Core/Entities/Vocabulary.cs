namespace EchoAPI.Core.Entities
{
    public class Vocabulary
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }

        public string Word { get; set; } = null!;
        public string Translation { get; set; } = null!;
        public string? ExampleSentence { get; set; }
        public string AddedFrom { get; set; } = null!; // conversation, podcast

        public DateTime CreatedAt { get; set; }

        // Navigation
        public User User { get; set; } = null!;
        public ICollection<VocabularyPracticeHistory> PracticeHistory { get; set; }
            = new List<VocabularyPracticeHistory>();
    }
}
