namespace EchoAPI.Api.DTOs.Response
{
    public class MistakeResponse
    {
        public Guid Id { get; set; }

        public string OriginalText { get; set; } = string.Empty;

        public string CorrectedText { get; set; } = string.Empty;

        public string? Explanation { get; set; }

        public Guid MistakeCategoryId { get; set; }

        public string Category { get; set; } = string.Empty;

        public string Improvement { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; }
    }
}