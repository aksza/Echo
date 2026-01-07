using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{

    public interface IVocabularyPracticeRepository : IBaseRepository<VocabularyPracticeHistory>
    {
        Task<IEnumerable<VocabularyPracticeHistory>> GetPracticeHistoryAsync(Guid vocabId);
    }
}
