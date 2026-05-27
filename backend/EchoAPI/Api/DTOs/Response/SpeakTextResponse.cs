namespace EchoAPI.Api.DTOs.Response
{
    public class SpeakTextResponse
    {
        public string Text { get; set; } = string.Empty;

        public string AudioUrl { get; set; } = string.Empty;

        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }
}