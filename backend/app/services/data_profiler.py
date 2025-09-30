"""
Servicio de perfilado de datos para analizar y extraer información detallada
sobre los valores reales en las columnas de la base de datos.
"""
from typing import Dict, List, Any
import psycopg2
import pymysql
from app.models.database import DatabaseConnection, DatabaseType


class DataProfiler:
    """
    Analiza y perfila datos de la base de datos para proporcionar
    contexto más rico al modelo de IA.
    """
    
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
    
    def profile_column(self, table_name: str, column_name: str, column_type: str) -> Dict[str, Any]:
        """
        Perfilar una columna específica para obtener valores únicos,
        estadísticas y ejemplos reales.
        """
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            profile = {
                "unique_values": None,
                "sample_values": [],
                "total_count": 0,
                "null_count": 0,
                "distinct_count": 0,
                "value_distribution": {}
            }
            
            # Contar total de registros
            cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            profile["total_count"] = cursor.fetchone()[0]
            
            # Contar valores nulos
            cursor.execute(f"SELECT COUNT(*) FROM {table_name} WHERE {column_name} IS NULL")
            profile["null_count"] = cursor.fetchone()[0]
            
            # Contar valores distintos
            cursor.execute(f"SELECT COUNT(DISTINCT {column_name}) FROM {table_name} WHERE {column_name} IS NOT NULL")
            profile["distinct_count"] = cursor.fetchone()[0]
            
            # Si hay pocos valores únicos (columna categórica), obtenerlos todos
            if profile["distinct_count"] <= 20 and profile["distinct_count"] > 0:
                # Obtener todos los valores únicos con su frecuencia
                cursor.execute(f"""
                    SELECT {column_name}, COUNT(*) as count 
                    FROM {table_name} 
                    WHERE {column_name} IS NOT NULL 
                    GROUP BY {column_name} 
                    ORDER BY count DESC
                    LIMIT 20
                """)
                
                unique_vals = []
                value_dist = {}
                for row in cursor.fetchall():
                    value = row[0]
                    count = row[1]
                    unique_vals.append(value)
                    value_dist[str(value)] = count
                
                profile["unique_values"] = unique_vals
                profile["value_distribution"] = value_dist
            else:
                # Para columnas con muchos valores, solo obtener ejemplos
                cursor.execute(f"""
                    SELECT DISTINCT {column_name} 
                    FROM {table_name} 
                    WHERE {column_name} IS NOT NULL 
                    LIMIT 5
                """)
                profile["sample_values"] = [row[0] for row in cursor.fetchall()]
            
            cursor.close()
            conn.close()
            
            return profile
            
        except Exception as e:
            print(f"❌ Error perfilando columna {table_name}.{column_name}: {str(e)}")
            return {
                "unique_values": None,
                "sample_values": [],
                "total_count": 0,
                "null_count": 0,
                "distinct_count": 0,
                "value_distribution": {}
            }
    
    def profile_table(self, table_name: str, columns: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Perfilar una tabla completa, analizando columnas categóricas
        y obteniendo estadísticas generales.
        """
        table_profile = {
            "table_name": table_name,
            "columns_profile": {},
            "row_count": 0
        }
        
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            # Contar filas totales
            cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            table_profile["row_count"] = cursor.fetchone()[0]
            
            cursor.close()
            conn.close()
            
            # Perfilar cada columna (solo las categóricas o pequeñas)
            for column in columns:
                col_name = column["name"]
                col_type = column["type"].lower()
                
                # Perfilar columnas categóricas (char, varchar pequeños, enums, etc.)
                should_profile = (
                    "char" in col_type or 
                    ("varchar" in col_type and column.get("max_length", 0) <= 50) or
                    "enum" in col_type or
                    "boolean" in col_type or
                    "bool" in col_type
                )
                
                if should_profile:
                    profile = self.profile_column(table_name, col_name, col_type)
                    if profile["unique_values"] or profile["sample_values"]:
                        table_profile["columns_profile"][col_name] = profile
            
            return table_profile
            
        except Exception as e:
            print(f"❌ Error perfilando tabla {table_name}: {str(e)}")
            return table_profile
    
    def profile_database(self, tables: List[Any]) -> Dict[str, Any]:
        """
        Perfilar toda la base de datos, obteniendo información detallada
        de todas las tablas y sus columnas categóricas.
        """
        db_profile = {
            "tables": {}
        }
        
        print(f"🔍 [PROFILER] Iniciando perfilado de base de datos...")
        
        for table in tables:
            print(f"📊 [PROFILER] Perfilando tabla: {table.table_name}")
            table_profile = self.profile_table(table.table_name, table.columns)
            db_profile["tables"][table.table_name] = table_profile
        
        print(f"✅ [PROFILER] Perfilado completado para {len(tables)} tablas")
        
        return db_profile