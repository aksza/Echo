namespace EchoAPI.Api.DTOs.Requests
{
    public class AddVocabularyRequest
    {
        public string Expression { get; set; } = string.Empty;
        public string Translation { get; set; } = string.Empty;
        public string? ExampleSentence { get; set; }
        public int AddedFrom { get; set;  } = 0; // e.g., 0 = user added, 1 = imported, etc. frontend kuldi, enum
        public int KnowledgeLevel { get; set; } = 0; // e.g., 0-5 scale

    }
}
