using EchoAPI.Core.Interfaces.Utils;

namespace EchoAPI.Infrastructure.Utils
{
    public class PasswordHasher : IPasswordHasher
    {
        public string HashPassword(string password)
        => BCrypt.Net.BCrypt.HashPassword(password);

        public bool VerifyPassword(string hashedPassword, string providedPassword)
        => BCrypt.Net.BCrypt.Verify(providedPassword, hashedPassword);
    }
}
