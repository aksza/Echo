namespace EchoAPI.Core.Entities
{
    public class UserSettings
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }

        public string? TtsVoice { get; set; }
        public string? SttLanguage { get; set; }
        public string? LlmStyle { get; set; }
        public int? ResponseSpeed { get; set; } // 1–5

        // Navigation
        public User User { get; set; } = null!;
    }
}
