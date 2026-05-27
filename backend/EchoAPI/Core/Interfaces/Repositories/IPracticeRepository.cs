using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IPracticeRepository
    {
        Task<List<Mistake>> GetPracticeMistakesAsync(Guid userId, int count);

        Task AddSessionAsync(PracticeSession session);

        Task<PracticeSession?> GetSessionWithItemsAsync(Guid userId, Guid sessionId);

        Task<PracticeSessionItem?> GetSessionItemAsync(
            Guid userId,
            Guid sessionId,
            Guid practiceItemId);

        Task UpdateSessionAsync(PracticeSession session);

        Task UpdateSessionItemAsync(PracticeSessionItem item);

        Task SaveChangesAsync();
    }
}