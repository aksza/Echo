using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Services;
using EchoAPI.Infrastructure.Data;
using EchoAPI.Infrastructure.Services.AiServices.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EchoAPI.Application.Services
{
    public class ConversationOrchestrator
    {
        private readonly IWhisperServiceClient _whisperClient;
        private readonly IPhi3ServiceClient _phi3Client;
        private readonly IPiperServiceClient _piperClient;
        private readonly IAudioStorageService _audioStorage;
        private readonly EchoDbContext _dbContext;
        private readonly ILogger<ConversationOrchestrator> _logger;

        public ConversationOrchestrator(
            IWhisperServiceClient whisperClient,
            IPhi3ServiceClient phi3Client,
            IPiperServiceClient piperClient,
            IAudioStorageService audioStorage,
            EchoDbContext dbContext,
            ILogger<ConversationOrchestrator> logger)
        {
            _whisperClient = whisperClient;
            _phi3Client = phi3Client;
            _piperClient = piperClient;
            _audioStorage = audioStorage;
            _dbContext = dbContext;
            _logger = logger;
        }

        public async Task<VoiceConversationResult> ProcessVoiceMessageAsync(
            Guid userId,
            Stream audioStream,
            string fileName,
            string? conversationId = null,
            string? language = null,
            string? systemPrompt = null)
        {
            try
            {
                _logger.LogInformation("Step 1/3: Transcribing audio...");

                var transcription = await _whisperClient.TranscribeAsync(
                    audioStream,
                    fileName,
                    language);

                if (string.IsNullOrWhiteSpace(transcription.Text))
                {
                    throw new InvalidOperationException("Speech could not be detected.");
                }

                _logger.LogInformation("Step 2/3: Generating AI response and mistakes...");

                var prompt = """
                You are Echo, a friendly AI speaking partner for language learning.

                The user is practicing spoken English.

                Return ONLY raw JSON. Do not use markdown. Do not wrap the response in ```json.

                JSON format:
                {
                  "reply": "short natural answer",
                  "mistakes": [
                    {
                      "original": "wrong part",
                      "corrected": "correct version",
                      "type": "grammar",
                      "explanation": "short explanation"
                    }
                  ]
                }

                Rules:
                - reply must be maximum 1-2 short sentences.
                - reply should sound natural and conversational.
                - Do not give long grammar explanations in reply.
                - Detect grammar mistakes, vocabulary mistakes, and unnatural phrasing.
                - If there are no mistakes, return "mistakes": [].
                - Mistake type can be: grammar, vocabulary, phrasing, sentence_structure.
                - Return maximum 2 mistakes.
                - Each explanation must be maximum 8 words.
                - Keep the JSON very short.
                - Always close the JSON correctly.
                - Never cut the JSON response.
                - Do not add extra text outside JSON.

                IMPORTANT RESPONSE RULES:
                - Keep responses VERY short.
                - Maximum 1-2 sentences.
                - Prefer natural conversational replies.
                - Do not give long explanations.
                - Do not teach grammar unless explicitly asked.
                - Keep answers under 30 words whenever possible.
                - Sound like a real conversation partner. sentence_structure.
                """;

                if (!string.IsNullOrWhiteSpace(systemPrompt))
                {
                    prompt = $"{systemPrompt}\n\n{prompt}";
                }

                var chatResponse = await _phi3Client.ChatAsync(
                    message: transcription.Text,
                    conversationId: conversationId,
                    systemPrompt: prompt,
                    temperature: 0.7,
                    maxTokens: 350);

                var aiData = ParseConversationAiResponse(chatResponse.Response);

                _logger.LogInformation("AI raw response: {Response}", chatResponse.Response);
                _logger.LogInformation("Mistakes detected: {Count}", aiData.Mistakes.Count);

                await SaveMistakesAsync(userId, aiData.Mistakes);

                _logger.LogInformation("Step 3/3: Synthesizing AI reply...");

                var audioResponseStream = await _piperClient.SynthesizeToStreamAsync(
                    aiData.Reply,
                    language);

                var audioFileName = $"response_{DateTime.UtcNow:yyyyMMddHHmmss}.wav";

                var savedAudioPath = await _audioStorage.SaveAudioAsync(
                    audioResponseStream,
                    audioFileName);

                return new VoiceConversationResult
                {
                    UserTranscription = transcription.Text,
                    DetectedLanguage = transcription.Language,
                    AiResponse = aiData.Reply,
                    ConversationId = chatResponse.ConversationId,
                    AudioFilePath = savedAudioPath,
                    TokensUsed = chatResponse.TokensUsed,
                    AudioDuration = transcription.Duration
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing voice message");
                throw;
            }
        }

        public async Task<VoiceCorrectionResult> ProcessVoiceForCorrectionAsync(
            Stream audioStream,
            string fileName,
            string targetLanguage = "en",
            bool provideExplanation = true)
        {
            try
            {
                var transcription = await _whisperClient.TranscribeAsync(
                    audioStream,
                    fileName,
                    targetLanguage);

                var correction = await _phi3Client.CorrectTextAsync(
                    transcription.Text,
                    targetLanguage,
                    provideExplanation);

                var audioStream2 = await _piperClient.SynthesizeToStreamAsync(
                    correction.CorrectedText,
                    targetLanguage);

                var audioFileName = $"corrected_{DateTime.UtcNow:yyyyMMddHHmmss}.wav";

                var savedAudioPath = await _audioStorage.SaveAudioAsync(
                    audioStream2,
                    audioFileName);

                return new VoiceCorrectionResult
                {
                    OriginalText = correction.OriginalText,
                    CorrectedText = correction.CorrectedText,
                    Corrections = correction.Corrections,
                    Explanation = correction.Explanation,
                    CorrectedAudioPath = savedAudioPath
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing voice for correction");
                throw;
            }
        }

        private ConversationAiResponse ParseConversationAiResponse(string aiResponse)
        {
            try
            {
                var cleanJson = ExtractJson(aiResponse);

                var parsed = JsonSerializer.Deserialize<ConversationAiResponse>(
                    cleanJson,
                    new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

                if (parsed == null || string.IsNullOrWhiteSpace(parsed.Reply))
                {
                    throw new InvalidOperationException("Parsed AI response was empty.");
                }

                return parsed;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to parse conversation JSON. Falling back to raw AI response.");

                return new ConversationAiResponse
                {
                    Reply = aiResponse,
                    Mistakes = new List<CorrectionDetail>()
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

        private async Task SaveMistakesAsync(
            Guid userId,
            List<CorrectionDetail> mistakes)
        {
            if (mistakes == null || mistakes.Count == 0)
            {
                return;
            }

            foreach (var mistake in mistakes)
            {
                if (string.IsNullOrWhiteSpace(mistake.Original) ||
                    string.IsNullOrWhiteSpace(mistake.Corrected))
                {
                    continue;
                }

                var categoryName = NormalizeCategory(mistake.Type);

                var category = await _dbContext.MistakeCategories
                    .FirstOrDefaultAsync(c => c.Name.ToLower() == categoryName.ToLower());

                if (category == null)
                {
                    category = new MistakeCategory
                    {
                        Id = Guid.NewGuid(),
                        Name = categoryName
                    };

                    _dbContext.MistakeCategories.Add(category);
                    await _dbContext.SaveChangesAsync();
                }

                var dbMistake = new Mistake
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    OriginalText = Truncate(mistake.Original, 500),
                    CorrectedText = Truncate(mistake.Corrected, 500),
                    Explanation = mistake.Explanation,
                    MistakeCategoryId = category.Id,
                    CreatedAt = DateTime.UtcNow
                };

                _dbContext.Mistakes.Add(dbMistake);
            }

            await _dbContext.SaveChangesAsync();
        }

        private static string NormalizeCategory(string? category)
        {
            if (string.IsNullOrWhiteSpace(category))
            {
                return "grammar";
            }

            var normalized = category.Trim().ToLower();

            return normalized switch
            {
                "vocab" => "vocabulary",
                "word_choice" => "vocabulary",
                "sentence structure" => "sentence_structure",
                "sentence-structure" => "sentence_structure",
                _ => normalized.Length > 50 ? normalized[..50] : normalized
            };
        }

        private static string Truncate(string value, int maxLength)
        {
            if (string.IsNullOrEmpty(value))
            {
                return value;
            }

            return value.Length <= maxLength
                ? value
                : value[..maxLength];
        }
    }

    public class VoiceConversationResult
    {
        public string UserTranscription { get; set; } = string.Empty;
        public string DetectedLanguage { get; set; } = string.Empty;
        public string AiResponse { get; set; } = string.Empty;
        public string ConversationId { get; set; } = string.Empty;
        public string AudioFilePath { get; set; } = string.Empty;
        public int? TokensUsed { get; set; }
        public double? AudioDuration { get; set; }
    }

    public class VoiceCorrectionResult
    {
        public string OriginalText { get; set; } = string.Empty;
        public string CorrectedText { get; set; } = string.Empty;
        public List<CorrectionDetail> Corrections { get; set; } = new();
        public string? Explanation { get; set; }
        public string CorrectedAudioPath { get; set; } = string.Empty;
    }
}