using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IPodcastProgressRepository : IBaseRepository<PodcastProgress>
    {
        Task<PodcastProgress?> GetUserProgressAsync(Guid userId, Guid podcastId);
    }
}
