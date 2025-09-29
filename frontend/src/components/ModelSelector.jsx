import React, { useState, useEffect } from 'react';
import { Brain, RefreshCw, CheckCircle, AlertCircle, Loader2, Sparkles } from 'lucide-react';
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

        if (name.includes('gemma')) return 'bg-blue-100 text-blue-700 border-blue-200';
        if (name.includes('deepseek')) return 'bg-green-100 text-green-700 border-green-200';
        if (name.includes('qwen')) return 'bg-purple-100 text-purple-700 border-purple-200';
        if (name.includes('gpt')) return 'bg-orange-100 text-orange-700 border-orange-200';

        return 'bg-gray-100 text-gray-700 border-gray-200';
    };

    return (
        <div className="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg p-6 mb-6 border border-gray-200/50 transition-all duration-300 hover:shadow-xl">
            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-3">
                    <div className="p-2 bg-purple-100 rounded-lg">
                        <Brain className="text-purple-600" size={24} />
                    </div>
                </div>

                {!isLoading && !error && models.length === 0 && (
                    <div className="text-center py-12">
                        <div className="inline-flex items-center justify-center w-20 h-20 bg-gray-100 rounded-full mb-4">
                            <Brain size={40} className="text-gray-400" />
                        </div>
                        <h3 className="text-lg font-medium text-gray-800 mb-2">No hay modelos disponibles</h3>
                        <p className="text-gray-600 mb-6">Instala algunos modelos en Ollama para comenzar.</p>

                        <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-6 rounded-lg text-left max-w-2xl mx-auto border border-blue-100">
                            <h4 className="font-medium text-blue-800 mb-3 flex items-center gap-2">
                                <Sparkles size={18} />
                                Comandos para instalar modelos:
                            </h4>
                            <div className="space-y-2">
                                {[
                                    { cmd: 'ollama pull gemma2:7b', desc: 'Recomendado para balance' },
                                    { cmd: 'ollama pull deepseek-coder:6.7b', desc: 'Mejor para SQL' },
                                    { cmd: 'ollama pull qwen2.5:7b', desc: 'Multilingüe' }
                                ].map((item, idx) => (
                                    <div key={idx} className="bg-white p-3 rounded-lg border border-blue-200">
                                        <code className="text-sm font-mono text-blue-700 block mb-1">
                                            {item.cmd}
                                        </code>
                                        <span className="text-xs text-gray-600">{item.desc}</span>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>
                )}

                {!isLoading && !error && models.length > 0 && (
                    <div className="space-y-3">
                        {models.map((model) => {
                            const isSelected = selectedModel === model.name;

                            return (
                                <div
                                    key={model.name}
                                    className={`p-4 border-2 rounded-lg cursor-pointer transition-all duration-200 ${isSelected
                                            ? 'border-purple-500 bg-purple-50 shadow-md'
                                            : 'border-gray-200 bg-white hover:border-purple-300 hover:bg-gray-50'
                                        }`}
                                    onClick={() => onModelChange(model.name)}
                                >
                                    <div className="flex items-start justify-between gap-4">
                                        <div className="flex items-start gap-3 flex-1 min-w-0">
                                            <div className="flex-shrink-0 mt-1">
                                                {isSelected ? (
                                                    <CheckCircle className="text-purple-500" size={20} />
                                                ) : (
                                                    <div className="w-5 h-5 rounded-full border-2 border-gray-300"></div>
                                                )}
                                            </div>

                                            <div className="flex-1 min-w-0">
                                                <div className="flex items-center gap-2 flex-wrap mb-2">
                                                    <h3 className="font-semibold text-gray-800 truncate">
                                                        {model.name}
                                                    </h3>
                                                    <span className={`px-2 py-1 rounded-full text-xs font-medium border ${getModelColor(model.name)}`}>
                                                        {formatModelSize(model.size)}
                                                    </span>
                                                </div>

                                                <p className="text-gray-600 text-sm mb-3">
                                                    {getModelDescription(model.name)}
                                                </p>

                                                {model.modified_at && (
                                                    <div className="text-xs text-gray-500 flex items-center gap-1">
                                                        <span>Última actualización:</span>
                                                        <span className="font-medium">
                                                            {new Date(model.modified_at).toLocaleDateString('es-ES', {
                                                                year: 'numeric',
                                                                month: 'short',
                                                                day: 'numeric'
                                                            })}
                                                        </span>
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    </div>

                                    {isSelected && (
                                        <div className="mt-3 p-3 bg-purple-100 rounded-lg border border-purple-200">
                                            <p className="text-purple-800 text-sm font-medium flex items-center gap-2">
                                                <Sparkles size={16} />
                                                Modelo seleccionado - Listo para generar consultas SQL
                                            </p>
                                        </div>
                                    )}
                                </div>
                            );
                        })}
                    </div>
                )}

                {/* Información adicional */}
                {!isLoading && !error && models.length > 0 && (
                    <div className="mt-6 p-4 bg-gradient-to-r from-gray-50 to-gray-100 rounded-lg border border-gray-200">
                        <h4 className="font-medium text-gray-700 mb-3 flex items-center gap-2">
                            <span className="text-xl">💡</span>
                            Recomendaciones:
                        </h4>
                        <ul className="text-sm text-gray-600 space-y-2">
                            <li className="flex items-start gap-2">
                                <span className="text-purple-500 mt-0.5 flex-shrink-0">•</span>
                                <span><strong className="text-gray-700">DeepSeek Coder:</strong> Mejor para consultas SQL complejas y optimizadas</span>
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="text-purple-500 mt-0.5 flex-shrink-0">•</span>
                                <span><strong className="text-gray-700">Gemma 2:</strong> Excelente balance entre rendimiento y velocidad</span>
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="text-purple-500 mt-0.5 flex-shrink-0">•</span>
                                <span><strong className="text-gray-700">Qwen:</strong> Bueno para consultas en múltiples idiomas</span>
                            </li>
                            <li className="flex items-start gap-2">
                                <span className="text-purple-500 mt-0.5 flex-shrink-0">•</span>
                                <span>Los modelos más grandes generan mejores consultas pero son más lentos</span>
                            </li>
                        </ul>
                    </div>
                )}
            </div>
        </div>
    );
};

export default ModelSelector;