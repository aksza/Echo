namespace EchoAPI.Api.DTOs
{
    public class AssessmentAiResult
    {
        public string Level { get; set; } = string.Empty;

        public int Score { get; set; }

        public float Confidence { get; set; }

        public string Feedback { get; set; } = string.Empty;
    }
}
