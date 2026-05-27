using EchoAPI.Api.DTOs.Practice;
using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Core.Interfaces.Services;
using System.Text.Json;

namespace EchoAPI.Application.Services
{
    public class PracticeService
    {
        private readonly IPracticeRepository _practiceRepository;
        private readonly IPhi3ServiceClient _phi3Client;
        private readonly IWhisperServiceClient _whisperClient;
        private readonly ILogger<PracticeService> _logger;

        public PracticeService(
            IPracticeRepository practiceRepository,
            IPhi3ServiceClient phi3Client,
            IWhisperServiceClient whisperClient,
            ILogger<PracticeService> logger)
        {
            _practiceRepository = practiceRepository;
            _phi3Client = phi3Client;
            _whisperClient = whisperClient;
            _logger = logger;
        }

        public async Task<StartPracticeSessionResponse> StartMistakePracticeSessionAsync(
            Guid userId,
            int count = 5)
        {
            count = Math.Clamp(count, 1, 10);

            var mistakes = await _practiceRepository.GetPracticeMistakesAsync(userId, count);

            if (mistakes.Count == 0)
            {
                throw new InvalidOperationException("No mistakes available for practice.");
            }

            var session = new PracticeSession
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                StartedAt = DateTime.UtcNow,
                TotalItems = mistakes.Count,
                CorrectCount = 0,
                IncorrectCount = 0,
                SkippedCount = 0,
                IsCompleted = false,
                Items = mistakes.Select(m => new PracticeSessionItem
                {
                    Id = Guid.NewGuid(),
                    MistakeId = m.Id,
                    OriginalText = m.OriginalText,
                    CorrectedText = m.CorrectedText,
                    CreatedAt = DateTime.UtcNow
                }).ToList()
            };

            await _practiceRepository.AddSessionAsync(session);
            await _practiceRepository.SaveChangesAsync();

            return new StartPracticeSessionResponse
            {
                SessionId = session.Id,
                TotalItems = session.TotalItems,
                Items = session.Items.Select(item =>
                {
                    var mistake = mistakes.First(m => m.Id == item.MistakeId);

                    return new PracticeItemResponse
                    {
                        PracticeItemId = item.Id,
                        MistakeId = item.MistakeId,
                        OriginalText = item.OriginalText,
                        CorrectedText = item.CorrectedText,
                        Explanation = mistake.Explanation,
                        Category = mistake.MistakeCategory?.Name ?? string.Empty
                    };
                }).ToList()
            };
        }

        public async Task<PracticeAnswerResponse> SubmitTextAnswerAsync(
            Guid userId,
            PracticeTextAnswerRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Answer))
            {
                throw new ArgumentException("Answer cannot be empty.");
            }

            return await EvaluateAndSaveAnswerAsync(
                userId,
                request.SessionId,
                request.PracticeItemId,
                request.Answer,
                transcribedAnswer: null);
        }

        public async Task<PracticeAnswerResponse> SubmitVoiceAnswerAsync(
            Guid userId,
            PracticeVoiceAnswerRequest request)
        {
            if (request.AudioFile == null || request.AudioFile.Length == 0)
            {
                throw new ArgumentException("Audio file is required.");
            }

            using var stream = request.AudioFile.OpenReadStream();

            var transcription = await _whisperClient.TranscribeAsync(
                stream,
                request.AudioFile.FileName,
                request.Language);

            if (string.IsNullOrWhiteSpace(transcription.Text))
            {
                throw new InvalidOperationException("Speech could not be detected.");
            }

            return await EvaluateAndSaveAnswerAsync(
                userId,
                request.SessionId,
                request.PracticeItemId,
                transcription.Text,
                transcription.Text);
        }

        public async Task<PracticeAnswerResponse> SkipItemAsync(
            Guid userId,
            PracticeSkipRequest request)
        {
            var item = await _practiceRepository.GetSessionItemAsync(
                userId,
                request.SessionId,
                request.PracticeItemId);

            if (item == null)
            {
                throw new InvalidOperationException("Practice item not found.");
            }

            if (item.PracticeSession.IsCompleted)
            {
                throw new InvalidOperationException("Practice session is already completed.");
            }

            if (!item.Skipped && item.IsCorrect == null)
            {
                item.Skipped = true;
                item.CompletedAt = DateTime.UtcNow;

                item.PracticeSession.SkippedCount++;
            }

            CompleteSessionIfNeeded(item.PracticeSession);

            await _practiceRepository.UpdateSessionItemAsync(item);
            await _practiceRepository.UpdateSessionAsync(item.PracticeSession);
            await _practiceRepository.SaveChangesAsync();

            var summary = item.PracticeSession.IsCompleted
                ? BuildSummary(item.PracticeSession)
                : null;

            return new PracticeAnswerResponse
            {
                SessionId = item.PracticeSessionId,
                PracticeItemId = item.Id,
                IsCorrect = false,
                Score = 0,
                Feedback = "Skipped.",
                CorrectAnswer = item.CorrectedText,
                UserAnswer = null,
                TranscribedAnswer = null,
                SessionCompleted = item.PracticeSession.IsCompleted,
                Summary = summary
            };
        }

        public async Task<PracticeSummaryResponse> EndSessionAsync(
            Guid userId,
            Guid sessionId)
        {
            var session = await _practiceRepository.GetSessionWithItemsAsync(
                userId,
                sessionId);

            if (session == null)
            {
                throw new InvalidOperationException("Practice session not found.");
            }

            if (!session.IsCompleted)
            {
                session.IsCompleted = true;
                session.EndedAt = DateTime.UtcNow;

                await _practiceRepository.UpdateSessionAsync(session);
                await _practiceRepository.SaveChangesAsync();
            }

            return BuildSummary(session);
        }

        public async Task<PracticeSummaryResponse> GetSummaryAsync(
            Guid userId,
            Guid sessionId)
        {
            var session = await _practiceRepository.GetSessionWithItemsAsync(
                userId,
                sessionId);

            if (session == null)
            {
                throw new InvalidOperationException("Practice session not found.");
            }

            return BuildSummary(session);
        }

        private async Task<PracticeAnswerResponse> EvaluateAndSaveAnswerAsync(
            Guid userId,
            Guid sessionId,
            Guid practiceItemId,
            string userAnswer,
            string? transcribedAnswer)
        {
            var item = await _practiceRepository.GetSessionItemAsync(
                userId,
                sessionId,
                practiceItemId);

            if (item == null)
            {
                throw new InvalidOperationException("Practice item not found.");
            }

            if (item.PracticeSession.IsCompleted)
            {
                throw new InvalidOperationException("Practice session is already completed.");
            }

            var evaluation = await EvaluateAnswerWithAiAsync(
                item.OriginalText,
                item.CorrectedText,
                userAnswer);

            var wasPreviouslyAnswered = item.IsCorrect != null || item.Skipped;

            item.UserAnswer = userAnswer;
            item.TranscribedAnswer = transcribedAnswer;
            item.IsCorrect = evaluation.IsCorrect;
            item.Score = evaluation.Score;
            item.Feedback = evaluation.Feedback;
            item.AttemptCount++;
            item.Skipped = false;

            if (evaluation.IsCorrect)
            {
                item.CompletedAt = DateTime.UtcNow;
            }

            if (!wasPreviouslyAnswered)
            {
                if (evaluation.IsCorrect)
                {
                    item.PracticeSession.CorrectCount++;
                }
                else
                {
                    item.PracticeSession.IncorrectCount++;
                }
            }
            else
            {
                RecalculateSessionStats(item.PracticeSession);
            }

            CompleteSessionIfNeeded(item.PracticeSession);

            await _practiceRepository.UpdateSessionItemAsync(item);
            await _practiceRepository.UpdateSessionAsync(item.PracticeSession);
            await _practiceRepository.SaveChangesAsync();

            var summary = item.PracticeSession.IsCompleted
                ? BuildSummary(item.PracticeSession)
                : null;

            return new PracticeAnswerResponse
            {
                SessionId = sessionId,
                PracticeItemId = practiceItemId,
                IsCorrect = evaluation.IsCorrect,
                Score = evaluation.Score,
                Feedback = evaluation.Feedback,
                CorrectAnswer = evaluation.CorrectAnswer,
                UserAnswer = userAnswer,
                TranscribedAnswer = transcribedAnswer,
                SessionCompleted = item.PracticeSession.IsCompleted,
                Summary = summary
            };
        }

        private async Task<PracticeAnswerAiResult> EvaluateAnswerWithAiAsync(
            string originalText,
            string correctedText,
            string userAnswer)
        {
            var prompt = """
            You are an English practice evaluator.

            The user is practicing fixing their previous language mistake.

            Return ONLY raw JSON. No markdown.

            JSON format:
            {
              "isCorrect": true,
              "score": 100,
              "feedback": "short feedback",
              "correctAnswer": "correct sentence"
            }

            Rules:
            - isCorrect is true only if the user's answer fixes the original mistake.
            - Accept small harmless differences if the target mistake is fixed.
            - score must be 0-100.
            - feedback must be short, maximum 1 sentence.
            - correctAnswer should contain the best corrected version.
            """;

            var message = $"""
            Original mistake:
            {originalText}

            Expected correction:
            {correctedText}

            User answer:
            {userAnswer}
            """;

            try
            {
                var aiResponse = await _phi3Client.ChatAsync(
                    message: message,
                    conversationId: null,
                    systemPrompt: prompt,
                    temperature: 0.1,
                    maxTokens: 140);

                var cleanJson = ExtractJson(aiResponse.Response);

                var parsed = JsonSerializer.Deserialize<PracticeAnswerAiResult>(
                    cleanJson,
                    new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

                if (parsed == null)
                {
                    throw new InvalidOperationException("AI evaluation was empty.");
                }

                parsed.Score = Math.Clamp(parsed.Score, 0, 100);

                if (string.IsNullOrWhiteSpace(parsed.CorrectAnswer))
                {
                    parsed.CorrectAnswer = correctedText;
                }

                return parsed;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "AI practice evaluation failed. Falling back to simple comparison.");

                var simpleCorrect = Normalize(userAnswer) == Normalize(correctedText);

                return new PracticeAnswerAiResult
                {
                    IsCorrect = simpleCorrect,
                    Score = simpleCorrect ? 100 : 0,
                    Feedback = simpleCorrect
                        ? "Correct, nice work!"
                        : "Not quite. Compare it with the corrected sentence.",
                    CorrectAnswer = correctedText
                };
            }
        }

        private static string ExtractJson(string response)
        {
            var cleaned = response
                .Replace("```json", "", StringComparison.OrdinalIgnoreCase)
                .Replace("```", "")
                .Trim();

            var start = cleaned.IndexOf('{');
            var end = cleaned.LastIndexOf('}');

            if (start < 0 || end < 0 || end <= start)
            {
                throw new InvalidOperationException("AI response did not contain valid JSON.");
            }

            return cleaned.Substring(start, end - start + 1);
        }

        private static string Normalize(string value)
        {
            return value
                .Trim()
                .ToLowerInvariant()
                .Replace(".", "")
                .Replace(",", "")
                .Replace("!", "")
                .Replace("?", "");
        }

        private static void CompleteSessionIfNeeded(PracticeSession session)
        {
            var finishedCount = session.Items.Count(i =>
                i.IsCorrect == true ||
                i.Skipped);

            if (finishedCount >= session.TotalItems && !session.IsCompleted)
            {
                session.IsCompleted = true;
                session.EndedAt = DateTime.UtcNow;
            }
        }

        private static void RecalculateSessionStats(PracticeSession session)
        {
            session.CorrectCount = session.Items.Count(i => i.IsCorrect == true);
            session.IncorrectCount = session.Items.Count(i => i.IsCorrect == false && !i.Skipped);
            session.SkippedCount = session.Items.Count(i => i.Skipped);
        }

        private static PracticeSummaryResponse BuildSummary(PracticeSession session)
        {
            RecalculateSessionStats(session);

            var attempted = session.CorrectCount + session.IncorrectCount;
            var accuracy = attempted == 0
                ? 0
                : Math.Round((double)session.CorrectCount / attempted * 100, 2);

            return new PracticeSummaryResponse
            {
                SessionId = session.Id,
                TotalItems = session.TotalItems,
                CorrectCount = session.CorrectCount,
                IncorrectCount = session.IncorrectCount,
                SkippedCount = session.SkippedCount,
                AccuracyPercent = accuracy,
                Message = BuildSummaryMessage(accuracy, session.CorrectCount, session.TotalItems),
                StartedAt = session.StartedAt,
                EndedAt = session.EndedAt
            };
        }

        private static string BuildSummaryMessage(
            double accuracy,
            int correctCount,
            int totalItems)
        {
            if (totalItems == 0)
            {
                return "No practice items were completed.";
            }

            if (accuracy >= 85)
            {
                return "Excellent work! Your mistakes are improving.";
            }

            if (accuracy >= 60)
            {
                return "Good progress! Keep practicing these patterns.";
            }

            if (correctCount > 0)
            {
                return "Nice start! Review the corrections and try again.";
            }

            return "Keep going! These mistakes need more practice.";
        }
    }
}