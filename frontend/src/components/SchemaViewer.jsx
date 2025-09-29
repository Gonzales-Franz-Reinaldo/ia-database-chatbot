import React, { useState, useEffect } from 'react';
import { Table, Columns, Key, Link, Eye, Loader2, RefreshCw, ChevronDown, ChevronUp } from 'lucide-react';
import { apiService } from '../services/api';

const SchemaViewer = ({ databaseConnection, onSchemaLoaded }) => {
    const [schema, setSchema] = useState(null);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);
    const [expandedTables, setExpandedTables] = useState({});
    const [sampleData, setSampleData] = useState({});
    const [loadingSampleData, setLoadingSampleData] = useState({});

    useEffect(() => {
        if (databaseConnection) {
            loadSchema();
        }
    }, [databaseConnection]);

    const loadSchema = async () => {
        setIsLoading(true);
        setError(null);

        try {
            const schemaData = await apiService.analyzeDatabaseSchema(databaseConnection);
            setSchema(schemaData);
            onSchemaLoaded(schemaData);
            
            // Expandir la primera tabla por defecto
            if (schemaData.tables.length > 0) {
                setExpandedTables({ [schemaData.tables[0].table_name]: true });
            }
        } catch (err) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    const loadSampleData = async (tableName) => {
        setLoadingSampleData(prev => ({ ...prev, [tableName]: true }));

        try {
            const data = await apiService.getSampleData(databaseConnection, tableName, 5);
            if (data.success) {
                setSampleData(prev => ({ ...prev, [tableName]: data.data }));
            }
        } catch (err) {
            console.error('Error loading sample data:', err);
        } finally {
            setLoadingSampleData(prev => ({ ...prev, [tableName]: false }));
        }
    };

    const toggleTable = (tableName) => {
        setExpandedTables(prev => ({
            ...prev,
            [tableName]: !prev[tableName]
        }));
    };

    const getColumnIcon = (column) => {
        if (column.name.toLowerCase().includes('id')) return <Key className="text-yellow-500" size={14} />;
        if (column.type.toLowerCase().includes('varchar') || column.type.toLowerCase().includes('text')) {
            return <span className="text-green-500 text-xs font-bold">T</span>;
        }
        if (column.type.toLowerCase().includes('int') || column.type.toLowerCase().includes('number')) {
            return <span className="text-blue-500 text-xs font-bold">N</span>;
        }
        if (column.type.toLowerCase().includes('date') || column.type.toLowerCase().includes('time')) {
            return <span className="text-purple-500 text-xs font-bold">D</span>;
        }
        return <span className="text-gray-400 text-xs font-bold">?</span>;
    };

    if (isLoading) {
        return (
            <div className="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg p-8 border border-gray-200/50">
                <div className="flex items-center justify-center gap-3">
                    <Loader2 className="animate-spin text-blue-500" size={32} />
                    <span className="text-lg text-gray-600">Analizando esquema de la base de datos...</span>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg p-6 border border-red-200/50">
                <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-3">
                        <XCircle className="text-red-500" size={24} />
                        <h3 className="text-lg font-semibold text-red-600">Error al cargar esquema</h3>
                    </div>
                    <button
                        onClick={loadSchema}
                        className="flex items-center gap-2 px-3 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                    >
                        <RefreshCw size={16} />
                        Reintentar
                    </button>
                </div>
                <p className="text-red-500">{error}</p>
            </div>
        );
    }

    if (!schema) return null;

    return (
        <div className="bg-white/90 backdrop-blur-sm rounded-xl shadow-lg p-6 mb-6 border border-gray-200/50 transition-all duration-300 hover:shadow-xl">
            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-3">
                    <div className="p-2 bg-green-100 rounded-lg">
                        <Table className="text-green-600" size={24} />
                    </div>
                    <div>
                        <h2 className="text-xl font-semibold text-gray-800">
                            Esquema de Base de Datos
                        </h2>
                        <p className="text-sm text-gray-500">{schema.database_name}</p>
                    </div>
                </div>
                <button
                    onClick={loadSchema}
                    className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
                    title="Actualizar esquema"
                >
                    <RefreshCw size={18} />
                </button>
            </div>

            <div className="space-y-4">
                {schema.tables.map((table) => (
                    <div key={table.table_name} className="border border-gray-200 rounded-lg overflow-hidden transition-all duration-200 hover:border-gray-300">
                        {/* Cabecera de la tabla */}
                        <div 
                            className="bg-gradient-to-r from-gray-50 to-gray-100 px-4 py-3 flex items-center justify-between cursor-pointer hover:from-gray-100 hover:to-gray-200 transition-colors"
                            onClick={() => toggleTable(table.table_name)}
                        >
                            <div className="flex items-center gap-3">
                                {expandedTables[table.table_name] ? (
                                    <ChevronUp className="text-gray-600" size={20} />
                                ) : (
                                    <ChevronDown className="text-gray-600" size={20} />
                                )}
                                <Table className="text-gray-600" size={20} />
                                <h3 className="font-semibold text-gray-800">{table.table_name}</h3>
                                <span className="text-sm text-gray-500 bg-white px-2 py-1 rounded-full">
                                    {table.columns.length} columnas
                                </span>
                            </div>
                            <button
                                onClick={(e) => {
                                    e.stopPropagation();
                                    loadSampleData(table.table_name);
                                }}
                                disabled={loadingSampleData[table.table_name]}
                                className="flex items-center gap-2 px-3 py-1 text-sm bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                                {loadingSampleData[table.table_name] ? (
                                    <Loader2 className="animate-spin" size={14} />
                                ) : (
                                    <Eye size={14} />
                                )}
                                <span className="hidden sm:inline">Ver datos</span>
                            </button>
                        </div>

                        {/* Contenido expandible */}
                        {expandedTables[table.table_name] && (
                            <div className="p-4 bg-white">
                                {/* Columnas */}
                                <div className="mb-4">
                                    <h4 className="font-medium text-gray-700 mb-3 flex items-center gap-2">
                                        <Columns size={16} />
                                        Columnas
                                    </h4>
                                    <div className="grid gap-2">
                                        {table.columns.map((column) => (
                                            <div key={column.name} className="flex items-center gap-3 p-3 rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors">
                                                <div className="flex items-center justify-center w-6 h-6">
                                                    {getColumnIcon(column)}
                                                </div>
                                                <span className="font-medium text-gray-800">{column.name}</span>
                                                <span className="text-sm text-gray-500 bg-white px-2 py-1 rounded">
                                                    {column.type}
                                                </span>
                                                {!column.nullable && (
                                                    <span className="text-xs bg-red-100 text-red-600 px-2 py-1 rounded font-medium">
                                                        NOT NULL
                                                    </span>
                                                )}
                                                {table.primary_keys.includes(column.name) && (
                                                    <span className="text-xs bg-yellow-100 text-yellow-700 px-2 py-1 rounded flex items-center gap-1 font-medium">
                                                        <Key size={10} />
                                                        PK
                                                    </span>
                                                )}
                                            </div>
                                        ))}
                                    </div>
                                </div>

                                {/* Claves foráneas */}
                                {table.foreign_keys.length > 0 && (
                                    <div className="mb-4">
                                        <h4 className="font-medium text-gray-700 mb-3 flex items-center gap-2">
                                            <Link size={16} />
                                            Claves Foráneas
                                        </h4>
                                        <div className="space-y-2">
                                            {table.foreign_keys.map((fk, index) => (
                                                <div key={index} className="text-sm text-gray-700 bg-blue-50 p-3 rounded-lg border border-blue-100">
                                                    <span className="font-medium text-blue-700">{fk.column}</span>
                                                    <span className="text-gray-400 mx-2">→</span>
                                                    <span className="font-medium text-blue-700">{fk.referenced_table}.{fk.referenced_column}</span>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* Datos de muestra */}
                                {sampleData[table.table_name] && (
                                    <div>
                                        <h4 className="font-medium text-gray-700 mb-3 flex items-center gap-2">
                                            <Eye size={16} />
                                            Datos de Muestra
                                        </h4>
                                        <div className="overflow-x-auto rounded-lg border border-gray-200">
                                            <table className="min-w-full text-sm">
                                                <thead>
                                                    <tr className="bg-gray-100 border-b border-gray-200">
                                                        {table.columns.map((column) => (
                                                            <th key={column.name} className="px-4 py-3 text-left font-medium text-gray-700 whitespace-nowrap">
                                                                {column.name}
                                                            </th>
                                                        ))}
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {sampleData[table.table_name].slice(0, 3).map((row, rowIndex) => (
                                                        <tr key={rowIndex} className="border-b border-gray-100 hover:bg-gray-50 transition-colors">
                                                            {table.columns.map((column) => (
                                                                <td key={column.name} className="px-4 py-3 text-gray-600">
                                                                    {row[column.name] !== null ? (
                                                                        <span className="max-w-xs truncate block">
                                                                            {String(row[column.name])}
                                                                        </span>
                                                                    ) : (
                                                                        <span className="text-gray-400 italic">null</span>
                                                                    )}
                                                                </td>
                                                            ))}
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                ))}
            </div>

            {/* Resumen */}
            <div className="mt-6 p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg border border-blue-100">
                <h4 className="font-medium text-blue-800 mb-3 flex items-center gap-2">
                    <span className="text-xl">📊</span>
                    Resumen del Esquema
                </h4>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
                    <div className="bg-white p-3 rounded-lg">
                        <span className="text-gray-600 block mb-1">Tablas:</span>
                        <span className="font-semibold text-blue-600 text-lg">{schema.tables.length}</span>
                    </div>
                    <div className="bg-white p-3 rounded-lg">
                        <span className="text-gray-600 block mb-1">Total Columnas:</span>
                        <span className="font-semibold text-green-600 text-lg">
                            {schema.tables.reduce((acc, table) => acc + table.columns.length, 0)}
                        </span>
                    </div>
                    <div className="bg-white p-3 rounded-lg">
                        <span className="text-gray-600 block mb-1">Claves Foráneas:</span>
                        <span className="font-semibold text-purple-600 text-lg">
                            {schema.tables.reduce((acc, table) => acc + table.foreign_keys.length, 0)}
                        </span>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default SchemaViewer;