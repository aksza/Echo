using AutoMapper;
using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Entities;
using EchoAPI.Core.Interfaces.Repositories;
using EchoAPI.Core.Interfaces.Services;
using System.Text.Json;

namespace EchoAPI.Application.Services
{
    public class VocabularyService
    {
        private readonly IVocabularyRepository _vocabularyRepository;
        private readonly IPhi3ServiceClient _phi3Client;
        private readonly IMapper _mapper;

        public VocabularyService(
            IVocabularyRepository vocabularyRepository,
            IPhi3ServiceClient phi3Client,
            IMapper mapper)
        {
            _vocabularyRepository = vocabularyRepository;
            _phi3Client = phi3Client;
            _mapper = mapper;
        }

        public async Task<VocabularyResponse> AddVocabularyAsync(
            Guid userId,
            AddVocabularyRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Expression))
            {
                throw new ArgumentException("Expression is required.");
            }

            if (string.IsNullOrWhiteSpace(request.Translation))
            {
                throw new ArgumentException("Translation is required.");
            }

            var vocabulary = _mapper.Map<Vocabulary>(request);
            vocabulary.UserId = userId;
            vocabulary.CreatedAt = DateTime.UtcNow;

            await _vocabularyRepository.AddAsync(vocabulary);
            await _vocabularyRepository.SaveChangesAsync();

            return _mapper.Map<VocabularyResponse>(vocabulary);
        }

        public async Task<IEnumerable<VocabularyResponse>> GetUserVocabulariesAsync(
            Guid userId)
        {
            var vocabularies = await _vocabularyRepository.GetByUserIdAsync(userId);

            return _mapper.Map<IEnumerable<VocabularyResponse>>(vocabularies);
        }

        public async Task<VocabularyResponse?> EditVocabularyAsync(
            Guid userId,
            Guid vocabularyId,
            EditVocabularyRequest request)
        {
            var vocabulary = await _vocabularyRepository.GetByIdAsync(vocabularyId);

            if (vocabulary == null ||
                vocabulary.IsDeleted ||
                vocabulary.UserId != userId)
            {
                throw new InvalidOperationException("Vocabulary not found or unauthorized.");
            }

            if (!string.IsNullOrWhiteSpace(request.Expression))
            {
                vocabulary.Expression = request.Expression;
            }

            if (!string.IsNullOrWhiteSpace(request.Translation))
            {
                vocabulary.Translation = request.Translation;
            }

            if (request.ExampleSentence != null)
            {
                vocabulary.ExampleSentence = request.ExampleSentence;
            }

            _vocabularyRepository.Update(vocabulary);
            await _vocabularyRepository.SaveChangesAsync();

            return _mapper.Map<VocabularyResponse>(vocabulary);
        }

        public async Task<bool> DeleteVocabularyAsync(
            Guid userId,
            Guid vocabularyId)
        {
            var vocabulary = await _vocabularyRepository.GetByIdAsync(vocabularyId);

            if (vocabulary == null ||
                vocabulary.IsDeleted ||
                vocabulary.UserId != userId)
            {
                throw new InvalidOperationException("Vocabulary not found or unauthorized.");
            }

            vocabulary.IsDeleted = true;

            _vocabularyRepository.Update(vocabulary);
            await _vocabularyRepository.SaveChangesAsync();

            return true;
        }

        public async Task<TranslateTextResponse> TranslateTextAsync(
            TranslateTextRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Text))
            {
                throw new ArgumentException("Text is required.");
            }

            var prompt = """
            You are a translation assistant for a language learning app.

            Return ONLY raw JSON.
            Do not use markdown.
            Do not wrap the response in ```json.

            JSON format:
            {
              "translation": "translated text"
            }

            Rules:
            - Translate naturally.
            - Keep only the translation in the translation field.
            - Do not add explanations.
            - If the input is a single word, return only the best common meaning.
            - If the input is an expression, translate the full expression naturally.
            """;

            var message = $"""
            Source language: {request.SourceLanguage}
            Target language: {request.TargetLanguage}
            Text: {request.Text}
            """;

            var aiResponse = await _phi3Client.ChatAsync(
                message: message,
                conversationId: null,
                systemPrompt: prompt,
                temperature: 0.1,
                maxTokens: 120);

            var translation = ParseTranslation(aiResponse.Response);

            return new TranslateTextResponse
            {
                Text = request.Text,
                Translation = translation,
                SourceLanguage = request.SourceLanguage,
                TargetLanguage = request.TargetLanguage
            };
        }

        private static string ParseTranslation(string aiResponse)
        {
            var cleanJson = ExtractJson(aiResponse);

            var parsed = JsonSerializer.Deserialize<TranslationAiResult>(
                cleanJson,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

            if (parsed == null || string.IsNullOrWhiteSpace(parsed.Translation))
            {
                throw new InvalidOperationException("Failed to parse translation response.");
            }

            return parsed.Translation.Trim();
        }

        private static string ExtractJson(string response)
        {
            if (string.IsNullOrWhiteSpace(response))
            {
                throw new InvalidOperationException("AI response was empty.");
            }

            var cleaned = response
                .Replace("```json", "", StringComparison.OrdinalIgnoreCase)
                .Replace("```", "")
                .Trim();

            var start = cleaned.IndexOf('{');
            var end = cleaned.LastIndexOf('}');

            if (start < 0 || end < 0 || end <= start)
            {
                throw new InvalidOperationException(
                    $"AI response did not contain valid JSON. Response: {response}");
            }

            return cleaned.Substring(start, end - start + 1);
        }

        private class TranslationAiResult
        {
            public string Translation { get; set; } = string.Empty;
        }
    }
}