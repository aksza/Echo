using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IVocabularyRepository : IBaseRepository<Vocabulary>
    {
        Task<IEnumerable<Vocabulary>> GetByUserAsync(Guid userId);
    }
}
