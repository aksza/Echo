using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EchoAPI.Infrastructure.Repositories
{
    public class UserRepository : BaseRepository<User>, IUserRepository
    {
        public UserRepository(EchoDbContext context) : base(context)
        {
        }

        public Task<User?> GetByEmailAsync(string email)
        {
            return _dbSet.FirstOrDefaultAsync(u => u.Email == email && !u.IsDeleted);
        }
    }
}
