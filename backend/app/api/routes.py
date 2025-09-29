from fastapi import APIRouter, HTTPException
from typing import List
from app.models.database import (
    DatabaseConnection, DatabaseSchema, ChatMessage, QueryResult, OllamaModel
)
from app.services.schema_analyzer import SchemaAnalyzer
from app.services.database_service import DatabaseService
from app.services.ollama_service import OllamaService
import os

router = APIRouter()
ollama_service = OllamaService(os.getenv("OLLAMA_BASE_URL", "http://localhost:11434"))

@router.get("/models", response_model=List[OllamaModel])
async def get_ollama_models():
    """Obtener modelos disponibles de Ollama"""
    models = await ollama_service.get_available_models()
    return models

@router.post("/test-connection")
async def test_database_connection(db_connection: DatabaseConnection):
    """Probar conexión a la base de datos"""
    try:
        analyzer = SchemaAnalyzer(db_connection)
        is_connected = analyzer.test_connection()
        
        if is_connected:
            return {
                "success": True,
                "message": "Conexión exitosa a la base de datos"
            }
        else:
            return {
                "success": False,
                "message": "No se pudo conectar a la base de datos"
            }
    except Exception as e:
        return {
            "success": False,
            "message": f"Error de conexión: {str(e)}"
        }

@router.post("/analyze-schema", response_model=DatabaseSchema)
async def analyze_database_schema(db_connection: DatabaseConnection):
    """Analizar esquema de la base de datos"""
    try:
        analyzer = SchemaAnalyzer(db_connection)
        schema = analyzer.analyze_schema()
        return schema
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al analizar esquema: {str(e)}")

@router.post("/sample-data")
async def get_sample_data(db_connection: DatabaseConnection, table_name: str, limit: int = 5):
    """Obtener datos de muestra de una tabla"""
    try:
        db_service = DatabaseService(db_connection)
        result = db_service.get_sample_data(table_name, limit)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener datos de muestra: {str(e)}")

@router.post("/chat", response_model=QueryResult)
async def process_chat_message(chat_request: ChatMessage):
    """Procesar mensaje de chat y ejecutar consulta SQL"""
    try:
        # 1. Analizar esquema de la base de datos
        analyzer = SchemaAnalyzer(chat_request.database_connection)
        schema = analyzer.analyze_schema()
        
        # 2. Generar consulta SQL usando Ollama
        ollama_result = await ollama_service.generate_sql_query(
            chat_request.message,
            chat_request.model,
            schema
        )
        
        if not ollama_result["success"]:
            return QueryResult(
                success=False,
                error=ollama_result.get("error", "Error al generar consulta SQL")
            )
        
        sql_query = ollama_result.get("sql_query")
        explanation = ollama_result.get("explanation")
        
        if not sql_query:
            return QueryResult(
                success=False,
                error="No se pudo extraer una consulta SQL válida de la respuesta de la IA"
            )
        
        # 3. Ejecutar consulta SQL
        db_service = DatabaseService(chat_request.database_connection)
        query_result = db_service.execute_query(sql_query)
        
        if not query_result["success"]:
            return QueryResult(
                success=False,
                sql_query=sql_query,
                error=query_result.get("error", "Error al ejecutar consulta SQL"),
                explanation=explanation
            )
        
        # 4. Devolver resultado completo
        return QueryResult(
            success=True,
            data=query_result["data"],
            sql_query=sql_query,
            explanation=explanation
        )
    
    except Exception as e:
        return QueryResult(
            success=False,
            error=f"Error interno del servidor: {str(e)}"
        )

@router.post("/execute-sql")
async def execute_sql_query(db_connection: DatabaseConnection, sql_query: str):
    """Ejecutar consulta SQL directamente"""
    try:
        db_service = DatabaseService(db_connection)
        result = db_service.execute_query(sql_query)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al ejecutar consulta: {str(e)}")

@router.get("/health")
async def health_check():
    """Verificar estado del servidor"""
    return {
        "status": "healthy",
        "message": "AI Database Chatbot API está funcionando correctamente"
    }