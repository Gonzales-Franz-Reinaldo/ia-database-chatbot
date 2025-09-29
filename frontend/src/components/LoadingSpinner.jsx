import React from 'react';
import { Loader2 } from 'lucide-react';

const LoadingSpinner = ({ size = 'medium', text = 'Cargando...', className = '' }) => {
    const sizeClasses = {
        small: 'w-4 h-4',
        medium: 'w-6 h-6',
        large: 'w-8 h-8',
        xl: 'w-12 h-12'
    };

    const textSizes = {
        small: 'text-sm',
        medium: 'text-base',
        large: 'text-lg',
        xl: 'text-xl'
    };

    return (
        <div className={`flex items-center justify-center gap-2 ${className}`}>
            <Loader2 className={`animate-spin text-blue-500 ${sizeClasses[size]}`} />
            {text && (
                <span className={`text-gray-600 ${textSizes[size]}`}>
                    {text}
                </span>
            )}
        </div>
    );
};

export const LoadingCard = ({ title = 'Cargando...', description, className = '' }) => (
    <div className={`bg-white rounded-lg shadow-lg p-8 ${className}`}>
        <div className="text-center">
            <LoadingSpinner size="large" text="" />
            <h3 className="text-lg font-medium text-gray-800 mt-4 mb-2">{title}</h3>
            {description && (
                <p className="text-gray-600 text-sm">{description}</p>
            )}
        </div>
    </div>
);

export const LoadingOverlay = ({ isVisible, text = 'Procesando...' }) => {
    if (!isVisible) return null;

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-8 shadow-xl">
                <LoadingSpinner size="xl" text={text} />
            </div>
        </div>
    );
};

export default LoadingSpinner;