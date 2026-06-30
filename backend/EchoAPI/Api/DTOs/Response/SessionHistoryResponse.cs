namespace EchoAPI.Api.DTOs.Response
{
    public class SessionHistoryResponse
    {
        public Guid Id { get; set; }

        public string Title { get; set; } = string.Empty;

        public string SessionType { get; set; } = string.Empty;

        public DateTime StartedAt { get; set; }

        public DateTime? EndedAt { get; set; }
    }
}