# AI Szolgáltatások Architektúra

## Áttekintés

A projekt három független mikroszolgáltatásból áll, amelyek FastAPI keretrendszerrel készültek:

1. **Whisper Service** (Port: 8002) - Speech-to-Text (Beszédfelismerés)
2. **Piper Service** (Port: 8001) - Text-to-Speech (Beszédszintézis)
3. **Phi3 Service** (Port: 8003) - Language Model (AI Nyelvtanár)

## Szolgáltatások közötti kapcsolat

### Jelenlegi állapot
Jelenleg a szolgáltatások **független mikroszolgáltatásokként** működnek:
- Mindegyik önálló FastAPI alkalmazás
- Saját portjukon futnak
- CORS middleware-rel rendelkeznek külső hívásokhoz
- Nincsenek közvetlen függőségek egymás között

### Tipikus használati folyamat (Echo alkalmazásban)

```
┌─────────────────────────────────────────────────────────────┐
│                    .NET Backend (Echo)                      │
│                    Központi koordinátor                      │
└─────────────────────────────────────────────────────────────┘
            │                  │                  │
            │                  │                  │
            ▼                  ▼                  ▼
    ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
    │   Whisper    │   │    Piper     │   │     Phi3     │
    │   Service    │   │   Service    │   │   Service    │
    │   (STT)      │   │    (TTS)     │   │     (LLM)    │
    │   :8002      │   │    :8001     │   │    :8003     │
    └──────────────┘   └──────────────┘   └──────────────┘
```

### Nyelvtanulási szcenárió példa:

1. **Felhasználó beszél** (audio fájl)
   - .NET Backend → Whisper Service
   - Eredmény: Átírt szöveg

2. **Szöveg elemzése/javítása**
   - .NET Backend → Phi3 Service (`/correct` endpoint)
   - Eredmény: Javított szöveg + magyarázatok

3. **AI válasz generálása**
   - .NET Backend → Phi3 Service (`/chat` endpoint)
   - Eredmény: AI válasz szöveg

4. **Válasz felolvasása**
   - .NET Backend → Piper Service
   - Eredmény: Audio válasz

## API Endpointok összefoglalása

### Whisper Service (STT)
```
Base URL: http://localhost:8002/api/v1/stt

POST /transcribe
  - Input: Audio fájl (multipart/form-data)
  - Output: { "text": "...", "language": "en", ... }

GET /health
  - Output: { "status": "healthy", "model_loaded": true }
```

### Piper Service (TTS)
```
Base URL: http://localhost:8001/api/v1/tts

POST /synthesize
  - Input: { "text": "Hello world", "language": "en_US" }
  - Output: { "message": "...", "audio_duration": 2.5, ... }

POST /synthesize/audio
  - Input: { "text": "Hello world" }
  - Output: WAV audio stream

GET /health
  - Output: { "status": "healthy", "voice_model_loaded": true }
```

### Phi3 Service (LLM)
```
Base URL: http://localhost:8003/api/v1/llm

POST /chat
  - Input: { "message": "...", "conversation_id": "...", ... }
  - Output: { "response": "...", "conversation_id": "..." }

POST /correct
  - Input: { "text": "I goed to store", "target_language": "en" }
  - Output: { "corrected_text": "...", "corrections": [...] }

DELETE /conversation/{conversation_id}
  - Output: { "message": "Conversation cleared" }

GET /health
  - Output: { "status": "healthy", "service": "phi3-service" }
```

## .NET Backend integráció

### 1. HttpClient konfiguráció

A .NET backend-ben hozz létre HttpClient-eket a szolgáltatásokhoz:

```csharp
// Program.cs vagy Startup.cs

// Whisper Service Client
builder.Services.AddHttpClient("WhisperService", client =>
{
    client.BaseAddress = new Uri("http://localhost:8002/api/v1/stt/");
    client.Timeout = TimeSpan.FromMinutes(5); // STT lassú lehet nagyobb fájloknál
});

// Piper Service Client
builder.Services.AddHttpClient("PiperService", client =>
{
    client.BaseAddress = new Uri("http://localhost:8001/api/v1/tts/");
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Phi3 Service Client
builder.Services.AddHttpClient("Phi3Service", client =>
{
    client.BaseAddress = new Uri("http://localhost:8003/api/v1/llm/");
    client.Timeout = TimeSpan.FromMinutes(2); // LLM generálás időigényes lehet
});
```

### 2. Service osztályok létrehozása

#### WhisperServiceClient.cs
```csharp
public interface IWhisperServiceClient
{
    Task<TranscriptionResponse> TranscribeAsync(Stream audioStream, string? language = null);
}

public class WhisperServiceClient : IWhisperServiceClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<WhisperServiceClient> _logger;

    public WhisperServiceClient(
        IHttpClientFactory httpClientFactory,
        ILogger<WhisperServiceClient> logger)
    {
        _httpClient = httpClientFactory.CreateClient("WhisperService");
        _logger = logger;
    }

    public async Task<TranscriptionResponse> TranscribeAsync(
        Stream audioStream, 
        string? language = null)
    {
        using var content = new MultipartFormDataContent();
        content.Add(new StreamContent(audioStream), "file", "audio.wav");
        
        if (!string.IsNullOrEmpty(language))
        {
            content.Add(new StringContent(language), "language");
        }

        var response = await _httpClient.PostAsync("transcribe", content);
        response.EnsureSuccessStatusCode();

        return await response.Content.ReadFromJsonAsync<TranscriptionResponse>()
            ?? throw new InvalidOperationException("Failed to deserialize response");
    }
}

public record TranscriptionResponse(
    string Text,
    string Language,
    double? Duration,
    List<TranscriptionSegment>? Segments
);

public record TranscriptionSegment(
    int Id,
    double Start,
    double End,
    string Text
);
```

#### PiperServiceClient.cs
```csharp
public interface IPiperServiceClient
{
    Task<byte[]> SynthesizeAudioAsync(string text, string language = "en_US");
    Task<SynthesisMetadata> SynthesizeAsync(string text, string language = "en_US");
}

public class PiperServiceClient : IPiperServiceClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<PiperServiceClient> _logger;

    public PiperServiceClient(
        IHttpClientFactory httpClientFactory,
        ILogger<PiperServiceClient> logger)
    {
        _httpClient = httpClientFactory.CreateClient("PiperService");
        _logger = logger;
    }

    public async Task<byte[]> SynthesizeAudioAsync(string text, string language = "en_US")
    {
        var request = new { text, language };
        var response = await _httpClient.PostAsJsonAsync("synthesize/audio", request);
        response.EnsureSuccessStatusCode();

        return await response.Content.ReadAsByteArrayAsync();
    }

    public async Task<SynthesisMetadata> SynthesizeAsync(string text, string language = "en_US")
    {
        var request = new { text, language };
        var response = await _httpClient.PostAsJsonAsync("synthesize", request);
        response.EnsureSuccessStatusCode();

        return await response.Content.ReadFromJsonAsync<SynthesisMetadata>()
            ?? throw new InvalidOperationException("Failed to deserialize response");
    }
}

public record SynthesisMetadata(
    string Message,
    double AudioDuration,
    int SampleRate,
    int TextLength
);
```

#### Phi3ServiceClient.cs
```csharp
public interface IPhi3ServiceClient
{
    Task<ChatResponse> ChatAsync(ChatRequest request);
    Task<CorrectionResponse> CorrectTextAsync(CorrectionRequest request);
    Task ClearConversationAsync(string conversationId);
}

public class Phi3ServiceClient : IPhi3ServiceClient
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<Phi3ServiceClient> _logger;

    public Phi3ServiceClient(
        IHttpClientFactory httpClientFactory,
        ILogger<Phi3ServiceClient> logger)
    {
        _httpClient = httpClientFactory.CreateClient("Phi3Service");
        _logger = logger;
    }

    public async Task<ChatResponse> ChatAsync(ChatRequest request)
    {
        var response = await _httpClient.PostAsJsonAsync("chat", request);
        response.EnsureSuccessStatusCode();

        return await response.Content.ReadFromJsonAsync<ChatResponse>()
            ?? throw new InvalidOperationException("Failed to deserialize response");
    }

    public async Task<CorrectionResponse> CorrectTextAsync(CorrectionRequest request)
    {
        var response = await _httpClient.PostAsJsonAsync("correct", request);
        response.EnsureSuccessStatusCode();

        return await response.Content.ReadFromJsonAsync<CorrectionResponse>()
            ?? throw new InvalidOperationException("Failed to deserialize response");
    }

    public async Task ClearConversationAsync(string conversationId)
    {
        var response = await _httpClient.DeleteAsync($"conversation/{conversationId}");
        response.EnsureSuccessStatusCode();
    }
}

// DTOs
public record ChatRequest(
    string Message,
    string? ConversationId = null,
    string? SystemPrompt = null,
    double? Temperature = null,
    int? MaxTokens = null
);

public record ChatResponse(
    string Response,
    string ConversationId,
    int? TokensUsed
);

public record CorrectionRequest(
    string Text,
    string TargetLanguage = "en",
    bool ProvideExplanation = true
);

public record CorrectionResponse(
    string OriginalText,
    string CorrectedText,
    List<CorrectionDetail> Corrections,
    string? Explanation
);

public record CorrectionDetail(string Correction);
```

### 3. Dependency Injection regisztráció

```csharp
// Program.cs

builder.Services.AddScoped<IWhisperServiceClient, WhisperServiceClient>();
builder.Services.AddScoped<IPiperServiceClient, PiperServiceClient>();
builder.Services.AddScoped<IPhi3ServiceClient, Phi3ServiceClient>();
```

### 4. Használat Controller-ben vagy Service-ben

```csharp
[ApiController]
[Route("api/[controller]")]
public class LanguagePracticeController : ControllerBase
{
    private readonly IWhisperServiceClient _whisperService;
    private readonly IPiperServiceClient _piperService;
    private readonly IPhi3ServiceClient _phi3Service;
    private readonly ILogger<LanguagePracticeController> _logger;

    public LanguagePracticeController(
        IWhisperServiceClient whisperService,
        IPiperServiceClient piperService,
        IPhi3ServiceClient phi3Service,
        ILogger<LanguagePracticeController> logger)
    {
        _whisperService = whisperService;
        _piperService = piperService;
        _phi3Service = phi3Service;
        _logger = logger;
    }

    [HttpPost("practice-speaking")]
    public async Task<IActionResult> PracticeSpeaking(
        IFormFile audioFile,
        [FromForm] string conversationId)
    {
        try
        {
            // 1. Transcribe audio
            using var audioStream = audioFile.OpenReadStream();
            var transcription = await _whisperService.TranscribeAsync(audioStream, "en");
            
            _logger.LogInformation("User said: {Text}", transcription.Text);

            // 2. Correct the text
            var correction = await _phi3Service.CorrectTextAsync(new CorrectionRequest(
                Text: transcription.Text,
                TargetLanguage: "en",
                ProvideExplanation: true
            ));

            // 3. Generate AI response
            var chatResponse = await _phi3Service.ChatAsync(new ChatRequest(
                Message: correction.CorrectedText,
                ConversationId: conversationId,
                SystemPrompt: "You are a friendly English language tutor. Keep responses concise and encouraging."
            ));

            // 4. Synthesize speech
            var responseAudio = await _piperService.SynthesizeAudioAsync(chatResponse.Response);

            return Ok(new
            {
                userTranscription = transcription.Text,
                corrections = correction.Corrections,
                aiResponse = chatResponse.Response,
                conversationId = chatResponse.ConversationId,
                responseAudioBase64 = Convert.ToBase64String(responseAudio)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in practice speaking");
            return StatusCode(500, "An error occurred during practice");
        }
    }

    [HttpPost("correct-text")]
    public async Task<IActionResult> CorrectText([FromBody] string text)
    {
        var correction = await _phi3Service.CorrectTextAsync(new CorrectionRequest(
            Text: text,
            TargetLanguage: "en"
        ));

        return Ok(correction);
    }

    [HttpPost("text-to-speech")]
    public async Task<IActionResult> TextToSpeech([FromBody] string text)
    {
        var audio = await _piperService.SynthesizeAudioAsync(text);
        return File(audio, "audio/wav", "speech.wav");
    }
}
```

## Konfigurálás appsettings.json-ban

```json
{
  "AiServices": {
    "WhisperService": {
      "BaseUrl": "http://localhost:8002/api/v1/stt/",
      "TimeoutSeconds": 300
    },
    "PiperService": {
      "BaseUrl": "http://localhost:8001/api/v1/tts/",
      "TimeoutSeconds": 30
    },
    "Phi3Service": {
      "BaseUrl": "http://localhost:8003/api/v1/llm/",
      "TimeoutSeconds": 120
    }
  }
}
```

## Deployment lehetőségek

### Docker Compose (Ajánlott)
Minden szolgáltatást konténerizálhatsz és együtt futtathatod:

```yaml
version: '3.8'
services:
  whisper-service:
    build: ./whisper-service
    ports:
      - "8002:8002"
    environment:
      - WHISPER_MODEL=base
      - DEVICE=cpu

  piper-service:
    build: ./piper-service
    ports:
      - "8001:8001"

  phi3-service:
    build: ./phi3-service
    ports:
      - "8003:8003"
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434

  echo-backend:
    build: ./echo-backend
    ports:
      - "5000:80"
    depends_on:
      - whisper-service
      - piper-service
      - phi3-service
```

### Külön szervereken
Production környezetben érdemes lehet külön szervereken futtatni őket terhelés alapján.

## Health Check implementáció

```csharp
public class AiServicesHealthCheck : IHealthCheck
{
    private readonly IHttpClientFactory _httpClientFactory;

    public AiServicesHealthCheck(IHttpClientFactory httpClientFactory)
    {
        _httpClientFactory = httpClientFactory;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var services = new[] { "WhisperService", "PiperService", "Phi3Service" };
        var healthStatuses = new Dictionary<string, bool>();

        foreach (var service in services)
        {
            try
            {
                var client = _httpClientFactory.CreateClient(service);
                var response = await client.GetAsync("health", cancellationToken);
                healthStatuses[service] = response.IsSuccessStatusCode;
            }
            catch
            {
                healthStatuses[service] = false;
            }
        }

        var allHealthy = healthStatuses.Values.All(x => x);
        
        return allHealthy
            ? HealthCheckResult.Healthy("All AI services are healthy", healthStatuses)
            : HealthCheckResult.Degraded("Some AI services are unhealthy", data: healthStatuses);
    }
}

// Regisztráció
builder.Services.AddHealthChecks()
    .AddCheck<AiServicesHealthCheck>("ai_services");
```

## Következő lépések

1. ✅ Mikroszolgáltatások létrehozása (Kész)
2. 🔲 .NET Backend client osztályok implementálása
3. 🔲 Docker konténerizálás
4. 🔲 CI/CD pipeline beállítása
5. 🔲 Monitoring és logging (Prometheus, Grafana)
6. 🔲 Rate limiting és caching
7. 🔲 Production deployment
