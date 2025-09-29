import httpx
import json
import re
from typing import List, Dict, Any, Optional
from app.models.database import DatabaseSchema, OllamaModel

class OllamaService:
    def __init__(self, base_url: str = "http://localhost:11434"):
        self.base_url = base_url
    
    async def get_available_models(self) -> List[OllamaModel]:
        """Obtener lista de modelos disponibles en Ollama"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(f"{self.base_url}/api/tags")
                if response.status_code == 200:
                    data = response.json()
                    models = []
                    for model in data.get("models", []):
                        models.append(OllamaModel(
                            name=model["name"],
                            size=model.get("size", "Unknown"),
                            modified_at=model.get("modified_at", "")
                        ))
                    return models
                return []
        except Exception:
            return []
    
    async def generate_sql_query(self, 
                                message: str, 
                                model: str, 
                                schema: DatabaseSchema) -> Dict[str, Any]:
        """Generar consulta SQL usando Ollama"""
        try:
            # Crear contexto del esquema de la base de datos
            schema_context = self._create_schema_context(schema)
            
            # Crear prompt optimizado con RAG
            prompt = self._create_sql_prompt(schema_context, message)
            
            # Llamar a Ollama
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(
                    f"{self.base_url}/api/generate",
                    json={
                        "model": model,
                        "prompt": prompt,
                        "stream": False,
                        "options": {
                            "temperature": 0.1,  # Baja temperatura para respuestas más precisas
                            "top_p": 0.9,
                            "max_tokens": 1500  # Aumentado para respuestas más detalladas
                        }
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    ai_response = result.get("response", "")
                    
                    # Extraer SQL y explicación
                    sql_query = self._extract_sql_query(ai_response)
                    explanation = self._extract_explanation(ai_response)
                    
                    return {
                        "success": True,
                        "sql_query": sql_query,
                        "explanation": explanation,
                        "full_response": ai_response
                    }
                else:
                    return {
                        "success": False,
                        "error": f"Error en Ollama: {response.status_code}"
                    }
        
        except Exception as e:
            return {
                "success": False,
                "error": f"Error al generar consulta SQL: {str(e)}"
            }
    
    def _create_schema_context(self, schema: DatabaseSchema) -> str:
        """Crear contexto del esquema de la base de datos"""
        context = f"# ESQUEMA DE BASE DE DATOS: {schema.database_name}\n\n"
        
        for table in schema.tables:
            context += f"## Tabla: {table.table_name}\n"
            context += "Columnas:\n"
            
            for column in table.columns:
                nullable = "NULL" if column["nullable"] else "NOT NULL"
                context += f"- {column['name']} ({column['type']}) {nullable}"
                if column.get("default"):
                    context += f" DEFAULT {column['default']}"
                context += "\n"
            
            if table.primary_keys:
                context += f"Clave primaria: {', '.join(table.primary_keys)}\n"
            
            if table.foreign_keys:
                context += "Claves foráneas:\n"
                for fk in table.foreign_keys:
                    context += f"- {fk['column']} → {fk['referenced_table']}.{fk['referenced_column']}\n"
            
            context += "\n"
        
        return context
    
    def _create_sql_prompt(self, schema_context: str, user_message: str) -> str:
        """Crear prompt optimizado para generar SQL"""
        return f"""{schema_context}

# INSTRUCCIONES PARA GENERAR CONSULTAS SQL

Eres un experto en bases de datos con acceso completo al esquema. Tu trabajo es:

1. **ANALIZAR** la pregunta del usuario en contexto del esquema
2. **GENERAR** una consulta SQL válida y eficiente
3. **EXPLICAR** claramente qué hace la consulta
4. **OPTIMIZAR** para obtener los mejores resultados

## REGLAS CRÍTICAS:
- ✅ Solo consultas SELECT (nunca INSERT, UPDATE, DELETE, DROP, etc.)
- ✅ Usa nombres exactos de tablas y columnas del esquema
- ✅ Para JOINs, usa las claves foráneas correctas
- ✅ Para "mejores/top", usa ORDER BY + LIMIT
- ✅ Para conteos, usa COUNT()
- ✅ Para promedios, usa AVG()
- ✅ Para búsquedas, usa WHERE con LIKE o =
- ✅ Para agrupaciones, usa GROUP BY

## PATRONES COMUNES:
- "mejores X" → ORDER BY X DESC LIMIT N
- "cuántos" → SELECT COUNT(*) FROM tabla WHERE condición
- "promedio" → SELECT AVG(columna) FROM tabla
- "todos los" → SELECT * FROM tabla
- "por categoría" → GROUP BY categoría

## FORMATO DE RESPUESTA OBLIGATORIO:
SQL: [consulta sql aquí]
EXPLICACIÓN: [explicación detallada de la consulta]

## PREGUNTA DEL USUARIO:
{user_message}

## RESPUESTA:"""
    
    def _extract_sql_query(self, response: str) -> Optional[str]:
        """Extraer consulta SQL de la respuesta de la IA"""
        # Buscar patrón SQL:
        sql_match = re.search(r'SQL:\s*(.*?)(?=EXPLICACIÓN:|$)', response, re.IGNORECASE | re.DOTALL)
        if sql_match:
            sql = sql_match.group(1).strip()
            # Limpiar SQL
            sql = re.sub(r'^```sql\s*', '', sql)
            sql = re.sub(r'\s*```$', '', sql)
            sql = sql.strip()
            return sql if sql else None
        
        # Buscar SQL entre ```
        code_match = re.search(r'```(?:sql)?\s*(SELECT.*?)```', response, re.IGNORECASE | re.DOTALL)
        if code_match:
            return code_match.group(1).strip()
        
        # Buscar SELECT directamente
        select_match = re.search(r'(SELECT.*?);?$', response, re.IGNORECASE | re.DOTALL)
        if select_match:
            return select_match.group(1).strip()
        
        return None
    
    def _extract_explanation(self, response: str) -> Optional[str]:
        """Extraer explicación de la respuesta de la IA"""
        # Buscar patrón EXPLICACIÓN:
        explanation_match = re.search(r'EXPLICACIÓN:\s*(.*?)$', response, re.IGNORECASE | re.DOTALL)
        if explanation_match:
            return explanation_match.group(1).strip()
        
        return None