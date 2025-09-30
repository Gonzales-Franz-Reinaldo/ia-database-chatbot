import React, { useState, useRef, useEffect } from 'react';
import { Send, Bot, User, Database, Code, Copy, CheckCircle, AlertCircle, Loader2, Brain, Zap, RefreshCw, Power } from 'lucide-react';
import { apiService } from '../services/api';

const Chatbot = ({ databaseConnection, schema, selectedModel, onDisconnect }) => {
    const [messages, setMessages] = useState([
        {
            id: 1,
            type: 'bot',
            content: '¡Hola! Soy tu asistente de base de datos con IA. Puedo ayudarte a consultar tus datos usando lenguaje natural. ¿Qué te gustaría saber?',
            timestamp: new Date()
        }
    ]);
    const [inputMessage, setInputMessage] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [isRefreshing, setIsRefreshing] = useState(false);
    const [isDisconnecting, setIsDisconnecting] = useState(false);
    const [copiedMessageId, setCopiedMessageId] = useState(null);
    const messagesEndRef = useRef(null);
    const inputRef = useRef(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const handleSendMessage = async () => {
        if (!inputMessage.trim() || isLoading) return;

        if (!databaseConnection) {
            alert('Por favor, conecta una base de datos primero');
            return;
        }

        if (!selectedModel) {
            alert('Por favor, selecciona un modelo de IA');
            return;
        }

        const userMessage = {
            id: Date.now(),
            type: 'user',
            content: inputMessage.trim(),
            timestamp: new Date()
        };

        setMessages(prev => [...prev, userMessage]);
        setInputMessage('');
        setIsLoading(true);

        try {
            const response = await apiService.sendChatMessage(
                userMessage.content,
                selectedModel,
                databaseConnection
            );

            const botMessage = {
                id: Date.now() + 1,
                type: 'bot',
                content: response.success ? 'Consulta ejecutada exitosamente' : 'Error en la consulta',
                sqlQuery: response.sql_query,
                explanation: response.explanation,
                data: response.data,
                error: response.error,
                success: response.success,
                timestamp: new Date()
            };

            setMessages(prev => [...prev, botMessage]);
        } catch (error) {
            const errorMessage = {
                id: Date.now() + 1,
                type: 'bot',
                content: 'Error al procesar tu mensaje',
                error: error.message,
                success: false,
                timestamp: new Date()
            };

            setMessages(prev => [...prev, errorMessage]);
        } finally {
            setIsLoading(false);
        }
    };

    const handleKeyPress = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSendMessage();
        }
    };

    const copyToClipboard = async (text, messageId) => {
        try {
            await navigator.clipboard.writeText(text);
            setCopiedMessageId(messageId);
            setTimeout(() => setCopiedMessageId(null), 2000);
        } catch (error) {
            console.error('Error al copiar:', error);
        }
    };

    const handleRefreshContext = async () => {
        setIsRefreshing(true);
        try {
            const result = await apiService.refreshContext(databaseConnection);
            if (result.success) {
                const refreshMessage = {
                    id: Date.now(),
                    type: 'bot',
                    content: `✨ Contexto actualizado exitosamente. La IA ahora tiene información fresca sobre ${result.tables_analyzed} tablas de tu base de datos.`,
                    success: true,
                    timestamp: new Date()
                };
                setMessages(prev => [...prev, refreshMessage]);
            }
        } catch (error) {
            const errorMessage = {
                id: Date.now(),
                type: 'bot',
                content: 'Error al refrescar el contexto',
                error: error.message,
                success: false,
                timestamp: new Date()
            };
            setMessages(prev => [...prev, errorMessage]);
        } finally {
            setIsRefreshing(false);
        }
    };

    const handleDisconnect = async () => {
        if (!window.confirm('¿Estás seguro de que deseas desconectar? Se borrará el caché y se detendrá el modelo.')) {
            return;
        }

        setIsDisconnecting(true);
        try {
            // Llamar al endpoint de desconectar
            await apiService.disconnect(databaseConnection, selectedModel);
            
            // Mensaje de confirmación
            const disconnectMessage = {
                id: Date.now(),
                type: 'bot',
                content: '🔌 Desconexión exitosa. El caché ha sido limpiado y el modelo detenido. Puedes volver a conectarte cuando quieras.',
                success: true,
                timestamp: new Date()
            };
            setMessages(prev => [...prev, disconnectMessage]);
            
            // Esperar 1 segundo para que el usuario vea el mensaje
            setTimeout(() => {
                onDisconnect();
            }, 1500);
        } catch (error) {
            const errorMessage = {
                id: Date.now(),
                type: 'bot',
                content: 'Error al desconectar',
                error: error.message,
                success: false,
                timestamp: new Date()
            };
            setMessages(prev => [...prev, errorMessage]);
            setIsDisconnecting(false);
        }
    };

    const formatData = (data) => {
        if (!data || data.length === 0) return null;

        const columns = Object.keys(data[0]);

        return (
            <div className="mt-4">
                <h4 className="font-medium text-gray-700 mb-3 flex items-center gap-2">
                    <Database size={16} />
                    Resultados ({data.length} {data.length === 1 ? 'fila' : 'filas'})
                </h4>
                <div className="overflow-x-auto bg-gray-50 rounded-xl border border-gray-200">
                    <table className="min-w-full text-sm">
                        <thead>
                            <tr className="bg-gradient-to-r from-gray-100 to-gray-200 border-b border-gray-300">
                                {columns.map((column) => (
                                    <th key={column} className="px-4 py-3 text-left font-semibold text-gray-700 whitespace-nowrap">
                                        {column}
                                    </th>
                                ))}
                            </tr>
                        </thead>
                        <tbody className="bg-white">
                            {data.slice(0, 10).map((row, index) => (
                                <tr key={index} className="border-b border-gray-100 hover:bg-blue-50 transition-colors">
                                    {columns.map((column) => (
                                        <td key={column} className="px-4 py-3 text-gray-600">
                                            {row[column] !== null ? (
                                                <span className="max-w-xs truncate block">
                                                    {String(row[column])}
                                                </span>
                                            ) : (
                                                <span className="text-gray-400 italic text-xs">null</span>
                                            )}
                                        </td>
                                    ))}
                                </tr>
                            ))}
                        </tbody>
                    </table>
                    {data.length > 10 && (
                        <div className="p-3 text-center text-gray-500 text-sm bg-gradient-to-r from-gray-100 to-gray-200 border-t border-gray-300 font-medium">
                            ... y {data.length - 10} {data.length - 10 === 1 ? 'fila' : 'filas'} más
                        </div>
                    )}
                </div>
            </div>
        );
    };

    const renderMessage = (message) => {
        const isUser = message.type === 'user';

        return (
            <div key={message.id} className={`flex ${isUser ? 'justify-end' : 'justify-start'} mb-6 chat-message`}>
                <div className={`flex gap-3 max-w-4xl w-full ${isUser ? 'flex-row-reverse' : 'flex-row'}`}>
                    {/* Avatar */}
                    <div className={`flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center shadow-lg ${
                        isUser
                            ? 'bg-gradient-to-br from-blue-500 to-blue-600 text-white'
                            : 'bg-gradient-to-br from-purple-500 to-blue-500 text-white'
                    }`}>
                        {isUser ? <User size={18} /> : <Brain size={18} />}
                    </div>

                    {/* Contenido del mensaje */}
                    <div className={`rounded-xl p-4 shadow-sm ${
                        isUser
                            ? 'bg-blue-500 text-white max-w-lg'
                            : 'bg-white border border-gray-200 flex-1'
                    }`}>
                        {/* Mensaje principal */}
                        <div className="mb-2">
                            <p className={`${isUser ? 'text-white' : 'text-gray-800'} leading-relaxed`}>
                                {message.content}
                            </p>
                        </div>

                        {/* Consulta SQL */}
                        {message.sqlQuery && (
                            <div className="mt-4 bg-gray-900 text-green-400 p-4 rounded-lg font-mono text-sm overflow-hidden">
                                <div className="flex items-center justify-between mb-2">
                                    <span className="flex items-center gap-2 text-gray-300 font-semibold">
                                        <Code size={16} />
                                        SQL Query
                                    </span>
                                    <button
                                        onClick={() => copyToClipboard(message.sqlQuery, `sql-${message.id}`)}
                                        className="text-gray-400 hover:text-white transition-colors p-1.5 rounded hover:bg-gray-800"
                                        title="Copiar SQL"
                                    >
                                        {copiedMessageId === `sql-${message.id}` ? (
                                            <CheckCircle size={16} className="text-green-400" />
                                        ) : (
                                            <Copy size={16} />
                                        )}
                                    </button>
                                </div>
                                <pre className="whitespace-pre-wrap text-sm overflow-x-auto">
                                    {message.sqlQuery}
                                </pre>
                            </div>
                        )}

                        {/* Explicación */}
                        {message.explanation && (
                            <div className="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 rounded-r-lg">
                                <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                                    <Zap size={16} />
                                    Explicación
                                </h4>
                                <p className="text-blue-700 text-sm leading-relaxed">
                                    {message.explanation}
                                </p>
                            </div>
                        )}

                        {/* Resultados de datos */}
                        {message.data && formatData(message.data)}

                        {/* Error */}
                        {message.error && !message.success && (
                            <div className="mt-4 p-3 bg-red-50 border-l-4 border-red-400 rounded-r-lg">
                                <div className="flex items-start gap-2">
                                    <AlertCircle className="text-red-500 flex-shrink-0 mt-0.5" size={16} />
                                    <div className="flex-1">
                                        <h4 className="font-medium text-red-800 mb-1">Error:</h4>
                                        <p className="text-red-700 text-sm">{message.error}</p>
                                    </div>
                                </div>
                            </div>
                        )}

                        {/* Timestamp */}
                        <div className={`text-xs mt-3 ${isUser ? 'text-blue-100' : 'text-gray-500'}`}>
                            {message.timestamp.toLocaleTimeString('es-ES', { 
                                hour: '2-digit', 
                                minute: '2-digit' 
                            })}
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    if (!databaseConnection) {
        return (
            <div className="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg p-12 border border-gray-200/50">
                <div className="text-center text-gray-500">
                    <div className="inline-flex items-center justify-center w-20 h-20 bg-gray-100 rounded-full mb-4">
                        <Database size={40} className="text-gray-400" />
                    </div>
                    <h3 className="text-xl font-medium mb-2 text-gray-700">
                        Conecta una Base de Datos
                    </h3>
                    <p className="text-gray-600">
                        Para comenzar a usar el chatbot, primero conecta una base de datos.
                    </p>
                </div>
            </div>
        );
    }

    return (
        <div className="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg flex flex-col h-[700px] border border-gray-200/50 overflow-hidden">
            {/* Header */}
            <div className="border-b border-gray-200/50 p-4 bg-gradient-to-r from-white to-gray-50">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gradient-to-r from-purple-500 to-blue-500 rounded-full flex items-center justify-center shadow-lg">
                            <Bot className="text-white" size={20} />
                        </div>
                        <div>
                            <h2 className="font-semibold text-gray-800 flex items-center gap-2">
                                Chatbot de Base de Datos
                                <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-700">
                                    Activo
                                </span>
                            </h2>
                            <p className="text-sm text-gray-500 truncate max-w-md">
                                {databaseConnection.database} • {selectedModel}
                            </p>
                        </div>
                    </div>
                    
                    {/* Botones de Acción */}
                    <div className="flex items-center gap-2">
                        {/* Botón de Refrescar Contexto */}
                        <button
                            onClick={handleRefreshContext}
                            disabled={isRefreshing || isLoading || isDisconnecting}
                            className="flex items-center gap-2 px-3 py-2 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded-lg transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
                            title="Refrescar contexto de la BD"
                        >
                            <RefreshCw className={isRefreshing ? 'animate-spin' : ''} size={16} />
                            <span className="hidden lg:inline">
                                {isRefreshing ? 'Refrescando...' : 'Refrescar'}
                            </span>
                        </button>
                        
                        {/* Botón de Desconectar */}
                        <button
                            onClick={handleDisconnect}
                            disabled={isDisconnecting || isLoading}
                            className="flex items-center gap-2 px-3 py-2 bg-red-100 hover:bg-red-200 text-red-700 rounded-lg transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed text-sm font-medium"
                            title="Desconectar y limpiar caché"
                        >
                            <Power className={isDisconnecting ? 'animate-pulse' : ''} size={16} />
                            <span className="hidden lg:inline">
                                {isDisconnecting ? 'Desconectando...' : 'Desconectar'}
                            </span>
                        </button>
                    </div>
                </div>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gradient-to-b from-gray-50/50 to-white">
                {messages.map(renderMessage)}

                {/* Loading indicator */}
                {isLoading && (
                    <div className="flex justify-start mb-4">
                        <div className="flex gap-3">
                            <div className="w-10 h-10 rounded-full bg-gradient-to-r from-purple-500 to-blue-500 flex items-center justify-center shadow-lg">
                                <Bot size={18} className="text-white" />
                            </div>
                            <div className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
                                <div className="flex items-center gap-2">
                                    <Loader2 className="animate-spin text-blue-500" size={16} />
                                    <span className="text-gray-600">
                                        Analizando consulta y ejecutando SQL...
                                    </span>
                                </div>
                                <div className="mt-2 flex gap-1">
                                    <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
                                    <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                                    <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                                </div>
                            </div>
                        </div>
                    </div>
                )}

                <div ref={messagesEndRef} />
            </div>

            {/* Input */}
            <div className="border-t border-gray-200/50 p-4 bg-white">
                <div className="flex gap-3">
                    <input
                        ref={inputRef}
                        type="text"
                        value={inputMessage}
                        onChange={(e) => setInputMessage(e.target.value)}
                        onKeyPress={handleKeyPress}
                        placeholder="Pregunta algo sobre tus datos... ej: '¿Cuáles son las mejores notas?'"
                        className="flex-1 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all bg-white text-gray-900 placeholder:text-gray-400"
                        disabled={isLoading}
                    />
                    <button
                        onClick={handleSendMessage}
                        disabled={!inputMessage.trim() || isLoading}
                        className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed transition-all duration-200 flex items-center gap-2 shadow-sm hover:shadow-md transform hover:scale-105 active:scale-95"
                    >
                        <Send size={16} />
                        <span className="hidden sm:inline">Enviar</span>
                    </button>
                </div>

                {/* Ejemplos de consultas */}
                <div className="mt-3">
                    <p className="text-xs text-gray-500 mb-2 font-medium">
                        💡 Ejemplos de consultas:
                    </p>
                    <div className="flex flex-wrap gap-2">
                        {[
                            "¿Cuáles son las mejores notas?",
                            "Muestra todos los estudiantes",
                            "¿Cuántos registros hay por tabla?",
                            "Dame el promedio de notas",
                        ].map((example, index) => (
                            <button
                                key={index}
                                onClick={() => setInputMessage(example)}
                                className="text-xs bg-gray-100 hover:bg-blue-100 hover:text-blue-700 text-gray-600 px-3 py-1.5 rounded-full transition-all duration-200 font-medium"
                                disabled={isLoading}
                            >
                                {example}
                            </button>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Chatbot;