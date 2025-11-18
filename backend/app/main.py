from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from .database import init_db
from .api.routes import router
from .services.ai_agent import ai_agent


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan event handler for startup and shutdown"""
    # Startup
    print("Initializing database...")
    init_db()
    print("Database initialized.")
    
    print("Initializing AI agent...")
    if ai_agent.initialize():
        print("AI agent initialized successfully.")
    else:
        print("AI agent initialization failed. Chat functionality will be limited.")
    
    yield
    
    # Shutdown
    print("Shutting down...")


app = FastAPI(
    title="Enterprise CRM API",
    description="Enterprise CRM with AI-powered chat using local LLM",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routes
app.include_router(router, prefix="/api/v1", tags=["CRM"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Enterprise CRM API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}
