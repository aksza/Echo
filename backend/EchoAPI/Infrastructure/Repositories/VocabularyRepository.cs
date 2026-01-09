using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EchoAPI.Infrastructure.Repositories
{
    public class VocabularyRepository : BaseRepository<Vocabulary>, IVocabularyRepository
    {
        private readonly EchoDbContext _context;
        public VocabularyRepository(EchoDbContext context) : base(context)
        {
            _context = context;
        }
        public async Task<IEnumerable<Vocabulary>> GetByUserIdAsync(Guid userId)
        {
            return await _context.Vocabulary
                .Where(v => v.UserId == userId && !v.IsDeleted).ToListAsync();
        }
    }
}
