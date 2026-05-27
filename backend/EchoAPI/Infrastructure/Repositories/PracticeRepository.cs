using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EchoAPI.Infrastructure.Repositories
{
    public class PracticeRepository : IPracticeRepository
    {
        private readonly EchoDbContext _dbContext;

        public PracticeRepository(EchoDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<List<Mistake>> GetPracticeMistakesAsync(Guid userId, int count)
        {
            return await _dbContext.Mistakes
                .Where(m => m.UserId == userId)
                .Include(m => m.MistakeCategory)
                .OrderByDescending(m => m.CreatedAt)
                .Take(count)
                .ToListAsync();
        }

        public async Task AddSessionAsync(PracticeSession session)
        {
            await _dbContext.PracticeSessions.AddAsync(session);
        }

        public async Task<PracticeSession?> GetSessionWithItemsAsync(Guid userId, Guid sessionId)
        {
            return await _dbContext.PracticeSessions
                .Where(s => s.UserId == userId && s.Id == sessionId)
                .Include(s => s.Items)
                    .ThenInclude(i => i.Mistake)
                        .ThenInclude(m => m.MistakeCategory)
                .FirstOrDefaultAsync();
        }

        public async Task<PracticeSessionItem?> GetSessionItemAsync(
            Guid userId,
            Guid sessionId,
            Guid practiceItemId)
        {
            return await _dbContext.PracticeSessionItems
                .Where(i =>
                    i.Id == practiceItemId &&
                    i.PracticeSessionId == sessionId &&
                    i.PracticeSession.UserId == userId)
                .Include(i => i.PracticeSession)
                .Include(i => i.Mistake)
                    .ThenInclude(m => m.MistakeCategory)
                .FirstOrDefaultAsync();
        }

        public Task UpdateSessionAsync(PracticeSession session)
        {
            _dbContext.PracticeSessions.Update(session);
            return Task.CompletedTask;
        }

        public Task UpdateSessionItemAsync(PracticeSessionItem item)
        {
            _dbContext.PracticeSessionItems.Update(item);
            return Task.CompletedTask;
        }

        public async Task SaveChangesAsync()
        {
            await _dbContext.SaveChangesAsync();
        }
    }
}