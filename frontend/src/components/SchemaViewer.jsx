import React, { useState, useEffect } from 'react';
import { Table, Columns, Key, Link, Eye, Loader2, RefreshCw } from 'lucide-react';
import { apiService } from '../services/api';

const SchemaViewer = ({ databaseConnection, onSchemaLoaded }) => {
    const [schema, setSchema] = useState(null);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);
    const [selectedTable, setSelectedTable] = useState(null);
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
            <div className="bg-white rounded-lg shadow-lg p-8">
                <div className="flex items-center justify-center">
                    <Loader2 className="animate-spin text-blue-500" size={32} />
                    <span className="ml-3 text-lg text-gray-600">Analizando esquema de la base de datos...</span>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-white rounded-lg shadow-lg p-6">
                <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold text-red-600">Error al cargar esquema</h3>
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
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <div className="flex items-center gap-3 mb-6">
                <Table className="text-green-500" size={24} />
                <h2 className="text-xl font-semibold text-gray-800">
                    Esquema: {schema.database_name}
                </h2>
                <button
                    onClick={loadSchema}
                    className="ml-auto p-2 text-gray-500 hover:text-gray-700 transition-colors"
                    title="Actualizar esquema"
                >
                    <RefreshCw size={16} />
                </button>
            </div>

            <div className="grid gap-4">
                {schema.tables.map((table) => (
                    <div key={table.table_name} className="border border-gray-200 rounded-lg overflow-hidden">
                        {/* Cabecera de la tabla */}
                        <div className="bg-gray-50 px-4 py-3 flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <Table className="text-gray-600" size={20} />
                                <h3 className="font-semibold text-gray-800">{table.table_name}</h3>
                                <span className="text-sm text-gray-500">
                                    ({table.columns.length} columnas)
                                </span>
                            </div>
                            <button
                                onClick={() => loadSampleData(table.table_name)}
                                disabled={loadingSampleData[table.table_name]}
                                className="flex items-center gap-2 px-3 py-1 text-sm bg-blue-100 text-blue-600 rounded-lg hover:bg-blue-200 transition-colors disabled:opacity-50"
                            >
                                {loadingSampleData[table.table_name] ? (
                                    <Loader2 className="animate-spin" size={14} />
                                ) : (
                                    <Eye size={14} />
                                )}
                                Ver datos
                            </button>
                        </div>

                        {/* Columnas */}
                        <div className="p-4">
                            <div className="grid gap-2 mb-4">
                                {table.columns.map((column) => (
                                    <div key={column.name} className="flex items-center gap-3 p-2 rounded bg-gray-50">
                                        {getColumnIcon(column)}
                                        <span className="font-medium text-gray-800">{column.name}</span>
                                        <span className="text-sm text-gray-500">({column.type})</span>
                                        {!column.nullable && (
                                            <span className="text-xs bg-red-100 text-red-600 px-2 py-1 rounded">NOT NULL</span>
                                        )}
                                        {table.primary_keys.includes(column.name) && (
                                            <span className="text-xs bg-yellow-100 text-yellow-700 px-2 py-1 rounded flex items-center gap-1">
                                                <Key size={10} />
                                                PK
                                            </span>
                                        )}
                                    </div>
                                ))}
                            </div>

                            {/* Claves foráneas */}
                            {table.foreign_keys.length > 0 && (
                                <div className="mb-4">
                                    <h4 className="font-medium text-gray-700 mb-2 flex items-center gap-2">
                                        <Link size={16} />
                                        Claves Foráneas
                                    </h4>
                                    <div className="space-y-1">
                                        {table.foreign_keys.map((fk, index) => (
                                            <div key={index} className="text-sm text-gray-600 bg-blue-50 p-2 rounded">
                                                <span className="font-medium">{fk.column}</span>
                                                <span className="text-gray-400"> → </span>
                                                <span className="font-medium">{fk.referenced_table}.{fk.referenced_column}</span>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}

                            {/* Datos de muestra */}
                            {sampleData[table.table_name] && (
                                <div>
                                    <h4 className="font-medium text-gray-700 mb-2">Datos de Muestra</h4>
                                    <div className="overflow-x-auto">
                                        <table className="min-w-full text-sm">
                                            <thead>
                                                <tr className="bg-gray-100">
                                                    {table.columns.map((column) => (
                                                        <th key={column.name} className="px-3 py-2 text-left font-medium text-gray-700">
                                                            {column.name}
                                                        </th>
                                                    ))}
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {sampleData[table.table_name].slice(0, 3).map((row, rowIndex) => (
                                                    <tr key={rowIndex} className="border-t">
                                                        {table.columns.map((column) => (
                                                            <td key={column.name} className="px-3 py-2 text-gray-600">
                                                                {row[column.name] !== null ? String(row[column.name]) : (
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
                    </div>
                ))}
            </div>

            {/* Resumen */}
            <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <h4 className="font-medium text-blue-800 mb-2">📊 Resumen del Esquema</h4>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm text-blue-700">
                    <div>
                        <span className="font-medium">Tablas:</span> {schema.tables.length}
                    </div>
                    <div>
                        <span className="font-medium">Total de Columnas:</span> {' '}
                        {schema.tables.reduce((acc, table) => acc + table.columns.length, 0)}
                    </div>
                    <div>
                        <span className="font-medium">Claves Foráneas:</span> {' '}
                        {schema.tables.reduce((acc, table) => acc + table.foreign_keys.length, 0)}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default SchemaViewer;