using EchoAPI.Api.DTOs;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Enums;
using EchoAPI.Core.Interfaces.Services;
using EchoAPI.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EchoAPI.Application.Services
{
    public class AssessmentService
    {
        private readonly IPhi3ServiceClient _phi3Client;
        private readonly EchoDbContext _dbContext;

        public AssessmentService(IPhi3ServiceClient phi3Client, EchoDbContext dbContext)
        {
            _phi3Client = phi3Client;
            _dbContext = dbContext;
        }

        public async Task<AssessmentResponse> AssessTextAndSaveAsync(Guid userId, string text)
        {
            var assessment = await AssessTextAsync(text);

            var user = await _dbContext.Users
                .FirstOrDefaultAsync(u => u.Id == userId 
                && !u.IsDeleted);

            if (user == null)
            {
                throw new InvalidOperationException("User not found.");
            }

            user.WritingLevel = assessment.EstimatedLevel;
            user.WritingScore = assessment.Score;
            user.WritingConfidence = assessment.Confidence;

            user.Level = assessment.EstimatedLevel;

            user.LevelAssessedAt = DateTime.UtcNow;
            user.PlacementCompleted = true;

            await _dbContext.SaveChangesAsync();

            return assessment;
        }

        public async Task<AssessmentResponse> AssessTextAsync(string text)
        {
            var prompt = """
            You are a professional CEFR language evaluator.

            Evaluate the user's WRITING skill only.

            Important:
            - This app is mainly focused on speaking practice.
            - This writing assessment is only a supporting signal.
            - Do not evaluate pronunciation or speaking fluency here.

            Respond ONLY with a raw JSON object.
            Do NOT use markdown.
            Do NOT wrap the response in ```json.
            Do NOT add explanations outside the JSON.

            Format:
            {
              "level": "A1",
              "score": 0,
              "confidence": 0.0,
              "feedback": "short feedback"
            }

            Rules:
            - level must be one of: A1, A2, B1, B2, C1, C2
            - score must be between 0 and 100
            - confidence must be between 0 and 1
            - feedback should be short and useful
            """;

            var aiResponse = await _phi3Client.ChatAsync(
                message: text,
                conversationId: null,
                systemPrompt: prompt,
                temperature: 0.1,
                maxTokens: 250
            );

            var cleanJson = ExtractJson(aiResponse.Response);

            var parsedResponse = JsonSerializer.Deserialize<AssessmentAiResult>(
                cleanJson,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

            if (parsedResponse == null)
            {
                throw new InvalidOperationException("Failed to parse AI response.");
            }

            return new AssessmentResponse
            {
                EstimatedLevel = ParseLevel(parsedResponse.Level),
                Score = Clamp(parsedResponse.Score, 0, 100),
                Confidence = Clamp(parsedResponse.Confidence, 0f, 1f),
                Feedback = parsedResponse.Feedback
            };
        }

        private static string ExtractJson(string response)
        {
            if (string.IsNullOrWhiteSpace(response))
            {
                throw new InvalidOperationException("AI response was empty.");
            }

            var cleaned = response.Trim();

            cleaned = cleaned
                .Replace("```json", "", StringComparison.OrdinalIgnoreCase)
                .Replace("```", "")
                .Trim();

            var start = cleaned.IndexOf('{');
            var end = cleaned.LastIndexOf('}');

            if (start < 0 || end < 0 || end <= start)
            {
                throw new InvalidOperationException($"AI response did not contain valid JSON. Response: {response}");
            }

            return cleaned.Substring(start, end - start + 1);
        }

        private LanguageLevel ParseLevel(string level)
        {
            return Enum.TryParse<LanguageLevel>(
                level,
                ignoreCase: true,
                out var parsedLevel)
                    ? parsedLevel
                    : LanguageLevel.A1;
        }

        private static int Clamp(int value, int min, int max)
        {
            return Math.Min(Math.Max(value, min), max);
        }

        private static float Clamp(float value, float min, float max)
        {
            return Math.Min(Math.Max(value, min), max);
        }
    }
}
