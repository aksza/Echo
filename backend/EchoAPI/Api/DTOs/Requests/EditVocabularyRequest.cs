namespace EchoAPI.Api.DTOs.Requests
{
    public class EditVocabularyRequest
    {
        public string? Expression { get; set; }
        public string? Translation { get; set; }
        public string? ExampleSentence { get; set; }
    }
}
