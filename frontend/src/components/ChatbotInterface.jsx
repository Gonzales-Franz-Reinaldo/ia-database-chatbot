import React, { useState, useRef, useEffect } from "react";
import {
    Send,
    Bot,
    User,
    Database,
    Code,
    Copy,
    CheckCircle,
    AlertCircle,
    Loader2,
    Download,
} from "lucide-react";
import { apiService } from "../services/api";

const ChatbotInterface = ({ databaseConnection, schema, selectedModel }) => {
    const [messages, setMessages] = useState([
        {
            id: 1,
            type: "bot",
            content:
                "¡Hola! Soy tu asistente de base de datos con IA. Puedes hacerme preguntas sobre los datos y generaré consultas SQL para ti.",
            timestamp: new Date(),
        },
    ]);
    const [inputMessage, setInputMessage] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [copiedMessageId, setCopiedMessageId] = useState(null);
    const messagesEndRef = useRef(null);
    const inputRef = useRef(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const handleSendMessage = async () => {
        if (!inputMessage.trim() || isLoading) return;

        if (!databaseConnection) {
            alert("Por favor, conecta una base de datos primero");
            return;
        }

        if (!selectedModel) {
            alert("Por favor, selecciona un modelo de IA");
            return;
        }

        const userMessage = {
            id: Date.now(),
            type: "user",
            content: inputMessage.trim(),
            timestamp: new Date(),
        };

        setMessages((prev) => [...prev, userMessage]);
        setInputMessage("");
        setIsLoading(true);

        try {
            const response = await apiService.sendChatMessage(
                userMessage.content,
                selectedModel,
                databaseConnection
            );

            const botMessage = {
                id: Date.now() + 1,
                type: "bot",
                content: response.success
                    ? "Consulta ejecutada exitosamente"
                    : "Error en la consulta",
                sqlQuery: response.sql_query,
                explanation: response.explanation,
                data: response.data,
                error: response.error,
                success: response.success,
                timestamp: new Date(),
            };

            setMessages((prev) => [...prev, botMessage]);
        } catch (error) {
            const errorMessage = {
                id: Date.now() + 1,
                type: "bot",
                content: "Error al procesar tu mensaje",
                error: error.message,
                success: false,
                timestamp: new Date(),
            };

            setMessages((prev) => [...prev, errorMessage]);
        } finally {
            setIsLoading(false);
        }
    };

    const handleKeyPress = (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
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
            console.error("Error al copiar:", error);
        }
    };

    const exportToCsv = (data, filename = "query_results.csv") => {
        if (!data || data.length === 0) return;

        const headers = Object.keys(data[0]);
        const csvContent = [
            headers.join(","),
            ...data.map((row) =>
                headers
                    .map((header) => {
                        const value = row[header];
                        return value !== null && value !== undefined ? `"${value}"` : '""';
                    })
                    .join(",")
            ),
        ].join("\n");

        const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
        const link = document.createElement("a");
        const url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        link.setAttribute("download", filename);
        link.style.visibility = "hidden";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    const clearChat = () => {
        setMessages([
            {
                id: 1,
                type: "bot",
                content:
                    "¡Hola! Soy tu asistente de base de datos con IA. Puedes hacerme preguntas sobre los datos y generaré consultas SQL para ti.",
                timestamp: new Date(),
            },
        ]);
    };

    const formatData = (data) => {
        if (!data || data.length === 0) return null;

        const columns = Object.keys(data[0]);

        return (
            <div className="mt-4">
                <div className="flex items-center justify-between mb-2">
                    <h4 className="font-medium text-gray-700 flex items-center gap-2">
                        <Database size={16} />
                        Resultados ({data.length} filas)
                    </h4>
                    <button
                        onClick={() => exportToCsv(data)}
                        className="flex items-center gap-1 px-2 py-1 text-xs bg-green-100 text-green-700 rounded hover:bg-green-200 transition-colors"
                    >
                        <Download size={12} />
                        CSV
                    </button>
                </div>
                <div className="overflow-x-auto bg-gray-50 rounded-lg border">
                    <table className="min-w-full text-sm">
                        <thead>
                            <tr className="bg-gray-100 border-b">
                                {columns.map((column) => (
                                    <th
                                        key={column}
                                        className="px-4 py-2 text-left font-medium text-gray-700"
                                    >
                                        {column}
                                    </th>
                                ))}
                            </tr>
                        </thead>
                        <tbody>
                            {data.slice(0, 50).map((row, index) => (
                                <tr key={index} className="border-b hover:bg-gray-50">
                                    {columns.map((column) => (
                                        <td key={column} className="px-4 py-2 text-gray-600">
                                            {row[column] !== null && row[column] !== undefined ? (
                                                <span className="break-all">{String(row[column])}</span>
                                            ) : (
                                                <span className="text-gray-400 italic">null</span>
                                            )}
                                        </td>
                                    ))}
                                </tr>
                            ))}
                        </tbody>
                    </table>
                    {data.length > 50 && (
                        <div className="p-3 text-center text-gray-500 text-sm bg-gray-100 border-t">
                            Mostrando 50 de {data.length} filas. Descarga CSV para ver todos
                            los datos.
                        </div>
                    )}
                </div>
            </div>
        );
    };

    const renderMessage = (message) => {
        const isUser = message.type === "user";

        return (
            <div
                key={message.id}
                className={`flex ${isUser ? "justify-end" : "justify-start"
                    } mb-6 animate-fadeIn`}
            >
                <div
                    className={`flex gap-3 max-w-4xl w-full ${isUser ? "flex-row-reverse" : "flex-row"
                        }`}
                >
                    {/* Avatar */}
                    <div
                        className={`flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center shadow-sm ${isUser
                                ? "bg-blue-500 text-white"
                                : "bg-gradient-to-r from-purple-500 to-blue-500 text-white"
                            }`}
                    >
                        {isUser ? <User size={18} /> : <Bot size={18} />}
                    </div>

                    {/* Contenido del mensaje */}
                    <div
                        className={`rounded-xl p-4 shadow-sm ${isUser
                                ? "bg-blue-500 text-white max-w-lg"
                                : "bg-white border border-gray-200 flex-1"
                            }`}
                    >
                        {/* Mensaje principal */}
                        <div className="mb-2">
                            <p
                                className={`${isUser ? "text-white" : "text-gray-800"
                                    } leading-relaxed`}
                            >
                                {message.content}
                            </p>
                        </div>

                        {/* Consulta SQL */}
                        {message.sqlQuery && (
                            <div className="mt-4 bg-gray-900 text-green-400 p-4 rounded-lg font-mono text-sm">
                                <div className="flex items-center justify-between mb-2">
                                    <span className="flex items-center gap-2 text-gray-300">
                                        <Code size={16} />
                                        SQL Query
                                    </span>
                                    <button
                                        onClick={() =>
                                            copyToClipboard(message.sqlQuery, `sql-${message.id}`)
                                        }
                                        className="text-gray-400 hover:text-white transition-colors p-1 rounded"
                                        title="Copiar SQL"
                                    >
                                        {copiedMessageId === `sql-${message.id}` ? (
                                            <CheckCircle size={16} className="text-green-400" />
                                        ) : (
                                            <Copy size={16} />
                                        )}
                                    </button>
                                </div>
                                <pre className="whitespace-pre-wrap text-sm">
                                    {message.sqlQuery}
                                </pre>
                            </div>
                        )}

                        {/* Explicación */}
                        {message.explanation && (
                            <div className="mt-4 p-3 bg-blue-50 border-l-4 border-blue-400 rounded-r-lg">
                                <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                                    💡 Explicación
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
                                    <AlertCircle
                                        className="text-red-500 flex-shrink-0 mt-0.5"
                                        size={16}
                                    />
                                    <div>
                                        <h4 className="font-medium text-red-800 mb-1">Error:</h4>
                                        <p className="text-red-700 text-sm">{message.error}</p>
                                    </div>
                                </div>
                            </div>
                        )}

                        {/* Timestamp */}
                        <div
                            className={`text-xs mt-3 ${isUser ? "text-blue-100" : "text-gray-500"
                                }`}
                        >
                            {message.timestamp.toLocaleTimeString()}
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    if (!databaseConnection) {
        return (
            <div className="bg-white rounded-lg shadow-lg p-8">
                <div className="text-center text-gray-500">
                    <Database size={64} className="mx-auto mb-4 text-gray-300" />
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
        <div className="bg-white rounded-lg shadow-lg flex flex-col h-[600px]">
            {/* Header */}
            <div className="border-b border-gray-200 p-4">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-gradient-to-r from-purple-500 to-blue-500 rounded-full flex items-center justify-center">
                            <Bot className="text-white" size={18} />
                        </div>
                        <div>
                            <h2 className="font-semibold text-gray-800">
                                Chatbot de Base de Datos
                            </h2>
                            <p className="text-sm text-gray-500">
                                {databaseConnection.database} • {selectedModel}
                            </p>
                        </div>
                    </div>
                    <button
                        onClick={clearChat}
                        className="text-gray-500 hover:text-gray-700 px-3 py-1 text-sm rounded-lg hover:bg-gray-100 transition-colors"
                    >
                        Limpiar Chat
                    </button>
                </div>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">
                {messages.map(renderMessage)}

                {/* Loading indicator */}
                {isLoading && (
                    <div className="flex justify-start mb-4">
                        <div className="flex gap-3">
                            <div className="w-10 h-10 rounded-full bg-gradient-to-r from-purple-500 to-blue-500 flex items-center justify-center">
                                <Bot size={18} className="text-white" />
                            </div>
                            <div className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
                                <div className="flex items-center gap-2">
                                    <Loader2 className="animate-spin text-blue-500" size={16} />
                                    <span className="text-gray-600">
                                        Analizando consulta y ejecutando SQL...
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                )}

                <div ref={messagesEndRef} />
            </div>

            {/* Input */}
            <div className="border-t border-gray-200 p-4 bg-white">
                <div className="flex gap-3">
                    <input
                        ref={inputRef}
                        type="text"
                        value={inputMessage}
                        onChange={(e) => setInputMessage(e.target.value)}
                        onKeyPress={handleKeyPress}
                        placeholder="Pregunta algo sobre tus datos... ej: '¿Cuáles son las mejores notas?'"
                        className="flex-1 p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                        disabled={isLoading}
                    />
                    <button
                        onClick={handleSendMessage}
                        disabled={!inputMessage.trim() || isLoading}
                        className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center gap-2 shadow-sm"
                    >
                        <Send size={16} />
                        <span className="hidden sm:inline">Enviar</span>
                    </button>
                </div>

                {/* Ejemplos de consultas */}
                <div className="mt-3">
                    <p className="text-xs text-gray-500 mb-2">
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
                                className="text-xs bg-gray-100 hover:bg-gray-200 text-gray-600 px-2 py-1 rounded transition-colors"
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

export default ChatbotInterface;
