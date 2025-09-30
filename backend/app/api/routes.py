from fastapi import APIRouter, HTTPException
from typing import List
from app.models.database import (
    DatabaseConnection, DatabaseSchema, ChatMessage, QueryResult, OllamaModel, LearnDatabaseRequest
)
from app.services.schema_analyzer import SchemaAnalyzer
from app.services.database_service import DatabaseService
from app.services.ollama_service import OllamaService
from app.services.data_profiler import DataProfiler
from app.services.context_cache import context_cache
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
    """Procesar mensaje de chat y ejecutar consulta SQL con contexto mejorado y perfilado"""
    try:
        print(f"\n🚀 [CHAT] Nueva consulta: {chat_request.message}")
        
        # Convertir conexión a dict para el caché
        connection_dict = chat_request.database_connection.dict()
        
        # 1. Intentar obtener contexto del caché
        cached_context = context_cache.get(connection_dict)
        
        if cached_context:
            # Usar contexto en caché
            schema = cached_context["schema"]
            data_profile = cached_context["data_profile"]
            print(f"✅ [CHAT] Usando contexto en caché")
        else:
            # Analizar y perfilar la base de datos (primera vez o caché expirado)
            print(f"🔍 [CHAT] Analizando y perfilando base de datos...")
            
            # Analizar esquema
            analyzer = SchemaAnalyzer(chat_request.database_connection)
            schema = analyzer.analyze_schema()
            
            # Perfilar datos (obtener valores únicos de columnas categóricas)
            profiler = DataProfiler(chat_request.database_connection)
            data_profile = profiler.profile_database(schema.tables)
            
            # Guardar en caché
            context_cache.set(connection_dict, {
                "schema": schema,
                "data_profile": data_profile
            })
            
            print(f"💾 [CHAT] Contexto analizado y guardado en caché")
        
        # 2. Generar consulta SQL usando Ollama con contexto enriquecido
        ollama_result = await ollama_service.generate_sql_query(
            chat_request.message,
            chat_request.model,
            schema,
            sample_data=None,  
            data_profile=data_profile
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

async def create_optimized_learning_prompt(schema, learning_data):
    """Crear un prompt enfocado SOLO en estructura y esquema de la base de datos"""
    
    prompt = f"""Eres un experto generador de consultas SQL. Te proporciono la ESTRUCTURA COMPLETA de la base de datos '{schema.database_name}' para que puedas generar consultas SQL precisas.

# 📊 BASE DE DATOS: {schema.database_name}

## 🏗️ ESQUEMA Y ESTRUCTURA:
"""
    
    # Solo estructura esencial - SIN registros masivos
    for table in schema.tables:
        prompt += f"\n### 📋 TABLA: {table.table_name}\n"
        
        # Columnas con información esencial
        prompt += "**COLUMNAS:**\n"
        for col in table.columns:
            col_info = f"  • {col['name']} ({col['type']})"
            if col['name'] in table.primary_keys:
                col_info += " [PK]"
            if not col['nullable']:
                col_info += " [NOT NULL]"
            if col.get('default'):
                col_info += f" [DEFAULT: {col['default']}]"
            prompt += col_info + "\n"
        
        # Relaciones entre tablas
        if table.foreign_keys:
            prompt += "\n**RELACIONES:**\n"
            for fk in table.foreign_keys:
                prompt += f"  • {fk['column']} → {fk['referenced_table']}.{fk['referenced_column']}\n"
        
        # Solo 2-3 ejemplos para entender formato (NO datos masivos)
        if table.table_name in learning_data and learning_data[table.table_name]:
            prompt += f"\n**FORMATO DE DATOS (ejemplo):**\n"
            for i, record in enumerate(learning_data[table.table_name][:2]):  # Solo 2 ejemplos
                example_values = []
                for key, value in record.items():
                    if isinstance(value, str):
                        example_values.append(f"'{value}'")
                    else:
                        example_values.append(str(value))
                prompt += f"  Ejemplo {i+1}: ({', '.join(example_values)})\n"
        
        prompt += "\n" + "-"*50 + "\n"
    
    # Instrucciones claras y concisas
    prompt += f"""
## ✅ RESUMEN:
- Base de datos: {schema.database_name}
- Tablas disponibles: {len(schema.tables)}
- Tu función: Generar consultas SQL precisas usando esta estructura

## 🎯 IMPORTANTE:
Cuando recibas preguntas:
1. Usa nombres EXACTOS de tablas y columnas mostradas arriba
2. Respeta las relaciones entre tablas (FK)
3. Genera SOLO consultas SELECT válidas
4. Los datos reales vendrán de la ejecución de la consulta

Responde únicamente: "ESTRUCTURA MEMORIZADA - Listo para generar consultas SQL para {schema.database_name} con {len(schema.tables)} tablas."
"""
    
    return prompt

@router.post("/learn-database")
async def learn_database(request: LearnDatabaseRequest):
    """Hacer que el modelo de IA aprenda la base de datos completamente"""
    try:
        # 1. Analizar esquema completo
        analyzer = SchemaAnalyzer(request.database_connection)
        if not analyzer.test_connection():
            return {
                "success": False,
                "message": "No se pudo conectar a la base de datos"
            }
        
        schema = analyzer.analyze_schema()
        
        # 2. Obtener muestras de datos de todas las tablas
        db_service = DatabaseService(request.database_connection)
        learning_data = {}
        
        for table in schema.tables:
            try:
                # Solo obtener 2-3 registros de ejemplo para entender estructura
                result = db_service.get_sample_data(table.table_name, limit=3)  # Solo ejemplos mínimos
                if result["success"] and result["data"]:
                    learning_data[table.table_name] = result["data"]
            except Exception as e:
                learning_data[table.table_name] = []
        
        # 3. Crear prompt de aprendizaje optimizado
        learning_prompt = await create_optimized_learning_prompt(schema, learning_data)
        
        # 4. Enviar al modelo para aprendizaje
        async with httpx.AsyncClient(timeout=1000.0) as client:
            response = await client.post(
                f"{ollama_service.base_url}/api/generate",
                json={
                    "model": request.selected_model,
                    "prompt": learning_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.1,
                        "top_p": 0.8,
                        "num_predict": 1000,  # Respuesta corta esperada
                        "repeat_penalty": 1.1
                        # Sin stop tokens para permitir respuesta completa
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

@router.post("/refresh-context")
async def refresh_context(db_connection: DatabaseConnection):
    """Refrescar el contexto de la base de datos (invalidar caché y reanalizar)"""
    try:
        connection_dict = db_connection.dict()
        
        # Invalidar caché existente
        context_cache.invalidate(connection_dict)
        
        # Reanalizar y perfilar
        analyzer = SchemaAnalyzer(db_connection)
        schema = analyzer.analyze_schema()
        
        profiler = DataProfiler(db_connection)
        data_profile = profiler.profile_database(schema.tables)
        
        # Guardar nuevo contexto en caché
        context_cache.set(connection_dict, {
            "schema": schema,
            "data_profile": data_profile
        })
        
        return {
            "success": True,
            "message": f"Contexto refrescado para {db_connection.database}",
            "tables_analyzed": len(schema.tables)
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"Error al refrescar contexto: {str(e)}"
        }

@router.get("/cache-stats")
async def get_cache_stats():
    """Obtener estadísticas del caché de contextos"""
    return context_cache.get_stats()

@router.post("/disconnect")
async def disconnect(request: dict):
    """Desconectar: limpiar caché y detener modelo de Ollama"""
    try:
        db_connection_dict = request.get("database_connection")
        model_name = request.get("model_name")
        
        if not db_connection_dict or not model_name:
            return {
                "success": False,
                "message": "Faltan parámetros requeridos"
            }
        
        # 1. Limpiar caché
        context_cache.invalidate(db_connection_dict)
        print(f"🗑️ [DISCONNECT] Caché limpiado para {db_connection_dict.get('database')}")
        
        # 2. Detener modelo en Ollama
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                # Comando para detener el modelo en Ollama
                # Nota: Ollama no tiene un endpoint directo para "stop", pero podemos
                # intentar descargar el modelo de memoria (esto es opcional)
                print(f"⏸️ [DISCONNECT] Intentando detener modelo: {model_name}")
                # En Ollama, los modelos se descargan automáticamente después de un tiempo
                # No hay un endpoint oficial para "stop", pero lo registramos
        except Exception as e:
            print(f"⚠️ [DISCONNECT] Advertencia al detener modelo: {str(e)}")
        
        return {
            "success": True,
            "message": f"Desconexión exitosa. Caché limpiado para {db_connection_dict.get('database')}",
            "model_stopped": model_name
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"Error al desconectar: {str(e)}"
        }

@router.get("/health")
async def health_check():
    """Verificar estado del servidor"""
    return {
        "status": "healthy",
        "message": "AI Database Chatbot API está funcionando correctamente"
    }
