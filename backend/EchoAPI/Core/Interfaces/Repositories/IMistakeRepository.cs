using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IMistakeRepository : IBaseRepository<Mistake>
    {
        Task<IEnumerable<Mistake>> GetUserMistakesAsync(Guid userId);
        Task<IEnumerable<Mistake>> GetMistakesByMessageAsync(Guid messageId);
    }
}
