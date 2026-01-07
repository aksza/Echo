# Phi3 Language Model Service

Nyelvtanuló AI szolgáltatás Microsoft Phi-3 használatával.

## Telepítés

```bash
# Virtuális környezet létrehozása (ajánlott)
python -m venv venv
.\venv\Scripts\activate  # Windows

# Függőségek telepítése
pip install -r requirements.txt

# Környezeti változók beállítása
copy .env.example .env
```

## Modellek

A service használja a **Microsoft Phi-3-mini-4k-instruct** modelt:
- Paraméterek: 3.8B
- Kontextus ablak: 4K token
- Optimalizálva beszélgetésre és instrukció követésre

Az első indításkor a modell automatikusan letöltődik (~7.5GB).

## Indítás

```bash
python start.py
```

⚠️ **Figyelem:** A modell betöltése 2-5 percet is igénybe vehet!

## API Endpoints

### POST /api/v1/llm/chat
Beszélgetés a nyelvi modellel

**Request:**
```json
{
  "message": "Hello, I want to practice English.",
  "conversation_id": "uuid-optional",
  "system_prompt": "You are a language tutor",
  "temperature": 0.7,
  "max_tokens": 512
}
```

**Response:**
```json
{
  "response": "Great! I'd be happy to help you practice English...",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "tokens_used": null
}
```

### POST /api/v1/llm/correct
Szöveg javítása nyelvtani hibákkal

**Request:**
```json
{
  "text": "I goed to the store yesterday",
  "target_language": "en",
  "provide_explanation": true
}
```

**Response:**
```json
{
  "original_text": "I goed to the store yesterday",
  "corrected_text": "I went to the store yesterday",
  "corrections": [
    {
      "correction": "goed → went: Past tense of 'go' is irregular"
    }
  ],
  "explanation": "The verb 'go' has an irregular past tense form..."
}
```

### DELETE /api/v1/llm/conversation/{conversation_id}
Beszélgetés törlése

**Response:**
```json
{
  "message": "Conversation cleared",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

### GET /api/v1/llm/health
Service állapot

**Response:**
```json
{
  "status": "healthy",
  "service": "phi3-service",
  "model_loaded": true,
  "model_name": "microsoft/Phi-3-mini-4k-instruct"
}
```

### GET /api/v1/llm/info
Részletes információ

**Response:**
```json
{
  "model_name": "microsoft/Phi-3-mini-4k-instruct",
  "device": "cpu",
  "max_history": 10,
  "active_conversations": 3,
  "status": "loaded"
}
```

## Használati példák

### Python
```python
import requests

# Beszélgetés indítása
response = requests.post(
    "http://localhost:8003/api/v1/llm/chat",
    json={
        "message": "Can you help me practice English?",
        "system_prompt": "You are a friendly English tutor."
    }
)

result = response.json()
print(result["response"])
conversation_id = result["conversation_id"]

# Folytatás ugyanabban a beszélgetésben
response = requests.post(
    "http://localhost:8003/api/v1/llm/chat",
    json={
        "message": "Tell me about past tense.",
        "conversation_id": conversation_id
    }
)
```

### cURL
```bash
# Szöveg javítása
curl -X POST "http://localhost:8003/api/v1/llm/correct" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "She dont like apples",
    "target_language": "en",
    "provide_explanation": true
  }'
```

## Dokumentáció

Swagger UI: http://localhost:8003/docs
ReDoc: http://localhost:8003/redoc
