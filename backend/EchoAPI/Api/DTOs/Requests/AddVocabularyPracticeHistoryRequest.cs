using System.ComponentModel.DataAnnotations;

namespace EchoAPI.Api.DTOs.Requests
{
    public class AddVocabularyPracticeHistoryRequest
    {
        [Required]
        public Guid VocabularyId { get; set; }

        [Range(0, int.MaxValue)]
        public int? ResponseTimeMs { get; set; }

        public bool Success { get; set; }
    }
}