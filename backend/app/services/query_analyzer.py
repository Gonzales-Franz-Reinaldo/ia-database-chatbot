"""
Analizador inteligente de queries - GENÉRICO para cualquier base de datos.
No asume nombres de tablas específicos.
"""
from typing import List, Dict, Set, Any, Tuple
import re
from difflib import get_close_matches
from app.models.database import DatabaseSchema, TableSchema


class QueryAnalyzer:
    """
    Analiza la pregunta del usuario de forma DINÁMICA usando:
    1. Análisis de similitud de palabras con nombres de tablas reales
    2. Detección de patrones SQL genéricos
    3. Análisis de relaciones FK entre tablas
    """
    
    # Patrones genéricos de operaciones SQL
    AGGREGATION_PATTERNS = [
        r'\b(cuánto|cuanta|cuantos|cuantas)\b',
        r'\b(promedio|media|avg)\b',
        r'\b(suma|total|sumar)\b',
        r'\b(cantidad|conteo|count)\b',
        r'\b(máximo|minimo|max|min)\b'
    ]
    
    JOIN_PATTERNS = [
        r'\b(con su|con sus|con el|con la|con los|con las)\b',
        r'\b(relacionado|relacionados|relacionada|relacionadas)\b',
        r'\b(junto a|junto con)\b',
        r'\b(y su|y sus|y el|y la|y los|y las)\b'
    ]
    
    FILTER_PATTERNS = [
        r'\b(donde|que|cual|cuales)\b',
        r'\b(solo|solamente|únicamente)\b',
        r'\b(activo|inactivo|vigente)\b',
        r'\b(igual a|mayor que|menor que|entre)\b'
    ]
    
    ORDER_PATTERNS = [
        r'\b(mejor|peor|primero|último|top)\b',
        r'\b(mayor|menor|más|menos)\b',
        r'\b(ordenado|orden|ordenar)\b',
        r'\b(ascendente|descendente|asc|desc)\b'
    ]
    
    def __init__(self, schema: DatabaseSchema):
        self.schema = schema
        self.table_names = [table.table_name.lower() for table in schema.tables]
        self.table_dict = {table.table_name.lower(): table for table in schema.tables}
        
        # Crear índice de columnas por tabla para búsqueda rápida
        self.column_index = self._build_column_index()
        
        # Crear índice de palabras clave de todas las tablas/columnas
        self.keyword_index = self._build_keyword_index()
    
    def _build_column_index(self) -> Dict[str, List[str]]:
        """Construir índice de columnas por tabla"""
        index = {}
        for table in self.schema.tables:
            index[table.table_name.lower()] = [
                col['name'].lower() for col in table.columns
            ]
        return index
    
    def _build_keyword_index(self) -> Dict[str, Set[str]]:
        """
        Construir índice de palabras clave extraídas de nombres de tablas y columnas.
        Esto permite detectar menciones indirectas.
        """
        index = {}
        
        for table in self.schema.tables:
            table_name = table.table_name.lower()
            
            # Extraer palabras del nombre de la tabla (split por _ y camelCase)
            words = self._extract_words_from_identifier(table_name)
            
            for word in words:
                if word not in index:
                    index[word] = set()
                index[word].add(table_name)
            
            # También indexar por columnas (para menciones como "nombre", "precio")
            for col in table.columns:
                col_words = self._extract_words_from_identifier(col['name'])
                for word in col_words:
                    if word not in index:
                        index[word] = set()
                    index[word].add(table_name)
        
        return index
    
    def _extract_words_from_identifier(self, identifier: str) -> List[str]:
        """
        Extraer palabras significativas de un identificador de BD.
        Ejemplo: 'alumnos_posgrado' -> ['alumnos', 'posgrado']
                 'CreatedAt' -> ['created', 'at']
        """
        # Split por underscore
        parts = identifier.split('_')
        
        words = []
        for part in parts:
            # Split camelCase: 'CreatedAt' -> ['Created', 'At']
            camel_split = re.sub('([A-Z][a-z]+)', r' \1', part).split()
            words.extend([w.lower() for w in camel_split if len(w) > 2])
        
        # Remover números y caracteres especiales
        words = [re.sub(r'[^a-z]', '', w) for w in words if len(w) > 2]
        
        return [w for w in words if w]  # Remover vacíos
    
    def analyze_query(self, user_message: str) -> Dict[str, Any]:
        """
        Analizar la query del usuario de forma DINÁMICA.
        """
        message_lower = user_message.lower()
        
        # 1. Detectar tablas relevantes usando múltiples estrategias
        relevant_tables = self._extract_relevant_tables_dynamic(message_lower)
        
        # 2. Determinar tipo de query
        query_type = self._determine_query_type(message_lower)
        
        # 3. Detectar columnas mencionadas
        mentioned_columns = self._extract_mentioned_columns(message_lower, relevant_tables)
        
        # 4. Extraer hints de filtros (valores específicos)
        filter_hints = self._extract_filter_hints_dynamic(message_lower, relevant_tables)
        
        # 5. Calcular complejidad
        complexity_level = self._calculate_complexity(
            len(relevant_tables), 
            query_type, 
            len(mentioned_columns)
        )
        
        analysis = {
            "relevant_tables": relevant_tables,
            "mentioned_columns": mentioned_columns,
            "query_type": query_type,
            "complexity_level": complexity_level,
            "filter_hints": filter_hints,
            "requires_joins": len(relevant_tables) > 1,
            "aggregation_needed": query_type == "aggregation"
        }
        
        return analysis
    
    def _extract_relevant_tables_dynamic(self, message: str) -> Set[str]:
        """
        Extraer tablas relevantes usando 4 estrategias:
        1. Coincidencia exacta de nombres de tabla
        2. Coincidencia de palabras clave en índice
        3. Similitud difusa (fuzzy matching)
        4. Análisis de contexto semántico
        """
        relevant = set()
        
        # Estrategia 1: Coincidencia exacta
        for table_name in self.table_names:
            # Buscar nombre completo o con espacios en lugar de _
            table_variants = [
                table_name,
                table_name.replace('_', ' '),
                table_name.replace('_', '')
            ]
            
            for variant in table_variants:
                if variant in message:
                    relevant.add(table_name)
                    break
        
        # Estrategia 2: Búsqueda por palabras clave indexadas
        message_words = self._extract_words_from_identifier(message)
        for word in message_words:
            if word in self.keyword_index:
                relevant.update(self.keyword_index[word])
        
        # Estrategia 3: Similitud difusa (para typos o variaciones)
        if not relevant:
            # Extraer "sustantivos" potenciales (palabras largas)
            potential_nouns = [w for w in message.split() if len(w) >= 4]
            
            for noun in potential_nouns:
                # Buscar coincidencias cercanas en nombres de tablas
                matches = get_close_matches(
                    noun.lower(), 
                    self.table_names, 
                    n=2, 
                    cutoff=0.6
                )
                relevant.update(matches)
        
        # Estrategia 4: Si aún no hay tablas, usar relaciones FK
        if not relevant:
            # Buscar tablas que tienen más relaciones (probablemente principales)
            central_tables = self._get_central_tables()
            relevant.update(central_tables[:3])  # Top 3 tablas centrales
        
        return relevant
    
    def _get_central_tables(self) -> List[str]:
        """
        Obtener tablas "centrales" basándose en número de relaciones FK.
        Tablas con más FKs son típicamente tablas principales.
        """
        table_scores = {}
        
        for table in self.schema.tables:
            score = len(table.foreign_keys)
            
            # También contar cuántas veces es referenciada por otras tablas
            referenced_count = sum(
                1 for t in self.schema.tables 
                for fk in t.foreign_keys 
                if fk['referenced_table'].lower() == table.table_name.lower()
            )
            
            table_scores[table.table_name.lower()] = score + referenced_count
        
        # Ordenar por score
        sorted_tables = sorted(
            table_scores.items(), 
            key=lambda x: x[1], 
            reverse=True
        )
        
        return [t[0] for t in sorted_tables]
    
    def _extract_mentioned_columns(self, message: str, relevant_tables: Set[str]) -> Dict[str, List[str]]:
        """
        Detectar columnas mencionadas en el mensaje para cada tabla relevante.
        """
        mentioned = {}
        
        for table_name in relevant_tables:
            if table_name not in self.column_index:
                continue
            
            table_columns = self.column_index[table_name]
            mentioned_cols = []
            
            for col in table_columns:
                # Buscar menciones directas o palabras clave de la columna
                col_words = self._extract_words_from_identifier(col)
                
                for word in col_words:
                    if word in message and len(word) > 3:
                        mentioned_cols.append(col)
                        break
            
            if mentioned_cols:
                mentioned[table_name] = mentioned_cols
        
        return mentioned
    
    def _determine_query_type(self, message: str) -> str:
        """Determinar tipo de query basándose en patrones genéricos"""
        
        # Verificar cada tipo en orden de especificidad
        for pattern in self.AGGREGATION_PATTERNS:
            if re.search(pattern, message, re.IGNORECASE):
                return "aggregation"
        
        for pattern in self.ORDER_PATTERNS:
            if re.search(pattern, message, re.IGNORECASE):
                return "top_n"
        
        for pattern in self.JOIN_PATTERNS:
            if re.search(pattern, message, re.IGNORECASE):
                return "join"
        
        for pattern in self.FILTER_PATTERNS:
            if re.search(pattern, message, re.IGNORECASE):
                return "filter"
        
        return "simple_select"
    
    def _extract_filter_hints_dynamic(self, message: str, relevant_tables: Set[str]) -> Dict[str, Any]:
        """
        Extraer hints de filtros de forma dinámica buscando valores específicos.
        """
        hints = {
            "exact_values": [],  # Valores entre comillas
            "numeric_values": [],  # Números mencionados
            "boolean_keywords": []  # activo/inactivo, si/no, verdadero/falso
        }
        
        # Extraer valores entre comillas
        quoted = re.findall(r"['\"]([^'\"]+)['\"]", message)
        hints["exact_values"] = quoted
        
        # Extraer números
        numbers = re.findall(r'\b\d+(?:\.\d+)?\b', message)
        hints["numeric_values"] = [float(n) if '.' in n else int(n) for n in numbers]
        
        # Detectar palabras booleanas
        boolean_keywords = {
            'activo': True, 'inactivo': False,
            'si': True, 'no': False,
            'verdadero': True, 'falso': False,
            'habilitado': True, 'deshabilitado': False,
            'vigente': True, 'vencido': False
        }
        
        for keyword, value in boolean_keywords.items():
            if keyword in message:
                hints["boolean_keywords"].append((keyword, value))
        
        return hints
    
    def _calculate_complexity(self, table_count: int, query_type: str, column_count: int) -> int:
        """Calcular complejidad basándose en factores dinámicos"""
        complexity = 1
        
        if table_count > 1:
            complexity += 1
        if table_count > 3:
            complexity += 1
        if table_count > 5:
            complexity += 1
        
        if query_type == "aggregation":
            complexity += 1
        elif query_type == "join":
            complexity += 1
        elif query_type == "top_n":
            complexity += 1
        
        if column_count > 5:
            complexity += 1
        
        return min(complexity, 5)
    
    def get_focused_context(self, analysis: Dict[str, Any]) -> Dict[str, Any]:
        """
        Generar contexto focalizado con solo información relevante.
        """
        relevant_tables = analysis["relevant_tables"]
        
        # Expandir con tablas relacionadas vía FK
        expanded_tables = self._expand_with_related_tables(relevant_tables)
        
        focused_schema = {
            "tables": [],
            "relationships": [],
            "total_tables_in_db": len(self.schema.tables),
            "focused_table_count": len(expanded_tables)
        }
        
        for table_name in expanded_tables:
            if table_name in self.table_dict:
                table = self.table_dict[table_name]
                focused_schema["tables"].append(table)
                
                # Extraer relaciones
                for fk in table.foreign_keys:
                    focused_schema["relationships"].append({
                        "from_table": table_name,
                        "from_column": fk["column"],
                        "to_table": fk["referenced_table"],
                        "to_column": fk["referenced_column"]
                    })
        
        return focused_schema
    
    def _expand_with_related_tables(self, tables: Set[str]) -> Set[str]:
        """Expandir incluyendo tablas relacionadas vía FK"""
        expanded = set(tables)
        
        # Agregar tablas referenciadas (nivel 1)
        for table_name in list(tables):
            if table_name in self.table_dict:
                table = self.table_dict[table_name]
                
                for fk in table.foreign_keys:
                    expanded.add(fk["referenced_table"].lower())
        
        # Agregar tablas que referencian a las actuales (nivel 1 inverso)
        for table_name in list(tables):
            for table in self.schema.tables:
                for fk in table.foreign_keys:
                    if fk["referenced_table"].lower() == table_name:
                        expanded.add(table.table_name.lower())
        
        return expanded
    
    def generate_example_queries(self, analysis: Dict[str, Any]) -> List[str]:
        """
        Generar ejemplos DINÁMICOS basados en las tablas detectadas.
        """
        examples = []
        query_type = analysis["query_type"]
        relevant_tables = list(analysis["relevant_tables"])
        
        if not relevant_tables:
            return []
        
        # Obtener primera tabla relevante
        first_table = relevant_tables[0]
        table_obj = self.table_dict.get(first_table)
        
        if not table_obj:
            return []
        
        # Obtener columnas de ejemplo
        columns = [col['name'] for col in table_obj.columns[:3]]
        pk = table_obj.primary_keys[0] if table_obj.primary_keys else columns[0]
        
        if query_type == "simple_select":
            examples.append(f"SELECT * FROM {first_table} LIMIT 10")
            if len(columns) >= 2:
                examples.append(f"SELECT {columns[0]}, {columns[1]} FROM {first_table}")
        
        elif query_type == "aggregation":
            examples.append(f"SELECT COUNT(*) FROM {first_table}")
            examples.append(f"SELECT COUNT(*), {columns[0]} FROM {first_table} GROUP BY {columns[0]}")
        
        elif query_type == "join" and len(relevant_tables) > 1:
            second_table = relevant_tables[1]
            # Buscar FK entre las dos tablas
            fk_info = self._find_fk_between_tables(first_table, second_table)
            if fk_info:
                examples.append(
                    f"SELECT t1.*, t2.* FROM {first_table} t1 "
                    f"JOIN {second_table} t2 ON t1.{fk_info['from_col']} = t2.{fk_info['to_col']}"
                )
        
        elif query_type == "top_n":
            if len(columns) >= 2:
                examples.append(
                    f"SELECT {columns[0]}, {columns[1]} FROM {first_table} "
                    f"ORDER BY {columns[1]} DESC LIMIT 5"
                )
        
        return examples[:3]
    
    def _find_fk_between_tables(self, table1: str, table2: str) -> Dict[str, str]:
        """Buscar FK entre dos tablas"""
        table1_obj = self.table_dict.get(table1)
        
        if not table1_obj:
            return None
        
        for fk in table1_obj.foreign_keys:
            if fk['referenced_table'].lower() == table2:
                return {
                    'from_col': fk['column'],
                    'to_col': fk['referenced_column']
                }
        
        # Buscar en sentido inverso
        table2_obj = self.table_dict.get(table2)
        if table2_obj:
            for fk in table2_obj.foreign_keys:
                if fk['referenced_table'].lower() == table1:
                    return {
                        'from_col': fk['referenced_column'],
                        'to_col': fk['column']
                    }
        
        return None