using EchoAPI.Core.Interfaces.Services;

namespace EchoAPI.Application.Services
{
    /// <summary>
    /// Orchestrates the full voice conversation flow: STT → LLM → TTS
    /// </summary>
    public class ConversationOrchestrator
    {
        private readonly IWhisperServiceClient _whisperClient;
        private readonly IPhi3ServiceClient _phi3Client;
        private readonly IPiperServiceClient _piperClient;
        private readonly IAudioStorageService _audioStorage;
        private readonly ILogger<ConversationOrchestrator> _logger;

        public ConversationOrchestrator(
            IWhisperServiceClient whisperClient,
            IPhi3ServiceClient phi3Client,
            IPiperServiceClient piperClient,
            IAudioStorageService audioStorage,
            ILogger<ConversationOrchestrator> logger)
        {
            _whisperClient = whisperClient;
            _phi3Client = phi3Client;
            _piperClient = piperClient;
            _audioStorage = audioStorage;
            _logger = logger;
        }

        /// <summary>
        /// Process a voice message: transcribe, chat, and synthesize response
        /// </summary>
        /// <param name="audioStream">Input audio stream</param>
        /// <param name="fileName">Audio filename</param>
        /// <param name="conversationId">Optional conversation ID for context</param>
        /// <param name="language">Optional language code</param>
        /// <param name="systemPrompt">Optional system prompt</param>
        /// <returns>Voice conversation result with transcription, AI response, and audio</returns>
        public async Task<VoiceConversationResult> ProcessVoiceMessageAsync(
            Stream audioStream,
            string fileName,
            string? conversationId = null,
            string? language = null,
            string? systemPrompt = null)
        {
            _logger.LogInformation(
                "Processing voice message. ConversationId: {ConversationId}, Language: {Language}",
                conversationId ?? "new",
                language ?? "auto");

            try
            {
                // 1. Speech to Text - Transcribe audio
                _logger.LogInformation("Step 1/3: Transcribing audio...");
                var transcription = await _whisperClient.TranscribeAsync(
                    audioStream,
                    fileName,
                    language);

                _logger.LogInformation(
                    "Transcription complete. Text: '{Text}', Language: {Lang}",
                    transcription.Text,
                    transcription.Language);

                // 2. Language Model - Generate AI response
                _logger.LogInformation("Step 2/3: Generating AI response...");
                var chatResponse = await _phi3Client.ChatAsync(
                    message: transcription.Text,
                    conversationId: conversationId,
                    systemPrompt: systemPrompt);

                _logger.LogInformation(
                    "AI response generated. ConversationId: {ConversationId}",
                    chatResponse.ConversationId);

                // 3. Text to Speech - Synthesize AI response
                _logger.LogInformation("Step 3/3: Synthesizing audio response...");
                var audioResponseStream = await _piperClient.SynthesizeToStreamAsync(
                    chatResponse.Response,
                    language);

                // Save response audio to storage
                var audioFileName = $"response_{DateTime.UtcNow:yyyyMMddHHmmss}.wav";
                var savedAudioPath = await _audioStorage.SaveAudioAsync(
                    audioResponseStream,
                    audioFileName);

                _logger.LogInformation("Voice processing complete. Audio saved: {Path}", savedAudioPath);

                return new VoiceConversationResult
                {
                    UserTranscription = transcription.Text,
                    DetectedLanguage = transcription.Language,
                    AiResponse = chatResponse.Response,
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

        /// <summary>
        /// Process voice message with text correction
        /// </summary>
        /// <param name="audioStream">Input audio stream</param>
        /// <param name="fileName">Audio filename</param>
        /// <param name="targetLanguage">Target language for correction</param>
        /// <param name="provideExplanation">Whether to provide explanation</param>
        /// <returns>Voice correction result with corrections and audio</returns>
        public async Task<VoiceCorrectionResult> ProcessVoiceForCorrectionAsync(
            Stream audioStream,
            string fileName,
            string targetLanguage = "en",
            bool provideExplanation = true)
        {
            _logger.LogInformation("Processing voice for correction. Target language: {Language}", targetLanguage);

            try
            {
                // 1. Transcribe audio
                _logger.LogInformation("Step 1/3: Transcribing audio...");
                var transcription = await _whisperClient.TranscribeAsync(
                    audioStream,
                    fileName,
                    targetLanguage);

                _logger.LogInformation("Transcription: '{Text}'", transcription.Text);

                // 2. Get corrections from AI
                _logger.LogInformation("Step 2/3: Getting corrections...");
                var correction = await _phi3Client.CorrectTextAsync(
                    transcription.Text,
                    targetLanguage,
                    provideExplanation);

                _logger.LogInformation(
                    "Corrections found: {Count}",
                    correction.Corrections.Count);

                // 3. Synthesize corrected text
                _logger.LogInformation("Step 3/3: Synthesizing corrected audio...");
                var audioStream2 = await _piperClient.SynthesizeToStreamAsync(
                    correction.CorrectedText,
                    targetLanguage);

                var audioFileName = $"corrected_{DateTime.UtcNow:yyyyMMddHHmmss}.wav";
                var savedAudioPath = await _audioStorage.SaveAudioAsync(
                    audioStream2,
                    audioFileName);

                _logger.LogInformation("Voice correction complete");

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
    }

    /// <summary>
    /// Result of voice conversation processing
    /// </summary>
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

    /// <summary>
    /// Result of voice correction processing
    /// </summary>
    public class VoiceCorrectionResult
    {
        public string OriginalText { get; set; } = string.Empty;
        public string CorrectedText { get; set; } = string.Empty;
        public List<Infrastructure.Services.AiServices.Models.CorrectionDetail> Corrections { get; set; } = new();
        public string? Explanation { get; set; }
        public string CorrectedAudioPath { get; set; } = string.Empty;
    }
}
