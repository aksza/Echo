using AutoMapper;
using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Core.Interfaces.Utils;


namespace EchoAPI.Application.Services
{
    public class UserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IJwtTokenService _jwtTokenService;
        private readonly IMapper _mapper;

        public UserService(IUserRepository userRepository, IPasswordHasher passwordHasher, IMapper mapper, IJwtTokenService jwtTokenService)
        {
            _userRepository = userRepository;
            _passwordHasher = passwordHasher;
            _jwtTokenService = jwtTokenService;
            _mapper = mapper;
        }

        public async Task<UserResponse> RegisterAsync(RegisterUserRequest request)
        {
            //email uniqueness check
            var existingUser = await _userRepository.GetByEmailAsync(request.Email);
            if (existingUser != null)
            {
                throw new InvalidOperationException("Email is already in use.");
            }

            //ezt valtsuk at imapperre
            var user = _mapper.Map<User>(request);

            user.Id = Guid.NewGuid();
            user.CreatedAt = DateTime.UtcNow;
            user.PasswordHash = _passwordHasher.HashPassword(request.Password);

            //mentes
            await _userRepository.AddAsync(user);
            await _userRepository.SaveChangesAsync();

            return _mapper.Map<UserResponse>(user);
        }

        public async Task<LoginResponse> LoginAsync(LoginRequest request)
        {
            var user = await _userRepository.GetByEmailAsync(request.Email);
            if (user == null || !_passwordHasher.VerifyPassword(request.Password, user.PasswordHash))
            {
                throw new UnauthorizedAccessException("Invalid email or password.");
            }

            user.LastLogin = DateTime.UtcNow;
            _userRepository.Update(user);

            await _userRepository.SaveChangesAsync();

            var token = _jwtTokenService.GenerateToken(user, out var expiresAt);

            return new LoginResponse
            {
                AccessToken = token,
                ExpiresAt = expiresAt
            };
        }

        public async Task<UserResponse?> GetByIdAsync(Guid userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);

            if (user == null || user.IsDeleted)
            {
                throw new InvalidOperationException("User not found.");
            }

            var userResponse = _mapper.Map<UserResponse>(user);
            return userResponse;
        }

        public async Task<UserResponse> EditUserAsync(Guid usderId, EditUserRequest request)
        {
            var user = await _userRepository.GetByIdAsync(usderId);
            if (user == null || user.IsDeleted)
            {
                throw new InvalidOperationException("User not found.");
            }
            // Update fields
            if (!string.IsNullOrEmpty(request.NativeLanguage))
            {
                user.NativeLanguage = request.NativeLanguage;
            }
            if (!string.IsNullOrEmpty(request.TargetLanguage))
            {
                user.TargetLanguage = request.TargetLanguage;
            }
            if (!string.IsNullOrEmpty(request.LearningGoals))
            {
                user.LearningGoals = request.LearningGoals;
            }
            if (request.AllowLearningDataSharing.HasValue)
            {
                user.AllowLearningDataSharing = request.AllowLearningDataSharing.Value;
            }

            _userRepository.Update(user);
            await _userRepository.SaveChangesAsync();

            return _mapper.Map<UserResponse>(user);
        }

        public async Task DeleteUserAsync(Guid userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);

            if(user == null || user.IsDeleted)
            {
                throw new InvalidOperationException("User not found");
            }

            user.IsDeleted = true;
            _userRepository.Update(user);
            await _userRepository.SaveChangesAsync();
        }
    }
}
