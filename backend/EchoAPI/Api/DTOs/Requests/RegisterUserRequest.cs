using EchoAPI.Core.Enums;

namespace EchoAPI.Api.DTOs.Requests
{
    public class RegisterUserRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;

        public LanguageLevel Level { get; set; } = LanguageLevel.A1;
        public string NativeLanguage { get; set; } = "hu";
        public string TargetLanguage { get; set; } = "en";
        public string? LearningGoals { get; set; }
        public bool AllowLearningDataSharing { get; set; } = false;
    }
}
