using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IPodcastSegmentRepository : IBaseRepository<PodcastSegment>
    {
        Task<IEnumerable<PodcastSegment>> GetByPodcastAsync(Guid podcastId);
    }
}
