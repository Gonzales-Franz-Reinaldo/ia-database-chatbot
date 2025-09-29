import { useState } from "react";
import DatabaseConnection from "./components/DatabaseConnection";
import SchemaViewer from "./components/SchemaViewer";
import ModelSelector from "./components/ModelSelector";
import Chatbot from "./components/Chatbot";
import { Database, Brain, MessageSquare, Github } from "lucide-react";
import "./App.css";

function App() {
  const [databaseConnection, setDatabaseConnection] = useState(null);
  const [schema, setSchema] = useState(null);
  const [selectedModel, setSelectedModel] = useState("");
  const [activeStep, setActiveStep] = useState(1);

  const handleConnectionSuccess = (connectionData) => {
    setDatabaseConnection(connectionData);
    setActiveStep(2);
  };

  const handleSchemaLoaded = (schemaData) => {
    setSchema(schemaData);
    setActiveStep(3);
  };

  const handleModelChange = (model) => {
    setSelectedModel(model);
    if (schema && model) {
      setActiveStep(4);
    }
  };

  const getStepStatus = (step) => {
    if (step < activeStep) return "completed";
    if (step === activeStep) return "active";
    return "pending";
  };

  const getStepClass = (status) => {
    const baseClasses = "w-12 h-12 rounded-full flex items-center justify-center font-semibold mb-2 transition-all duration-300";
    
    switch (status) {
      case "completed":
        return `${baseClasses} bg-green-500 text-white shadow-lg`;
      case "active":
        return `${baseClasses} bg-blue-500 text-white shadow-lg animate-pulse`;
      default:
        return `${baseClasses} bg-gray-300 text-gray-500`;
    }
  };

  const getStepTextClass = (status) => {
    const baseClasses = "text-sm font-medium transition-colors";
    
    switch (status) {
      case "active":
        return `${baseClasses} text-blue-600`;
      case "completed":
        return `${baseClasses} text-green-600`;
      default:
        return `${baseClasses} text-gray-500`;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Header */}
      <header className="bg-white/80 backdrop-blur-sm shadow-sm border-b border-gray-200/50 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex items-center gap-2">
                <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center shadow-lg">
                  <Database className="text-white" size={24} />
                </div>
                <div className="w-8 h-8 bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg flex items-center justify-center shadow-lg">
                  <Brain className="text-white" size={20} />
                </div>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  AI Database Chatbot
                </h1>
                <p className="text-sm text-gray-500">
                  Consulta tu base de datos usando IA powered by Ollama
                </p>
              </div>
            </div>

            <div className="flex items-center gap-4">
              <a
                href="https://github.com"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors px-3 py-2 rounded-lg hover:bg-gray-100"
              >
                <Github size={20} />
                <span className="hidden sm:inline">GitHub</span>
              </a>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Progress Steps */}
        <div className="mb-8">
          <div className="flex items-center justify-center space-x-4 sm:space-x-8">
            {[
              { number: 1, title: "Conectar BD", icon: Database },
              { number: 2, title: "Ver Esquema", icon: MessageSquare },
              { number: 3, title: "Seleccionar IA", icon: Brain },
              { number: 4, title: "Chatbot", icon: MessageSquare },
            ].map(({ number, title, icon: Icon }) => {
              const status = getStepStatus(number);
              return (
                <div key={number} className="flex flex-col items-center">
                  <div className={getStepClass(status)}>
                    {status === "completed" ? <Icon size={20} /> : number}
                  </div>
                  <span className={getStepTextClass(status)}>
                    {title}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Main Content */}
        <div className="space-y-6">
          {/* Paso 1: Conexión a Base de Datos */}
          <DatabaseConnection
            onConnectionSuccess={handleConnectionSuccess}
            isConnected={!!databaseConnection}
          />

          {/* Paso 2: Visualización del Esquema */}
          {databaseConnection && (
            <SchemaViewer
              databaseConnection={databaseConnection}
              onSchemaLoaded={handleSchemaLoaded}
            />
          )}

          {/* Paso 3: Selector de Modelo */}
          {schema && (
            <ModelSelector
              selectedModel={selectedModel}
              onModelChange={handleModelChange}
            />
          )}

          {/* Paso 4: Chatbot */}
          {schema && selectedModel && (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Chat Principal */}
              <div className="lg:col-span-2">
                <Chatbot
                  databaseConnection={databaseConnection}
                  schema={schema}
                  selectedModel={selectedModel}
                />
              </div>

              {/* Panel de Información */}
              <div className="space-y-4">
                {/* Estado Actual */}
                <div className="bg-white/80 backdrop-blur-sm rounded-xl shadow-lg p-6 border border-gray-200/50">
                  <h3 className="font-semibold text-gray-800 mb-4 flex items-center gap-2">
                    <span className="text-2xl">📊</span>
                    Estado Actual
                  </h3>
                  <div className="space-y-3 text-sm">
                    <div className="flex justify-between items-center p-2 bg-gray-50 rounded-lg">
                      <span className="text-gray-600">Base de Datos:</span>
                      <span className="font-medium text-blue-600 break-all text-right ml-2">
                        {databaseConnection?.database}
                      </span>
                    </div>
                    <div className="flex justify-between items-center p-2 bg-gray-50 rounded-lg">
                      <span className="text-gray-600">Tipo:</span>
                      <span className="font-medium text-green-600">
                        {databaseConnection?.type}
                      </span>
                    </div>
                    <div className="flex justify-between items-center p-2 bg-gray-50 rounded-lg">
                      <span className="text-gray-600">Tablas:</span>
                      <span className="font-medium text-purple-600">
                        {schema?.tables?.length || 0}
                      </span>
                    </div>
                    <div className="flex justify-between items-center p-2 bg-gray-50 rounded-lg">
                      <span className="text-gray-600">Modelo IA:</span>
                      <span className="font-medium text-xs text-orange-600 break-all text-right ml-2">
                        {selectedModel}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Ejemplos de Consultas */}
                <div className="bg-white/80 backdrop-blur-sm rounded-xl shadow-lg p-6 border border-gray-200/50">
                  <h3 className="font-semibold text-gray-800 mb-4 flex items-center gap-2">
                    <span className="text-2xl">💡</span>
                    Ejemplos de Consultas
                  </h3>
                  <div className="space-y-2 text-sm text-gray-600">
                    <div className="p-3 bg-gradient-to-r from-blue-50 to-blue-100 rounded-lg border-l-4 border-blue-400">
                      "¿Cuáles son las mejores notas?"
                    </div>
                    <div className="p-3 bg-gradient-to-r from-green-50 to-green-100 rounded-lg border-l-4 border-green-400">
                      "Muestra todos los estudiantes activos"
                    </div>
                    <div className="p-3 bg-gradient-to-r from-purple-50 to-purple-100 rounded-lg border-l-4 border-purple-400">
                      "Dame el promedio de ventas por mes"
                    </div>
                    <div className="p-3 bg-gradient-to-r from-orange-50 to-orange-100 rounded-lg border-l-4 border-orange-400">
                      "¿Cuántos usuarios hay en cada categoría?"
                    </div>
                  </div>
                </div>

                {/* Tips */}
                <div className="bg-gradient-to-br from-blue-50 to-indigo-100 rounded-xl p-6 border border-blue-200/50">
                  <h3 className="font-semibold text-blue-800 mb-4 flex items-center gap-2">
                    <span className="text-2xl">🚀</span>
                    Consejos
                  </h3>
                  <ul className="space-y-2 text-sm text-blue-700">
                    <li className="flex items-start gap-2">
                      <span className="text-blue-500 mt-1 flex-shrink-0">•</span>
                      <span>Usa preguntas naturales y específicas</span>
                    </li>
                    <li className="flex items-start gap-2">
                      <span className="text-blue-500 mt-1 flex-shrink-0">•</span>
                      <span>Menciona nombres de tablas si las conoces</span>
                    </li>
                    <li className="flex items-start gap-2">
                      <span className="text-blue-500 mt-1 flex-shrink-0">•</span>
                      <span>Pide ordenamiento (mejores, peores, top 10)</span>
                    </li>
                    <li className="flex items-start gap-2">
                      <span className="text-blue-500 mt-1 flex-shrink-0">•</span>
                      <span>Usa fechas y rangos para filtrar datos</span>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <footer className="mt-16 text-center text-gray-500 text-sm">
          <div className="border-t border-gray-200/50 pt-8">
            <p className="text-gray-600">
              Desarrollado con ❤️ usando FastAPI, React, Tailwind CSS y Ollama
            </p>
            <p className="mt-2 text-gray-500">Compatible con PostgreSQL y MySQL</p>
          </div>
        </footer>
      </main>
    </div>
  );
}

export default App;