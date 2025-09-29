# AI Database Chatbot

Una aplicación web completa que permite consultar bases de datos usando modelos de IA locales a través de Ollama. El sistema implementa RAG (Retrieval-Augmented Generation) con ejecución dinámica de SQL.

## 🚀 Características

- **Conexión a múltiples tipos de BD**: PostgreSQL y MySQL
- **Análisis automático de esquemas**: Extrae estructura completa de la base de datos
- **Múltiples modelos de IA**: Compatible con todos los modelos de Ollama
- **Interfaz intuitiva**: Chat en tiempo real con resultados tabulares
- **Consultas SQL automáticas**: Genera y ejecuta consultas basadas en preguntas naturales
- **Completamente local**: Sin envío de datos a servicios externos

## 🏗️ Arquitectura

```
Frontend (React + Tailwind)  ←→  Backend (FastAPI)  ←→  Ollama  ←→  Base de Datos
```

### Backend (FastAPI)
- **Schema Analyzer**: Extrae estructura de la BD automáticamente
- **Ollama Service**: Comunicación con modelos de IA locales
- **Database Service**: Ejecución segura de consultas SQL
- **API REST**: Endpoints para todas las operaciones

### Frontend (React)
- **Database Connection**: Configuración de conexión a BD
- **Schema Viewer**: Visualización del esquema de datos
- **Model Selector**: Selección de modelos de Ollama
- **Chatbot**: Interface conversacional con la IA

## 📋 Requisitos Previos

### Backend
- Python 3.11+
- PostgreSQL y/o MySQL
- Ollama instalado y ejecutándose

### Frontend
- Node.js 22+
- npm o yarn

### Modelos de IA
```bash
# Instalar modelos en Ollama
ollama pull gemma2:7b
ollama pull deepseek-coder:6.7b
ollama pull qwen2.5:7b
ollama pull deepseek-r1:1.5b
```

## 🛠️ Instalación

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd ai-database-chatbot
```

### 2. Configurar Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Configurar variables de entorno
```bash
cp .env.example .env
# Editar .env con tus configuraciones
```

### 4. Configurar Frontend
```bash
cd ../frontend
npm install
```

### 5. Inicializar Tailwind CSS
```bash
npx tailwindcss init -p
```

## 🚀 Ejecución

### Backend
```bash
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend
```bash
cd frontend
npm start
```

### Ollama (si no está ejecutándose)
```bash
ollama serve
```

## 📖 Uso

### 1. **Conectar Base de Datos**
- Selecciona PostgreSQL o MySQL
- Ingresa credenciales de conexión
- Prueba la conexión

### 2. **Visualizar Esquema**
- El sistema analiza automáticamente las tablas
- Ve columnas, tipos de datos, claves primarias y foráneas
- Explora datos de muestra

### 3. **Seleccionar Modelo de IA**
- Elige entre los modelos disponibles de Ollama
- Recomendado: DeepSeek Coder para consultas SQL

### 4. **Chatear con la IA**
- Haz preguntas en lenguaje natural
- La IA genera y ejecuta consultas SQL
- Ve resultados en tiempo real

## 💬 Ejemplos de Consultas

```
"¿Cuáles son las mejores notas?"
"Muestra todos los estudiantes del curso de matemáticas"
"Dame el promedio de ventas por mes"
"¿Cuántos usuarios hay en cada categoría?"
"Encuentra los productos más vendidos"
```

## 🔧 API Endpoints

### Backend API (Puerto 8000)
- `GET /api/v1/models` - Obtener modelos de Ollama
- `POST /api/v1/test-connection` - Probar conexión a BD
- `POST /api/v1/analyze-schema` - Analizar esquema de BD
- `POST /api/v1/chat` - Procesar mensaje de chat
- `POST /api/v1/execute-sql` - Ejecutar SQL directamente
- `GET /api/v1/health` - Estado del servicio

## 🔒 Seguridad

- **Solo consultas SELECT**: Bloquea operaciones de modificación
- **Validación de consultas**: Sanitización de SQL antes de ejecutar
- **Conexiones seguras**: Manejo seguro de credenciales
- **Datos locales**: Toda la IA se ejecuta localmente

## 🎨 Personalización

### Agregar nuevos tipos de BD
1. Extender enum `DatabaseType` en `models/database.py`
2. Implementar driver en `services/schema_analyzer.py`
3. Actualizar selector en frontend

### Personalizar prompts de IA
Editar `_create_sql_prompt()` en `services/ollama_service.py`

### Modificar UI
Componentes están en `frontend/src/components/`
Estilos en `frontend/src/App.css`

## 🐛 Solución de Problemas

### Backend no se conecta a la BD
- Verificar credenciales en `.env`
- Comprobar que la BD esté ejecutándose
- Revisar puertos y firewalls

### Ollama no responde
```bash
# Verificar que Ollama esté ejecutándose
ollama list
ollama serve
```

### Frontend no se conecta al Backend
- Verificar que el backend esté en puerto 8000
- Comprobar configuración de CORS
- Revisar proxy en `package.json`

## 📝 Logs y Debugging

### Backend
```bash
# Ejecutar con logs detallados
uvicorn app.main:app --reload --log-level debug
```

### Frontend
```bash
# Consola del navegador para errores de React
# Network tab para errores de API
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 🙏 Agradecimientos

- **Ollama** - Por hacer la IA local accesible
- **FastAPI** - Por el excelente framework de API
- **React** - Por la interfaz de usuario
- **Tailwind CSS** - Por el diseño moderno

## 📞 Soporte

Si tienes problemas o preguntas:

1. Revisa la sección de solución de problemas
2. Busca en los issues existentes
3. Crea un nuevo issue con detalles del problema

---

**¡Disfruta consultando tus bases de datos con IA! 🚀**