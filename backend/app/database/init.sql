-- Esquema de ejemplo para pruebas
-- DB UNIVERSIDAD

-- Tabla de cursos
CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    creditos INTEGER DEFAULT 3,
    profesor VARCHAR(100),
    fecha_inicio DATE,
    fecha_fin DATE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de estudiantes
CREATE TABLE estudiantes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_nacimiento DATE,
    genero VARCHAR(10),
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_ingreso DATE DEFAULT CURRENT_DATE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de inscripciones (relación muchos a muchos)
CREATE TABLE inscripciones (
    id SERIAL PRIMARY KEY,
    estudiante_id INTEGER REFERENCES estudiantes(id),
    curso_id INTEGER REFERENCES cursos(id),
    fecha_inscripcion DATE DEFAULT CURRENT_DATE,
    estado VARCHAR(20) DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(estudiante_id, curso_id)
);

-- Tabla de notas
CREATE TABLE notas (
    id SERIAL PRIMARY KEY,
    estudiante_id INTEGER REFERENCES estudiantes(id),
    curso_id INTEGER REFERENCES cursos(id),
    tipo_evaluacion VARCHAR(50) NOT NULL,
    nota DECIMAL(4,2) NOT NULL CHECK (nota >= 0 AND nota <= 100),
    fecha_evaluacion DATE DEFAULT CURRENT_DATE,
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de profesores
CREATE TABLE profesores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    especialidad VARCHAR(100),
    titulo VARCHAR(100),
    telefono VARCHAR(20),
    fecha_contratacion DATE DEFAULT CURRENT_DATE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO profesores (nombre, apellido, email, especialidad, titulo) VALUES
('María', 'González', 'maria.gonzalez@escuela.edu', 'Matemáticas', 'Licenciatura en Matemáticas'),
('Carlos', 'Rodríguez', 'carlos.rodriguez@escuela.edu', 'Historia', 'Maestría en Historia'),
('Ana', 'López', 'ana.lopez@escuela.edu', 'Ciencias', 'Doctorado en Biología'),
('José', 'Martínez', 'jose.martinez@escuela.edu', 'Literatura', 'Licenciatura en Literatura'),
('Laura', 'Sánchez', 'laura.sanchez@escuela.edu', 'Inglés', 'Certificación TESOL');

INSERT INTO cursos (nombre, descripcion, creditos, profesor, fecha_inicio, fecha_fin) VALUES
('Cálculo I', 'Introducción al cálculo diferencial e integral', 4, 'María González', '2024-01-15', '2024-05-15'),
('Historia Mundial', 'Panorama de la historia mundial desde la antigüedad', 3, 'Carlos Rodríguez', '2024-01-15', '2024-05-15'),
('Biología General', 'Conceptos fundamentales de biología', 4, 'Ana López', '2024-01-15', '2024-05-15'),
('Literatura Española', 'Obras clásicas de la literatura en español', 3, 'José Martínez', '2024-01-15', '2024-05-15'),
('Inglés Avanzado', 'Perfeccionamiento del inglés como segunda lengua', 3, 'Laura Sánchez', '2024-01-15', '2024-05-15'),
('Álgebra Lineal', 'Vectores, matrices y transformaciones lineales', 4, 'María González', '2024-02-01', '2024-06-01'),
('Química Orgánica', 'Estudio de compuestos orgánicos', 4, 'Ana López', '2024-02-01', '2024-06-01');

INSERT INTO estudiantes (nombre, apellido, email, fecha_nacimiento, genero, telefono) VALUES
('Juan', 'Pérez', 'juan.perez@estudiante.edu', '2001-03-15', 'M', '555-0101'),
('María', 'García', 'maria.garcia@estudiante.edu', '2000-07-22', 'F', '555-0102'),
('Carlos', 'López', 'carlos.lopez@estudiante.edu', '2002-01-10', 'M', '555-0103'),
('Ana', 'Martínez', 'ana.martinez@estudiante.edu', '2001-09-05', 'F', '555-0104'),
('Luis', 'Rodríguez', 'luis.rodriguez@estudiante.edu', '2000-12-18', 'M', '555-0105'),
('Elena', 'Sánchez', 'elena.sanchez@estudiante.edu', '2001-05-30', 'F', '555-0106'),
('Miguel', 'Torres', 'miguel.torres@estudiante.edu', '2002-08-14', 'M', '555-0107'),
('Patricia', 'Ruiz', 'patricia.ruiz@estudiante.edu', '2001-11-25', 'F', '555-0108'),
('Roberto', 'Jiménez', 'roberto.jimenez@estudiante.edu', '2000-04-12', 'M', '555-0109'),
('Isabel', 'Morales', 'isabel.morales@estudiante.edu', '2002-02-28', 'F', '555-0110');

-- Inscribir estudiantes a cursos
INSERT INTO inscripciones (estudiante_id, curso_id) VALUES
(1, 1), (1, 2), (1, 5),
(2, 1), (2, 3), (2, 4),
(3, 2), (3, 4), (3, 5),
(4, 1), (4, 3), (4, 6),
(5, 2), (5, 3), (5, 7),
(6, 1), (6, 4), (6, 5),
(7, 2), (7, 6), (7, 7),
(8, 3), (8, 4), (8, 5),
(9, 1), (9, 2), (9, 6),
(10, 3), (10, 5), (10, 7);

-- Insertar notas de ejemplo
INSERT INTO notas (estudiante_id, curso_id, tipo_evaluacion, nota, fecha_evaluacion) VALUES
(1, 1, 'Examen Parcial', 85.5, '2024-03-01'),
(1, 1, 'Tarea', 92.0, '2024-03-15'),
(1, 1, 'Examen Final', 88.5, '2024-05-10'),
(2, 1, 'Examen Parcial', 78.0, '2024-03-01'),
(2, 1, 'Tarea', 85.5, '2024-03-15'),
(2, 1, 'Examen Final', 82.0, '2024-05-10'),
(4, 1, 'Examen Parcial', 95.0, '2024-03-01'),
(4, 1, 'Tarea', 98.5, '2024-03-15'),
(4, 1, 'Examen Final', 94.5, '2024-05-10'),
(1, 2, 'Ensayo', 87.0, '2024-03-20'),
(1, 2, 'Examen', 89.5, '2024-05-05'),
(3, 2, 'Ensayo', 91.5, '2024-03-20'),
(3, 2, 'Examen', 88.0, '2024-05-05'),
(5, 2, 'Ensayo', 79.5, '2024-03-20'),
(5, 2, 'Examen', 83.0, '2024-05-05'),
(2, 3, 'Laboratorio', 92.5, '2024-02-28'),
(2, 3, 'Examen', 87.0, '2024-04-15'),
(4, 3, 'Laboratorio', 88.5, '2024-02-28'),
(4, 3, 'Examen', 91.0, '2024-04-15'),
(5, 3, 'Laboratorio', 85.0, '2024-02-28'),
(5, 3, 'Examen', 89.5, '2024-04-15');

-- Crear índices para mejor rendimiento
CREATE INDEX idx_estudiantes_email ON estudiantes(email);
CREATE INDEX idx_inscripciones_estudiante ON inscripciones(estudiante_id);
CREATE INDEX idx_inscripciones_curso ON inscripciones(curso_id);
CREATE INDEX idx_notas_estudiante ON notas(estudiante_id);
CREATE INDEX idx_notas_curso ON notas(curso_id);
CREATE INDEX idx_notas_fecha ON notas(fecha_evaluacion);

-- Vistas útiles para consultas comunes
CREATE VIEW vista_estudiantes_cursos AS
SELECT 
    e.id as estudiante_id,
    e.nombre || ' ' || e.apellido as estudiante_nombre,
    e.email as estudiante_email,
    c.id as curso_id,
    c.nombre as curso_nombre,
    c.profesor,
    i.fecha_inscripcion,
    i.estado as estado_inscripcion
FROM estudiantes e
JOIN inscripciones i ON e.id = i.estudiante_id
JOIN cursos c ON i.curso_id = c.id
WHERE e.activo = true AND c.activo = true;

CREATE VIEW vista_promedios_estudiantes AS
SELECT 
    e.id as estudiante_id,
    e.nombre || ' ' || e.apellido as estudiante_nombre,
    c.id as curso_id,
    c.nombre as curso_nombre,
    ROUND(AVG(n.nota), 2) as promedio_notas,
    COUNT(n.id) as total_evaluaciones
FROM estudiantes e
JOIN notas n ON e.id = n.estudiante_id
JOIN cursos c ON n.curso_id = c.id
GROUP BY e.id, e.nombre, e.apellido, c.id, c.nombre;

-- Comentarios para documentación
COMMENT ON TABLE estudiantes IS 'Información de los estudiantes registrados';
COMMENT ON TABLE cursos IS 'Catálogo de cursos disponibles';
COMMENT ON TABLE inscripciones IS 'Registro de inscripciones estudiante-curso';
COMMENT ON TABLE notas IS 'Calificaciones de los estudiantes por curso';
COMMENT ON TABLE profesores IS 'Información del personal docente';