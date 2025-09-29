from fastapi import APIRouter, HTTPException
from typing import List
from app.models.database import (
    DatabaseConnection, DatabaseSchema, ChatMessage, QueryResult, OllamaModel
)
from app.services.schema_analyzer import SchemaAnalyzer
from app.services.database_service import DatabaseService
from app.services.ollama_service import OllamaService
import os
import httpx

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

@router.post("/analyze-schema")
async def analyze_database_schema(db_connection: DatabaseConnection):
    """Analizar esquema de la base de datos"""
    try:
        # Primero verificar que la conexión funcione
        analyzer = SchemaAnalyzer(db_connection)
        if not analyzer.test_connection():
            return {
                "success": False,
                "message": "No se pudo conectar a la base de datos. Verifica las credenciales.",
                "error": "connection_failed"
            }
        
        # Si la conexión funciona, analizar el esquema
        schema = analyzer.analyze_schema()
        return {
            "success": True,
            "schema": schema,
            "message": "Esquema analizado correctamente"
        }
    except Exception as e:
        # Manejar errores específicos de base de datos vs errores del servidor
        error_msg = str(e).lower()
        if any(keyword in error_msg for keyword in ['authentication', 'password', 'connection', 'refused', 'timeout']):
            return {
                "success": False,
                "message": f"Error de conexión: {str(e)}",
                "error": "database_connection_error"
            }
        else:
            return {
                "success": False,
                "message": f"Error al analizar esquema: {str(e)}",
                "error": "schema_analysis_error"
            }

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
    """Procesar mensaje de chat y ejecutar consulta SQL con contexto mejorado"""
    try:
        # 1. Analizar esquema de la base de datos
        analyzer = SchemaAnalyzer(chat_request.database_connection)
        schema = analyzer.analyze_schema()
        
        # 2. Obtener datos de muestra para contexto RAG mejorado
        db_service = DatabaseService(chat_request.database_connection)
        sample_data = {}
        
        # Obtener hasta 3 filas de muestra de cada tabla (para contexto)
        for table in schema.tables:
            try:
                result = db_service.get_sample_data(table.table_name, limit=3)
                if result["success"] and result["data"]:
                    sample_data[table.table_name] = result["data"]
            except Exception:
                continue  # Si falla una tabla, continuar con las demás
        
        # 3. Generar consulta SQL usando Ollama con contexto enriquecido
        ollama_result = await ollama_service.generate_sql_query(
            chat_request.message,
            chat_request.model,
            schema,
            sample_data
        )
        
        if not ollama_result["success"]:
            return QueryResult(
                success=False,
                error=ollama_result.get("error", "Error al generar consulta SQL"),
                sql_query=ollama_result.get("sql_query"),
                explanation=ollama_result.get("explanation")
            )
        
        sql_query = ollama_result.get("sql_query")
        explanation = ollama_result.get("explanation")
        
        if not sql_query:
            return QueryResult(
                success=False,
                error="No se pudo extraer una consulta SQL válida de la respuesta de la IA",
                explanation=explanation
            )
        
        # 4. Ejecutar consulta SQL
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

@router.post("/learn-database")
async def learn_database(db_connection: DatabaseConnection, selected_model: str):
    """Hacer que el modelo de IA aprenda la base de datos completamente"""
    try:
        # 1. Analizar esquema completo
        analyzer = SchemaAnalyzer(db_connection)
        if not analyzer.test_connection():
            return {
                "success": False,
                "message": "No se pudo conectar a la base de datos"
            }
        
        schema = analyzer.analyze_schema()
        
        # 2. Obtener muestras de datos de todas las tablas
        db_service = DatabaseService(db_connection)
        learning_data = {}
        
        for table in schema.tables:
            try:
                # Obtener más muestras para el aprendizaje completo
                result = db_service.get_sample_data(table.table_name, limit=10)
                if result["success"] and result["data"]:
                    learning_data[table.table_name] = result["data"]
            except Exception as e:
                learning_data[table.table_name] = []
        
        # 3. Crear prompt de aprendizaje para el modelo
        learning_prompt = f"""# 🎓 APRENDIZAJE COMPLETO DE BASE DE DATOS
        
Analiza completamente esta base de datos y aprende todos sus patrones, estructuras y datos.
Después de este análisis, serás capaz de generar consultas SQL perfectas para cualquier pregunta.
        
## BASE DE DATOS: {schema.database_name}
        
{await ollama_service._create_enhanced_context(schema, learning_data)}
        
## INSTRUCCIONES DE APRENDIZAJE:
1. Memoriza todas las tablas, columnas y tipos de datos
2. Entiende todas las relaciones entre tablas
3. Aprende los patrones de datos mostrados en las muestras
4. Identifica las mejores estrategias de consulta para cada tabla
5. Reconoce los tipos de preguntas más comunes para estos datos
        
## CONFIRMACIÓN:
Responde con "BASE DE DATOS APRENDIDA" si has procesado toda la información correctamente.
Incluye un breve resumen de lo que has aprendido."""
        
        # 4. Enviar al modelo para aprendizaje
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(
                f"{ollama_service.base_url}/api/generate",
                json={
                    "model": selected_model,
                    "prompt": learning_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.1,
                        "top_p": 0.9,
                        "num_predict": 2000
                    }
                }
            )
        
        if response.status_code == 200:
            result = response.json()
            learning_response = result.get("response", "")
            
            return {
                "success": True,
                "message": "El modelo ha aprendido la base de datos exitosamente",
                "learning_summary": learning_response,
                "tables_analyzed": len(schema.tables),
                "total_samples": sum(len(data) for data in learning_data.values()),
                "database_name": schema.database_name
            }
        else:
            return {
                "success": False,
                "message": f"Error en el proceso de aprendizaje: {response.status_code}"
            }
            
    except Exception as e:
        return {
            "success": False,
            "message": f"Error durante el aprendizaje: {str(e)}"
        }

@router.get("/health")
async def health_check():
    """Verificar estado del servidor"""
    return {
        "status": "healthy",
        "message": "AI Database Chatbot API está funcionando correctamente"
    }
