namespace EchoAPI.Api.DTOs.Response
{
    public class UserResponse
    {
        public Guid Id { get; set; }
        public string Email { get; set; } = null!;
        public DateTime CreatedAt { get; set; }

        public string NativeLanguage { get; set; } = null!;
        public string TargetLanguage { get; set; } = null!;
        public bool AllowLearningDataSharing { get; set; } = false;
    }
}
