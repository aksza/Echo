using EchoAPI.Core.Enums;

namespace EchoAPI.Api.DTOs.Response
{
    public class AssessmentResponse
    {
        public LanguageLevel EstimatedLevel { get; set; }

        public int Score { get; set; }

        public float Confidence { get; set; }

        public string Feedback { get; set; } = string.Empty;
    }
}
