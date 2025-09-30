from typing import List, Dict, Any
import psycopg2
import pymysql
import re
from app.models.database import DatabaseConnection, DatabaseType

class DatabaseService:
    def __init__(self, db_connection: DatabaseConnection):
        self.db_connection = db_connection
    
    def get_connection(self):
        """Crear conexión a la base de datos"""
        if self.db_connection.type == DatabaseType.POSTGRESQL:
            return psycopg2.connect(
                host=self.db_connection.host,
                port=self.db_connection.port,
                database=self.db_connection.database,
                user=self.db_connection.username,
                password=self.db_connection.password
            )
        elif self.db_connection.type == DatabaseType.MYSQL:
            return pymysql.connect(
                host=self.db_connection.host,
                port=self.db_connection.port,
                database=self.db_connection.database,
                user=self.db_connection.username,
                password=self.db_connection.password
            )
    
    def execute_query(self, sql_query: str) -> Dict[str, Any]:
        """Ejecutar consulta SQL y devolver resultados"""
        try:
            # Validar que sea una consulta SELECT segura
            if not self._is_safe_query(sql_query):
                return {
                    "success": False,
                    "error": "Solo se permiten consultas SELECT. Operaciones de modificación están bloqueadas por seguridad.",
                    "data": None
                }
            
            conn = self.get_connection()
            
            if self.db_connection.type == DatabaseType.POSTGRESQL:
                cursor = conn.cursor()
                cursor.execute(sql_query)
                results = cursor.fetchall()
                columns = [desc[0] for desc in cursor.description] if cursor.description else []
            else:  # MySQL
                cursor = conn.cursor(pymysql.cursors.DictCursor)
                cursor.execute(sql_query)
                results = cursor.fetchall()
                columns = list(results[0].keys()) if results else []
            
            cursor.close()
            conn.close()
            
            # Convertir resultados a formato JSON serializable
            formatted_results = []
            for row in results:
                if self.db_connection.type == DatabaseType.POSTGRESQL:
                    row_dict = {}
                    for i, col in enumerate(columns):
                        value = row[i]
                        # Convertir tipos no serializables
                        if hasattr(value, 'isoformat'):  # datetime, date
                            value = value.isoformat()
                        elif isinstance(value, bytes):
                            value = value.decode('utf-8', errors='ignore')
                        elif hasattr(value, '__dict__'):  # Objetos complejos
                            value = str(value)
                        row_dict[col] = value
                    formatted_results.append(row_dict)
                else:  # MySQL ya devuelve dict
                    row_dict = {}
                    for key, value in row.items():
                        if hasattr(value, 'isoformat'):  # datetime, date
                            value = value.isoformat()
                        elif isinstance(value, bytes):
                            value = value.decode('utf-8', errors='ignore')
                        elif hasattr(value, '__dict__'):  # Objetos complejos
                            value = str(value)
                        row_dict[key] = value
                    formatted_results.append(row_dict)
            
            return {
                "success": True,
                "data": formatted_results,
                "columns": columns,
                "row_count": len(formatted_results)
            }
        
        except Exception as e:
            return {
                "success": False,
                "error": f"Error al ejecutar consulta: {str(e)}",
                "data": None
            }
    
    def _is_safe_query(self, sql_query: str) -> bool:
        """Validar que la consulta SQL sea segura (solo SELECT)"""
        # Limpiar la consulta
        cleaned_query = sql_query.strip().upper()
        
        # Verificar que empiece con SELECT
        if not cleaned_query.startswith('SELECT'):
            return False
        
        # Palabras prohibidas que podrían modificar datos
        forbidden_words = [
            'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER',
            'TRUNCATE', 'EXEC', 'EXECUTE', 'CALL', 'GRANT', 'REVOKE',
            'MERGE', 'REPLACE', 'LOAD', 'COPY', 'BULK'
        ]
        
        # Usar regex para buscar palabras completas, no subcadenas
        # Esto evita que "created_at", "updated_at" activen el filtro
        for word in forbidden_words:
            pattern = r'\b' + word + r'\b'
            if re.search(pattern, cleaned_query):
                return False
        
        # Verificar que no contenga subconsultas peligrosas
        dangerous_patterns = [
            r'INTO\s+',  # SELECT INTO
            r'OUTFILE\s+',  # SELECT INTO OUTFILE
            r'DUMPFILE\s+',  # SELECT INTO DUMPFILE
        ]
        
        for pattern in dangerous_patterns:
            if re.search(pattern, cleaned_query):
                return False
        
        return True
    
    def test_connection(self) -> bool:
        """Probar conexión a la base de datos"""
        try:
            conn = self.get_connection()
            conn.close()
            return True
        except Exception:
            return False
    
    def get_sample_data(self, table_name: str, limit: int = 5) -> Dict[str, Any]:
        """Obtener datos de muestra de una tabla"""
        try:
            sql_query = f"SELECT * FROM {table_name} LIMIT {limit}"
            return self.execute_query(sql_query)
        except Exception as e:
            return {
                "success": False,
                "error": f"Error al obtener datos de muestra: {str(e)}",
                "data": None
            }