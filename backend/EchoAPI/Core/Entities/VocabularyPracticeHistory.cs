namespace EchoAPI.Core.Entities
{
    public class VocabularyPracticeHistory
    {
        public Guid Id { get; set; }

        public Guid VocabularyId { get; set; }

        public DateTime PracticedAt { get; set; }
        public bool Success { get; set; }

        // Navigation
        public Vocabulary Vocabulary { get; set; } = null!;
    }
}
