using Microsoft.AspNetCore.Http;

namespace EchoAPI.Api.DTOs.Practice
{
    public class StartPracticeSessionResponse
    {
        public Guid SessionId { get; set; }

        public int TotalItems { get; set; }

        public List<PracticeItemResponse> Items { get; set; } = new();
    }

    public class PracticeItemResponse
    {
        public Guid PracticeItemId { get; set; }

        public Guid MistakeId { get; set; }

        public string OriginalText { get; set; } = string.Empty;

        public string CorrectedText { get; set; } = string.Empty;

        public string? Explanation { get; set; }

        public string Category { get; set; } = string.Empty;
    }

    public class PracticeTextAnswerRequest
    {
        public Guid SessionId { get; set; }

        public Guid PracticeItemId { get; set; }

        public string Answer { get; set; } = string.Empty;
    }

    public class PracticeVoiceAnswerRequest
    {
        public Guid SessionId { get; set; }

        public Guid PracticeItemId { get; set; }

        public IFormFile AudioFile { get; set; } = null!;

        public string? Language { get; set; } = "en";
    }

    public class PracticeSkipRequest
    {
        public Guid SessionId { get; set; }

        public Guid PracticeItemId { get; set; }
    }

    public class EndPracticeSessionRequest
    {
        public Guid SessionId { get; set; }
    }

    public class PracticeAnswerResponse
    {
        public Guid SessionId { get; set; }

        public Guid PracticeItemId { get; set; }

        public bool IsCorrect { get; set; }

        public int Score { get; set; }

        public string Feedback { get; set; } = string.Empty;

        public string CorrectAnswer { get; set; } = string.Empty;

        public string? UserAnswer { get; set; }

        public string? TranscribedAnswer { get; set; }

        public bool SessionCompleted { get; set; }

        public PracticeSummaryResponse? Summary { get; set; }
    }

    public class PracticeSummaryResponse
    {
        public Guid SessionId { get; set; }

        public int TotalItems { get; set; }

        public int CorrectCount { get; set; }

        public int IncorrectCount { get; set; }

        public int SkippedCount { get; set; }

        public double AccuracyPercent { get; set; }

        public string Message { get; set; } = string.Empty;

        public DateTime StartedAt { get; set; }

        public DateTime? EndedAt { get; set; }
    }

    public class PracticeAnswerAiResult
    {
        public bool IsCorrect { get; set; }

        public int Score { get; set; }

        public string Feedback { get; set; } = string.Empty;

        public string CorrectAnswer { get; set; } = string.Empty;
    }
}