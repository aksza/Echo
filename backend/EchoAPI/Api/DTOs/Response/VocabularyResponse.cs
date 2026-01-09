namespace EchoAPI.Api.DTOs.Response
{
    public class VocabularyResponse
    {
        public Guid Id { get; set; }
        public string Expression { get; set; } = null!;
        public string Translation { get; set; } = null!;
        public string? ExampleSentence { get; set; }
        public string AddedFrom { get; set; } = null!;
        public string KnowledgeLevel { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
    }
}
