-- ================================ DATOS BÁSICOS GEOGRÁFICOS ================================
INSERT INTO paises (nombre) VALUES
('Bolivia'),
('Argentina'),
('Brasil'),
('Chile'),
('Perú'),
('Colombia'),
('Ecuador'),
('Venezuela'),
('Paraguay'),
('Uruguay');

INSERT INTO departamentos (id_pais, nombre) VALUES
(1, 'Potosí'),
(1, 'La Paz'),
(1, 'Cochabamba'),
(1, 'Santa Cruz'),
(1, 'Oruro'),
(1, 'Tarija'),
(1, 'Chuquisaca'),
(1, 'Beni'),
(1, 'Pando'),
(2, 'Buenos Aires');

INSERT INTO provincias (id_departamento, nombre) VALUES
(1, 'Tomás Frías'),
(1, 'Rafael Bustillo'),
(1, 'Cornelio Saavedra'),
(2, 'Murillo'),
(2, 'Omasuyos'),
(3, 'Cercado'),
(4, 'Andrés Ibáñez'),
(5, 'Cercado'),
(6, 'Cercado'),
(7, 'Oropeza');

INSERT INTO localidades (id_provincia, nombre) VALUES
(1, 'Potosí'),
(1, 'Yocalla'),
(2, 'Llallagua'),
(2, 'Uncía'),
(3, 'Betanzos'),
(4, 'La Paz'),
(5, 'Achacachi'),
(6, 'Cochabamba'),
(7, 'Santa Cruz'),
(8, 'Oruro');

-- ======================= DATOS DE CONFIGURACIÓN PERSONAL =======================
INSERT INTO grupos_sanguineos (nombre) VALUES
('O+'),
('O-'),
('A+'),
('A-'),
('B+'),
('B-'),
('AB+'),
('AB-');

INSERT INTO sexos (nombre) VALUES
('Masculino'),
('Femenino');

INSERT INTO estados_civiles (nombre) VALUES
('Soltero'),
('Casado'),
('Divorciado'),
('Viudo'),
('Concubino');

INSERT INTO emision_cedulas (nombre, descripcion) VALUES
('PT', 'Potosí'),
('LP', 'La Paz'),
('CB', 'Cochabamba'),
('SC', 'Santa Cruz'),
('OR', 'Oruro'),
('TJ', 'Tarija'),
('CH', 'Chuquisaca'),
('BN', 'Beni'),
('PD', 'Pando'),
('EX', 'Extranjero');

-- ========================= ESTRUCTURA ORGANIZACIONAL =========================
INSERT INTO universidades (nombre, nombre_abreviado, inicial) VALUES
('Universidad Autónoma Tomás Frías', 'UATF', 'UATF'),
('Universidad Mayor de San Andrés', 'UMSA', 'UMSA'),
('Universidad Mayor de San Simón', 'UMSS', 'UMSS');

INSERT INTO configuraciones (id_universidad, tipo, descripcion) VALUES
(1, 'LOGO', 'Logo institucional principal'),
(1, 'CABECERA', 'Cabecera para documentos oficiales'),
(1, 'PIE_PAGINA', 'Pie de página institucional'),
(1, 'TELEFONO', '2622587'),
(1, 'EMAIL', 'info@uatf.edu.bo'),
(1, 'DIRECCION', 'Av. Cívica s/n'),
(2, 'LOGO', 'Logo UMSA'),
(2, 'EMAIL', 'info@umsa.edu.bo'),
(3, 'LOGO', 'Logo UMSS'),
(3, 'EMAIL', 'info@umss.edu.bo');

INSERT INTO areas (id_universidad, nombre, nombre_abreviado) VALUES
(1, 'Área de Ciencias y Tecnología', 'ACT'),
(1, 'Área de Salud', 'AS'),
(1, 'Área Social Humanística', 'ASH'),
(2, 'Área Tecnológica', 'AT'),
(2, 'Área de Salud', 'AS'),
(3, 'Área de Ingeniería', 'AI'),
(3, 'Área de Ciencias Sociales', 'ACS'),
(1, 'Área de Ciencias Económicas', 'ACE'),
(1, 'Área de Arquitectura', 'AA'),
(1, 'Área de Derecho', 'AD');

INSERT INTO facultades (id_area, nombre, nombre_abreviado, direccion, telefono, email, fecha_creacion) VALUES
(1, 'Facultad de Ingeniería', 'FI', 'Av. Cívica s/n', '2622587', 'ingenieria@uatf.edu.bo', '1892-07-06'),
(1, 'Facultad de Ciencias', 'FC', 'Av. Cívica s/n', '2623456', 'ciencias@uatf.edu.bo', '1950-03-15'),
(2, 'Facultad de Medicina', 'FM', 'Av. Maestro s/n', '2624567', 'medicina@uatf.edu.bo', '1963-05-20'),
(3, 'Facultad de Ciencias Sociales', 'FCS', 'Plaza 10 de Noviembre', '2625678', 'sociales@uatf.edu.bo', '1970-08-12'),
(8, 'Facultad de Ciencias Económicas', 'FCE', 'Calle Quijarro', '2626789', 'economia@uatf.edu.bo', '1975-04-18'),
(9, 'Facultad de Arquitectura', 'FA', 'Av. Universitaria', '2627890', 'arquitectura@uatf.edu.bo', '1985-09-25'),
(10, 'Facultad de Derecho', 'FD', 'Plaza Arce', '2628901', 'derecho@uatf.edu.bo', '1960-11-10'),
(4, 'Facultad de Tecnología UMSA', 'FT', 'La Paz', '2234567', 'tecnologia@umsa.edu.bo', '1980-01-15'),
(5, 'Facultad de Medicina UMSA', 'FMED', 'La Paz', '2234568', 'medicina@umsa.edu.bo', '1945-06-20'),
(6, 'Facultad de Ingeniería UMSS', 'FING', 'Cochabamba', '4234567', 'ingenieria@umss.edu.bo', '1960-03-10');

-- =========================== GESTIÓN DE AMBIENTES ===========================
INSERT INTO campus (nombre, direccion, latitud, longitud) VALUES
('Campus Central UATF', 'Av. Cívica s/n', '-19.5723', '-65.7550'),
('Campus Villa Imperial', 'Av. Maestro s/n', '-19.5800', '-65.7600'),
('Campus Norte', 'Zona Norte', '-19.5650', '-65.7500'),
('Campus UMSA La Paz', 'Plaza del Estudiante', '-16.5000', '-68.1500'),
('Campus UMSS Cochabamba', 'Av. Jordán', '-17.3935', '-66.1570');

INSERT INTO edificios (id_campus, nombre, direccion, latitud, longitud) VALUES
(1, 'Edificio Central', 'Av. Cívica s/n', '-19.5723', '-65.7550'),
(1, 'Edificio de Ingeniería', 'Av. Cívica s/n', '-19.5725', '-65.7552'),
(1, 'Edificio de Ciencias', 'Av. Cívica s/n', '-19.5720', '-65.7548'),
(2, 'Edificio de Medicina', 'Av. Maestro s/n', '-19.5800', '-65.7600'),
(1, 'Edificio de Derecho', 'Plaza Arce', '-19.5730', '-65.7560'),
(1, 'Edificio de Economía', 'Calle Quijarro', '-19.5710', '-65.7540'),
(3, 'Edificio Postgrado', 'Zona Norte', '-19.5650', '-65.7500'),
(4, 'Edificio UMSA Central', 'Plaza del Estudiante', '-16.5000', '-68.1500'),
(5, 'Edificio UMSS Principal', 'Av. Jordán', '-17.3935', '-66.1570'),
(1, 'Biblioteca Central', 'Av. Cívica s/n', '-19.5728', '-65.7555');

INSERT INTO facultades_edificios (id_facultad, id_edificio, fecha_asignacion) VALUES
(1, 2, '2020-01-01'),
(2, 3, '2020-01-01'),
(3, 4, '2020-01-01'),
(4, 1, '2020-01-01'),
(5, 6, '2020-01-01'),
(6, 1, '2020-01-01'),
(7, 5, '2020-01-01'),
(1, 7, '2021-01-01'),
(8, 8, '2020-01-01'),
(9, 9, '2020-01-01');

INSERT INTO bloques (id_edificio, nombre) VALUES
(1, 'Bloque A'),
(1, 'Bloque B'),
(2, 'Bloque Ingeniería A'),
(2, 'Bloque Ingeniería B'),
(3, 'Bloque Ciencias'),
(4, 'Bloque Medicina'),
(5, 'Bloque Derecho'),
(6, 'Bloque Economía'),
(7, 'Bloque Postgrado A'),
(7, 'Bloque Postgrado B');

INSERT INTO pisos (numero, nombre) VALUES
(-1, 'Planta Baja'),
(0, 'Piso 0'),
(1, 'Primer Piso'),
(2, 'Segundo Piso'),
(3, 'Tercer Piso'),
(4, 'Cuarto Piso'),
(5, 'Quinto Piso');

INSERT INTO pisos_bloques (id_bloque, id_piso, nombre, cantidad_ambientes) VALUES
(1, 1, 'Planta Baja - Bloque A', 10),
(1, 3, 'Primer Piso - Bloque A', 8),
(2, 1, 'Planta Baja - Bloque B', 12),
(3, 1, 'Planta Baja - Ing A', 15),
(3, 3, 'Primer Piso - Ing A', 12),
(4, 1, 'Planta Baja - Ing B', 10),
(5, 1, 'Planta Baja - Ciencias', 8),
(6, 1, 'Planta Baja - Medicina', 20),
(9, 1, 'Planta Baja - Post A', 6),
(9, 3, 'Primer Piso - Post A', 8);

INSERT INTO tipos_ambientes (nombre) VALUES
('Aula'),
('Laboratorio de Computación'),
('Laboratorio de Física'),
('Laboratorio de Química'),
('Sala de Conferencias'),
('Auditorio'),
('Oficina'),
('Biblioteca'),
('Aula Virtual'),
('Sala de Reuniones');

INSERT INTO ambientes (id_piso_bloque, id_tipo_ambiente, nombre, codigo, capacidad, metro_cuadrado) VALUES
(1, 1, 'Aula 101', 'A-101', 40, 80.5),
(1, 1, 'Aula 102', 'A-102', 35, 75.0),
(2, 1, 'Aula 201', 'A-201', 50, 100.0),
(3, 2, 'Lab. Comp 1', 'LC-01', 30, 90.0),
(4, 1, 'Aula Ing 101', 'AI-101', 45, 95.0),
(5, 3, 'Lab. Física 1', 'LF-01', 25, 120.0),
(6, 1, 'Aula Ing B1', 'AIB-01', 40, 85.0),
(7, 4, 'Lab. Química 1', 'LQ-01', 20, 110.0),
(9, 9, 'Aula Virtual 1', 'AV-01', 60, 150.0),
(10, 5, 'Sala Conf. 1', 'SC-01', 80, 200.0);

-- ========================= SISTEMA DE ROLES Y MENÚS =========================
INSERT INTO modulos (nombre) VALUES
('Administración'),
('Postgrado'),
('Pregrado'),
('Académico'),
('Financiero'),
('Recursos Humanos'),
('Biblioteca'),
('Investigación'),
('Extensión'),
('Planificación');

INSERT INTO menus_principales (id_modulo, nombre, icono, orden) VALUES
(1, 'Gestión de Usuarios', 'fas fa-users', 1),
(1, 'Configuraciones', 'fas fa-cog', 2),
(2, 'Programas de Postgrado', 'fas fa-graduation-cap', 1),
(2, 'Gestión Académica', 'fas fa-book', 2),
(2, 'Gestión Financiera', 'fas fa-money-bill', 3),
(3, 'Carreras de Pregrado', 'fas fa-university', 1),
(4, 'Planillas de Notas', 'fas fa-clipboard-list', 1),
(4, 'Horarios', 'fas fa-calendar', 2),
(5, 'Facturación', 'fas fa-file-invoice', 1),
(6, 'Personal Docente', 'fas fa-chalkboard-teacher', 1);

INSERT INTO menus (id_menu_principal, nombre, directorio, icono, orden) VALUES
(1, 'Usuarios del Sistema', '/admin/usuarios', 'fas fa-user', 1),
(1, 'Roles y Permisos', '/admin/roles', 'fas fa-key', 2),
(2, 'Configuración General', '/admin/config', 'fas fa-tools', 1),
(3, 'Crear Programa', '/postgrado/crear', 'fas fa-plus', 1),
(3, 'Lista de Programas', '/postgrado/lista', 'fas fa-list', 2),
(4, 'Materias', '/postgrado/materias', 'fas fa-book-open', 1),
(4, 'Asignación Docentes', '/postgrado/asignaciones', 'fas fa-user-tie', 2),
(5, 'Contratos', '/postgrado/contratos', 'fas fa-file-contract', 1),
(5, 'Pagos y Transacciones', '/postgrado/pagos', 'fas fa-credit-card', 2),
(6, 'Gestión de Carreras', '/pregrado/carreras', 'fas fa-building', 1);

INSERT INTO roles (nombre, descripcion) VALUES
('Super Administrador', 'Acceso total al sistema'),
('Director de Postgrado', 'Gestión de programas de postgrado'),
('Administrador de Facultad', 'Gestión administrativa de facultad'),
('Docente', 'Acceso a funciones docentes'),
('Secretaria Académica', 'Gestión académica y registros'),
('Tesorero', 'Gestión financiera y pagos'),
('Decano', 'Gestión de facultad'),
('Estudiante', 'Acceso a información académica'),
('Bibliotecario', 'Gestión de biblioteca'),
('Coordinador Académico', 'Coordinación académica');

INSERT INTO roles_menus_principales (id_rol, id_menu_principal) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
(2, 3), (2, 4), (2, 5),
(3, 3), (3, 5),
(4, 4), (4, 7),
(5, 4), (5, 7),
(6, 5), (6, 9),
(7, 3), (7, 4),
(8, 4),
(9, 4),
(10, 4), (10, 7);

-- ========================= GESTIÓN ACADÉMICA =========================
INSERT INTO carreras_niveles_academicos (nombre, descripcion) VALUES
('Pregrado', 'Carreras de nivel de licenciatura'),
('Técnico Superior', 'Carreras técnicas superiores'),
('Postgrado', 'Programas de especialización superior');

INSERT INTO niveles_academicos (nombre, descripcion) VALUES
('Diplomado', 'Programa de especialización de 120 horas académicas'),
('Especialidad', 'Programa de especialización de 600 horas académicas'),
('Maestría', 'Programa de maestría de 1000 horas académicas'),
('Doctorado', 'Programa doctoral de investigación'),
('Post-Doctorado', 'Programa post-doctoral de investigación');

INSERT INTO sedes (nombre) VALUES
('Local Potosí'),
('Llallagua'),
('Uyuni'),
('Villazón'),
('Uncía'),
('Betanzos'),
('Virtual'),
('Tupiza'),
('Colquechaca'),
('Yocalla');

INSERT INTO modalidades (nombre, descripcion) VALUES
('Presencial', 'Clases presenciales en aula'),
('Virtual', 'Clases completamente virtuales'),
('Semi-presencial', 'Modalidad híbrida presencial-virtual'),
('A distancia', 'Educación a distancia'),
('Intensiva', 'Modalidad intensiva de fin de semana');

INSERT INTO carreras (id_facultad, id_modalidad, id_carrera_nivel_academico, id_sede, nombre, nombre_abreviado, fecha_creacion, email) VALUES
(1, 1, 1, 1, 'Ingeniería de Sistemas', 'Ing. Sistemas', '1995-03-15', 'sistemas@uatf.edu.bo'),
(1, 1, 1, 1, 'Ingeniería Civil', 'Ing. Civil', '1892-07-06', 'civil@uatf.edu.bo'),
(1, 1, 1, 1, 'Ingeniería de Minas', 'Ing. Minas', '1892-07-06', 'minas@uatf.edu.bo'),
(2, 1, 1, 1, 'Biología', 'Biología', '1950-03-15', 'biologia@uatf.edu.bo'),
(3, 1, 1, 1, 'Medicina', 'Medicina', '1963-05-20', 'medicina@uatf.edu.bo'),
(5, 1, 1, 1, 'Contaduría Pública', 'C.P.', '1975-04-18', 'contaduria@uatf.edu.bo'),
(5, 1, 1, 1, 'Administración de Empresas', 'Adm. Emp.', '1975-04-18', 'administracion@uatf.edu.bo'),
(6, 1, 1, 1, 'Arquitectura', 'Arquitectura', '1985-09-25', 'arquitectura@uatf.edu.bo'),
(7, 1, 1, 1, 'Derecho', 'Derecho', '1960-11-10', 'derecho@uatf.edu.bo'),
(4, 2, 1, 7, 'Trabajo Social', 'T. Social', '1970-08-12', 'social@uatf.edu.bo');

-- ========================= PERSONAS Y DATOS PERSONALES =========================
INSERT INTO personas (id_localidad, numero_identificacion_personal, id_emision_cedula, paterno, materno, nombre, id_sexo, id_grupo_sanguineo, fecha_nacimiento, direccion, telefono_celular, id_estado_civil, email) VALUES
(1, '4567890', 1, 'García', 'López', 'Juan Carlos', 1, 1, '1980-05-15', 'Av. Serrudo 123', '70123456', 2, 'jgarcia@email.com'),
(1, '3456789', 1, 'Mamani', 'Quispe', 'María Elena', 2, 2, '1985-08-20', 'Calle Bolívar 456', '71234567', 1, 'mmamani@email.com'),
(1, '5678901', 1, 'Rodríguez', 'Pérez', 'Carlos Alberto', 1, 3, '1975-12-10', 'Av. Cívica 789', '72345678', 2, 'crodriguez@email.com'),
(1, '6789012', 1, 'Condori', 'Huanca', 'Ana Lucia', 2, 1, '1990-03-25', 'Calle Sucre 321', '73456789', 1, 'acondori@email.com'),
(2, '7890123', 1, 'Vargas', 'Silva', 'Roberto Miguel', 1, 4, '1982-07-18', 'Av. Maestro 654', '74567890', 2, 'rvargas@email.com'),
(1, '8901234', 1, 'Flores', 'Mendoza', 'Patricia Rosa', 2, 2, '1987-11-08', 'Calle Matos 987', '75678901', 1, 'pflores@email.com'),
(1, '9012345', 1, 'Choque', 'Nina', 'Luis Fernando', 1, 1, '1979-04-12', 'Av. Universitaria 147', '76789012', 2, 'lchoque@email.com'),
(1, '0123456', 1, 'Salinas', 'Torres', 'Carmen Gloria', 2, 3, '1983-09-30', 'Calle Junín 258', '77890123', 1, 'csalinas@email.com'),
(3, '1234567', 1, 'Mendoza', 'Ramos', 'Diego Alejandro', 1, 2, '1988-01-14', 'Av. Potosí 369', '78901234', 1, 'dmendoza@email.com'),
(1, '2345678', 1, 'Ticona', 'Apaza', 'Silvia Beatriz', 2, 4, '1986-06-22', 'Calle Ayacucho 741', '79012345', 2, 'sticona@email.com');

-- ========================= USUARIOS DEL SISTEMA =========================
INSERT INTO usuarios (id_persona, nombre_email, password, tipo, fecha_finalizacion) VALUES
(1, 'jgarcia@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(2, 'mmamani@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(3, 'crodriguez@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(4, 'acondori@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(5, 'rvargas@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(6, 'pflores@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(7, 'lchoque@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(8, 'csalinas@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(9, 'dmendoza@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31'),
(10, 'sticona@uatf.edu.bo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, '2025-12-31');

-- ========================= ASIGNACIÓN DE ROLES =========================
INSERT INTO tipos_personas (id_persona, id_rol, tipo) VALUES
(1, 1, 'A'), -- Super Admin
(2, 2, 'A'), -- Director Postgrado
(3, 4, 'D'), -- Docente
(4, 5, 'A'), -- Secretaria
(5, 4, 'D'), -- Docente
(6, 6, 'A'), -- Tesorero
(7, 7, 'A'), -- Decano
(8, 8, 'E'), -- Estudiante
(9, 4, 'D'), -- Docente
(10, 3, 'A'); -- Admin Facultad

INSERT INTO personas_roles (id_persona, id_rol, fecha_asignacion) VALUES
(1, 1, '2024-01-01'),
(2, 2, '2024-01-01'),
(3, 4, '2024-01-01'),
(4, 5, '2024-01-01'),
(5, 4, '2024-01-01'),
(6, 6, '2024-01-01'),
(7, 7, '2024-01-01'),
(8, 8, '2024-01-01'),
(9, 4, '2024-01-01'),
(10, 3, '2024-01-01');

-- ========================= PERSONAL ACADÉMICO =========================
INSERT INTO personas_docentes (id_persona, fecha_ingreso) VALUES
(3, '2015-03-01'),
(5, '2018-08-15'),
(9, '2020-02-10'),
(1, '2010-01-15'),
(7, '2012-06-20');

INSERT INTO personas_administrativos (id_persona, cargo) VALUES
(2, 'Director de Postgrado'),
(4, 'Secretaria Académica'),
(6, 'Tesorero'),
(10, 'Administrador de Facultad'),
(1, 'Coordinador Académico');

INSERT INTO personas_alumnos (id_persona, id_carrera) VALUES
(8, 1),
(4, 2),
(6, 3),
(10, 4),
(2, 5);

INSERT INTO personas_directores_carreras (id_carrera, id_persona, fecha_inicio, fecha_fin) VALUES
(1, 3, '2023-01-01', '2025-12-31'),
(2, 5, '2023-01-01', '2025-12-31'),
(3, 9, '2024-01-01', '2026-12-31'),
(4, 1, '2023-06-01', '2025-05-31'),
(5, 7, '2023-01-01', '2025-12-31');

INSERT INTO personas_decanos (id_facultad, id_persona, fecha_inicio, fecha_fin) VALUES
(1, 7, '2022-01-01', '2025-12-31'),
(2, 1, '2023-01-01', '2026-12-31'),
(3, 3, '2022-06-01', '2025-05-31'),
(5, 5, '2023-01-01', '2026-12-31'),
(7, 9, '2024-01-01', '2027-12-31');

INSERT INTO personas_directores_posgrados (id_persona, fecha_inicio, fecha_fin) VALUES
(2, '2023-01-01', '2025-12-31'),
(1, '2024-01-01', '2026-12-31'),
(7, '2023-06-01', '2025-05-31');

INSERT INTO personas_facultades_administradores (id_persona, fecha_inicio, fecha_fin) VALUES
(10, '2023-01-01', '2025-12-31'),
(4, '2024-01-01', '2026-12-31'),
(6, '2023-06-01', '2025-05-31'),
(1, '2024-02-01', '2026-01-31'),
(2, '2023-03-01', '2025-02-28');

-- ========================= GESTIONES Y PERÍODOS =========================
INSERT INTO gestiones_periodos (gestion, periodo, tipo) VALUES
(2023, 1, 'S'),
(2023, 2, 'S'),
(2024, 1, 'S'),
(2024, 2, 'S'),
(2025, 1, 'S'),
(2025, 2, 'S'),
(2022, 1, 'A'),
(2023, 1, 'A'),
(2024, 1, 'A'),
(2025, 1, 'A');

-- ========================= HORARIOS ACADÉMICOS =========================
INSERT INTO dias (numero, nombre) VALUES
(1, 'Lunes'),
(2, 'Martes'),
(3, 'Miércoles'),
(4, 'Jueves'),
(5, 'Viernes'),
(6, 'Sábado'),
(7, 'Domingo');

INSERT INTO horas_clases (numero, hora_inicio, hora_fin) VALUES
(1, '07:00:00', '07:45:00'),
(2, '07:45:00', '08:30:00'),
(3, '08:30:00', '09:15:00'),
(4, '09:30:00', '10:15:00'),
(5, '10:15:00', '11:00:00'),
(6, '11:00:00', '11:45:00'),
(7, '14:00:00', '14:45:00'),
(8, '14:45:00', '15:30:00'),
(9, '15:30:00', '16:15:00'),
(10, '16:30:00', '17:15:00');

-- ========================= TIPOS DE EVALUACIÓN =========================
INSERT INTO tipos_evaluaciones_notas (nombre, parcial, practica, laboratorio, examen_final, nota_minima_aprobacion) VALUES
('100', 30, 30, 20, 20, 51),
('EST', 40, 30, 0, 30, 51),
('LAB', 20, 30, 30, 20, 56),
('TEO', 50, 0, 0, 50, 51),
('MIX', 25, 25, 25, 25, 51);

-- ========================= CONCEPTOS FINANCIEROS =========================
INSERT INTO cuentas_conceptos (nombre, descripcion) VALUES
('Matrícula', 'Costo de matrícula del programa'),
('Mensualidad', 'Pago mensual del programa'),
('Material Didáctico', 'Costo de material de estudio'),
('Certificado', 'Costo de certificado de graduación'),
('Título', 'Costo de emisión de título'),
('Diploma', 'Costo de diploma'),
('Empastado', 'Costo de empastado de tesis'),
('Defensa', 'Costo de defensa de tesis'),
('Laboratorio', 'Costo de uso de laboratorio'),
('Biblioteca', 'Costo de servicios bibliotecarios');

-- ========================= PROGRAMAS DE POSTGRADO =========================
INSERT INTO posgrados_programas (id_nivel_academico, id_carrera, gestion, nombre, id_modalidad, fecha_inicio, fecha_fin, fecha_inicio_inscrito, fecha_fin_inscrito, numero_max_cuotas, costo_total, formato_contrato) VALUES
(3, 1, 2024, 'Maestría en Ingeniería de Software', 2, '2024-03-01', '2025-12-15', '2024-01-15', '2024-02-28', 18, 15000.00, 'Contrato estándar de maestría'),
(1, 2, 2024, 'Diplomado en Gestión de Proyectos de Construcción', 3, '2024-04-01', '2024-09-30', '2024-02-01', '2024-03-15', 6, 3500.00, 'Contrato de diplomado'),
(2, 3, 2024, 'Especialidad en Seguridad Minera', 1, '2024-05-01', '2025-04-30', '2024-03-01', '2024-04-15', 12, 8000.00, 'Contrato de especialidad'),
(3, 4, 2024, 'Maestría en Biotecnología', 2, '2024-06-01', '2026-05-31', '2024-04-01', '2024-05-15', 24, 18000.00, 'Contrato de maestría científica'),
(1, 5, 2024, 'Diplomado en Salud Pública', 3, '2024-07-01', '2024-12-15', '2024-05-01', '2024-06-15', 6, 4000.00, 'Contrato de diplomado médico'),
(3, 6, 2025, 'Maestría en Auditoría Financiera', 1, '2025-03-01', '2026-12-15', '2025-01-15', '2025-02-28', 20, 16000.00, 'Contrato de maestría empresarial'),
(2, 7, 2024, 'Especialidad en Derecho Tributario', 1, '2024-08-01', '2025-07-31', '2024-06-01', '2024-07-15', 12, 9000.00, 'Contrato de especialidad jurídica'),
(1, 8, 2024, 'Diplomado en Diseño Arquitectónico Sustentable', 3, '2024-09-01', '2025-02-28', '2024-07-01', '2024-08-15', 6, 4500.00, 'Contrato de diplomado técnico'),
(4, 1, 2025, 'Doctorado en Ciencias de la Computación', 2, '2025-03-01', '2028-12-15', '2025-01-01', '2025-02-15', 36, 35000.00, 'Contrato doctoral'),
(3, 9, 2024, 'Maestría en Ciencias Sociales', 1, '2024-10-01', '2026-09-30', '2024-08-01', '2024-09-15', 24, 14000.00, 'Contrato de maestría social');

-- ========================= ALUMNOS DE POSTGRADO =========================
INSERT INTO personas_alumnos_posgrados (id_persona, id_posgrado_programa, fecha, inscrito) VALUES
(1, 1, '2024-02-20', '1'),
(2, 2, '2024-02-25', '1'),
(3, 3, '2024-03-10', '1'),
(4, 4, '2024-04-15', '1'),
(5, 5, '2024-05-20', '1'),
(6, 6, '2025-02-10', '0'),
(7, 7, '2024-06-25', '1'),
(8, 8, '2024-07-30', '1'),
(9, 9, '2025-01-15', '0'),
(10, 10, '2024-08-20', '1');

-- ========================= CONFIGURACIÓN DE CARGOS =========================
INSERT INTO cuentas_cargos_posgrados (id_posgrado_programa, nombre, numero_formulario) VALUES
(1, 'Pago Completo - Sin Descuento', 'FORM-001'),
(1, 'Pago con 10% Descuento', 'FORM-002'),
(2, 'Pago Completo - Sin Descuento', 'FORM-003'),
(2, 'Pago con 5% Descuento Docentes', 'FORM-004'),
(3, 'Pago Completo - Sin Descuento', 'FORM-005'),
(4, 'Pago Completo - Sin Descuento', 'FORM-006'),
(5, 'Pago con 15% Descuento Médicos', 'FORM-007'),
(6, 'Pago Completo - Sin Descuento', 'FORM-008'),
(7, 'Pago con 10% Descuento Abogados', 'FORM-009'),
(8, 'Pago Completo - Sin Descuento', 'FORM-010');

-- ========================= CONCEPTOS DE CARGOS =========================
INSERT INTO cuentas_cargos_posgrados_conceptos (id_cuenta_cargo_posgrado, id_cuenta_concepto, tiene_descuento) VALUES
(1, 1, 'N'), (1, 2, 'N'), (1, 4, 'N'),
(2, 1, 'S'), (2, 2, 'S'), (2, 4, 'N'),
(3, 1, 'N'), (3, 2, 'N'), (3, 3, 'N'),
(4, 1, 'S'), (4, 2, 'S'), (4, 3, 'S'),
(5, 1, 'N'), (5, 2, 'N'), (5, 5, 'N'),
(6, 1, 'N'), (6, 2, 'N'), (6, 4, 'N'), (6, 5, 'N'),
(7, 1, 'S'), (7, 2, 'S'), (7, 4, 'S'),
(8, 1, 'N'), (8, 2, 'N'), (8, 3, 'N'),
(9, 1, 'S'), (9, 2, 'S'), (9, 6, 'S'),
(10, 1, 'N'), (10, 2, 'N'), (10, 3, 'N');

-- ========================= COSTOS DETALLADOS =========================
INSERT INTO cuentas_cargos_conceptos_posgrados (id_cuenta_cargo_posgrado_concepto, costo, porcentaje, descuento, monto_pagar, fecha, desglose) VALUES
(1, 2000.00, 0, 0.00, 2000.00, '2024-03-01', false),
(2, 750.00, 0, 0.00, 750.00, '2024-03-01', true),
(3, 1500.00, 0, 0.00, 1500.00, '2024-03-01', false),
(4, 2000.00, 10, 200.00, 1800.00, '2024-03-01', false),
(5, 750.00, 10, 75.00, 675.00, '2024-03-01', true),
(6, 1500.00, 0, 0.00, 1500.00, '2024-03-01', false),
(7, 800.00, 0, 0.00, 800.00, '2024-04-01', false),
(8, 300.00, 0, 0.00, 300.00, '2024-04-01', true),
(9, 500.00, 0, 0.00, 500.00, '2024-04-01', false),
(10, 800.00, 5, 40.00, 760.00, '2024-04-01', false);

-- ========================= CONTRATOS =========================
INSERT INTO posgrados_contratos (id_cuenta_cargo_posgrado, id_persona_alumno_posgrado, numero_cuotas, id_persona_director_posgrado, id_persona_facultad_administrador, id_persona_decano) VALUES
(1, 1, 18, 1, 1, 1),
(3, 2, 6, 1, 2, 2),
(5, 3, 12, 1, 3, 3),
(6, 4, 24, 2, 4, 4),
(7, 5, 6, 2, 5, 5),
(8, 7, 12, 3, 1, 1),
(10, 8, 6, 3, 2, 2),
(1, 9, 36, 1, 3, 3),
(8, 10, 24, 2, 4, 4);

-- ========================= DETALLES DE CONTRATOS =========================
INSERT INTO posgrados_contratos_detalles (id_posgrado_contrato, id_cuenta_cargo_concepto_posgrado, pagado, monto_pagado, monto_adeudado) VALUES
(1, 1, true, 2000.00, 0.00),
(1, 2, false, 0.00, 750.00),
(1, 3, false, 0.00, 1500.00),
(2, 7, true, 800.00, 0.00),
(2, 8, false, 0.00, 300.00),
(3, 1, true, 2000.00, 0.00),
(3, 2, false, 200.00, 550.00),
(4, 1, false, 0.00, 2000.00),
(5, 1, true, 2000.00, 0.00),
(6, 1, false, 500.00, 1300.00);

-- ========================= DESGLOSE DE PAGOS =========================
INSERT INTO posgrados_contratos_detalles_desglose (id_posgrado_contrato_detalle, monto, descripcion, pagado) VALUES
(2, 125.00, 'Marzo 2024', false),
(2, 125.00, 'Abril 2024', false),
(2, 125.00, 'Mayo 2024', false),
(2, 125.00, 'Junio 2024', false),
(2, 125.00, 'Julio 2024', false),
(2, 125.00, 'Agosto 2024', false),
(5, 50.00, 'Marzo 2024', false),
(5, 50.00, 'Abril 2024', false),
(5, 50.00, 'Mayo 2024', false),
(5, 50.00, 'Junio 2024', false);

-- ========================= TRANSACCIONES =========================
INSERT INTO posgrados_transacciones (id_posgrado_contrato, id_persona_alumno_posgrado, fecha_transaccion) VALUES
(1, 1, '2024-03-05'),
(2, 2, '2024-04-10'),
(3, 3, '2024-03-15'),
(5, 5, '2024-05-20'),
(6, 7, '2024-06-25'),
(1, 1, '2024-04-05'),
(3, 3, '2024-04-15'),
(2, 2, '2024-05-10'),
(5, 5, '2024-06-20'),
(6, 7, '2024-07-25');

-- ========================= DETALLES DE TRANSACCIONES =========================
INSERT INTO posgrados_transacciones_detalles (id_posgrado_transaccion, id_posgrado_contrato_detalle, fecha_deposito, numero_deposito, monto_deposito, usado_transaccion) VALUES
(1, 1, '2024-03-05', 'DEP001', 2000.00, '1'),
(2, 4, '2024-04-10', 'DEP002', 800.00, '1'),
(3, 6, '2024-03-15', 'DEP003', 2000.00, '1'),
(4, 9, '2024-05-20', 'DEP004', 2000.00, '1'),
(5, 10, '2024-06-25', 'DEP005', 500.00, '1'),
(6, 2, '2024-04-05', 'DEP006', 200.00, '1'),
(7, 7, '2024-04-15', 'DEP007', 200.00, '1'),
(8, 5, '2024-05-10', 'DEP008', 150.00, '0'),
(9, 9, '2024-06-20', 'DEP009', 300.00, '0'),
(10, 10, '2024-07-25', 'DEP010', 800.00, '1');

-- ========================= DESGLOSE DE TRANSACCIONES =========================
INSERT INTO posgrados_transacciones_detalles_desglose (id_posgrado_contrato_detalle, id_posgrado_transaccion_detalle, monto_desglosado, descripcion) VALUES
(1, 1, 2000.00, 'Pago completo matrícula'),
(4, 2, 800.00, 'Pago completo matrícula diplomado'),
(6, 3, 2000.00, 'Pago matrícula especialidad'),
(9, 4, 2000.00, 'Pago matrícula maestría'),
(10, 5, 500.00, 'Pago parcial matrícula'),
(2, 6, 200.00, 'Pago parcial mensualidad'),
(7, 7, 200.00, 'Pago parcial mensualidad'),
(5, 8, 150.00, 'Pago parcial material'),
(9, 9, 300.00, 'Pago parcial mensualidad'),
(10, 10, 800.00, 'Pago adicional matrícula');

-- ========================= MONTOS EXCEDENTES =========================
INSERT INTO montos_excedentes (id_posgrado_transaccion_detalle, monto_excedente, procesando) VALUES
(8, 50.00, '0'),
(9, 25.00, '0'),
(10, 300.00, '1');

-- ========================= TRÁMITES Y DOCUMENTOS =========================
INSERT INTO tramites_documentos (nombre, descripcion) VALUES
('Fotocopia de Cédula de Identidad', 'Documento de identificación personal vigente'),
('Título de Licenciatura', 'Título académico de pregrado legalizado'),
('Certificado de Notas', 'Certificado de calificaciones de pregrado'),
('Fotografías', 'Fotografías tamaño carnet actualizadas'),
('Certificado de Nacimiento', 'Certificado de nacimiento legalizado'),
('Currículum Vitae', 'Hoja de vida actualizada'),
('Carta de Motivación', 'Carta explicando motivación para el programa'),
('Referencias Laborales', 'Cartas de recomendación laboral'),
('Certificado Médico', 'Certificado médico de aptitud'),
('Comprobante de Pago', 'Recibo de pago de matrícula');

-- ========================= DOCUMENTOS POR NIVEL ACADÉMICO =========================
INSERT INTO niveles_academicos_tramites_documentos (id_nivel_academico, id_tramite_documento) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 6),
(2, 1), (2, 2), (2, 3), (2, 4), (2, 6), (2, 7),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 6), (3, 7), (3, 8),
(4, 1), (4, 2), (4, 3), (4, 4), (4, 6), (4, 7), (4, 8), (4, 9),
(5, 1), (5, 2), (5, 3), (5, 4), (5, 6), (5, 7), (5, 8), (5, 9);

-- ========================= DOCUMENTOS DE ALUMNOS =========================
INSERT INTO posgrado_alumnos_documentos (id_persona_alumno_posgrado, id_nivel_academico_tramite_documento, archivo, verificado, fecha_verificacion) VALUES
(1, 15, 'ci_juan_garcia.pdf', 'S', '2024-02-22 10:30:00'),
(1, 16, 'titulo_juan_garcia.pdf', 'S', '2024-02-22 10:35:00'),
(1, 17, 'notas_juan_garcia.pdf', 'S', '2024-02-22 10:40:00'),
(2, 1, 'ci_maria_mamani.pdf', 'S', '2024-02-27 09:15:00'),
(2, 2, 'titulo_maria_mamani.pdf', 'S', '2024-02-27 09:20:00'),
(3, 6, 'ci_carlos_rodriguez.pdf', 'N', NULL),
(3, 7, 'titulo_carlos_rodriguez.pdf', 'S', '2024-03-12 14:20:00'),
(4, 20, 'ci_ana_condori.pdf', 'S', '2024-04-17 11:10:00'),
(5, 11, 'ci_roberto_vargas.pdf', 'S', '2024-05-22 08:45:00'),
(7, 6, 'ci_luis_choque.pdf', 'N', NULL);

-- ========================= EXTRACTOS BANCARIOS =========================
INSERT INTO extractos_bancarios (nombre_completo, carnet_identidad, numero_codigo, monto, fecha, hora, procesando) VALUES
('GARCIA LOPEZ JUAN CARLOS', '4567890 PT', 'TRX001', 2000.00, '2024-03-05', '10:30:00', '1'),
('MAMANI QUISPE MARIA ELENA', '3456789 PT', 'TRX002', 800.00, '2024-04-10', '14:15:00', '1'),
('RODRIGUEZ PEREZ CARLOS ALBERTO', '5678901 PT', 'TRX003', 2000.00, '2024-03-15', '09:45:00', '1'),
('CONDORI HUANCA ANA LUCIA', '6789012 PT', 'TRX004', 2000.00, '2024-05-20', '16:20:00', '1'),
('VARGAS SILVA ROBERTO MIGUEL', '7890123 PT', 'TRX005', 2000.00, '2024-05-20', '11:30:00', '1'),
('CHOQUE NINA LUIS FERNANDO', '9012345 PT', 'TRX006', 500.00, '2024-06-25', '13:45:00', '1'),
('FLORES MENDOZA PATRICIA ROSA', '8901234 PT', 'TRX007', 200.00, '2024-04-05', '15:10:00', '0'),
('SALINAS TORRES CARMEN GLORIA', '0123456 PT', 'TRX008', 150.00, '2024-05-10', '12:25:00', '0'),
('MENDOZA RAMOS DIEGO ALEJANDRO', '1234567 PT', 'TRX009', 300.00, '2024-06-20', '17:05:00', '0'),
('TICONA APAZA SILVIA BEATRIZ', '2345678 PT', 'TRX010', 1100.00, '2024-07-25', '08:15:00', '1');

-- ========================= PARTE ACADÉMICA DE POSTGRADO =========================
INSERT INTO posgrado_niveles (nombre, descripcion) VALUES
('Básico', 'Nivel básico de formación'),
('Intermedio', 'Nivel intermedio de profundización'),
('Avanzado', 'Nivel avanzado de especialización'),
('Investigación', 'Nivel de investigación aplicada'),
('Tesis', 'Nivel de desarrollo de tesis');

INSERT INTO posgrado_materias (id_posgrado_programa, id_posgrado_nivel, sigla, nombre, nivel_curso, cantidad_hora_teorica, cantidad_hora_practica, cantidad_hora_laboratorio, cantidad_credito, color) VALUES
(1, 1, 'IS101', 'Metodología de la Investigación', 1, 40, 20, 0, 3, '#FF5733'),
(1, 1, 'IS102', 'Ingeniería de Software I', 1, 50, 30, 20, 4, '#33FF57'),
(1, 2, 'IS201', 'Arquitectura de Software', 2, 45, 25, 10, 4, '#3357FF'),
(1, 2, 'IS202', 'Gestión de Proyectos de Software', 2, 40, 30, 0, 3, '#FF33F5'),
(2, 1, 'GP101', 'Fundamentos de Gestión', 1, 30, 10, 0, 2, '#F5FF33'),
(2, 1, 'GP102', 'Planificación de Proyectos', 1, 35, 15, 0, 3, '#33FFF5'),
(3, 1, 'SM101', 'Seguridad Industrial', 1, 40, 20, 10, 3, '#FF8C33'),
(3, 2, 'SM201', 'Gestión de Riesgos Mineros', 2, 45, 25, 5, 4, '#8C33FF'),
(4, 1, 'BT101', 'Biología Molecular', 1, 30, 10, 20, 3, '#33FF8C'),
(4, 2, 'BT201', 'Biotecnología Aplicada', 2, 35, 15, 25, 4, '#FF3333');

INSERT INTO posgrado_tipos_evaluaciones_notas (nombre, configuracion, nota_minima_aprobacion) VALUES
('100', '{"parcial":30,"practica":30,"laboratorio":20,"final":20}', 70),
('EST', '{"parcial1":20,"parcial2":20,"practica":30,"final":30}', 70),
('LAB', '{"laboratorio1":25,"laboratorio2":25,"practica":25,"final":25}', 70),
('TEO', '{"parcial1":25,"parcial2":25,"final":50}', 70),
('MIX', '{"evaluacion1":20,"evaluacion2":20,"evaluacion3":20,"evaluacion4":20,"final":20}', 70);

INSERT INTO posgrado_asignaciones_docentes (id_persona_docente, id_posgrado_materia, id_posgrado_tipo_evaluacion_nota, id_gestion_periodo, grupo, cupo_maximo_estudiante, fecha_limite_examen_final) VALUES
(1, 1, 1, 5, 'A', 25, '2024-07-15 18:00:00'),
(2, 2, 2, 5, 'A', 25, '2024-07-20 18:00:00'),
(3, 3, 1, 5, 'A', 20, '2024-08-15 18:00:00'),
(4, 4, 3, 5, 'A', 20, '2024-08-20 18:00:00'),
(5, 5, 4, 5, 'A', 30, '2024-06-15 18:00:00'),
(1, 6, 4, 5, 'A', 30, '2024-06-20 18:00:00'),
(2, 7, 2, 5, 'A', 25, '2024-09-15 18:00:00'),
(3, 8, 1, 5, 'A', 25, '2024-09-20 18:00:00'),
(4, 9, 5, 5, 'A', 15, '2024-07-25 18:00:00'),
(5, 10, 5, 5, 'A', 15, '2024-08-25 18:00:00');

INSERT INTO posgrado_calificaciones (id_persona_alumno_posgrado, id_posgrado_asignacion_docente, configuracion, calificacion1, calificacion2, calificacion3, calificacion15, nota_final, observacion) VALUES
(1, 1, '{"parcial":75,"practica":80,"laboratorio":70,"final":85}', 75, 80, 70, 85, 78, 'A'),
(1, 2, '{"parcial1":72,"parcial2":78,"practica":85,"final":80}', 72, 78, 85, 80, 79, 'A'),
(2, 5, '{"parcial1":65,"parcial2":70,"final":75}', 65, 70, 0, 75, 71, 'A'),
(2, 6, '{"parcial1":68,"parcial2":72,"final":78}', 68, 72, 0, 78, 73, 'A'),
(3, 7, '{"parcial1":60,"parcial2":65,"practica":70,"final":68}', 60, 65, 70, 68, 66, 'R'),
(4, 9, '{"evaluacion1":85,"evaluacion2":80,"evaluacion3":88,"evaluacion4":82,"final":90}', 85, 80, 88, 90, 85, 'A'),
(5, 5, '{"parcial1":75,"parcial2":78,"final":80}', 75, 78, 0, 80, 78, 'A'),
(7, 7, '{"parcial1":70,"parcial2":74,"practica":76,"final":75}', 70, 74, 76, 75, 74, 'A'),
(8, 6, '{"parcial1":82,"parcial2":85,"final":88}', 82, 85, 0, 88, 85, 'A'),
(10, 9, '{"evaluacion1":78,"evaluacion2":76,"evaluacion3":80,"evaluacion4":79,"final":82}', 78, 76, 80, 82, 79, 'A');

-- ========================= HORARIOS DE POSTGRADO =========================
INSERT INTO posgrado_asignaciones_horarios (id_posgrado_asignacion_docente, id_ambiente, id_dia, id_hora_clase, clase_link, clase_descripcion) VALUES
(1, 9, 1, 7, 'https://meet.google.com/abc-defg-hij', 'Clase virtual de Metodología de Investigación'),
(2, 9, 2, 7, 'https://zoom.us/j/123456789', 'Clase de Ingeniería de Software I'),
(3, 9, 3, 7, 'https://meet.google.com/klm-nopq-rst', 'Arquitectura de Software - Clase virtual'),
(4, 9, 4, 7, 'https://teams.microsoft.com/meeting1', 'Gestión de Proyectos - Teams'),
(5, 10, 6, 1, 'https://meet.google.com/uvw-xyza-bcd', 'Diplomado - Fundamentos de Gestión'),
(6, 10, 6, 2, 'https://zoom.us/j/987654321', 'Diplomado - Planificación de Proyectos'),
(7, 1, 1, 8, NULL, 'Clase presencial - Seguridad Industrial'),
(8, 1, 3, 8, NULL, 'Clase presencial - Gestión de Riesgos'),
(9, 9, 5, 7, 'https://meet.google.com/efg-hijk-lmn', 'Biología Molecular - Virtual'),
(10, 9, 2, 8, 'https://zoom.us/j/456789123', 'Biotecnología Aplicada - Zoom');

--- ========================= VIDEOS DE CLASES =========================

INSERT INTO posgrado_clases_videos (id_posgrado_asignacion_horario, clase_link, clase_fecha, clase_hora_inicio, clase_hora_fin, clase_duracion) VALUES
(1, 'https://drive.google.com/video1', '2024-03-04', '2024-03-04 14:00:00', '2024-03-04 15:30:00', '2024-03-04 15:30:00'),
(1, 'https://drive.google.com/video2', '2024-03-11', '2024-03-11 14:00:00', '2024-03-11 15:30:00', '2024-03-11 15:30:00'),
(2, 'https://drive.google.com/video3', '2024-03-05', '2024-03-05 14:00:00', '2024-03-05 15:30:00', '2024-03-05 15:30:00'),
(3, 'https://drive.google.com/video4', '2024-03-06', '2024-03-06 14:00:00', '2024-03-06 15:30:00', '2024-03-06 15:30:00'),
(4, 'https://drive.google.com/video5', '2024-03-07', '2024-03-07 14:00:00', '2024-03-07 15:30:00', '2024-03-07 15:30:00'),
(5, 'https://drive.google.com/video6', '2024-04-06', '2024-04-06 07:00:00', '2024-04-06 08:30:00', '2024-04-06 08:30:00'),
(6, 'https://drive.google.com/video7', '2024-04-06', '2024-04-06 07:45:00', '2024-04-06 09:15:00', '2024-04-06 09:15:00'),
(9, 'https://drive.google.com/video8', '2024-06-07', '2024-06-07 14:00:00', '2024-06-07 15:30:00', '2024-06-07 15:30:00'),
(10, 'https://drive.google.com/video9', '2024-06-04', '2024-06-04 14:45:00', '2024-06-04 16:15:00', '2024-06-04 16:15:00'),
(1, 'https://drive.google.com/video10', '2024-03-18', '2024-03-18 14:00:00', '2024-03-18 15:30:00', '2024-03-18 15:30:00');