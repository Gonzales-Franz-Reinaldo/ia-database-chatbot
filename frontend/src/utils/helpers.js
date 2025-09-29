// Utilidades y funciones de ayuda para la aplicación

/**
 * Formatea un timestamp a una fecha legible
 */
export const formatDate = (date) => {
    if (!date) return '';

    const now = new Date();
    const targetDate = new Date(date);
    const diffInSeconds = Math.floor((now - targetDate) / 1000);

    if (diffInSeconds < 60) {
        return 'Hace un momento';
    } else if (diffInSeconds < 3600) {
        const minutes = Math.floor(diffInSeconds / 60);
        return `Hace ${minutes} minuto${minutes > 1 ? 's' : ''}`;
    } else if (diffInSeconds < 86400) {
        const hours = Math.floor(diffInSeconds / 3600);
        return `Hace ${hours} hora${hours > 1 ? 's' : ''}`;
    } else {
        return targetDate.toLocaleDateString('es-ES', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }
};

/**
 * Valida los datos de conexión a la base de datos
 */
export const validateDatabaseConnection = (connectionData) => {
    const errors = [];

    if (!connectionData.host.trim()) {
        errors.push('El host es requerido');
    }

    if (!connectionData.port || connectionData.port < 1 || connectionData.port > 65535) {
        errors.push('El puerto debe estar entre 1 y 65535');
    }

    if (!connectionData.database.trim()) {
        errors.push('El nombre de la base de datos es requerido');
    }

    if (!connectionData.username.trim()) {
        errors.push('El usuario es requerido');
    }

    if (!connectionData.password.trim()) {
        errors.push('La contraseña es requerida');
    }

    return {
        isValid: errors.length === 0,
        errors
    };
};

/**
 * Genera un color basado en el tipo de dato
 */
export const getDataTypeColor = (dataType) => {
    const type = dataType.toLowerCase();

    if (type.includes('int') || type.includes('number') || type.includes('decimal') || type.includes('float')) {
        return 'text-blue-600 bg-blue-100';
    } else if (type.includes('varchar') || type.includes('text') || type.includes('char')) {
        return 'text-green-600 bg-green-100';
    } else if (type.includes('date') || type.includes('time')) {
        return 'text-purple-600 bg-purple-100';
    } else if (type.includes('boolean') || type.includes('bool')) {
        return 'text-orange-600 bg-orange-100';
    } else {
        return 'text-gray-600 bg-gray-100';
    }
};

/**
 * Formatea el tamaño de un modelo
 */
export const formatModelSize = (size) => {
    if (typeof size === 'string' && size.includes('B')) {
        return size;
    }

    if (typeof size === 'number') {
        const gb = size / (1024 * 1024 * 1024);
        if (gb >= 1) {
            return `${gb.toFixed(1)}GB`;
        }
        const mb = size / (1024 * 1024);
        return `${mb.toFixed(0)}MB`;
    }

    return 'Tamaño desconocido';
};

/**
 * Extrae el nombre limpio del modelo
 */
export const getCleanModelName = (modelName) => {
    return modelName.split(':')[0].replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
};

/**
 * Valida si una consulta SQL es segura (solo SELECT)
 */
export const isSafeQuery = (query) => {
    const cleanQuery = query.trim().toUpperCase();

    // Debe empezar con SELECT
    if (!cleanQuery.startsWith('SELECT')) {
        return false;
    }

    // Palabras prohibidas
    const forbiddenWords = [
        'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER',
        'TRUNCATE', 'EXEC', 'EXECUTE', 'CALL', 'GRANT', 'REVOKE',
        'MERGE', 'REPLACE', 'LOAD', 'IMPORT'
    ];

    return !forbiddenWords.some(word => cleanQuery.includes(word));
};

/**
 * Trunca texto largo
 */
export const truncateText = (text, maxLength = 100) => {
    if (!text || text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
};

/**
 * Debounce function para búsquedas
 */
export const debounce = (func, wait) => {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
};

/**
 * Copia texto al portapapeles
 */
export const copyToClipboard = async (text) => {
    try {
        await navigator.clipboard.writeText(text);
        return true;
    } catch {
        // Fallback para navegadores antiguos
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        try {
            const successful = document.execCommand('copy');
            document.body.removeChild(textArea);
            return successful;
        } catch {
            document.body.removeChild(textArea);
            return false;
        }
    }
};

/**
 * Genera un ID único
 */
export const generateId = () => {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
};

/**
 * Formatea números grandes
 */
export const formatNumber = (num) => {
    if (!num) return '0';

    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    } else if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }

    return num.toString();
};

/**
 * Convierte datos a CSV
 */
export const convertToCSV = (data) => {
    if (!data || data.length === 0) return '';

    const headers = Object.keys(data[0]);
    const csvContent = [
        headers.join(','),
        ...data.map(row =>
            headers.map(header => {
                const value = row[header];
                if (value === null || value === undefined) return '';
                const stringValue = String(value);
                // Escapar comillas y envolver en comillas si contiene comas
                if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
                    return `"${stringValue.replace(/"/g, '""')}"`;
                }
                return stringValue;
            }).join(',')
        )
    ].join('\n');

    return csvContent;
};

/**
 * Descarga un archivo
 */
export const downloadFile = (content, filename, contentType = 'text/plain') => {
    const blob = new Blob([content], { type: contentType });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');

    link.href = url;
    link.download = filename;
    link.style.display = 'none';

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    URL.revokeObjectURL(url);
};

/**
 * Manejo de errores de API
 */
export const handleApiError = (error) => {
    if (error.response) {
        // Error de respuesta del servidor
        const status = error.response.status;
        const message = error.response.data?.message || error.response.data?.detail || 'Error del servidor';

        switch (status) {
            case 400:
                return `Error de solicitud: ${message}`;
            case 401:
                return 'No autorizado. Verifica tus credenciales.';
            case 403:
                return 'Acceso denegado.';
            case 404:
                return 'Recurso no encontrado.';
            case 500:
                return `Error interno del servidor: ${message}`;
            default:
                return `Error ${status}: ${message}`;
        }
    } else if (error.request) {
        // Error de red
        return 'Error de conexión. Verifica tu conexión a internet y que el servidor esté ejecutándose.';
    } else {
        // Error de configuración
        return `Error: ${error.message}`;
    }
};

/**
 * Validaciones de entrada
 */
export const validators = {
    email: (email) => {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    },

    port: (port) => {
        const numPort = parseInt(port);
        return numPort >= 1 && numPort <= 65535;
    },

    required: (value) => {
        return value && value.toString().trim().length > 0;
    },

    minLength: (value, min) => {
        return value && value.toString().length >= min;
    }
};

/**
 * Constantes de la aplicación
 */
export const constants = {
    DATABASE_TYPES: {
        POSTGRESQL: 'postgresql',
        MYSQL: 'mysql'
    },

    DEFAULT_PORTS: {
        postgresql: 5432,
        mysql: 3306
    },

    MESSAGE_TYPES: {
        USER: 'user',
        BOT: 'bot',
        SYSTEM: 'system'
    },

    QUERY_STATUS: {
        SUCCESS: 'success',
        ERROR: 'error',
        LOADING: 'loading',
        PENDING: 'pending'
    }
};