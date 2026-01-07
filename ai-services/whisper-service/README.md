# Whisper Speech-to-Text Service

Speech-to-Text mikroszerviz Faster-Whisper használatával (gyorsabb mint az eredeti Whisper).

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

## Whisper modellek

A Whisper különböző méretű modelleket kínál:

| Model  | Paraméterek | Sebesség | Pontosság | Memória |
|--------|-------------|----------|-----------|---------|
| tiny   | 39M         | ~32x     | ⭐⭐      | ~1GB    |
| base   | 74M         | ~16x     | ⭐⭐⭐    | ~1GB    |
| small  | 244M        | ~6x      | ⭐⭐⭐⭐  | ~2GB    |
| medium | 769M        | ~2x      | ⭐⭐⭐⭐⭐| ~5GB    |
| large  | 1550M       | 1x       | ⭐⭐⭐⭐⭐| ~10GB   |

Az első használatkor a modell automatikusan letöltődik.

## Indítás

```bash
# Fejlesztői mód
python start.py
```

## API Endpoints

### POST /api/v1/stt/transcribe
Audio fájl átírása szöveggé

**Form Data:**
- `file`: Audio fájl (required)
- `language`: Nyelv kód (optional, pl. "en", "hu")
- `task`: "transcribe" vagy "translate" (optional, default: "transcribe")
- `return_segments`: Részletes szegmensek visszaadása (optional, default: false)

**Response:**
```json
{
  "text": "This is the transcribed text.",
  "language": "en",
  "duration": null,
  "segments": null
}
```

**Példa szegmensekkel:**
```json
{
  "text": "Hello world. How are you?",
  "language": "en",
  "duration": null,
  "segments": [
    {
      "id": 0,
      "start": 0.0,
      "end": 2.5,
      "text": "Hello world."
    },
    {
      "id": 1,
      "start": 2.5,
      "end": 4.0,
      "text": "How are you?"
    }
  ]
}
```

### GET /api/v1/stt/health
Szolgáltatás állapot ellenőrzése

**Response:**
```json
{
  "status": "healthy",
  "service": "whisper-service",
  "model_loaded": true,
  "model_name": "base"
}
```

### GET /api/v1/stt/models
Elérhető modellek listája

**Response:**
```json
{
  "available_models": ["tiny", "base", "small", "medium", "large"],
  "current_model": "base",
  "device": "cpu"
}
```

## Tesztelés

```bash
# PowerShell példa
$audioFile = "test.mp3"
curl -X POST "http://localhost:8002/api/v1/stt/transcribe" `
  -F "file=@$audioFile" `
  -F "language=en" `
  -F "return_segments=true"

# Python példa
import requests

with open("audio.wav", "rb") as f:
    files = {"file": f}
    data = {
        "language": "en",
        "return_segments": True
    }
    response = requests.post(
        "http://localhost:8002/api/v1/stt/transcribe",
        files=files,
        data=data
    )
    print(response.json())
```

## Támogatott audio formátumok

- WAV
- MP3
- M4A
- OGG
- FLAC
- WebM
- És még sok más (amit ffmpeg támogat)

## Dokumentáció

Swagger UI: http://localhost:8002/docs
ReDoc: http://localhost:8002/redoc
