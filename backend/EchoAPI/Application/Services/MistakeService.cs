using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;

namespace EchoAPI.Application.Services
{
    public class MistakeService
    {
        private readonly IMistakeRepository _mistakeRepository;

        public MistakeService(IMistakeRepository mistakeRepository)
        {
            _mistakeRepository = mistakeRepository;
        }

        public async Task<List<MistakeResponse>> GetUserMistakesAsync(Guid userId)
        {
            var mistakes = await _mistakeRepository.GetUserMistakesAsync(userId);

            return mistakes
                .Select(MapToResponse)
                .ToList();
        }

        public async Task<MistakeResponse?> GetUserMistakeByIdAsync(
            Guid userId,
            Guid mistakeId)
        {
            var mistake = await _mistakeRepository.GetUserMistakeByIdAsync(
                userId,
                mistakeId);

            if (mistake == null)
            {
                return null;
            }

            return MapToResponse(mistake);
        }

        public async Task DeleteUserMistakeAsync(
            Guid userId,
            Guid mistakeId)
        {
            var mistake = await _mistakeRepository.GetUserMistakeByIdAsync(
                userId,
                mistakeId);

            if (mistake == null)
            {
                throw new InvalidOperationException("Mistake not found.");
            }

            mistake.IsDeleted = true;

            await _mistakeRepository.UpdateAsync(mistake);
            await _mistakeRepository.SaveChangesAsync();
        }

        private static MistakeResponse MapToResponse(Mistake mistake)
        {
            return new MistakeResponse
            {
                Id = mistake.Id,
                OriginalText = mistake.OriginalText,
                CorrectedText = mistake.CorrectedText,
                Explanation = mistake.Explanation,
                MistakeCategoryId = mistake.MistakeCategoryId,
                Category = mistake.MistakeCategory?.Name ?? string.Empty,
                Improvement = mistake.Improvement.ToString(),
                CreatedAt = mistake.CreatedAt
            };
        }
    }
}