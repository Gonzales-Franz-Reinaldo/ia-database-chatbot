import httpx
import json
import re
from typing import List, Dict, Any, Optional
from app.models.database import DatabaseSchema, OllamaModel
from app.services.query_analyzer import QueryAnalyzer

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
                                sample_data: Dict[str, list] = None,
                                data_profile: Dict[str, Any] = None) -> Dict[str, Any]:
        """Generar consulta SQL con contexto FOCALIZADO usando QueryAnalyzer"""
        try:
            print(f"🔍 [SQL-GEN] Analizando query: {message}")
            
            # 🆕 PASO 1: Analizar la query del usuario
            analyzer = QueryAnalyzer(schema)
            query_analysis = analyzer.analyze_query(message)
            
            print(f"📊 [SQL-GEN] Tablas relevantes: {query_analysis['relevant_tables']}")
            print(f"📊 [SQL-GEN] Tipo: {query_analysis['query_type']}")
            print(f"📊 [SQL-GEN] Complejidad: {query_analysis['complexity_level']}/5")
            
            # 🆕 PASO 2: Obtener contexto focalizado
            focused_context = analyzer.get_focused_context(query_analysis)
            
            print(f"🎯 [SQL-GEN] Contexto focalizado: {focused_context['focused_table_count']}/{focused_context['total_tables_in_db']} tablas")
            
            # 🆕 PASO 3: Generar ejemplos contextuales
            example_queries = analyzer.generate_example_queries(query_analysis)
            
            # 🆕 PASO 4: Crear prompt MEJORADO con contexto focalizado
            prompt = self._create_focused_sql_prompt(
                schema,
                message,
                data_profile,
                focused_context,
                query_analysis,
                example_queries
            )
            
            print(f"📝 [SQL-GEN] Longitud prompt: {len(prompt)} caracteres")
            
            # Ajustar temperatura según complejidad
            temperature = 0.05 if query_analysis['complexity_level'] <= 2 else 0.1
            
            async with httpx.AsyncClient(timeout=1000.0) as client:
                response = await client.post(
                    f"{self.base_url}/api/generate",
                    json={
                        "model": model,
                        "prompt": prompt,
                        "stream": False,
                        "options": {
                            "temperature": temperature,
                            "top_p": 0.8,
                            "top_k": 20,
                            "repeat_penalty": 1.1,
                            "num_predict": 5000
                        }
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    ai_response = result.get("response", "")
                    
                    sql_query = self._extract_sql_query(ai_response)
                    explanation = self._extract_explanation(ai_response)
                    
                    if not sql_query:
                        return {
                            "success": False,
                            "error": "No se pudo extraer consulta SQL",
                            "full_response": ai_response
                        }
                    
                    # Validar SQL
                    validation_result = self._validate_sql_query(sql_query, schema)
                    if not validation_result["valid"]:
                        return {
                            "success": False,
                            "error": f"SQL inválido: {validation_result['error']}",
                            "sql_query": sql_query
                        }
                    
                    return {
                        "success": True,
                        "sql_query": sql_query,
                        "explanation": explanation,
                        "full_response": ai_response,
                        "analysis": query_analysis
                    }
                else:
                    return {
                        "success": False,
                        "error": f"Error Ollama: {response.status_code}"
                    }
        
        except Exception as e:
            print(f"💥 [SQL-GEN] Error: {str(e)}")
            import traceback
            traceback.print_exc()
            return {
                "success": False,
                "error": f"Error generando SQL: {str(e)}"
            }
    
    def _create_focused_sql_prompt(self,
                                   schema: DatabaseSchema,
                                   user_message: str,
                                   data_profile: Dict[str, Any],
                                   focused_context: Dict[str, Any],
                                   query_analysis: Dict[str, Any],
                                   example_queries: List[str]) -> str:
        """
        🆕 Crear prompt FOCALIZADO con solo información relevante
        """
        
        prompt = f"""# 🎯 CONTEXTO FOCALIZADO PARA CONSULTA SQL

Base de datos: **{schema.database_name}**
Tablas en BD: {focused_context['total_tables_in_db']}
Tablas relevantes para esta query: {focused_context['focused_table_count']}
Complejidad: Nivel {query_analysis['complexity_level']}/5
Tipo: {query_analysis['query_type']}

---

## 📋 TABLAS RELEVANTES (Solo estas son importantes para esta consulta)

"""
        
        # Solo mostrar tablas focalizadas
        for table in focused_context["tables"]:
            prompt += f"\n### 🔹 TABLA: `{table.table_name}`\n"
            
            # Obtener perfil si existe
            table_profile = None
            if data_profile and "tables" in data_profile:
                table_profile = data_profile["tables"].get(table.table_name, {})
            
            if table_profile and "row_count" in table_profile:
                prompt += f"  📊 Registros: {table_profile['row_count']}\n"
            
            prompt += "\n**COLUMNAS:**\n"
            
            # Resaltar columnas mencionadas en la query
            mentioned_cols = query_analysis.get("mentioned_columns", {}).get(table.table_name, [])
            
            for col in table.columns:
                col_name = col['name']
                col_type = col['type']
                
                # Marcar si fue mencionada
                mention_mark = " ⭐ [MENCIONADA]" if col_name.lower() in mentioned_cols else ""
                
                col_info = f"  • `{col_name}` ({col_type}){mention_mark}"
                
                if col_name in table.primary_keys:
                    col_info += " 🔑 [PK]"
                if not col['nullable']:
                    col_info += " [NOT NULL]"
                
                prompt += col_info + "\n"
                
                # VALORES PERMITIDOS del perfil
                if table_profile and "columns_profile" in table_profile:
                    col_profile = table_profile["columns_profile"].get(col_name)
                    if col_profile and col_profile.get("unique_values"):
                        values = col_profile["unique_values"]
                        formatted = [f"'{v}'" if isinstance(v, str) else str(v) for v in values]
                        prompt += f"    ⚠️  VALORES PERMITIDOS: {', '.join(formatted)}\n"
            
            prompt += "\n"
        
        # MAPA DE RELACIONES
        if focused_context["relationships"]:
            prompt += "\n## 🔗 RELACIONES (Usa estas para JOINs)\n\n"
            for rel in focused_context["relationships"]:
                prompt += f"  • `{rel['from_table']}.{rel['from_column']}` → `{rel['to_table']}.{rel['to_column']}`\n"
            prompt += "\n"
        
        # EJEMPLOS CONTEXTUALES
        if example_queries:
            prompt += "\n## 💡 EJEMPLOS DE QUERIES SIMILARES\n\n"
            for i, example in enumerate(example_queries, 1):
                prompt += f"{i}. ```sql\n{example}\n```\n\n"
        
        # HINTS ESPECÍFICOS
        hints = query_analysis.get("filter_hints", {})
        if hints.get("exact_values") or hints.get("boolean_keywords"):
            prompt += "\n## 🎯 HINTS PARA ESTA CONSULTA\n\n"
            
            if hints.get("exact_values"):
                prompt += f"  • Valores exactos mencionados: {', '.join([f'\'{v}\'' for v in hints['exact_values']])}\n"
            
            if hints.get("boolean_keywords"):
                for keyword, value in hints["boolean_keywords"]:
                    prompt += f"  • '{keyword}' probablemente significa: {value}\n"
            
            prompt += "\n"
        
        # PREGUNTA E INSTRUCCIONES
        prompt += f"""
---

## 🎯 PREGUNTA DEL USUARIO:
**"{user_message}"**

---

## 📝 INSTRUCCIONES CRÍTICAS:

1. **USA SOLO LAS TABLAS MOSTRADAS ARRIBA** (no inventes nombres)
2. **PARA JOINS**: Usa EXACTAMENTE las relaciones del mapa
3. **PARA VALORES**: Si hay "VALORES PERMITIDOS", usa esos exactos
4. **COLUMNAS MENCIONADAS**: Prioriza las marcadas con ⭐
5. **GENERA SOLO SELECT**: Nunca INSERT/UPDATE/DELETE

## 🎯 FORMATO DE RESPUESTA (OBLIGATORIO):

SQL: [tu consulta SELECT aquí]
EXPLICACIÓN: [explicación breve]

## 🚀 GENERA TU RESPUESTA AHORA:
"""
        
        return prompt
    
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
- ✅ Y otras funciones SQL estándar según la pregunta

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
        """Extraer consulta SQL de la respuesta de la IA con múltiples patrones"""
        print(f"🔍 [DEBUG] Extrayendo SQL de respuesta de {len(response)} caracteres")
        
        patterns = [
            # Patrón 1: SQL: seguido de consulta hasta nueva línea o EXPLICACIÓN
            r'SQL:\s*(SELECT[^\r\n]*(?:;)?)',
            # Patrón 2: SELECT en bloque de código
            r'```(?:sql)?\s*(SELECT.*?)```',
            # Patrón 3: SELECT en una línea completa
            r'^\s*(SELECT[^\r\n]*(?:;)?)\s*$',
            # Patrón 4: SELECT hasta punto y coma
            r'(SELECT[^;]*);',
            # Patrón 5: SELECT hasta salto de línea
            r'(SELECT[^\r\n]*)',
        ]
        
        for i, pattern in enumerate(patterns, 1):
            matches = re.findall(pattern, response, re.IGNORECASE | re.DOTALL)
            if matches:
                for match in matches:
                    sql = match.strip() if isinstance(match, str) else match
                    # Limpiar SQL
                    sql = re.sub(r'^```sql\s*', '', sql, flags=re.IGNORECASE)
                    sql = re.sub(r'\s*```$', '', sql)
                    sql = sql.strip()
                    
                    # Validar que sea una consulta SQL válida
                    if sql and sql.upper().startswith('SELECT') and len(sql) > 10:
                        print(f"✅ [DEBUG] SQL encontrado con patrón {i}: {sql[:100]}...")
                        return sql
        
        print(f"❌ [DEBUG] No se encontró SQL válido en la respuesta")
        print(f"📄 [DEBUG] Respuesta completa: {response}")
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
        """Crear prompt simple y directo para generación de SQL"""
        
        # Extraer solo la información esencial de tablas
        simple_schema = ""
        for table in self.schema.tables if hasattr(self, 'schema') else []:
            simple_schema += f"Tabla {table.table_name}: "
            columns = [col['name'] for col in table.columns]
            simple_schema += ", ".join(columns) + "\n"
        
        return f"""Tienes acceso a la base de datos {db_name} con estas tablas:

{enhanced_context}

Pregunta del usuario: {user_message}

Genera SOLO una consulta SQL SELECT válida para responder la pregunta. 
Usa los nombres exactos de tablas y columnas mostrados arriba.

Formato de respuesta requerido:
SQL: [consulta SELECT aquí]
EXPLICACIÓN: [explicación corta]

Respuesta:"""
    
    def _create_simple_sql_prompt(self, schema: DatabaseSchema, user_message: str, data_profile: Dict[str, Any] = None) -> str:
        """Crear prompt enriquecido con información detallada del esquema y valores reales"""
        
        # Encabezado con información de la base de datos
        schema_info = f"""# 🗄️ BASE DE DATOS: {schema.database_name}

## 📋 ESQUEMA COMPLETO CON VALORES REALES

ATENCIÓN: Usa SOLO los nombres exactos de tablas, columnas y valores mostrados aquí.

"""
        
        # Información detallada por tabla
        for table in schema.tables:
            schema_info += f"\n### 📊 TABLA: `{table.table_name}`\n"
            
            # Obtener perfil de la tabla si está disponible
            table_profile = None
            if data_profile and "tables" in data_profile:
                table_profile = data_profile["tables"].get(table.table_name, {})
            
            # Mostrar número de filas si está disponible
            if table_profile and "row_count" in table_profile:
                schema_info += f"  Total de registros: {table_profile['row_count']}\n"
            
            schema_info += "\n**COLUMNAS:**\n"
            
            # Columnas con información detallada
            for col in table.columns:
                col_name = col['name']
                col_type = col['type']
                
                # Construir información de la columna
                col_info = f"  • `{col_name}` ({col_type})"
                
                # Indicadores de restricciones
                if col_name in table.primary_keys:
                    col_info += " [PRIMARY KEY]"
                if not col['nullable']:
                    col_info += " [NOT NULL]"
                if col.get('default'):
                    col_info += f" [DEFAULT: {col['default']}]"
                
                schema_info += col_info + "\n"
                
                # IMPORTANTE: Agregar valores permitidos si existen en el perfil
                if table_profile and "columns_profile" in table_profile:
                    col_profile = table_profile["columns_profile"].get(col_name)
                    if col_profile:
                        if col_profile.get("unique_values"):
                            values = col_profile["unique_values"]
                            # Formatear valores según el tipo
                            formatted_values = []
                            for v in values:
                                if isinstance(v, str):
                                    formatted_values.append(f"'{v}'")
                                else:
                                    formatted_values.append(str(v))
                            
                            schema_info += f"    ⚠️  VALORES PERMITIDOS: {', '.join(formatted_values)}\n"
                            
                            # Mostrar distribución si hay pocos valores
                            if len(values) <= 10 and col_profile.get("value_distribution"):
                                schema_info += "    📊 Distribución: "
                                dist_items = []
                                for val, count in col_profile["value_distribution"].items():
                                    dist_items.append(f"{val}({count})")
                                schema_info += ", ".join(dist_items[:5]) + "\n"
                        
                        elif col_profile.get("sample_values"):
                            samples = col_profile["sample_values"]
                            formatted_samples = []
                            for v in samples:
                                if isinstance(v, str):
                                    formatted_samples.append(f"'{v}'")
                                else:
                                    formatted_samples.append(str(v))
                            schema_info += f"    💡 Ejemplos: {', '.join(formatted_samples)}\n"
            
            # Relaciones (Foreign Keys)
            if table.foreign_keys:
                schema_info += "\n**RELACIONES (Foreign Keys):**\n"
                for fk in table.foreign_keys:
                    schema_info += f"  • `{fk['column']}` → `{fk['referenced_table']}.{fk['referenced_column']}`\n"
            
            schema_info += "\n" + "─" * 70 + "\n"
        
        # Instrucciones mejoradas para el modelo
        prompt = f"""{schema_info}

## 🎯 INSTRUCCIONES CRÍTICAS:

1. **USA VALORES EXACTOS**: Si una columna tiene "VALORES PERMITIDOS" especificados, úsalos TAL CUAL están escritos
2. **NOMBRES EXACTOS**: Usa los nombres de tablas y columnas exactamente como se muestran arriba
3. **TIPOS DE DATOS**: Respeta los tipos de datos al construir condiciones WHERE
4. **RELACIONES**: Usa las Foreign Keys mostradas para hacer JOINs correctos
5. **SOLO SELECT**: Genera únicamente consultas SELECT, nunca INSERT/UPDATE/DELETE

## 💬 PREGUNTA DEL USUARIO:
{user_message}

## 📝 TU RESPUESTA (usa este formato EXACTO):

SQL: [escribe aquí la consulta SELECT]
EXPLICACIÓN: [explica brevemente qué hace la consulta]

## 🚨 REGLAS IMPORTANTES:
- Si una columna tiene "VALORES PERMITIDOS", usa EXACTAMENTE esos valores (no inventes valores alternativos)
- Si necesitas filtrar por una columna categórica, verifica primero si hay valores permitidos listados
- Para hacer JOIN entre tablas, usa las relaciones Foreign Keys mostradas
- Si la pregunta es ambigua, genera la consulta más lógica basándote en el esquema
- Si hay vistas (VIEW), puedes usarlas directamente en lugar de hacer JOINs complejos
"""
        
        return prompt
    
    def _validate_sql_query(self, sql_query: str, schema: DatabaseSchema) -> Dict[str, Any]:
        """Validar consulta SQL contra el esquema"""
        if not sql_query:
            return {"valid": False, "error": "Consulta SQL vacía"}
        
        sql_upper = sql_query.upper().strip()
        
        # Verificar que sea SELECT
        if not sql_upper.startswith('SELECT'):
            return {"valid": False, "error": "Solo se permiten consultas SELECT"}
        
        # Verificar palabras prohibidas usando word boundaries (palabras completas)
        forbidden = ['INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER', 'TRUNCATE']
        for word in forbidden:
            # Usar regex para buscar palabra completa, no subcadena
            # Esto evita que "created_at" active el filtro "CREATE"
            pattern = r'\b' + word + r'\b'
            if re.search(pattern, sql_upper):
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