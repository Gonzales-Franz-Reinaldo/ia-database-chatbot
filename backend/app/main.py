from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import os
from dotenv import load_dotenv
from app.api.routes import router

# Cargar variables de entorno
load_dotenv()

# Crear aplicación FastAPI
app = FastAPI(
    title="AI Database Chatbot API",
    description="API para chatbot con IA que puede consultar bases de datos usando Ollama",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000"],  # Frontend React
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir rutas
app.include_router(router, prefix="/api/v1")

@app.get("/")
async def root():
    """Endpoint raíz"""
    return {
        "message": "AI Database Chatbot API",
        "version": "1.0.0",
        "status": "active",
        "endpoints": {
            "health": "/health",
            "models": "/api/v1/models",
            "test_connection": "/api/v1/test-connection",
            "analyze_schema": "/api/v1/analyze-schema",
            "chat": "/api/v1/chat"
        }
    }

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Manejador global de excepciones"""
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": f"Error interno del servidor: {str(exc)}",
            "detail": "Revisa los logs del servidor para más información"
        }
    )

if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "localhost")
    port = int(os.getenv("PORT", 8000))
    
    uvicorn.run(
        "app.main:app",
        host=host,
        port=port,
        reload=True,
        log_level="info"
    )