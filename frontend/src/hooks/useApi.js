import { useState, useEffect, useCallback } from 'react';
import { apiService } from '../services/api';
import { handleApiError } from '../utils/helpers';

/**
 * Hook para manejar llamadas a la API con estado de carga y error
 */
export const useApi = (apiFunction, dependencies = []) => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const execute = useCallback(async (...args) => {
        setLoading(true);
        setError(null);

        try {
            const result = await apiFunction(...args);
            setData(result);
            return result;
        } catch (err) {
            const errorMessage = handleApiError(err);
            setError(errorMessage);
            throw err;
        } finally {
            setLoading(false);
        }
    }, dependencies);

    const reset = () => {
        setData(null);
        setError(null);
        setLoading(false);
    };

    return { data, loading, error, execute, reset };
};

/**
 * Hook para manejar la conexión a base de datos
 */
export const useDatabaseConnection = () => {
    const [connection, setConnection] = useState(null);
    const [isConnected, setIsConnected] = useState(false);

    const { loading: testingConnection, execute: testConnection } = useApi(
        apiService.testDatabaseConnection
    );

    const connect = async (connectionData) => {
        try {
            const result = await testConnection(connectionData);
            if (result.success) {
                setConnection(connectionData);
                setIsConnected(true);
                return { success: true, message: result.message };
            } else {
                setIsConnected(false);
                return { success: false, message: result.message };
            }
        } catch (error) {
            setIsConnected(false);
            return { success: false, message: handleApiError(error) };
        }
    };

    const disconnect = () => {
        setConnection(null);
        setIsConnected(false);
    };

    return {
        connection,
        isConnected,
        testingConnection,
        connect,
        disconnect
    };
};

/**
 * Hook para manejar modelos de Ollama
 */
export const useOllamaModels = () => {
    const [models, setModels] = useState([]);
    const [selectedModel, setSelectedModel] = useState('');

    const { loading, error, execute: loadModels } = useApi(
        apiService.getModels
    );

    const fetchModels = async () => {
        try {
            const modelList = await loadModels();
            setModels(modelList);

            // Auto-seleccionar primer modelo si no hay ninguno seleccionado
            if (modelList.length > 0 && !selectedModel) {
                setSelectedModel(modelList[0].name);
            }

            return modelList;
        } catch (err) {
            console.error('Error loading models:', err);
            return [];
        }
    };

    useEffect(() => {
        fetchModels();
    }, []);

    const selectModel = (modelName) => {
        setSelectedModel(modelName);
    };

    return {
        models,
        selectedModel,
        loading,
        error,
        fetchModels,
        selectModel
    };
};

/**
 * Hook para manejar el esquema de base de datos
 */
export const useDatabaseSchema = (connection) => {
    const [schema, setSchema] = useState(null);

    const {
        loading: analyzingSchema,
        error: schemaError,
        execute: analyzeSchema
    } = useApi(apiService.analyzeDatabaseSchema, [connection]);

    const loadSchema = async () => {
        if (!connection) return null;

        try {
            const schemaData = await analyzeSchema(connection);
            setSchema(schemaData);
            return schemaData;
        } catch (err) {
            console.error('Error analyzing schema:', err);
            setSchema(null);
            return null;
        }
    };

    const clearSchema = () => {
        setSchema(null);
    };

    useEffect(() => {
        if (connection) {
            loadSchema();
        } else {
            clearSchema();
        }
    }, [connection]);

    return {
        schema,
        analyzingSchema,
        schemaError,
        loadSchema,
        clearSchema
    };
};

/**
 * Hook para manejar el chat
 */
export const useChat = (connection, selectedModel) => {
    const [messages, setMessages] = useState([
        {
            id: 1,
            type: 'bot',
            content: '¡Hola! Soy tu asistente de base de datos con IA. Puedes hacerme preguntas sobre los datos y generaré consultas SQL para ti.',
            timestamp: new Date()
        }
    ]);

    const {
        loading: sendingMessage,
        execute: sendChatMessage
    } = useApi(apiService.sendChatMessage);

    const addMessage = (message) => {
        setMessages(prev => [...prev, { ...message, id: Date.now() }]);
    };

    const sendMessage = async (content) => {
        if (!connection || !selectedModel || !content.trim()) {
            return;
        }

        // Agregar mensaje del usuario
        const userMessage = {
            type: 'user',
            content: content.trim(),
            timestamp: new Date()
        };
        addMessage(userMessage);

        try {
            // Enviar a la API
            const response = await sendChatMessage(content, selectedModel, connection);

            // Agregar respuesta del bot
            const botMessage = {
                type: 'bot',
                content: response.success ? 'Consulta ejecutada exitosamente' : 'Error en la consulta',
                sqlQuery: response.sql_query,
                explanation: response.explanation,
                data: response.data,
                error: response.error,
                success: response.success,
                timestamp: new Date()
            };
            addMessage(botMessage);

            return response;
        } catch (error) {
            const errorMessage = {
                type: 'bot',
                content: 'Error al procesar tu mensaje',
                error: handleApiError(error),
                success: false,
                timestamp: new Date()
            };
            addMessage(errorMessage);
            throw error;
        }
    };

    const clearChat = () => {
        setMessages([
            {
                id: 1,
                type: 'bot',
                content: '¡Hola! Soy tu asistente de base de datos con IA. Puedes hacerme preguntas sobre los datos y generaré consultas SQL para ti.',
                timestamp: new Date()
            }
        ]);
    };

    return {
        messages,
        sendingMessage,
        sendMessage,
        clearChat,
        addMessage
    };
};

/**
 * Hook para localStorage persistente
 */
export const useLocalStorage = (key, initialValue) => {
    const [storedValue, setStoredValue] = useState(() => {
        try {
            const item = window.localStorage.getItem(key);
            return item ? JSON.parse(item) : initialValue;
        } catch (error) {
            console.error(`Error reading localStorage key "${key}":`, error);
            return initialValue;
        }
    });

    const setValue = (value) => {
        try {
            setStoredValue(value);
            window.localStorage.setItem(key, JSON.stringify(value));
        } catch (error) {
            console.error(`Error setting localStorage key "${key}":`, error);
        }
    };

    const removeValue = () => {
        try {
            setStoredValue(initialValue);
            window.localStorage.removeItem(key);
        } catch (error) {
            console.error(`Error removing localStorage key "${key}":`, error);
        }
    };

    return [storedValue, setValue, removeValue];
};