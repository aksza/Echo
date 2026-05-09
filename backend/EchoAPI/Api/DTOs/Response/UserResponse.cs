using EchoAPI.Core.Enums;

namespace EchoAPI.Api.DTOs.Response
{
    public class UserResponse
    {
        public Guid Id { get; set; }
        public string Email { get; set; } = null!;
        public DateTime CreatedAt { get; set; }

        public LanguageLevel Level { get; set; } //overall level

        public LanguageLevel WritingLevel { get; set; } = LanguageLevel.A1;
        public int WritingScore { get; set; } = 0;
        public float WritingConfidence { get; set; } = 0;

        public LanguageLevel SpeakingLevel { get; set; } = LanguageLevel.A1;
        public int SpeakingScore { get; set; } = 0;
        public float SpeakingConfidence { get; set; } = 0;

        public DateTime? LevelAssessedAt { get; set; }
        public bool PlacementCompleted { get; set; } = false;
        public string? LearningGoals { get; set; }
        public string NativeLanguage { get; set; } = null!;
        public string TargetLanguage { get; set; } = null!;
        public bool AllowLearningDataSharing { get; set; } = false;
    }
}
