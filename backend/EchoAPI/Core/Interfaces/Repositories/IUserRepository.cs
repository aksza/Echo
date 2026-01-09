using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IUserRepository : IBaseRepository<User>
    {
        Task<User?> GetByEmailAsync(string email);
        new Task<User?> GetByIdAsync(Guid id); //override soft delete
    }
}
