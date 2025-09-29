import React from 'react';
import { AlertTriangle, RefreshCw, Variable } from 'lucide-react';
import dotenv from 'dotenv';
dotenv.config();

class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false, error: null, errorInfo: null };
    }

    static getDerivedStateFromError() {
        return { hasError: true };
    }

    componentDidCatch(error, errorInfo) {
        this.setState({
            error: error,
            errorInfo: errorInfo
        });
    }

    render() {
        if (this.state.hasError) {
            return (
                <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-lg shadow-lg p-8 max-w-lg w-full">
                        <div className="text-center">
                            <AlertTriangle className="mx-auto text-red-500 mb-4" size={48} />
                            <h2 className="text-2xl font-bold text-gray-800 mb-4">
                                ¡Oops! Algo salió mal
                            </h2>
                            <p className="text-gray-600 mb-6">
                                Ha ocurrido un error inesperado en la aplicación. Por favor, intenta recargar la página.
                            </p>

                            {/* Información del error para desarrollo */}
                            {import.meta.env.VITE_NODE_ENV === 'development' && this.state.error && (
                                <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-left mb-6">
                                    <h3 className="font-semibold text-red-800 mb-2">Error Details:</h3>
                                    <pre className="text-xs text-red-700 overflow-x-auto whitespace-pre-wrap">
                                        {this.state.error.toString()}
                                        {this.state.errorInfo.componentStack}
                                    </pre>
                                </div>
                            )}

                            <button
                                onClick={() => window.location.reload()}
                                className="flex items-center gap-2 mx-auto px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                            >
                                <RefreshCw size={16} />
                                Recargar Página
                            </button>
                        </div>
                    </div>
                </div>
            );
        }

        return this.props.children;
    }
}

export default ErrorBoundary;