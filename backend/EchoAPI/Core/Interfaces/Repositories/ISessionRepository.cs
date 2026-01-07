using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface ISessionRepository : IBaseRepository<Session>
    {
        Task<IEnumerable<Session>> GetUserSessionsAsync(Guid userId);
        Task<Session?> GetSessionWithMessagesAsync(Guid sessionId);
    }
}
