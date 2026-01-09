using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EchoAPI.Infrastructure.Repositories
{
    public class VocabularyRepository : BaseRepository<Vocabulary>, IVocabularyRepository
    {
        public VocabularyRepository(EchoDbContext context) : base(context)
        {
        }
        public async Task<IEnumerable<Vocabulary>> GetByUserIdAsync(Guid userId)
        {
            return await _dbSet
                .Where(u => u.UserId == userId && !u.IsDeleted).ToListAsync();
        }
    }
}
