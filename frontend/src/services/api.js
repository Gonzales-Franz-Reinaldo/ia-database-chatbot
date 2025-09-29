import axios from 'axios';


const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
    timeout: 60000, // 60 segundos para consultas que pueden tardar
});

// Interceptor para manejar errores globalmente
api.interceptors.response.use(
    (response) => response,
    (error) => {
        console.error('API Error:', error);
        if (error.code === 'ECONNABORTED') {
            throw new Error('Timeout: La consulta está tardando demasiado');
        }
        throw error;
    }
);

export const apiService = {
    // Obtener modelos disponibles de Ollama
    async getModels() {
        try {
            const response = await api.get('/models');
            return response.data;
        } catch (error) {
            throw new Error('Error al obtener modelos de Ollama: ' + error.message);
        }
    },

    // Probar conexión a base de datos
    async testDatabaseConnection(connectionData) {
        try {
            const response = await api.post('/test-connection', connectionData);
            return response.data;
        } catch (error) {
            throw new Error('Error al probar conexión: ' + error.message);
        }
    },

    // Analizar esquema de base de datos
    async analyzeDatabaseSchema(connectionData) {
        try {
            const response = await api.post('/analyze-schema', connectionData);
            return response.data;
        } catch (error) {
            throw new Error('Error al analizar esquema: ' + error.message);
        }
    },

    // Obtener datos de muestra de una tabla
    async getSampleData(connectionData, tableName, limit = 5) {
        try {
            const response = await api.post(`/sample-data?table_name=${tableName}&limit=${limit}`, connectionData);
            return response.data;
        } catch (error) {
            throw new Error('Error al obtener datos de muestra: ' + error.message);
        }
    },

    // Enviar mensaje de chat y obtener respuesta con consulta SQL
    async sendChatMessage(message, model, databaseConnection) {
        try {
            const chatData = {
                message,
                model,
                database_connection: databaseConnection
            };

            const response = await api.post('/chat', chatData);
            return response.data;
        } catch (error) {
            throw new Error('Error en chat: ' + error.message);
        }
    },

    // Ejecutar consulta SQL directamente
    async executeSQL(connectionData, sqlQuery) {
        try {
            const response = await api.post(`/execute-sql?sql_query=${encodeURIComponent(sqlQuery)}`, connectionData);
            return response.data;
        } catch (error) {
            throw new Error('Error al ejecutar SQL: ' + error.message);
        }
    },

    // Verificar estado del servidor
    async healthCheck() {
        try {
            const response = await api.get('/health');
            return response.data;
        } catch (error) {
            throw new Error('Error en verificación de salud: ' + error.message);
        }
    }
};

export default apiService;