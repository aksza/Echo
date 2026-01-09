using EchoAPI.Core.Entities;

namespace EchoAPI.Core.Interfaces.Utils
{
    public interface IJwtTokenService
    {
        string GenerateToken(User user, out DateTime expiresAt);
        //string GenerateToken(Guid userId, string Email, out DateTime expiresAt);
    }
}
