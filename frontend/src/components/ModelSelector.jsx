import React, { useState, useEffect } from 'react';
import { Brain, RefreshCw, CheckCircle, AlertCircle, Loader2 } from 'lucide-react';
import { apiService } from '../services/api';

const ModelSelector = ({ selectedModel, onModelChange }) => {
    const [models, setModels] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        loadModels();
    }, []);

    const loadModels = async () => {
        setIsLoading(true);
        setError(null);

        try {
            const availableModels = await apiService.getModels();
            setModels(availableModels);

            // Seleccionar el primer modelo disponible si no hay ninguno seleccionado
            if (availableModels.length > 0 && !selectedModel) {
                onModelChange(availableModels[0].name);
            }
        } catch (err) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    const formatModelSize = (size) => {
        if (typeof size === 'string' && size.includes('B')) {
            return size;
        }

        // Convertir bytes a GB/MB si es necesario
        if (typeof size === 'number') {
            const gb = size / (1024 * 1024 * 1024);
            if (gb >= 1) {
                return `${gb.toFixed(1)}GB`;
            }
            const mb = size / (1024 * 1024);
            return `${mb.toFixed(0)}MB`;
        }

        return 'Desconocido';
    };

    const getModelDescription = (modelName) => {
        const name = modelName.toLowerCase();

        if (name.includes('gemma')) {
            return 'Modelo conversacional de Google, excelente para tareas generales';
        }
        if (name.includes('deepseek-coder')) {
            return 'Especializado en programación y consultas SQL';
        }
        if (name.includes('qwen')) {
            return 'Modelo multilingüe con buen rendimiento en consultas';
        }
        if (name.includes('deepseek-r1')) {
            return 'Modelo avanzado con capacidades de razonamiento';
        }
        if (name.includes('gpt-oss')) {
            return 'Modelo de código abierto con excelente rendimiento';
        }

        return 'Modelo de IA para consultas de base de datos';
    };

    const getModelColor = (modelName) => {
        const name = modelName.toLowerCase();

        if (name.includes('gemma')) return 'bg-blue-100 text-blue-800';
        if (name.includes('deepseek')) return 'bg-green-100 text-green-800';
        if (name.includes('qwen')) return 'bg-purple-100 text-purple-800';
        if (name.includes('gpt')) return 'bg-orange-100 text-orange-800';

        return 'bg-gray-100 text-gray-800';
    };

    return (
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-3">
                    <Brain className="text-purple-500" size={24} />
                    <h2 className="text-xl font-semibold text-gray-800">Seleccionar Modelo de IA</h2>
                </div>

                <button
                    onClick={loadModels}
                    disabled={isLoading}
                    className="flex items-center gap-2 px-3 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg transition-colors disabled:opacity-50"
                >
                    <RefreshCw className={`${isLoading ? 'animate-spin' : ''}`} size={16} />
                    Actualizar
                </button>
            </div>

            {isLoading && (
                <div className="flex items-center justify-center py-8">
                    <Loader2 className="animate-spin text-purple-500" size={32} />
                    <span className="ml-3 text-gray-600">Cargando modelos de Ollama...</span>
                </div>
            )}

            {error && (
                <div className="flex items-center gap-3 p-4 bg-red-50 border border-red-200 rounded-lg mb-4">
                    <AlertCircle className="text-red-500" size={20} />
                    <div>
                        <p className="font-medium text-red-800">Error al cargar modelos</p>
                        <p className="text-red-600 text-sm">{error}</p>
                        <p className="text-red-600 text-sm mt-1">
                            Verifica que Ollama esté ejecutándose en http://localhost:11434
                        </p>
                    </div>
                </div>
            )}

            {!isLoading && !error && models.length === 0 && (
                <div className="text-center py-8 text-gray-500">
                    <Brain size={48} className="mx-auto mb-4 text-gray-300" />
                    <h3 className="text-lg font-medium mb-2">No hay modelos disponibles</h3>
                    <p className="mb-4">Instala algunos modelos en Ollama para comenzar.</p>
                    <div className="bg-blue-50 p-4 rounded-lg text-left">
                        <h4 className="font-medium text-blue-800 mb-2">Comandos para instalar modelos:</h4>
                        <div className="space-y-1 text-sm font-mono text-blue-700">
                            <div>ollama pull gemma2:7b</div>
                            <div>ollama pull deepseek-coder:6.7b</div>
                            <div>ollama pull qwen2.5:7b</div>
                        </div>
                    </div>
                </div>
            )}

            {!isLoading && !error && models.length > 0 && (
                <div className="space-y-3">
                    {models.map((model) => (
                        <div
                            key={model.name}
                            className={`p-4 border-2 rounded-lg cursor-pointer transition-all duration-200 ${selectedModel === model.name
                                    ? 'border-purple-500 bg-purple-50'
                                    : 'border-gray-200 hover:border-purple-300 hover:bg-gray-50'
                                }`}
                            onClick={() => onModelChange(model.name)}
                        >
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                    <div className="flex items-center gap-2">
                                        {selectedModel === model.name && (
                                            <CheckCircle className="text-purple-500" size={20} />
                                        )}
                                        <h3 className="font-semibold text-gray-800">{model.name}</h3>
                                    </div>

                                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${getModelColor(model.name)}`}>
                                        {formatModelSize(model.size)}
                                    </span>
                                </div>

                                <div className="text-right">
                                    <div className="text-sm text-gray-500">
                                        {model.modified_at && new Date(model.modified_at).toLocaleDateString()}
                                    </div>
                                </div>
                            </div>

                            <p className="text-gray-600 text-sm mt-2">
                                {getModelDescription(model.name)}
                            </p>

                            {selectedModel === model.name && (
                                <div className="mt-3 p-3 bg-purple-100 rounded-lg">
                                    <p className="text-purple-800 text-sm font-medium">
                                        ✨ Modelo seleccionado - Listo para generar consultas SQL
                                    </p>
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            )}

            {/* Información adicional */}
            <div className="mt-6 p-4 bg-gray-50 rounded-lg">
                <h4 className="font-medium text-gray-700 mb-2">💡 Recomendaciones:</h4>
                <ul className="text-sm text-gray-600 space-y-1">
                    <li>• <strong>DeepSeek Coder:</strong> Mejor para consultas SQL complejas</li>
                    <li>• <strong>Gemma 2:</strong> Excelente balance entre rendimiento y velocidad</li>
                    <li>• <strong>Qwen:</strong> Bueno para consultas en múltiples idiomas</li>
                    <li>• Los modelos más grandes suelen generar mejores consultas pero son más lentos</li>
                </ul>
            </div>
        </div>
    );
};

export default ModelSelector;