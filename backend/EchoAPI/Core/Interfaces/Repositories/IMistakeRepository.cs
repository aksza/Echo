using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Repositories
{
    public interface IMistakeRepository
    {
        Task<List<Mistake>> GetUserMistakesAsync(Guid userId);

        Task<Mistake?> GetUserMistakeByIdAsync(
            Guid userId,
            Guid mistakeId);

        Task UpdateAsync(Mistake mistake);

        Task SaveChangesAsync();
    }
}