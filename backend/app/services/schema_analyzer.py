from typing import List, Dict, Any
import psycopg2
import pymysql
from app.models.database import DatabaseConnection, DatabaseSchema, TableSchema, DatabaseType

class SchemaAnalyzer:
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
    
    def analyze_schema(self) -> DatabaseSchema:
        """Analizar el esquema completo de la base de datos"""
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            tables = self._get_tables(cursor)
            table_schemas = []
            
            for table_name in tables:
                columns = self._get_columns(cursor, table_name)
                primary_keys = self._get_primary_keys(cursor, table_name)
                foreign_keys = self._get_foreign_keys(cursor, table_name)
                
                table_schema = TableSchema(
                    table_name=table_name,
                    columns=columns,
                    primary_keys=primary_keys,
                    foreign_keys=foreign_keys
                )
                table_schemas.append(table_schema)
            
            cursor.close()
            conn.close()
            
            return DatabaseSchema(
                database_name=self.db_connection.database,
                tables=table_schemas
            )
        except Exception as e:
            raise Exception(f"Error al analizar el esquema: {str(e)}")
    
    def _get_tables(self, cursor) -> List[str]:
        """Obtener lista de tablas"""
        if self.db_connection.type == DatabaseType.POSTGRESQL:
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)
        else:  # MySQL
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = %s
                ORDER BY table_name
            """, (self.db_connection.database,))
        
        return [row[0] for row in cursor.fetchall()]
    
    def _get_columns(self, cursor, table_name: str) -> List[Dict[str, Any]]:
        """Obtener información de las columnas de una tabla"""
        if self.db_connection.type == DatabaseType.POSTGRESQL:
            cursor.execute("""
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default,
                    character_maximum_length
                FROM information_schema.columns 
                WHERE table_name = %s 
                AND table_schema = 'public'
                ORDER BY ordinal_position
            """, (table_name,))
        else:  # MySQL
            cursor.execute("""
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default,
                    character_maximum_length
                FROM information_schema.columns 
                WHERE table_name = %s 
                AND table_schema = %s
                ORDER BY ordinal_position
            """, (table_name, self.db_connection.database))
        
        columns = []
        for row in cursor.fetchall():
            columns.append({
                "name": row[0],
                "type": row[1],
                "nullable": row[2] == "YES",
                "default": row[3],
                "max_length": row[4]
            })
        
        return columns
    
    def _get_primary_keys(self, cursor, table_name: str) -> List[str]:
        """Obtener claves primarias de una tabla"""
        if self.db_connection.type == DatabaseType.POSTGRESQL:
            cursor.execute("""
                SELECT kc.column_name
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kc 
                ON tc.constraint_name = kc.constraint_name
                WHERE tc.table_name = %s 
                AND tc.constraint_type = 'PRIMARY KEY'
                AND tc.table_schema = 'public'
            """, (table_name,))
        else:  # MySQL
            cursor.execute("""
                SELECT kc.column_name
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kc 
                ON tc.constraint_name = kc.constraint_name
                WHERE tc.table_name = %s 
                AND tc.constraint_type = 'PRIMARY KEY'
                AND tc.table_schema = %s
            """, (table_name, self.db_connection.database))
        
        return [row[0] for row in cursor.fetchall()]
    
    def _get_foreign_keys(self, cursor, table_name: str) -> List[Dict[str, str]]:
        """Obtener claves foráneas de una tabla"""
        if self.db_connection.type == DatabaseType.POSTGRESQL:
            cursor.execute("""
                SELECT 
                    kc.column_name,
                    rc.referenced_table_name,
                    rc.referenced_column_name
                FROM information_schema.key_column_usage kc
                JOIN information_schema.referential_constraints rc 
                ON kc.constraint_name = rc.constraint_name
                WHERE kc.table_name = %s 
                AND kc.table_schema = 'public'
            """, (table_name,))
        else:  # MySQL
            cursor.execute("""
                SELECT 
                    kc.column_name,
                    kc.referenced_table_name,
                    kc.referenced_column_name
                FROM information_schema.key_column_usage kc
                WHERE kc.table_name = %s 
                AND kc.table_schema = %s
                AND kc.referenced_table_name IS NOT NULL
            """, (table_name, self.db_connection.database))
        
        foreign_keys = []
        for row in cursor.fetchall():
            foreign_keys.append({
                "column": row[0],
                "referenced_table": row[1],
                "referenced_column": row[2]
            })
        
        return foreign_keys
    
    def test_connection(self) -> bool:
        """Probar conexión a la base de datos"""
        try:
            conn = self.get_connection()
            conn.close()
            return True
        except Exception:
            return False