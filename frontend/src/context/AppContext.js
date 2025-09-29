import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { useLocalStorage } from '../hooks/useApi';

// Tipos de acciones
const ActionTypes = {
    SET_DATABASE_CONNECTION: 'SET_DATABASE_CONNECTION',
    SET_SCHEMA: 'SET_SCHEMA',
    SET_SELECTED_MODEL: 'SET_SELECTED_MODEL',
    SET_MODELS: 'SET_MODELS',
    SET_LOADING: 'SET_LOADING',
    SET_ERROR: 'SET_ERROR',
    CLEAR_ERROR: 'CLEAR_ERROR',
    RESET_APP: 'RESET_APP'
};

// Estado inicial
const initialState = {
    databaseConnection: null,
    schema: null,
    selectedModel: '',
    models: [],
    isLoading: false,
    error: null,
    isConnected: false
};

// Reducer
const appReducer = (state, action) => {
    switch (action.type) {
        case ActionTypes.SET_DATABASE_CONNECTION:
            return {
                ...state,
                databaseConnection: action.payload,
                isConnected: !!action.payload,
                schema: null // Reset schema when connection changes
            };

        case ActionTypes.SET_SCHEMA:
            return {
                ...state,
                schema: action.payload
            };

        case ActionTypes.SET_SELECTED_MODEL:
            return {
                ...state,
                selectedModel: action.payload
            };

        case ActionTypes.SET_MODELS:
            return {
                ...state,
                models: action.payload
            };

        case ActionTypes.SET_LOADING:
            return {
                ...state,
                isLoading: action.payload
            };

        case ActionTypes.SET_ERROR:
            return {
                ...state,
                error: action.payload,
                isLoading: false
            };

        case ActionTypes.CLEAR_ERROR:
            return {
                ...state,
                error: null
            };

        case ActionTypes.RESET_APP:
            return {
                ...initialState,
                models: state.models // Mantener la lista de modelos
            };

        default:
            return state;
    }
};

// Context
const AppContext = createContext();

// Provider component
export const AppProvider = ({ children }) => {
    const [state, dispatch] = useReducer(appReducer, initialState);

    // Persistir ciertas configuraciones
    const [savedConnection, setSavedConnection] = useLocalStorage('dbConnection', null);
    const [savedModel, setSavedModel] = useLocalStorage('selectedModel', '');

    // Cargar configuración guardada al inicializar
    useEffect(() => {
        if (savedConnection) {
            dispatch({ type: ActionTypes.SET_DATABASE_CONNECTION, payload: savedConnection });
        }
        if (savedModel) {
            dispatch({ type: ActionTypes.SET_SELECTED_MODEL, payload: savedModel });
        }
    }, [savedConnection, savedModel]);

    // Guardar configuración cuando cambie
    useEffect(() => {
        if (state.databaseConnection) {
            setSavedConnection(state.databaseConnection);
        }
    }, [state.databaseConnection, setSavedConnection]);

    useEffect(() => {
        if (state.selectedModel) {
            setSavedModel(state.selectedModel);
        }
    }, [state.selectedModel, setSavedModel]);

    // Actions
    const actions = {
        setDatabaseConnection: (connection) => {
            dispatch({ type: ActionTypes.SET_DATABASE_CONNECTION, payload: connection });
        },

        setSchema: (schema) => {
            dispatch({ type: ActionTypes.SET_SCHEMA, payload: schema });
        },

        setSelectedModel: (model) => {
            dispatch({ type: ActionTypes.SET_SELECTED_MODEL, payload: model });
        },

        setModels: (models) => {
            dispatch({ type: ActionTypes.SET_MODELS, payload: models });
        },

        setLoading: (loading) => {
            dispatch({ type: ActionTypes.SET_LOADING, payload: loading });
        },

        setError: (error) => {
            dispatch({ type: ActionTypes.SET_ERROR, payload: error });
        },

        clearError: () => {
            dispatch({ type: ActionTypes.CLEAR_ERROR });
        },

        resetApp: () => {
            setSavedConnection(null);
            setSavedModel('');
            dispatch({ type: ActionTypes.RESET_APP });
        }
    };

    // Computed values
    const computed = {
        isReady: state.isConnected && state.schema && state.selectedModel,
        currentStep: (() => {
            if (!state.isConnected) return 1;
            if (!state.schema) return 2;
            if (!state.selectedModel) return 3;
            return 4;
        })(),
        hasError: !!state.error
    };

    const value = {
        ...state,
        ...actions,
        ...computed
    };

    return (
        <AppContext.Provider value={value}>
            {children}
        </AppContext.Provider>
    );
};

// Hook para usar el contexto
export const useApp = () => {
    const context = useContext(AppContext);
    if (!context) {
        throw new Error('useApp must be used within an AppProvider');
    }
    return context;
};

// HOC para componentes que requieren conexión
export const withDatabaseConnection = (Component) => {
    return function ConnectedComponent(props) {
        const { isConnected, databaseConnection } = useApp();

        if (!isConnected) {
            return (
                <div className="text-center py-12">
                    <p className="text-gray-500 mb-4">Este componente requiere una conexión a base de datos</p>
                    <p className="text-sm text-gray-400">Por favor, conecta una base de datos primero</p>
                </div>
            );
        }

        return <Component {...props} databaseConnection={databaseConnection} />;
    };
};

// HOC para componentes que requieren esquema
export const withSchema = (Component) => {
    return function SchemaComponent(props) {
        const { schema, isConnected } = useApp();

        if (!isConnected) {
            return (
                <div className="text-center py-12">
                    <p className="text-gray-500">Conecta una base de datos primero</p>
                </div>
            );
        }

        if (!schema) {
            return (
                <div className="text-center py-12">
                    <p className="text-gray-500">Cargando esquema de la base de datos...</p>
                </div>
            );
        }

        return <Component {...props} schema={schema} />;
    };
};

export default AppContext;