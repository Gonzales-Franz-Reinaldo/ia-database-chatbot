import React from 'react';
import { CheckCircle, XCircle, AlertCircle, Clock, Zap } from 'lucide-react';

const StatusBadge = ({ status, text, size = 'medium', className = '' }) => {
    const statusConfig = {
        success: {
            icon: CheckCircle,
            bgColor: 'bg-green-100',
            textColor: 'text-green-800',
            iconColor: 'text-green-600'
        },
        error: {
            icon: XCircle,
            bgColor: 'bg-red-100',
            textColor: 'text-red-800',
            iconColor: 'text-red-600'
        },
        warning: {
            icon: AlertCircle,
            bgColor: 'bg-yellow-100',
            textColor: 'text-yellow-800',
            iconColor: 'text-yellow-600'
        },
        pending: {
            icon: Clock,
            bgColor: 'bg-blue-100',
            textColor: 'text-blue-800',
            iconColor: 'text-blue-600'
        },
        active: {
            icon: Zap,
            bgColor: 'bg-purple-100',
            textColor: 'text-purple-800',
            iconColor: 'text-purple-600'
        }
    };

    const sizeConfig = {
        small: {
            padding: 'px-2 py-1',
            textSize: 'text-xs',
            iconSize: 12
        },
        medium: {
            padding: 'px-3 py-1',
            textSize: 'text-sm',
            iconSize: 14
        },
        large: {
            padding: 'px-4 py-2',
            textSize: 'text-base',
            iconSize: 16
        }
    };

    const config = statusConfig[status] || statusConfig.pending;
    const sizeSettings = sizeConfig[size];
    const Icon = config.icon;

    return (
        <span className={`
      inline-flex items-center gap-2 rounded-full font-medium
      ${config.bgColor} ${config.textColor}
      ${sizeSettings.padding} ${sizeSettings.textSize}
      ${className}
    `}>
            <Icon size={sizeSettings.iconSize} className={config.iconColor} />
            {text}
        </span>
    );
};

export const ConnectionStatus = ({ isConnected, databaseName }) => (
    <StatusBadge
        status={isConnected ? 'success' : 'error'}
        text={isConnected ? `Conectado a ${databaseName}` : 'Desconectado'}
    />
);

export const ModelStatus = ({ modelName, isLoaded }) => (
    <StatusBadge
        status={isLoaded ? 'active' : 'pending'}
        text={isLoaded ? `Modelo: ${modelName}` : 'Sin modelo seleccionado'}
    />
);

export const QueryStatus = ({ status, count }) => {
    const statusText = {
        success: `${count} resultados`,
        error: 'Error en consulta',
        pending: 'Ejecutando...',
        warning: 'Advertencia'
    };

    return (
        <StatusBadge
            status={status}
            text={statusText[status] || 'Estado desconocido'}
            size="small"
        />
    );
};

export default StatusBadge;