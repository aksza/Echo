namespace EchoAPI.Core.Entities
{
    public class UserProfile
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }
        public int Level { get; set; }  // A1–C2 encoded as number (1–6)
        public string NativeLanguage { get; set; } = null!;
        public string TargetLanguage { get; set; } = null!;
        public string? LearningGoals { get; set; }

        // Navigation
        public User User { get; set; } = null!;
    }
}
