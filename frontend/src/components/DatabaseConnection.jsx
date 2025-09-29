import React, { useState } from 'react';
import { Database, CheckCircle, XCircle, Loader2 } from 'lucide-react';
import { apiService } from '../services/api';

const DatabaseConnection = ({ onConnectionSuccess, isConnected }) => {
    const [connectionData, setConnectionData] = useState({
        type: 'postgresql',
        host: 'localhost',
        port: 5432,
        database: '',
        username: '',
        password: ''
    });

    const [isConnecting, setIsConnecting] = useState(false);
    const [connectionStatus, setConnectionStatus] = useState(null);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setConnectionData(prev => ({
            ...prev,
            [name]: value,
            // Cambiar puerto por defecto según el tipo de BD
            ...(name === 'type' && {
                port: value === 'postgresql' ? 5432 : 3306
            })
        }));
        setConnectionStatus(null);
    };

    const testConnection = async () => {
        setIsConnecting(true);
        setConnectionStatus(null);

        try {
            const result = await apiService.testDatabaseConnection(connectionData);

            if (result.success) {
                setConnectionStatus({ type: 'success', message: result.message });
                onConnectionSuccess(connectionData);
            } else {
                setConnectionStatus({ type: 'error', message: result.message });
            }
        } catch (error) {
            setConnectionStatus({ type: 'error', message: error.message });
        } finally {
            setIsConnecting(false);
        }
    };

    return (
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <div className="flex items-center gap-3 mb-6">
                <Database className="text-blue-500" size={24} />
                <h2 className="text-xl font-semibold text-gray-800">Conexión a Base de Datos</h2>
                {isConnected && (
                    <div className="flex items-center gap-2 text-green-600 bg-green-50 px-3 py-1 rounded-full text-sm">
                        <CheckCircle size={16} />
                        <span>Conectado</span>
                    </div>
                )}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                {/* Tipo de Base de Datos */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        Tipo de Base de Datos
                    </label>
                    <select
                        name="type"
                        value={connectionData.type}
                        onChange={handleInputChange}
                        className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                        <option value="postgresql">PostgreSQL</option>
                        <option value="mysql">MySQL</option>
                    </select>
                </div>

                {/* Host */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        Host
                    </label>
                    <input
                        type="text"
                        name="host"
                        value={connectionData.host}
                        onChange={handleInputChange}
                        placeholder="localhost"
                        className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                </div>

                {/* Puerto */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        Puerto
                    </label>
                    <input
                        type="number"
                        name="port"
                        value={connectionData.port}
                        onChange={handleInputChange}
                        className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                </div>

                {/* Nombre de la Base de Datos */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        Base de Datos
                    </label>
                    <input
                        type="text"
                        name="database"
                        value={connectionData.database}
                        onChange={handleInputChange}
                        placeholder="nombre_de_la_bd"
                        className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                </div>

                {/* Usuario */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        Usuario
                    </label>
                    <input
                        type="text"
                        name="username"
                        value={connectionData.username}
                        onChange={handleInputChange}
                        placeholder="usuario"
                        className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                </div>

                {/* Contraseña */}
                <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                        Contraseña
                    </label>
                    <input
                        type="password"
                        name="password"
                        value={connectionData.password}
                        onChange={handleInputChange}
                        placeholder="contraseña"
                        className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                </div>
            </div>

            {/* Estado de Conexión */}
            {connectionStatus && (
                <div className={`p-4 rounded-lg mb-4 flex items-center gap-3 ${connectionStatus.type === 'success'
                        ? 'bg-green-50 text-green-700 border border-green-200'
                        : 'bg-red-50 text-red-700 border border-red-200'
                    }`}>
                    {connectionStatus.type === 'success' ? (
                        <CheckCircle size={20} />
                    ) : (
                        <XCircle size={20} />
                    )}
                    <span>{connectionStatus.message}</span>
                </div>
            )}

            {/* Botón de Conexión */}
            <button
                onClick={testConnection}
                disabled={isConnecting || !connectionData.database || !connectionData.username}
                className={`w-full py-3 px-4 rounded-lg font-medium transition-all duration-200 flex items-center justify-center gap-2 ${isConnecting || !connectionData.database || !connectionData.username
                        ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                        : 'bg-blue-500 hover:bg-blue-600 text-white shadow-md hover:shadow-lg'
                    }`}
            >
                {isConnecting ? (
                    <>
                        <Loader2 className="animate-spin" size={20} />
                        Conectando...
                    </>
                ) : (
                    <>
                        <Database size={20} />
                        Probar Conexión
                    </>
                )}
            </button>

            {/* Información de ayuda */}
            <div className="mt-4 p-4 bg-blue-50 rounded-lg">
                <h4 className="font-medium text-blue-800 mb-2">💡 Consejos:</h4>
                <ul className="text-sm text-blue-700 space-y-1">
                    <li>• Asegúrate de que la base de datos esté ejecutándose</li>
                    <li>• Verifica que el usuario tenga permisos de lectura</li>
                    <li>• PostgreSQL usa puerto 5432 por defecto, MySQL usa 3306</li>
                </ul>
            </div>
        </div>
    );
};

export default DatabaseConnection;