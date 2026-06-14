namespace EchoAPI.Api.DTOs.Response
{
    public class LearningSummaryResponse
    {
        public DateTime AccountCreatedAt { get; set; }

        public int TotalSessions { get; set; }
        public int ConversationSessions { get; set; }
        public DateTime? LastSessionAt { get; set; }

        public int VocabularyCount { get; set; }
        public int VocabularyPracticeCount { get; set; }
        public double VocabularyPracticeSuccessRate { get; set; }

        public int MistakesCount { get; set; }
        public int GrammarMistakesCount { get; set; }
        public int VocabularyMistakesCount { get; set; }
        public int PhrasingMistakesCount { get; set; }
        public int SentenceStructureMistakesCount { get; set; }

        public int PracticeSessionsCount { get; set; }
        public double LastMistakePracticeAccuracy { get; set; }
    }
}