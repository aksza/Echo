# Piper TTS Service

Text-to-Speech mikroszerviz Piper használatával.

## Telepítés

```bash
# Virtuális környezet létrehozása
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Függőségek telepítése
pip install -r requirements.txt

# Környezeti változók beállítása
copy .env.example .env
```

## Hang modell letöltése

```bash
python download_voice.py
```

## Indítás

```bash
# Fejlesztői mód
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001

# Vagy
python -m app.main
```

## API Endpoints

### POST /api/v1/tts/synthesize
Szöveg átalakítása beszéddé (metaadatokkal)

**Request:**
```json
{
  "text": "Hello, this is a test.",
  "language": "en_US"
}
```

**Response:**
```json
{
  "message": "Synthesis successful",
  "audio_duration": 2.5,
  "sample_rate": 22050,
  "text_length": 23
}
```

### POST /api/v1/tts/synthesize/audio
Szöveg átalakítása beszéddé (audio stream)

**Request:**
```json
{
  "text": "Hello, this is a test."
}
```

**Response:** WAV audio fájl

### GET /api/v1/tts/health
Szolgáltatás állapot ellenőrzése

**Response:**
```json
{
  "status": "healthy",
  "service": "piper-service",
  "voice_model_loaded": true
}
```

## Tesztelés

```bash
# cURL példa
curl -X POST "http://localhost:8001/api/v1/tts/synthesize/audio" \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello world"}' \
  --output speech.wav

# Python példa
import requests

response = requests.post(
    "http://localhost:8001/api/v1/tts/synthesize/audio",
    json={"text": "Hello, how are you?"}
)

with open("output.wav", "wb") as f:
    f.write(response.content)
```

## Dokumentáció

Swagger UI: http://localhost:8001/docs
ReDoc: http://localhost:8001/redoc
