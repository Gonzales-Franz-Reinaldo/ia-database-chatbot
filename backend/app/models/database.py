from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from enum import Enum

class DatabaseType(str, Enum):
    POSTGRESQL = "postgresql"
    MYSQL = "mysql"

class DatabaseConnection(BaseModel):
    type: DatabaseType
    host: str
    port: int
    database: str
    username: str
    password: str

class TableSchema(BaseModel):
    table_name: str
    columns: List[Dict[str, Any]]
    primary_keys: List[str]
    foreign_keys: List[Dict[str, str]]

class DatabaseSchema(BaseModel):
    database_name: str
    tables: List[TableSchema]

class ChatMessage(BaseModel):
    message: str
    model: str
    database_connection: DatabaseConnection

class QueryResult(BaseModel):
    success: bool
    data: Optional[List[Dict[str, Any]]] = None
    sql_query: Optional[str] = None
    error: Optional[str] = None
    explanation: Optional[str] = None

class OllamaModel(BaseModel):
    name: str
    size: str
    modified_at: str

class LearnDatabaseRequest(BaseModel):
    database_connection: DatabaseConnection
    selected_model: str
