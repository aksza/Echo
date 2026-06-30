using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Entities;
using EchoAPI.Core.Enums;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EchoAPI.Application.Services
{
    public class LearningSummaryService
    {
        private readonly EchoDbContext _dbContext;

        public LearningSummaryService(EchoDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<LearningSummaryResponse> GetMySummaryAsync(Guid userId)
        {
            var user = await _dbContext.Users
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                throw new InvalidOperationException("User not found.");
            }

            var sessions = await _dbContext.Sessions
                .Where(s => s.UserId == userId)
                .ToListAsync();

            var vocabularyItems = await _dbContext.Vocabulary
                .Where(v => v.UserId == userId)
                .ToListAsync();

            var vocabularyIds = vocabularyItems
                .Select(v => v.Id)
                .ToList();

            var vocabularyPracticeHistory = await _dbContext.VocabularyPracticeHistories
                .Where(h => vocabularyIds.Contains(h.VocabularyId))
                .ToListAsync();

            var mistakes = await _dbContext.Mistakes
                .Include(m => m.MistakeCategory)
                .Where(m => m.UserId == userId)
                .ToListAsync();

            var practiceSessions = await _dbContext.PracticeSessions
                .Include(ps => ps.Items)
                .Where(ps => ps.UserId == userId)
                .OrderByDescending(ps => ps.StartedAt)
                .ToListAsync();

            var lastPracticeSession = practiceSessions.FirstOrDefault();

            var lastPracticeAccuracy = CalculateLastPracticeAccuracy(lastPracticeSession);

            var vocabularyPracticeSuccessRate = CalculateSuccessRate(
                vocabularyPracticeHistory.Count,
                vocabularyPracticeHistory.Count(h => h.Success));

            return new LearningSummaryResponse
            {
                AccountCreatedAt = user.CreatedAt,

                TotalSessions = sessions.Count,
                ConversationSessions = sessions.Count(s => s.SessionType == SessionType.Conversation),
                DailyStreak = CalculateDailyStreak(sessions),
                LastSessionAt = sessions
                    .OrderByDescending(s => s.EndedAt ?? s.StartedAt)
                    .Select(s => (DateTime?)(s.EndedAt ?? s.StartedAt))
                    .FirstOrDefault(),

                VocabularyCount = vocabularyItems.Count,
                VocabularyPracticeCount = vocabularyPracticeHistory.Count,
                VocabularyPracticeSuccessRate = vocabularyPracticeSuccessRate,

                MistakesCount = mistakes.Count,
                GrammarMistakesCount = CountMistakesByCategory(mistakes, "grammar"),
                VocabularyMistakesCount = CountMistakesByCategory(mistakes, "vocabulary"),
                PhrasingMistakesCount = CountMistakesByCategory(mistakes, "phrasing"),
                SentenceStructureMistakesCount = CountMistakesByCategory(mistakes, "sentence_structure"),

                PracticeSessionsCount = practiceSessions.Count,
                LastMistakePracticeAccuracy = lastPracticeAccuracy
            };
        }

        private static int CountMistakesByCategory(
            List<Mistake> mistakes,
            string category)
        {
            return mistakes.Count(m =>
                m.MistakeCategory != null &&
                string.Equals(
                    m.MistakeCategory.Name,
                    category,
                    StringComparison.OrdinalIgnoreCase));
        }

        private static double CalculateSuccessRate(
            int total,
            int successful)
        {
            if (total == 0)
            {
                return 0;
            }

            return Math.Round((double)successful / total * 100, 1);
        }

        private static double CalculateLastPracticeAccuracy(
            PracticeSession? session)
        {
            if (session == null || session.Items.Count == 0)
            {
                return 0;
            }

            var total = session.Items.Count;
            var correct = session.Items.Count(item => item.IsCorrect ?? false);

            return Math.Round((double)correct / total * 100, 1);
        }

        private static int CalculateDailyStreak(List<Session> sessions)
        {
            if (sessions.Count == 0)
            {
                return 0;
            }

            var activeDays = sessions
                .Select(s => (s.EndedAt ?? s.StartedAt).Date)
                .Distinct()
                .OrderByDescending(date => date)
                .ToList();

            if (activeDays.Count == 0)
            {
                return 0;
            }

            var today = DateTime.UtcNow.Date;
            var yesterday = today.AddDays(-1);

            var latestActiveDay = activeDays.First();

            if (latestActiveDay != today && latestActiveDay != yesterday)
            {
                return 0;
            }

            var streak = 0;
            var currentDay = latestActiveDay;

            while (activeDays.Contains(currentDay))
            {
                streak++;
                currentDay = currentDay.AddDays(-1);
            }

            return streak;
        }
    }
}