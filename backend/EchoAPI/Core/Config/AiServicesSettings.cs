namespace EchoAPI.Core.Config
{
    /// <summary>
    /// Configuration settings for AI microservices
    /// </summary>
    public class AiServicesSettings
    {
        public const string SectionName = "AiServices";

        public WhisperServiceSettings WhisperService { get; set; } = new();
        public PiperServiceSettings PiperService { get; set; } = new();
        public Phi3ServiceSettings Phi3Service { get; set; } = new();
        public HealthCheckSettings HealthCheck { get; set; } = new();
    }

    public class WhisperServiceSettings
    {
        public string BaseUrl { get; set; } = "http://localhost:8002/api/v1/stt";
        public int TimeoutSeconds { get; set; } = 300;
        public int MaxFileSizeMB { get; set; } = 25;
        public bool Enabled { get; set; } = true;
    }

    public class PiperServiceSettings
    {
        public string BaseUrl { get; set; } = "http://localhost:8001/api/v1/tts";
        public int TimeoutSeconds { get; set; } = 30;
        public int MaxTextLength { get; set; } = 5000;
        public string DefaultLanguage { get; set; } = "en_US";
        public bool Enabled { get; set; } = true;
    }

    public class Phi3ServiceSettings
    {
        public string BaseUrl { get; set; } = "http://localhost:8003/api/v1/llm";
        public int TimeoutSeconds { get; set; } = 120;
        public int MaxTokens { get; set; } = 512;
        public double Temperature { get; set; } = 0.7;
        public int MaxConversationHistory { get; set; } = 10;
        public bool Enabled { get; set; } = true;
    }

    public class HealthCheckSettings
    {
        public int IntervalSeconds { get; set; } = 60;
        public int TimeoutSeconds { get; set; } = 10;
    }
}
