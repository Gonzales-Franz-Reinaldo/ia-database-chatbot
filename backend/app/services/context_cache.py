"""
Sistema de caché para almacenar esquemas de base de datos y perfiles
en memoria para evitar recalcularlos en cada request.
"""
from typing import Dict, Any, Optional
from datetime import datetime, timedelta
import hashlib
import json


class ContextCache:
    """
    Caché en memoria para esquemas y perfiles de bases de datos.
    Usa un hash de la conexión como clave para identificar cada BD.
    """
    
    def __init__(self, ttl_minutes: int = 30):
        """
        Inicializar caché con tiempo de vida configurable.
        
        Args:
            ttl_minutes: Minutos que permanece el contexto en caché antes de expirar
        """
        self._cache: Dict[str, Dict[str, Any]] = {}
        self._ttl = timedelta(minutes=ttl_minutes)
    
    def _generate_key(self, connection_data: Dict[str, Any]) -> str:
        """
        Generar clave única para una conexión de base de datos.
        """
        # Crear string único con datos de conexión
        connection_str = f"{connection_data.get('type')}_{connection_data.get('host')}_{connection_data.get('port')}_{connection_data.get('database')}_{connection_data.get('username')}"
        
        # Generar hash MD5
        return hashlib.md5(connection_str.encode()).hexdigest()
    
    def get(self, connection_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Obtener contexto del caché si existe y no ha expirado.
        """
        key = self._generate_key(connection_data)
        
        if key in self._cache:
            cached_data = self._cache[key]
            cached_time = cached_data.get("cached_at")
            
            # Verificar si el caché ha expirado
            if cached_time and datetime.now() - cached_time < self._ttl:
                print(f"✅ [CACHE] Usando contexto en caché para {connection_data.get('database')}")
                return cached_data.get("context")
            else:
                # Caché expirado, eliminarlo
                print(f"⏰ [CACHE] Caché expirado para {connection_data.get('database')}")
                del self._cache[key]
        
        print(f"❌ [CACHE] No hay caché disponible para {connection_data.get('database')}")
        return None
    
    def set(self, connection_data: Dict[str, Any], context: Dict[str, Any]) -> None:
        """
        Guardar contexto en el caché.
        """
        key = self._generate_key(connection_data)
        
        self._cache[key] = {
            "context": context,
            "cached_at": datetime.now(),
            "database": connection_data.get('database')
        }
        
        print(f"💾 [CACHE] Contexto almacenado en caché para {connection_data.get('database')}")
    
    def invalidate(self, connection_data: Dict[str, Any]) -> None:
        """
        Invalidar (eliminar) contexto del caché.
        """
        key = self._generate_key(connection_data)
        
        if key in self._cache:
            del self._cache[key]
            print(f"🗑️ [CACHE] Caché invalidado para {connection_data.get('database')}")
    
    def clear_all(self) -> None:
        """
        Limpiar todo el caché.
        """
        self._cache.clear()
        print(f"🧹 [CACHE] Todo el caché ha sido limpiado")
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Obtener estadísticas del caché.
        """
        return {
            "total_cached": len(self._cache),
            "databases": [data["database"] for data in self._cache.values()],
            "ttl_minutes": self._ttl.total_seconds() / 60
        }


# Instancia global del caché
context_cache = ContextCache(ttl_minutes=30)