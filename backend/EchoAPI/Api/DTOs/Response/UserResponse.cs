using EchoAPI.Core.Enums;

namespace EchoAPI.Api.DTOs.Response
{
    public class UserResponse
    {
        public Guid Id { get; set; }
        public string Email { get; set; } = null!;
        public DateTime CreatedAt { get; set; }

        public LanguageLevel Level { get; set; }

        public int PlacementScore { get; set; }
        public float PlacementConfidence { get; set; }
        public DateTime? LevelAssessedAt { get; set; }
        public bool PlacementCompleted { get; set; } = false;
        public string? LearningGoals { get; set; }
        public string NativeLanguage { get; set; } = null!;
        public string TargetLanguage { get; set; } = null!;
        public bool AllowLearningDataSharing { get; set; } = false;
    }
}
