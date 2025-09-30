#!/usr/bin/env python3
"""
Script para probar la extracción de SQL de respuestas de IA
"""
import re
from typing import Optional

def extract_sql_query(response: str) -> Optional[str]:
    """Extraer consulta SQL de la respuesta de la IA con múltiples patrones"""
    print(f"🔍 [DEBUG] Extrayendo SQL de respuesta de {len(response)} caracteres")
    
    patterns = [
        # Patrón 1: SQL: seguido de consulta
        r'SQL:\s*(.*?)(?=EXPLICACIÓN:|EXPLICACION:|$)',
        # Patrón 2: SELECT en bloque de código
        r'```(?:sql)?\s*(SELECT.*?)```',
        # Patrón 3: SELECT directo sin formato
        r'(SELECT\s+.*?)(?=\n\n|\nEXPLIC|$)',
        # Patrón 4: Cualquier SELECT hasta punto y coma o fin
        r'(SELECT\s+.*?);?(?=\s*$|\s*\n)',
        # Patrón 5: SELECT en cualquier lugar
        r'(SELECT\s+[^;]*)',
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
    return None

# Casos de prueba
test_cases = [
    """SQL: SELECT * FROM usuarios WHERE activo = 1
EXPLICACIÓN: Esta consulta obtiene todos los usuarios activos""",
    
    """```sql
SELECT nombre, email FROM estudiantes ORDER BY nombre
```
Esta consulta lista estudiantes ordenados por nombre""",
    
    """La consulta sería:
SELECT COUNT(*) FROM productos
para contar todos los productos""",
    
    """Puedes usar esta consulta SQL:
SELECT id, nombre FROM categorias WHERE tipo = 'activo';
Esto te dará las categorías activas.""",
]

print("🧪 PROBANDO EXTRACCIÓN DE SQL")
print("=" * 50)

for i, case in enumerate(test_cases, 1):
    print(f"\n📋 Caso de prueba {i}:")
    print(f"Input: {case[:100]}...")
    result = extract_sql_query(case)
    print(f"Resultado: {result}")
    print("-" * 30)