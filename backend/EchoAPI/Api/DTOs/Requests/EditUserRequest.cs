namespace EchoAPI.Api.DTOs.Requests
{
    public class EditUserRequest
    {
        public string? NativeLanguage { get; set; }
        public string? TargetLanguage { get; set; }
        public string? LearningGoals { get; set; }
        public bool? AllowLearningDataSharing { get; set; }
    }
}
