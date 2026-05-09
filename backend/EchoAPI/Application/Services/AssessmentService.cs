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
        private readonly IWhisperServiceClient _whisperClient;
        private readonly EchoDbContext _dbContext;

        public AssessmentService(IPhi3ServiceClient phi3Client, IWhisperServiceClient whisperClient, EchoDbContext dbContext)
        {
            _phi3Client = phi3Client;
            _whisperClient = whisperClient;
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

            user.Level = CalculateOverallLevel(
                user.SpeakingScore,
                user.WritingScore);

            user.LevelAssessedAt = DateTime.UtcNow;
            user.PlacementCompleted = true;

            await _dbContext.SaveChangesAsync();

            return assessment;
        }

        public async Task<AssessmentResponse> AssessSpeakingAndSaveAsync(
            Guid userId,
            Stream audioStream,
            string fileName,
            string? targetLanguage)
        {
            var transcription = await _whisperClient.TranscribeAsync(
                audioStream,
                fileName,
                targetLanguage);

            var result = await AssessSpeakingTextAsync(
                transcription.Text,
                transcription.Duration);

            var user = await _dbContext.Users
                .FirstOrDefaultAsync(u => u.Id == userId 
                && !u.IsDeleted);

            if (user == null)
            {
                 throw new InvalidOperationException("User not found.");
            }

            user.SpeakingLevel = result.EstimatedLevel;
            user.SpeakingScore = result.Score;
            user.SpeakingConfidence = result.Confidence;

            user.Level = CalculateOverallLevel(
                user.SpeakingScore,
                user.WritingScore);

            user.LevelAssessedAt = DateTime.UtcNow;
            user.PlacementCompleted = true;

            await _dbContext.SaveChangesAsync();

            return result;
        }

        private async Task<AssessmentResponse> AssessSpeakingTextAsync(
            string transcription,
            double? duration)
        {
            var prompt = $$$"""
            You are a professional CEFR speaking evaluator.

            Evaluate the user's SPOKEN language ability based on the transcription.

            Important:
            - This app focuses mainly on speaking practice.
            - Evaluate conversational speaking ability.
            - Consider fluency, vocabulary, grammar, sentence complexity, coherence, and ability to communicate.
            - Pronunciation cannot be measured perfectly from transcription, but if the transcription is fragmented or unclear, consider that as a possible speaking weakness.
            - Audio duration in seconds: {duration?.ToString("F1") ?? "unknown"}

            Respond ONLY with a raw JSON object.
            Do NOT use markdown.
            Do NOT wrap the response in ```json.
            Do NOT add explanations outside the JSON.

            Format:
            {{
              "level": "A1",
              "score": 0,
              "confidence": 0.0,
              "feedback": "short feedback"
            }}

            Rules:
            - level must be one of: A1, A2, B1, B2, C1, C2
            - score must be between 0 and 100
            - confidence must be between 0 and 1
            - feedback should focus on speaking improvement
            """;

            var aiResponse = await _phi3Client.ChatAsync(
                message: transcription,
                conversationId: null,
                systemPrompt: prompt,
                temperature: 0.1,
                maxTokens: 250
            );

            return ParseAssessmentResponse(aiResponse.Response);
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

        private AssessmentResponse ParseAssessmentResponse(string aiText)
        {
            var cleanJson = ExtractJson(aiText);

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

        private LanguageLevel CalculateOverallLevel(int speakingScore, int writingScore)
        {
            var overallScore = (int)Math.Round(
                speakingScore * 0.7 + writingScore * 0.3);

            return ScoreToLevel(overallScore);
        }

        private LanguageLevel ScoreToLevel(int score)
        {
            return score switch
            {
                <= 20 => LanguageLevel.A1,
                <= 40 => LanguageLevel.A2,
                <= 60 => LanguageLevel.B1,
                <= 80 => LanguageLevel.B2,
                <= 90 => LanguageLevel.C1,
                _ => LanguageLevel.C2
            };
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
