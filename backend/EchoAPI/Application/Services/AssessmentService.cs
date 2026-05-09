using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Enums;
using EchoAPI.Core.Interfaces.Services;

namespace EchoAPI.Application.Services
{
    public class AssessmentService
    {
        private readonly IPhi3ServiceClient _phi3Client;

        public AssessmentService(IPhi3ServiceClient phi3Client)
        {
            _phi3Client = phi3Client;
        }

        public async Task<AssessmentResponse> AssessTextAsync(string text)
        {
            var prompt = $"""
            You are a language proficiency evaluator.

            Evaluate the following English text and estimate the CEFR level.

            Return:
            - CEFR level
            - score from 0 to 100
            - confidence from 0 to 1
            - short feedback

            User text:
            {text}
            """;

            var aiResponse = await _phi3Client.ChatAsync(
                message: text,
                conversationId: null,
                systemPrompt: prompt,
                temperature: 2,
                maxTokens: 300
            );

            // egyelore mock parse
            // kesobb structured parsing

            return new AssessmentResponse
            {
                EstimatedLevel = LanguageLevel.B1,
                Score = 75,
                Confidence = 0.85f,
                Feedback = aiResponse.Response
            };
        }
    }
}
