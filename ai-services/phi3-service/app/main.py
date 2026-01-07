import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core import get_settings
from app.api import router
from app.services import Phi3Service
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
        # Initialize Phi3 service with Ollama
        routes_module.phi3_service = Phi3Service(
            ollama_base_url=settings.ollama_base_url,
            model_name=settings.model_name,
            max_history=settings.max_conversation_history
        )
        logger.info("Phi3 service initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Phi3 service: {e}")
        raise
    
    yield
    
    # Shutdown
    logger.info("Shutting down Phi3 service...")


# Create FastAPI application
settings = get_settings()
app = FastAPI(
    title="Phi3 Language Model Service",
    description="Language learning AI service using Phi-3 via Ollama",
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
app.include_router(router, prefix="/api/v1/llm", tags=["Language Model"])


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
