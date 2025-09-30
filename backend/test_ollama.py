#!/usr/bin/env python3
"""
Script para probar la conectividad y respuesta de Ollama
"""
import asyncio
import httpx
import time

async def test_ollama_connection():
    """Probar conexión básica con Ollama"""
    try:
        print("🔍 Probando conexión con Ollama...")
        
        async with httpx.AsyncClient(timeout=10.0) as client:
            # 1. Probar que Ollama esté corriendo
            response = await client.get("http://localhost:11434/api/tags")
            if response.status_code == 200:
                models = response.json().get("models", [])
                print(f"✅ Ollama está corriendo con {len(models)} modelos:")
                for model in models[:3]:  # Solo mostrar primeros 3
                    print(f"   - {model['name']}")
                
                # 2. Probar una consulta simple con el primer modelo
                if models:
                    test_model = models[0]["name"]
                    print(f"\n🧠 Probando modelo: {test_model}")
                    
                    start_time = time.time()
                    test_response = await client.post(
                        "http://localhost:11434/api/generate",
                        json={
                            "model": test_model,
                            "prompt": "Responde solo 'FUNCIONANDO' si entiendes este mensaje.",
                            "stream": False,
                            "options": {
                                "temperature": 0.1,
                                "num_predict": 50
                            }
                        }
                    )
                    end_time = time.time()
                    
                    if test_response.status_code == 200:
                        result = test_response.json()
                        ai_response = result.get("response", "")
                        print(f"✅ Respuesta en {end_time - start_time:.1f}s: {ai_response[:100]}")
                        return True
                    else:
                        print(f"❌ Error en generación: {test_response.status_code}")
                        return False
                else:
                    print("❌ No hay modelos disponibles en Ollama")
                    return False
            else:
                print(f"❌ Ollama no responde: {response.status_code}")
                return False
                
    except Exception as e:
        print(f"❌ Error conectando con Ollama: {str(e)}")
        print("   Asegúrate de que Ollama esté corriendo: ollama serve")
        return False

async def test_database_learning_simulation():
    """Simular el proceso de aprendizaje con datos mínimos"""
    try:
        print("\n📚 Simulando aprendizaje de base de datos...")
        
        # Datos simulados mínimos
        simple_prompt = """Aprende esta base de datos 'test_db' para generar consultas SQL.

ESQUEMA COMPACTO:
Tabla: usuarios
Columnas: id(integer)[PK], nombre(varchar)[NOT NULL], email(varchar)
Ejemplo: id='1', nombre='Juan', email='juan@test.com'

REGLAS:
1. Solo genera consultas SELECT
2. Usa nombres exactos de tablas/columnas

Responde: 'APRENDIDO - base de datos con 1 tabla usuarios'"""

        async with httpx.AsyncClient(timeout=30.0) as client:
            # Obtener primer modelo disponible
            models_response = await client.get("http://localhost:11434/api/tags")
            if models_response.status_code != 200:
                print("❌ No se pueden obtener modelos")
                return False
                
            models = models_response.json().get("models", [])
            if not models:
                print("❌ No hay modelos disponibles")
                return False
                
            test_model = models[0]["name"]
            print(f"🧠 Usando modelo: {test_model}")
            
            start_time = time.time()
            response = await client.post(
                "http://localhost:11434/api/generate",
                json={
                    "model": test_model,
                    "prompt": simple_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.1,
                        "top_p": 0.8,
                        "num_predict": 200,
                        "stop": ["\n\n"]
                    }
                }
            )
            end_time = time.time()
            
            if response.status_code == 200:
                result = response.json()
                ai_response = result.get("response", "")
                print(f"✅ Aprendizaje simulado completado en {end_time - start_time:.1f}s")
                print(f"   Respuesta: {ai_response[:200]}")
                return True
            else:
                print(f"❌ Error en aprendizaje simulado: {response.status_code}")
                return False
                
    except Exception as e:
        print(f"❌ Error en simulación: {str(e)}")
        return False

async def main():
    print("🚀 PRUEBA DE OLLAMA PARA AI DATABASE CHATBOT")
    print("=" * 50)
    
    # Prueba 1: Conexión básica
    if not await test_ollama_connection():
        return
    
    # Prueba 2: Simulación de aprendizaje
    if not await test_database_learning_simulation():
        return
        
    print("\n✅ TODAS LAS PRUEBAS PASARON!")
    print("Tu setup de Ollama está listo para el aprendizaje de bases de datos.")

if __name__ == "__main__":
    asyncio.run(main())