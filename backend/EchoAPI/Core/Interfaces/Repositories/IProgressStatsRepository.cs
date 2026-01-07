using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IProgressStatsRepository : IBaseRepository<ProgressStats>
    {
        Task<IEnumerable<ProgressStats>> GetStatsForUserAsync(Guid userId);
    }
}
