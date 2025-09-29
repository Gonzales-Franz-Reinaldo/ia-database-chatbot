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
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                if response.status_code == 200:
                    data = response.json()
                    models = []
                    for model in data.get("models", []):
                        # Convertir tamaño de bytes a formato legible
                        size_bytes = model.get("size", 0)
                        size_str = self._format_size(size_bytes)
                        
                        # Formatear fecha
                        modified_at = model.get("modified_at", "")
                        
                        models.append(OllamaModel(
                            name=model["name"],
                            size=size_str,
                            modified_at=modified_at
                        ))
                    return models
                return []
        except Exception as e:
            print(f"Error al obtener modelos de Ollama: {str(e)}")
            return []
    
    def _format_size(self, size_bytes: int) -> str:
        """Formatear tamaño en bytes a formato legible"""
        if size_bytes == 0:
            return "Unknown"
        
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size_bytes < 1024:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024
        return f"{size_bytes:.1f} PB"
    
    async def generate_sql_query(self, 
                                message: str, 
                                model: str, 
                                schema: DatabaseSchema,
                                sample_data: Dict[str, list] = None) -> Dict[str, Any]:
        """Generar consulta SQL usando Ollama con contexto mejorado de la BD"""
        try:
            # Crear contexto enriquecido del esquema y datos
            enhanced_context = await self._create_enhanced_context(schema, sample_data)
            
            # Crear prompt optimizado con RAG avanzado
            prompt = self._create_advanced_sql_prompt(enhanced_context, message, schema.database_name)
            
            # Llamar a Ollama con configuración optimizada
            async with httpx.AsyncClient(timeout=90.0) as client:
                response = await client.post(
                    f"{self.base_url}/api/generate",
                    json={
                        "model": model,
                        "prompt": prompt,
                        "stream": False,
                        "options": {
                            "temperature": 0.05,  # Muy baja para consultas SQL precisas
                            "top_p": 0.8,
                            "top_k": 20,
                            "repeat_penalty": 1.1,
                            "num_predict": 1000
                        }
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    ai_response = result.get("response", "")
                    
                    # Extraer SQL y explicación con mejor precisión
                    sql_query = self._extract_sql_query(ai_response)
                    explanation = self._extract_explanation(ai_response)
                    
                    # Validar la consulta SQL
                    if sql_query:
                        validation_result = self._validate_sql_query(sql_query, schema)
                        if not validation_result["valid"]:
                            return {
                                "success": False,
                                "error": f"Consulta SQL inválida: {validation_result['error']}",
                                "sql_query": sql_query,
                                "explanation": explanation
                            }
                    
                    return {
                        "success": True,
                        "sql_query": sql_query,
                        "explanation": explanation,
                        "full_response": ai_response
                    }
                else:
                    return {
                        "success": False,
                        "error": f"Error en Ollama: {response.status_code} - {response.text}"
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
    
    async def _create_enhanced_context(self, schema: DatabaseSchema, sample_data: Dict[str, list] = None) -> str:
        """Crear contexto enriquecido con esquema y datos de muestra"""
        context = f"# 🗄️ BASE DE DATOS: {schema.database_name}\n"
        context += f"# 📊 Análisis completo del esquema y datos\n\n"
        
        # Estadísticas generales
        total_tables = len(schema.tables)
        total_columns = sum(len(table.columns) for table in schema.tables)
        total_fks = sum(len(table.foreign_keys) for table in schema.tables)
        
        context += f"## 📈 RESUMEN EJECUTIVO\n"
        context += f"- Total de tablas: {total_tables}\n"
        context += f"- Total de columnas: {total_columns}\n"
        context += f"- Relaciones (FK): {total_fks}\n\n"
        
        # Información detallada por tabla
        for table in schema.tables:
            context += f"## 🔖 TABLA: `{table.table_name}`\n"
            
            # Columnas con tipos y detalles
            context += f"### Columnas ({len(table.columns)}):" + "\n"
            for column in table.columns:
                nullable = "✅ NULL" if column["nullable"] else "❌ NOT NULL"
                pk_indicator = " 🔑 PRIMARY KEY" if column["name"] in table.primary_keys else ""
                context += f"- **{column['name']}** (`{column['type']}`) {nullable}{pk_indicator}\n"
                
                if column.get("default"):
                    context += f"  - Valor por defecto: `{column['default']}`\n"
            
            # Claves foráneas
            if table.foreign_keys:
                context += f"\n### 🔗 Relaciones:\n"
                for fk in table.foreign_keys:
                    context += f"- `{fk['column']}` → `{fk['referenced_table']}.{fk['referenced_column']}`\n"
            
            # Datos de muestra si están disponibles
            if sample_data and table.table_name in sample_data:
                samples = sample_data[table.table_name]
                if samples:
                    context += f"\n### 📋 DATOS DE MUESTRA (primeras {len(samples)} filas):\n"
                    context += "```\n"
                    # Crear formato tabular de ejemplo
                    if len(samples) > 0:
                        headers = list(samples[0].keys())
                        context += " | ".join(headers) + "\n"
                        context += " | ".join(["---"] * len(headers)) + "\n"
                        
                        for i, row in enumerate(samples[:3]):  # Solo 3 ejemplos
                            values = [str(row.get(h, "NULL"))[:20] for h in headers]  # Limitar longitud
                            context += " | ".join(values) + "\n"
                    context += "```\n"
            
            context += "\n" + "="*50 + "\n\n"
        
        return context
    
    def _create_advanced_sql_prompt(self, enhanced_context: str, user_message: str, db_name: str) -> str:
        """Crear prompt avanzado para generación de SQL con máxima precisión"""
        return f"""{enhanced_context}

# 🎯 INSTRUCCIONES PARA CONSULTA SQL EXPERTA

Eres un **EXPERTO EN BASES DE DATOS** con conocimiento completo de la BD `{db_name}`.
Tu misión es generar consultas SQL **PERFECTAS** y **EFICIENTES**.

## 🚨 REGLAS CRÍTICAS (OBLIGATORIAS):
✅ **SOLO SELECT** - Jamás INSERT, UPDATE, DELETE, DROP, ALTER, etc.
✅ **NOMBRES EXACTOS** - Usa solo tablas y columnas que existen en el esquema
✅ **SINTAXIS CORRECTA** - SQL válido para PostgreSQL/MySQL
✅ **CASE SENSITIVE** - Respeta mayúsculas/minúsculas exactas
✅ **JOINS CORRECTOS** - Usa las foreign keys mostradas arriba
✅ **PERFORMANCE** - Optimiza para velocidad

## 🎪 PATRONES INTELIGENTES:
- **"mejores/top N"** → `ORDER BY columna DESC LIMIT N`
- **"peores/bottom N"** → `ORDER BY columna ASC LIMIT N`
- **"cuántos"** → `SELECT COUNT(*) FROM tabla WHERE...`
- **"promedio"** → `SELECT AVG(columna) FROM tabla`
- **"total/suma"** → `SELECT SUM(columna) FROM tabla`
- **"por categoría/grupo"** → `GROUP BY columna`
- **"entre fechas"** → `WHERE fecha BETWEEN 'fecha1' AND 'fecha2'`
- **"contiene texto"** → `WHERE columna LIKE '%texto%'`

## 💡 CONTEXTO DE LA CONSULTA:
**Pregunta del usuario:** {user_message}

## ⚡ FORMATO DE RESPUESTA OBLIGATORIO:
SQL: [tu consulta sql aquí - una sola línea o con saltos lógicos]
EXPLICACIÓN: [explicación clara y detallada en español]

## 🔍 ANÁLISIS Y RESPUESTA:"""
    
    def _validate_sql_query(self, sql_query: str, schema: DatabaseSchema) -> Dict[str, Any]:
        """Validar consulta SQL contra el esquema"""
        if not sql_query:
            return {"valid": False, "error": "Consulta SQL vacía"}
        
        sql_upper = sql_query.upper().strip()
        
        # Verificar que sea SELECT
        if not sql_upper.startswith('SELECT'):
            return {"valid": False, "error": "Solo se permiten consultas SELECT"}
        
        # Verificar palabras prohibidas
        forbidden = ['INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER', 'TRUNCATE']
        for word in forbidden:
            if word in sql_upper:
                return {"valid": False, "error": f"Operación prohibida: {word}"}
        
        # Verificar que las tablas existen
        table_names = [table.table_name for table in schema.tables]
        for table_name in table_names:
            if f' {table_name.upper()}' in sql_upper or f' {table_name.upper()} ' in sql_upper:
                continue  # Tabla encontrada
        
        return {"valid": True, "error": None}
    
    def _extract_explanation(self, response: str) -> Optional[str]:
        """Extraer explicación de la respuesta de la IA"""
        # Buscar patrón EXPLICACIÓN:
        explanation_match = re.search(r'EXPLICACIÓN:\s*(.*?)$', response, re.IGNORECASE | re.DOTALL)
        if explanation_match:
            return explanation_match.group(1).strip()
        
        return None