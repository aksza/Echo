using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EchoAPI.Infrastructure.Repositories
{
    public class MistakeRepository : IMistakeRepository
    {
        private readonly EchoDbContext _dbContext;

        public MistakeRepository(EchoDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<List<Mistake>> GetUserMistakesAsync(Guid userId)
        {
            return await _dbContext.Mistakes
                .Where(m =>
                    m.UserId == userId &&
                    !m.IsDeleted)
                .Include(m => m.MistakeCategory)
                .OrderByDescending(m => m.CreatedAt)
                .ToListAsync();
        }

        public async Task<Mistake?> GetUserMistakeByIdAsync(
            Guid userId,
            Guid mistakeId)
        {
            return await _dbContext.Mistakes
                .Where(m =>
                    m.UserId == userId &&
                    m.Id == mistakeId &&
                    !m.IsDeleted)
                .Include(m => m.MistakeCategory)
                .FirstOrDefaultAsync();
        }

        public Task UpdateAsync(Mistake mistake)
        {
            _dbContext.Mistakes.Update(mistake);

            return Task.CompletedTask;
        }

        public async Task SaveChangesAsync()
        {
            await _dbContext.SaveChangesAsync();
        }
    }
}