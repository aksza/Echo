import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core import get_settings
from app.api import router
from app.services import WhisperService
import app.api.routes as routes_module

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    # Startup
    settings = get_settings()
    logger.info(f"Starting {settings.service_name}...")
    
    try:
        # Initialize Whisper service
        routes_module.whisper_service = WhisperService(
            model_name=settings.whisper_model,
            device=settings.device
        )
        logger.info("Whisper service initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Whisper service: {e}")
        raise
    
    yield
    
    # Shutdown
    logger.info("Shutting down Whisper service...")


# Create FastAPI application
settings = get_settings()
app = FastAPI(
    title="Whisper Speech-to-Text Service",
    description="Speech-to-Text microservice using Faster-Whisper",
    version="1.0.0",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(router, prefix="/api/v1/stt", tags=["Speech-to-Text"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": settings.service_name,
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.service_host,
        port=settings.service_port,
        reload=True
    )
