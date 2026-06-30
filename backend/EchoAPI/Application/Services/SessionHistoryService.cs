using EchoAPI.Api.DTOs.Response;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EchoAPI.Application.Services
{
    public class SessionHistoryService
    {
        private readonly EchoDbContext _dbContext;

        public SessionHistoryService(EchoDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IEnumerable<SessionHistoryResponse>> GetMySessionsAsync(Guid userId)
        {
            var sessions = await _dbContext.Sessions
                .Where(s => s.UserId == userId)
                .OrderByDescending(s => s.EndedAt ?? s.StartedAt)
                .Select(s => new SessionHistoryResponse
                {
                    Id = s.Id,
                    Title = string.IsNullOrWhiteSpace(s.Title)
                        ? "Learning session"
                        : s.Title,
                    SessionType = s.SessionType.ToString(),
                    StartedAt = s.StartedAt,
                    EndedAt = s.EndedAt
                })
                .ToListAsync();

            return sessions;
        }
    }
}