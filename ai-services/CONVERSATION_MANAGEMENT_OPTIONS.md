# Beszélgetés Kezelési Lehetőségek

## Jelenlegi Megoldás Problémái

### ❌ A mostani implementáció:
```python
# phi3_service.py
self.conversations: Dict[str, List[Dict[str, str]]] = {}  # Csak memória!
```

**Problémák:**
1. ❌ **Nincs perzisztencia** - Service újraindításkor minden beszélgetés elveszik
2. ❌ **Nincs audit trail** - Nem látjuk a történeti adatokat
3. ❌ **Nincs hibakezelés logging** - Hibák nem kerülnek mentésre
4. ❌ **Skálázhatóság** - Több instance nem oszthatja meg a beszélgetéseket
5. ❌ **Nincs analitika** - Nem tudjuk elemezni a felhasználói interakciókat

## Alternatív Megoldások

### 1️⃣ **Adatbázis + Conversation Service (AJÁNLOTT)**

Külön mikroszolgáltatás a beszélgetések kezelésére.

```
┌─────────────────────────────────────────────────────────┐
│              .NET Backend (Echo)                        │
└─────────────────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
   ┌────────┐   ┌────────┐   ┌────────────────┐
   │Whisper │   │ Piper  │   │ Conversation   │◄──┐
   │Service │   │Service │   │    Service     │   │
   └────────┘   └────────┘   └────────────────┘   │
                                    │              │
                                    ▼              │
                              ┌────────────┐       │
                              │ PostgreSQL │       │
                              │   / Redis  │       │
                              └────────────┘       │
                                                   │
                                    ▼              │
                              ┌────────────┐       │
                              │    Phi3    │───────┘
                              │  Service   │
                              └────────────┘
```

#### Conversation Service API

```python
# conversation-service/app/api/routes.py

@router.post("/conversations")
async def create_conversation(request: CreateConversationRequest):
    """Új beszélgetés létrehozása"""
    return {
        "conversation_id": "uuid",
        "user_id": "user_id",
        "created_at": "timestamp"
    }

@router.post("/conversations/{conversation_id}/messages")
async def add_message(conversation_id: str, message: MessageRequest):
    """Üzenet hozzáadása beszélgetéshez"""
    return {
        "message_id": "uuid",
        "role": "user|assistant|system",
        "content": "text",
        "timestamp": "timestamp",
        "metadata": {
            "corrections": [],
            "audio_url": "optional"
        }
    }

@router.get("/conversations/{conversation_id}")
async def get_conversation(conversation_id: str):
    """Teljes beszélgetés lekérése"""
    return {
        "conversation_id": "uuid",
        "messages": [...],
        "created_at": "timestamp",
        "updated_at": "timestamp"
    }

@router.get("/conversations/{conversation_id}/summary")
async def get_summary(conversation_id: str):
    """Beszélgetés összefoglalója (LLM generált)"""
    return {
        "summary": "AI generated summary",
        "key_topics": ["topic1", "topic2"],
        "mistakes_count": 5,
        "improvement_areas": ["grammar", "vocabulary"]
    }

@router.post("/conversations/{conversation_id}/export")
async def export_conversation(conversation_id: str, format: str):
    """Export PDF/JSON/TXT formátumban"""
    return {"download_url": "url"}
```

#### Adatbázis Séma

```sql
-- PostgreSQL Schema

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    target_language VARCHAR(10) NOT NULL,
    level VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL, -- 'user', 'assistant', 'system'
    content TEXT NOT NULL,
    original_text TEXT, -- Ha volt javítás
    corrections JSONB,
    audio_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE TABLE errors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id),
    message_id UUID REFERENCES messages(id),
    error_type VARCHAR(50) NOT NULL, -- 'grammar', 'pronunciation', etc.
    original TEXT NOT NULL,
    corrected TEXT NOT NULL,
    explanation TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    language VARCHAR(10) NOT NULL,
    total_conversations INT DEFAULT 0,
    total_messages INT DEFAULT 0,
    total_corrections INT DEFAULT 0,
    common_mistakes JSONB,
    last_practiced TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexek
CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_errors_conversation_id ON errors(conversation_id);
CREATE INDEX idx_user_progress_user_language ON user_progress(user_id, language);
```

### 2️⃣ **Redis Cache + Event Sourcing**

Gyors hozzáférés + teljes történeti nyomon követés.

```python
# Gyors cache Redisben
redis_client.setex(
    f"conversation:{conversation_id}",
    3600,  # 1 óra TTL
    json.dumps(messages)
)

# Események mentése adatbázisba
event = {
    "type": "message_added",
    "conversation_id": "uuid",
    "timestamp": "iso8601",
    "data": {...}
}
```

**Előnyök:**
- Gyors olvasás (Redis)
- Teljes audit trail (Events)
- Replay lehetőség
- Analitika

### 3️⃣ **WebSocket + Real-time Streaming**

Folyamatos kommunikáció böngésző és backend között.

#### SignalR (.NET) implementáció

```csharp
// ConversationHub.cs
public class ConversationHub : Hub
{
    private readonly IPhi3ServiceClient _phi3Service;
    private readonly IConversationRepository _conversationRepo;

    public async Task SendMessage(string conversationId, string message)
    {
        // 1. Mentés azonnal
        await _conversationRepo.AddMessageAsync(conversationId, "user", message);
        
        // 2. Stream AI válasz
        await foreach (var chunk in _phi3Service.ChatStreamAsync(message))
        {
            // Real-time stream a kliensnek
            await Clients.Caller.SendAsync("ReceiveMessageChunk", chunk);
        }
        
        // 3. Teljes válasz mentése
        await _conversationRepo.AddMessageAsync(conversationId, "assistant", fullResponse);
    }

    public async Task<ConversationDto> GetConversation(string conversationId)
    {
        return await _conversationRepo.GetAsync(conversationId);
    }
}
```

#### Client oldal (JavaScript)

```javascript
const connection = new signalR.HubConnectionBuilder()
    .withUrl("/conversationHub")
    .build();

connection.on("ReceiveMessageChunk", (chunk) => {
    // Real-time megjelenítés
    appendToChat(chunk);
});

await connection.invoke("SendMessage", conversationId, userMessage);
```

**Előnyök:**
- Real-time élmény
- Streaming válaszok (mint ChatGPT)
- Kétirányú kommunikáció
- Automatikus újracsatlakozás

### 4️⃣ **Phi3 Service Streaming támogatás**

Módosítsuk a Phi3 Service-t, hogy támogassa a streaming-et:

```python
# phi3_service.py

async def chat_stream(
    self,
    message: str,
    conversation_id: Optional[str] = None,
    **kwargs
) -> AsyncIterator[str]:
    """Stream chat response token by token"""
    
    messages = self._get_or_create_conversation(conversation_id)
    messages.append({"role": "user", "content": message})
    
    async with httpx.AsyncClient(timeout=120.0) as client:
        async with client.stream(
            "POST",
            f"{self.ollama_base_url}/api/chat",
            json={
                "model": self.model_name,
                "messages": messages,
                "stream": True  # ← Streaming engedélyezése
            }
        ) as response:
            full_response = ""
            
            async for line in response.aiter_lines():
                if line:
                    data = json.loads(line)
                    if chunk := data.get("message", {}).get("content", ""):
                        full_response += chunk
                        yield chunk  # ← Token-by-token streaming
            
            # Teljes válasz mentése
            messages.append({"role": "assistant", "content": full_response})
```

#### FastAPI endpoint streaming-gel

```python
from fastapi.responses import StreamingResponse

@router.post("/chat/stream")
async def chat_stream(
    request: ChatRequest,
    service: Phi3Service = Depends(get_phi3_service)
):
    """Stream chat response"""
    
    async def generate():
        async for chunk in service.chat_stream(
            message=request.message,
            conversation_id=request.conversation_id
        ):
            yield f"data: {json.dumps({'chunk': chunk})}\n\n"
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream"
    )
```

### 5️⃣ **Audit & Error Logging Service**

Külön szolgáltatás a hibák és események nyomon követésére.

```python
# audit-service/app/api/routes.py

@router.post("/events")
async def log_event(event: EventRequest):
    """Log application event"""
    await db.events.insert_one({
        "type": event.type,
        "service": event.service,
        "conversation_id": event.conversation_id,
        "user_id": event.user_id,
        "data": event.data,
        "timestamp": datetime.utcnow(),
        "severity": event.severity
    })

@router.post("/errors")
async def log_error(error: ErrorRequest):
    """Log error with stack trace"""
    await db.errors.insert_one({
        "conversation_id": error.conversation_id,
        "service": error.service,
        "error_type": error.error_type,
        "message": error.message,
        "stack_trace": error.stack_trace,
        "timestamp": datetime.utcnow(),
        "resolved": False
    })

@router.get("/analytics/errors")
async def error_analytics(
    start_date: datetime,
    end_date: datetime,
    group_by: str = "service"
):
    """Error analytics"""
    # Aggregáció...
```

## Javasolt Architektúra (Best Practice)

```
┌──────────────────────────────────────────────────────────────┐
│                    Echo .NET Backend                         │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ SignalR Hub │  │  Controllers │  │  Background Jobs │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
└──────────────────────────────────────────────────────────────┘
         │                  │                    │
    ┌────┼──────────────────┼────────────────────┼─────┐
    │    │                  │                    │     │
    │    ▼                  ▼                    ▼     │
    │  ┌──────────────────────────────────────────┐   │
    │  │      Conversation Management Service     │   │
    │  │  - Perzisztens tárolás                   │   │
    │  │  - Conversation CRUD                     │   │
    │  │  - Export funkcionalitás                 │   │
    │  └──────────────────────────────────────────┘   │
    │                     │                            │
    │                     ▼                            │
    │              ┌─────────────┐                     │
    │              │ PostgreSQL  │                     │
    │              │   Database  │                     │
    │              └─────────────┘                     │
    │                                                  │
    ▼                                                  ▼
┌─────────┐  ┌─────────┐  ┌─────────┐    ┌────────────────┐
│ Whisper │  │  Piper  │  │  Phi3   │    │ Audit Service  │
│ Service │  │ Service │  │ Service │    │ (Logging/      │
│  (STT)  │  │  (TTS)  │  │  (LLM)  │    │  Analytics)    │
└─────────┘  └─────────┘  └─────────┘    └────────────────┘
                                                  │
                                                  ▼
                                          ┌───────────────┐
                                          │  MongoDB /    │
                                          │  Elasticsearch│
                                          └───────────────┘
```

## Implementációs Prioritások

### Fázis 1: Alapok (Most)
- ✅ Mikroszolgáltatások működnek
- 🔲 **Conversation Service létrehozása**
- 🔲 **PostgreSQL integráció**
- 🔲 **.NET Repository pattern**

### Fázis 2: Real-time (Következő)
- 🔲 **SignalR Hub implementáció**
- 🔲 **Streaming support Phi3-ban**
- 🔲 **WebSocket frontend**

### Fázis 3: Monitoring & Analytics
- 🔲 **Audit Service**
- 🔲 **Error tracking**
- 🔲 **User analytics dashboard**
- 🔲 **Prometheus + Grafana**

### Fázis 4: Scale & Performance
- 🔲 **Redis caching**
- 🔲 **Load balancing**
- 🔲 **Horizontal scaling**
- 🔲 **CDN audio fájlokhoz**

## Conversation Service Példa Implementáció

### Directory struktura

```
conversation-service/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── api/
│   │   ├── __init__.py
│   │   └── routes.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── conversation.py
│   │   └── message.py
│   ├── repositories/
│   │   ├── __init__.py
│   │   └── conversation_repo.py
│   ├── services/
│   │   ├── __init__.py
│   │   └── conversation_service.py
│   └── db/
│       ├── __init__.py
│       └── database.py
├── alembic/
│   └── versions/
├── requirements.txt
└── README.md
```

### models/conversation.py

```python
from sqlalchemy import Column, String, DateTime, JSON, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from app.db.database import Base

class Conversation(Base):
    __tablename__ = "conversations"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    target_language = Column(String(10), nullable=False)
    level = Column(String(20))
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    metadata = Column(JSON)
    
    messages = relationship("Message", back_populates="conversation", cascade="all, delete-orphan")
    errors = relationship("ConversationError", back_populates="conversation", cascade="all, delete-orphan")

class Message(Base):
    __tablename__ = "messages"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    conversation_id = Column(UUID(as_uuid=True), ForeignKey("conversations.id"))
    role = Column(String(20), nullable=False)  # user, assistant, system
    content = Column(String, nullable=False)
    original_text = Column(String)
    corrections = Column(JSON)
    audio_url = Column(String(500))
    created_at = Column(DateTime, default=datetime.utcnow)
    metadata = Column(JSON)
    
    conversation = relationship("Conversation", back_populates="messages")

class ConversationError(Base):
    __tablename__ = "errors"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    conversation_id = Column(UUID(as_uuid=True), ForeignKey("conversations.id"))
    message_id = Column(UUID(as_uuid=True), ForeignKey("messages.id"), nullable=True)
    error_type = Column(String(50), nullable=False)
    original = Column(String, nullable=False)
    corrected = Column(String, nullable=False)
    explanation = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    conversation = relationship("Conversation", back_populates="errors")
```

### .NET Integration

```csharp
// Services/ConversationServiceClient.cs

public interface IConversationServiceClient
{
    Task<Guid> CreateConversationAsync(Guid userId, string targetLanguage);
    Task AddMessageAsync(Guid conversationId, string role, string content, 
        string? originalText = null, List<CorrectionDetail>? corrections = null);
    Task<ConversationDto> GetConversationAsync(Guid conversationId);
    Task<List<ConversationDto>> GetUserConversationsAsync(Guid userId);
    Task<ConversationSummary> GetSummaryAsync(Guid conversationId);
    Task<byte[]> ExportConversationAsync(Guid conversationId, string format = "pdf");
}

public class ConversationServiceClient : IConversationServiceClient
{
    private readonly HttpClient _httpClient;

    public ConversationServiceClient(IHttpClientFactory httpClientFactory)
    {
        _httpClient = httpClientFactory.CreateClient("ConversationService");
    }

    public async Task<Guid> CreateConversationAsync(Guid userId, string targetLanguage)
    {
        var response = await _httpClient.PostAsJsonAsync("conversations", new
        {
            user_id = userId,
            target_language = targetLanguage
        });
        response.EnsureSuccessStatusCode();
        
        var result = await response.Content.ReadFromJsonAsync<CreateConversationResponse>();
        return result!.ConversationId;
    }

    public async Task AddMessageAsync(
        Guid conversationId, 
        string role, 
        string content,
        string? originalText = null,
        List<CorrectionDetail>? corrections = null)
    {
        await _httpClient.PostAsJsonAsync($"conversations/{conversationId}/messages", new
        {
            role,
            content,
            original_text = originalText,
            corrections
        });
    }

    // ... többi metódus
}
```

## Összefoglalás

### ✅ Előnyök a jelenlegi megoldáshoz képest:

1. **Perzisztencia** - Beszélgetések megmaradnak
2. **Audit Trail** - Teljes történet nyomon követhető
3. **Analitika** - Használati statisztikák
4. **Skálázhatóság** - Több instance megoszthatja az adatokat
5. **Export** - Beszélgetések exportálhatók
6. **Real-time** - SignalR/WebSocket support
7. **Streaming** - ChatGPT-szerű élmény
8. **Error Tracking** - Hibák rendszerezett tárolása

### 🎯 Ajánlás:

**Kezdd a Conversation Service-szel** - Ez ad alapot mindenhez, és később bővíthető streaming-gel, analytics-szel stb.
