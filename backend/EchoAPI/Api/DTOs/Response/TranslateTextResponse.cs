namespace EchoAPI.Api.DTOs.Response
{
    public class TranslateTextResponse
    {
        public string Text { get; set; } = string.Empty;

        public string Translation { get; set; } = string.Empty;

        public string SourceLanguage { get; set; } = string.Empty;

        public string TargetLanguage { get; set; } = string.Empty;
    }
}