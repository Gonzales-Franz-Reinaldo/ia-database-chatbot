-- -------------------------------------------------------------------------------------------
-- ------- BASE DE DATOS ACADEMICO (c) DERECHOS RESERVADOS -----------------------------------
-- -------------------------------------------------------------------------------------------
-- ------------- Nombre de la Base de Datos: dbpostgrado -------------------------------------
-- -------------------------------------------------------------------------------------------
-- ------------------------- TABLAS COMUNES A VARIOS MODULOS ---------------------------------
-- -------------------------------------------------------------------------------------------
CREATE TABLE universidades (
    id_universidad SERIAL NOT NULL,
    nombre VARCHAR(150),
    nombre_abreviado VARCHAR(100),
    inicial VARCHAR(50),
    estado VARCHAR(1) DEFAULT 'S',
    CONSTRAINT pk_universidades PRIMARY KEY(id_universidad)
);

CREATE TABLE configuraciones ( -- -- Las configuraciones de imagenes, cabeza, pie, Telefonos, APIKEY, etc.
    id_configuracion SERIAL NOT NULL,
	id_universidad INT NOT NULL,
    tipo VARCHAR(200),
	descripcion VARCHAR(500),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_configuraciones PRIMARY KEY(id_configuracion),
	CONSTRAINT fk_universidades_configuraciones FOREIGN KEY(id_universidad) REFERENCES universidades(id_universidad)
);

CREATE TABLE areas (
    id_area SERIAL NOT NULL,
 	id_universidad INT NOT NULL,
    nombre VARCHAR(150),
	nombre_abreviado VARCHAR(100),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_areas PRIMARY KEY(id_area),
 	CONSTRAINT fk_universidades_areas FOREIGN KEY(id_universidad) REFERENCES universidades(id_universidad)
);

CREATE TABLE facultades (
    id_facultad SERIAL NOT NULL,
	id_area INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    nombre_abreviado VARCHAR(50),
	direccion VARCHAR(100),
    telefono VARCHAR(100),
	telefono_interno VARCHAR(100),
	fax VARCHAR(20),
	email VARCHAR(100),
	latitud VARCHAR(25),
	longitud VARCHAR(25),
    fecha_creacion DATE,
    escudo VARCHAR(60),
    imagen VARCHAR(60),
    estado_virtual VARCHAR(1),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_facultades PRIMARY KEY(id_facultad),
	CONSTRAINT fk_areas_facultades FOREIGN KEY(id_area) REFERENCES areas(id_area)
);

-- --------------ROLES Y USUARIOS ----------------------------
CREATE TABLE modulos(
	id_modulo SERIAL  NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_modulos PRIMARY KEY(id_modulo)
);

CREATE TABLE menus_principales(
	id_menu_principal SERIAL NOT NULL,
	id_modulo INT NOT NULL,
	nombre VARCHAR(250) NOT NULL,
	icono VARCHAR(70),
	orden INT,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_menus_principales PRIMARY KEY (id_menu_principal),
	CONSTRAINT fk_modulos_menus_principales FOREIGN KEY(id_modulo) REFERENCES modulos(id_modulo)
);

CREATE TABLE menus(
	id_menu	SERIAL NOT NULL,
	id_menu_principal INT NOT NULL,
	nombre VARCHAR(250) NOT NULL,
	directorio VARCHAR(350) NOT NULL,
	icono VARCHAR(70),
	imagen VARCHAR(150),
	color VARCHAR(25),
	orden INT,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_menus PRIMARY KEY (id_menu),
	CONSTRAINT fk_menus_principales_menus FOREIGN KEY(id_menu_principal) REFERENCES menus_principales(id_menu_principal)
);

CREATE TABLE roles(
	id_rol SERIAL NOT NULL,
	nombre VARCHAR(150) NOT NULL,
	descripcion VARCHAR(200),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_roles PRIMARY KEY (id_rol)
);

CREATE TABLE roles_menus_principales(
	id_rol_menu_principal SERIAL NOT NULL,
	id_rol INT NOT NULL,
	id_menu_principal INT NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_roles_menus_principales PRIMARY KEY(id_rol_menu_principal),
	CONSTRAINT fk_roles_roles_menus_principales FOREIGN KEY(id_rol) REFERENCES roles(id_rol),
	CONSTRAINT fk_menus_principales_roles_menus_principales FOREIGN KEY(id_menu_principal) REFERENCES menus_principales(id_menu_principal)
);

-- -------------------------------- GESTION DE AMBIENTES -----------------------------
CREATE TABLE campus (
    id_campus SERIAL NOT NULL,
    nombre VARCHAR(70),
	direccion VARCHAR(255),
	poligono VARCHAR(5000), -- -- puntos que dibujan el campus sobre el mapa como un area con un poligono relleno de un color
    latitud VARCHAR(30),
	longitud VARCHAR(30),
    imagen VARCHAR(255),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_campus PRIMARY KEY(id_campus)
);

CREATE TABLE edificios (
    id_edificio SERIAL NOT NULL,
    id_campus INT,
    nombre VARCHAR(70),
    direccion VARCHAR(90),
    latitud VARCHAR(30),
    longitud VARCHAR(30),
    imagen VARCHAR(255),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_edificios PRIMARY KEY(id_edificio),
	CONSTRAINT fk_campus_edificios FOREIGN KEY(id_campus) REFERENCES campus(id_campus)
);

CREATE TABLE facultades_edificios (
    id_facultad_edificio SERIAL NOT NULL,
    id_facultad INT,
	id_edificio INT,
	fecha_asignacion DATE,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_facultades_edificios PRIMARY KEY(id_facultad_edificio),
	CONSTRAINT fk_facultades_facultades_edificios FOREIGN KEY(id_facultad) REFERENCES facultades(id_facultad),
	CONSTRAINT fk_edificios_facultades_edificios FOREIGN KEY(id_edificio) REFERENCES edificios(id_edificio)
);

CREATE TABLE bloques (
    id_bloque SERIAL NOT NULL,
    id_edificio INT,
    nombre VARCHAR(70),
    imagen VARCHAR(255),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_bloques PRIMARY KEY(id_bloque),
	CONSTRAINT fk_edificios_bloques FOREIGN KEY(id_edificio) REFERENCES edificios(id_edificio)
);

CREATE TABLE pisos (
    id_piso SERIAL NOT NULL,
    numero INT, -- ---------------- Piso -2, -1, 0, 1,2,3,4,5,6,7,8,9,10
    nombre VARCHAR(30), -- -------- -2=subsuelo,-1=planta baja, 0=piso 0, 1=primer piso, etc
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_pisos PRIMARY KEY(id_piso)
);

CREATE TABLE pisos_bloques (
    id_piso_bloque SERIAL NOT NULL,
    id_bloque INT,
    id_piso INT,
    nombre VARCHAR(30),
    cantidad_ambientes INT,
    imagen VARCHAR(200),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_pisos_bloques PRIMARY KEY(id_piso_bloque),
	CONSTRAINT fk_bloques_pisos_bloques FOREIGN KEY(id_bloque) REFERENCES bloques(id_bloque),
	CONSTRAINT fk_pisos_pisos_bloques FOREIGN KEY(id_piso) REFERENCES pisos(id_piso)
);

CREATE TABLE tipos_ambientes (
    id_tipo_ambiente SERIAL NOT NULL,
    nombre VARCHAR(30),	-- ------ Ambiente, Laboratorio Computacion, 
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_tipos_ambientes PRIMARY KEY(id_tipo_ambiente)
);

CREATE TABLE ambientes (
    id_ambiente SERIAL NOT NULL,
    id_piso_bloque INT,
    id_tipo_ambiente INT,
    nombre VARCHAR(30),
    codigo VARCHAR(30),
    capacidad INT, -- --aqui indica la capacidad del ambiente y si el lab. de computacion indica la capacidad del lab.
	metro_cuadrado FLOAT, -- --metro cuadrado del ambiente
    imagen_exterior VARCHAR(255),
    imagen_interior VARCHAR(255),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_ambientes PRIMARY KEY(id_ambiente),
	CONSTRAINT fk_pisos_bloques_ambientes FOREIGN KEY(id_piso_bloque) REFERENCES pisos_bloques(id_piso_bloque),
	CONSTRAINT fk_tipos_ambientes_ambientes FOREIGN KEY(id_tipo_ambiente) REFERENCES tipos_ambientes(id_tipo_ambiente)
);
-- ------------------------------------------------------------------------------paises
CREATE TABLE paises (
    id_pais SERIAL NOT NULL,
    nombre VARCHAR(30) NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_paises PRIMARY KEY(id_pais)
);

CREATE TABLE departamentos (
    id_departamento SERIAL NOT NULL,
    id_pais INT NOT NULL,
	nombre VARCHAR(30),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_departamentos PRIMARY KEY(id_departamento),
	CONSTRAINT fk_paises_departamentos FOREIGN KEY(id_pais) REFERENCES paises(id_pais)
);

CREATE TABLE provincias (
    id_provincia SERIAL NOT NULL,
	id_departamento INT NOT NULL,
    nombre VARCHAR(40),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_provincias PRIMARY KEY(id_provincia),
	CONSTRAINT fk_departamentos_provincias FOREIGN KEY(id_departamento) REFERENCES departamentos(id_departamento)
);

CREATE TABLE localidades (
    id_localidad SERIAL NOT NULL,
    id_provincia INT NOT NULL,
    nombre VARCHAR(40) NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_localidades PRIMARY KEY(id_localidad),
	CONSTRAINT fk_provincias_localidades FOREIGN KEY(id_provincia) REFERENCES provincias(id_provincia)
);

CREATE TABLE grupos_sanguineos(
	id_grupo_sanguineo SERIAL NOT NULL,
	nombre VARCHAR(15) NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_grupos_sanguineos PRIMARY KEY(id_grupo_sanguineo)
);

CREATE TABLE sexos(
	id_sexo SERIAL NOT NULL,
	nombre VARCHAR(15) NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_sexos PRIMARY KEY(id_sexo)
);

CREATE TABLE estados_civiles(
	id_estado_civil SERIAL NOT NULL,
	nombre VARCHAR(15) NOT NULL, -- -- soltero, casado, divorciado, viudo
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_estados_civiles PRIMARY KEY(id_estado_civil)
);

CREATE TABLE emision_cedulas(
	id_emision_cedula SERIAL NOT NULL,
	nombre VARCHAR(15) NOT NULL, -- -- PT,CH,.. EX = extranjero
	descripcion VARCHAR(45),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_emision_cedulas PRIMARY KEY(id_emision_cedula)
);

CREATE TABLE personas (
	id_persona SERIAL NOT NULL,
    id_localidad INT NOT NULL,
    numero_identificacion_personal VARCHAR(15), -- --Numero de C.I. o R.U.N. o Pasaporte
	id_emision_cedula INT NOT NULL,
    paterno VARCHAR(20) NOT NULL,
    materno VARCHAR(20),
    nombre VARCHAR(65) NOT NULL,
    id_sexo INT NOT NULL,
	id_grupo_sanguineo INT NOT NULL,
    fecha_nacimiento DATE,
    direccion VARCHAR(60),
	latitud VARCHAR(30),
    longitud VARCHAR(30),
    telefono_celular VARCHAR(12),
    telefono_fijo VARCHAR(12),
    zona VARCHAR(50),
    id_estado_civil INT NOT NULL,
    email VARCHAR(100),
    fotografia VARCHAR(255) DEFAULT 'default.jpg',
    abreviacion_titulo VARCHAR(10),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas PRIMARY KEY(id_persona),
	CONSTRAINT fk_localidades_personas FOREIGN KEY(id_localidad) REFERENCES localidades(id_localidad),
	CONSTRAINT fk_sexos_personas FOREIGN KEY(id_sexo) REFERENCES sexos(id_sexo),
	CONSTRAINT fk_grupos_sanguineos_personas FOREIGN KEY(id_grupo_sanguineo) REFERENCES grupos_sanguineos(id_grupo_sanguineo),
	CONSTRAINT fk_estados_civiles_personas FOREIGN KEY(id_estado_civil) REFERENCES estados_civiles(id_estado_civil),
	CONSTRAINT fk_emision_cedulas_personas FOREIGN KEY(id_emision_cedula) REFERENCES emision_cedulas(id_emision_cedula)
);

-- -- Where tipo = 1 AND fecha_finalizacion <= fecha_actual AND estado = 'S'
CREATE TABLE usuarios(
	id_usuario SERIAL NOT NULL,
	id_persona INT NOT NULL,
	nombre_email VARCHAR(100),	-- -- nombre de usuario o email	
	password VARCHAR(350),
	tipo INT,			-- -- 0 = Nuevo Asignado por el sistema, 1 = cambiado
	fecha DATE DEFAULT now(), -- -- fecha de asignacion
	fecha_finalizacion DATE,
	observacion VARCHAR(255),
	estado VARCHAR(1) DEFAULT 'S', -- --Vigente, No vigente
	CONSTRAINT pk_usuarios PRIMARY KEY(id_usuario),
	CONSTRAINT fk_personas_usuarios FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
);

-- --------------------------------------------------------------------
-- --------------------- MODULO PREGRADO ------------------------------
-- --------------------------------------------------------------------
CREATE TABLE carreras_niveles_academicos(
	id_carrera_nivel_academico SERIAL NOT NULL,
	nombre VARCHAR(35),
	descripcion VARCHAR(350),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_carreras_niveles_academicos PRIMARY KEY(id_carrera_nivel_academico)
);

CREATE TABLE niveles_academicos(-- --Postgrado: diplomado, especialidad, maestria, doctorado, post-doctorado
	id_nivel_academico SERIAL NOT NULL,
	nombre VARCHAR(35) NOT NULL,
	descripcion VARCHAR(350),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_niveles_academicos PRIMARY KEY(id_nivel_academico)
);

CREATE TABLE sedes( -- -- 1=Local Potosi, 2=Uyuni, 3=Villazon,4=Uncia
	id_sede SERIAL NOT NULL,
	nombre VARCHAR(35) NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_sedes PRIMARY KEY(id_sede)
);

CREATE TABLE modalidades( -- -- Presencial, Virtual Semi Presencial
	id_modalidad SERIAL NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	descripcion VARCHAR(100),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_modalidades PRIMARY KEY(id_modalidad)
);

CREATE TABLE carreras (
    id_carrera SERIAL NOT NULL,
    id_facultad INT NOT NULL,
	id_modalidad INT NOT NULL,
	id_carrera_nivel_academico INT NOT NULL,
	id_sede INT NOT NULL, -- -- Local, Provincia
	nombre VARCHAR(50) NOT NULL,
	nombre_abreviado VARCHAR(50),
    fecha_aprobacion_curriculo DATE,
    fecha_creacion DATE,
	resolucion VARCHAR(255), -- -- Un documento pdf que contiene todas las resoluciones, por ejem. HCU, DSA, HCF, certificado CEUB
    direccion VARCHAR(150),
	latitud VARCHAR(50),
	longitud VARCHAR(50),
    fax VARCHAR(20),
    telefono VARCHAR(20),
	telefono_interno VARCHAR(100),
    casilla VARCHAR(12),
    email VARCHAR(100),
    sitio_web VARCHAR(100),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_carreras PRIMARY KEY(id_carrera),
	CONSTRAINT fk_facultades_carreras FOREIGN KEY(id_facultad) REFERENCES facultades(id_facultad),
	CONSTRAINT fk_carreras_niveles_academicos_carreras FOREIGN KEY(id_carrera_nivel_academico) REFERENCES carreras_niveles_academicos(id_carrera_nivel_academico),
	CONSTRAINT fk_sedes_carreras FOREIGN KEY(id_sede) REFERENCES sedes(id_sede),
	CONSTRAINT fk_modalidades_carreras FOREIGN KEY(id_modalidad) REFERENCES modalidades(id_modalidad)
);

-- -----------------------------------------------------------------------------
-- --- tabla para usuarios del sistema (admin, administrativos(secretario),docentes,director,decano) Manejar en el Sistema -------------------
CREATE TABLE tipos_personas(  -- -- una persona puede tener mas de un rol
	id_tipo_persona SERIAL NOT NULL,
	id_persona INT NOT NULL,
	id_rol INT NOT NULL,
	tipo VARCHAR(1),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_tipos_personas PRIMARY KEY(id_tipo_persona),
	CONSTRAINT fk_personas_tipos_personas FOREIGN KEY(id_persona) REFERENCES personas(id_persona),
	CONSTRAINT fk_roles_tipos_personas FOREIGN KEY(id_rol) REFERENCES roles(id_rol)
);

CREATE TABLE personas_alumnos (
    id_persona_alumno SERIAL NOT NULL,
    id_persona INT NOT NULL,
	id_carrera INT NOT NULL,
    fecha DATE DEFAULT now(),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_alumnos PRIMARY KEY(id_persona_alumno),
	CONSTRAINT fk_personas_personas_alumnos FOREIGN KEY(id_persona) REFERENCES personas(id_persona),
	CONSTRAINT fk_carreras_personas_alumnos FOREIGN KEY(id_carrera) REFERENCES carreras(id_carrera)
);

CREATE TABLE personas_docentes (
    id_persona_docente SERIAL NOT NULL,
    id_persona INT NOT NULL,
	fecha_ingreso DATE,
    fecha DATE DEFAULT now(),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_docentes PRIMARY KEY(id_persona_docente),
	CONSTRAINT fk_personas_personas_docentes FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
);

CREATE TABLE personas_administrativos (
    id_persona_administrativo SERIAL NOT NULL,
    id_persona INT NOT NULL,
	cargo VARCHAR(150) , -- -- en el futuro id_cargo que hara referencia a una estructura de cargos
    fecha DATE DEFAULT now(),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_administrativos PRIMARY KEY(id_persona_administrativo),
	CONSTRAINT fk_personas_personas_administrativos FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
);

CREATE TABLE personas_directores_carreras (
    id_persona_director_carrera SERIAL NOT NULL,
    id_carrera INT NOT NULL,
    id_persona INT NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
	resolucion VARCHAR(255), -- -----imagen de la resolucion de asignacion
	firma_digital VARCHAR(255), -- -- imagen
	observacion VARCHAR(255),
    estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_directores_carreras PRIMARY KEY(id_persona_director_carrera),
	CONSTRAINT fk_carreras_personas_directores_carreras FOREIGN KEY(id_carrera) REFERENCES carreras(id_carrera),
	CONSTRAINT fk_personas_personas_directores_carreras FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
);

CREATE TABLE personas_decanos (
    id_persona_decano SERIAL NOT NULL,
    id_facultad INT NOT NULL,
    id_persona INT NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
	resolucion VARCHAR(255), -- -----imagen de la resolucion de asignacion
	firma_digital VARCHAR(255), -- -- imagen
	observacion VARCHAR(255),
    estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_decanos PRIMARY KEY(id_persona_decano),
	CONSTRAINT fk_facultades_id_persona_decano FOREIGN KEY(id_facultad) REFERENCES facultades(id_facultad),
	CONSTRAINT fk_personas_id_persona_decano FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
);

-- --------------------------------------------------------------------------------------------------------------
CREATE TABLE gestiones_periodos (
	id_gestion_periodo SERIAL NOT NULL,
    gestion INT NOT NULL,
    periodo INT NOT NULL,
    tipo VARCHAR(1) NOT NULL,   -- -- A=Anual, S=Semestral
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_gestiones_periodos PRIMARY KEY(id_gestion_periodo)
);

-- -------------------------------------------------------------------------------------------------------------------
CREATE TABLE tipos_evaluaciones_notas (
	id_tipo_evaluacion_nota SERIAL NOT NULL,
	nombre VARCHAR(3) NOT NULL,
	-- -- agregar labels de las dimensiones
    parcial INT DEFAULT 0,
    practica INT DEFAULT 0,
    laboratorio INT DEFAULT 0,
    examen_final INT DEFAULT 0,
	nota_minima_aprobacion INT, -- -- 51 o en otros casos 56
	-- -- Nota minima de standar colegio 
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_tipos_evaluaciones_notas PRIMARY KEY(id_tipo_evaluacion_nota)
);

-- ---------------------------------------------- HORARIOS DOCENTES ----------------------------------------------------------
CREATE TABLE dias (
    id_dia SERIAL NOT NULL,
    numero INT,
    nombre VARCHAR(30),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_dias PRIMARY KEY(id_dia)
);

CREATE TABLE horas_clases (
    id_hora_clase SERIAL NOT NULL,
    numero INT,
    hora_inicio TIME,
    hora_fin TIME,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_horas_clases PRIMARY KEY(id_hora_clase)
);

-- ------------------------------------------ GESTION DE VENTA DE MATRICULAS --------------------------------------------------------------
CREATE TABLE cuentas_conceptos (
    id_cuenta_concepto SERIAL NOT NULL,
	nombre VARCHAR(150),
	descripcion VARCHAR(350),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_cuentas_conceptos PRIMARY KEY(id_cuenta_concepto)
);
-- --------------------------------------------------------------------------------------------------------------
-- -------------------------------- POSTGRADO ADMINISTRATIVO ----------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------
CREATE TABLE personas_directores_posgrados(
	id_persona_director_posgrado SERIAL NOT NULL,
	id_persona INT NOT NULL,
	fecha_inicio DATE,
	fecha_fin DATE,
	firma_digital VARCHAR(255),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_directores_posgrados PRIMARY KEY(id_persona_director_posgrado),
	CONSTRAINT fk_personas_directores_posgrados_personas FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
	-- CONSTRAINT fk_personas_personas_roles FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
);

CREATE TABLE personas_facultades_administradores(
	id_persona_facultad_administrador SERIAL NOT NULL,
	id_persona INT NOT NULL,
	fecha_inicio DATE,
	fecha_fin DATE,
	firma_digital VARCHAR(255),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_facultades_administradores PRIMARY KEY(id_persona_facultad_administrador),
	CONSTRAINT fk_personas_facultades_administradores_personas FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
	-- CONSTRAINT fk_personas_personas_roles FOREIGN KEY(id_persona) REFERENCES personas(id_persona)
);

CREATE TABLE personas_roles(
	id_persona_rol SERIAL NOT NULL,
	id_persona INT NOT NULL,
	id_rol INT NOT NULL,
	fecha_asignacion DATE,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_roles PRIMARY KEY(id_persona_rol),
	CONSTRAINT fk_personas_personas_roles FOREIGN KEY(id_persona) REFERENCES personas(id_persona),
	CONSTRAINT fk_roles_personas_roles FOREIGN KEY(id_rol) REFERENCES roles(id_rol)
); 

CREATE TABLE posgrados_programas(
	id_posgrado_programa SERIAL NOT NULL,
	id_nivel_academico INT NOT NULL,
	id_carrera INT NOT NULL,
	gestion INT,
	nombre VARCHAR(100),
	id_modalidad INT NOT NULL,
	fecha_inicio DATE,
	fecha_fin DATE,
	fecha_inicio_inscrito DATE,
	fecha_fin_inscrito DATE,
	numero_max_cuotas INT,
	documento VARCHAR(500),
	costo_total FLOAT,
    formato_contrato TEXT,
	formato_contrato_docente TEXT,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrados_programas PRIMARY KEY(id_posgrado_programa),
	CONSTRAINT fk_nivel_academico_programa_posgrado FOREIGN KEY(id_nivel_academico) REFERENCES niveles_academicos(id_nivel_academico),
	CONSTRAINT fk_carreras_programa_posgrado FOREIGN KEY(id_carrera) REFERENCES carreras(id_carrera),
	CONSTRAINT fk_modalidades_programa_posgrado FOREIGN KEY(id_modalidad) REFERENCES modalidades(id_modalidad)
);

CREATE TABLE personas_alumnos_posgrados(
	id_persona_alumno_posgrado SERIAL NOT NULL,
    id_persona  INT NOT NULL,
    id_posgrado_programa INT NOT NULL, 
	fecha  DATE,
    inscrito  VARCHAR(1) DEFAULT '0', -- -- se define "0" cuando es alumno y "1" cuando ya pago la matricula del programa
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_personas_alumnos_posgrados PRIMARY KEY(id_persona_alumno_posgrado),
	CONSTRAINT fk_personas_personas_alumnos_posgrados FOREIGN KEY(id_persona) REFERENCES personas(id_persona),
	CONSTRAINT fk_posgrados_programas_personas_alumnos_posgrados FOREIGN KEY(id_posgrado_programa) REFERENCES posgrados_programas(id_posgrado_programa)
);

CREATE TABLE cuentas_cargos_posgrados( -- -- Se define el tipo de pago Gral. Ejm.: SIN DESCUENTO, CON DESCUENTO DEL 10%, CON DESCUENTO DEL 5, ETC.
	id_cuenta_cargo_posgrado SERIAL NOT NULL,
	id_posgrado_programa INT NOT NULL,
	nombre VARCHAR(250),
	numero_formulario VARCHAR(250),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_cuentas_cargos_posgrados PRIMARY KEY(id_cuenta_cargo_posgrado),
	CONSTRAINT fk_posgrados_programas_cuentas_cargos_posgrados FOREIGN KEY(id_posgrado_programa) REFERENCES posgrados_programas(id_posgrado_programa)
);

CREATE TABLE cuentas_cargos_posgrados_conceptos( -- -- Permite guardar que concepto tiene descuento
	id_cuenta_cargo_posgrado_concepto SERIAL NOT NULL,
	id_cuenta_cargo_posgrado INT NOT NULL,
	id_cuenta_concepto INT NOT NULL,
	tiene_descuento VARCHAR(1),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_cuentas_cargos_posgrados_conceptos PRIMARY KEY(id_cuenta_cargo_posgrado_concepto),
	CONSTRAINT fk_cuentas_cargos_posgrados_cargos_conceptos FOREIGN KEY(id_cuenta_cargo_posgrado) REFERENCES cuentas_cargos_posgrados(id_cuenta_cargo_posgrado),
	CONSTRAINT fk_cuentas_cargos_posgrados_cuentas_cargos_conceptos FOREIGN KEY(id_cuenta_concepto) REFERENCES cuentas_conceptos(id_cuenta_concepto)
);

CREATE TABLE cuentas_cargos_conceptos_posgrados( 
	id_cuenta_cargo_concepto_posgrado SERIAL NOT NULL,
	id_cuenta_cargo_posgrado_concepto INT NOT NULL,
	costo FLOAT,
	porcentaje INT,  -- -- default 0
	descuento FLOAT, -- -- default 0
	monto_pagar FLOAT,
	fecha DATE,
	desglose BOOLEAN,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_cuentas_cargos_conceptos_posgrados PRIMARY KEY(id_cuenta_cargo_concepto_posgrado),
	CONSTRAINT fk_cuentas_conceptos_posgrados_conceptos_cargos FOREIGN KEY(id_cuenta_cargo_posgrado_concepto) REFERENCES cuentas_cargos_posgrados_conceptos(id_cuenta_cargo_posgrado_concepto)
);

CREATE TABLE posgrados_contratos( 
	id_posgrado_contrato SERIAL NOT NULL,
	id_cuenta_cargo_posgrado INT NOT NULL,
	id_persona_alumno_posgrado INT NOT NULL,
	numero_cuotas INT,
	id_persona_director_posgrado INT NOT NULL,
	id_persona_facultad_administrador INT NOT NULL,
	id_persona_decano INT NOT NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrados_contratos PRIMARY KEY(id_posgrado_contrato),
	CONSTRAINT fk_conceptos_cargos_contratos FOREIGN KEY(id_cuenta_cargo_posgrado) REFERENCES cuentas_cargos_posgrados(id_cuenta_cargo_posgrado),
	CONSTRAINT fk_personas_alumnos_posgrados_contratos FOREIGN KEY(id_persona_alumno_posgrado) REFERENCES personas_alumnos_posgrados(id_persona_alumno_posgrado),
	CONSTRAINT fk_personas_directores_posgrado_posgrados_contratos FOREIGN KEY(id_persona_director_posgrado) REFERENCES personas_directores_posgrados(id_persona_director_posgrado),
	CONSTRAINT fk_personas_facultades_administradores_posgrados_contratos FOREIGN KEY(id_persona_facultad_administrador) REFERENCES personas_facultades_administradores(id_persona_facultad_administrador),
	CONSTRAINT fk_personas_decanos_posgrados_contratos FOREIGN KEY(id_persona_decano) REFERENCES personas_decanos(id_persona_decano)
);

CREATE TABLE posgrados_contratos_detalles(
	id_posgrado_contrato_detalle SERIAL NOT NULL,
	id_posgrado_contrato INT NOT NULL,
	id_cuenta_cargo_concepto_posgrado INT NOT NULL,
	pagado BOOLEAN,
	monto_pagado FLOAT,		-- -- Monto de pago control interno
	monto_adeudado FLOAT,	-- -- Monto de pago para cotrol interno 
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrados_contratos_detalles PRIMARY KEY(id_posgrado_contrato_detalle),
	CONSTRAINT fk_contratos_posgrados_contratos_detalles FOREIGN KEY(id_posgrado_contrato) REFERENCES posgrados_contratos(id_posgrado_contrato),
	CONSTRAINT fk_cuentas_cargos_posgrados_contratos_detalles FOREIGN KEY(id_cuenta_cargo_concepto_posgrado) REFERENCES cuentas_cargos_conceptos_posgrados(id_cuenta_cargo_concepto_posgrado)
);

-- -- Falta dos tablas de ccontrato para el Docente

CREATE TABLE posgrados_contratos_detalles_desglose(
	id_posgrado_desglose SERIAL NOT NULL,
	id_posgrado_contrato_detalle INT NOT NULL,
	monto FLOAT,
	descripcion VARCHAR(30), -- -- Mes o numero de Pago
	pagado BOOLEAN,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrados_contratos_detalles_desglose PRIMARY KEY(id_posgrado_desglose),
	CONSTRAINT fk_contratos_posgrados_contratos_detalles_desglose FOREIGN KEY(id_posgrado_contrato_detalle) REFERENCES posgrados_contratos_detalles(id_posgrado_contrato_detalle)
);

CREATE TABLE posgrados_transacciones(
	id_posgrado_transaccion SERIAL NOT NULL,
	id_posgrado_contrato INT NOT NULL,
	id_persona_alumno_posgrado INT NOT NULL,
	fecha_transaccion DATE,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrados_transacciones PRIMARY KEY(id_posgrado_transaccion),
	CONSTRAINT fk_posgrado_contrato_posgrados_transacciones FOREIGN KEY(id_posgrado_contrato) REFERENCES posgrados_contratos(id_posgrado_contrato),
	CONSTRAINT fk_personas_alumnos_posgrados_transacciones FOREIGN KEY(id_persona_alumno_posgrado) REFERENCES personas_alumnos_posgrados(id_persona_alumno_posgrado)
);

CREATE TABLE posgrados_transacciones_detalles(
	id_posgrado_transaccion_detalle SERIAL NOT NULL,
	id_posgrado_transaccion INT NOT NULL,
	id_posgrado_contrato_detalle INT NOT NULL,
	fecha_deposito DATE,
	numero_deposito VARCHAR(100),
	monto_deposito FLOAT,
	fotografia_deposito VARCHAR(255),
    usado_transaccion VARCHAR(1) DEFAULT '0', -- -- Para ver si utilizamos o no la transaccion
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrados_transacciones_detalles PRIMARY KEY(id_posgrado_transaccion_detalle),
	CONSTRAINT fk_transacciones_posgrados_transacciones_detalles FOREIGN KEY(id_posgrado_transaccion) REFERENCES posgrados_transacciones(id_posgrado_transaccion),
	CONSTRAINT fk_contrato_detalle_transacciones_detalles FOREIGN KEY(id_posgrado_contrato_detalle) REFERENCES posgrados_contratos_detalles(id_posgrado_contrato_detalle)
);

CREATE TABLE posgrados_transacciones_detalles_desglose(
	id_transaccion_desglose SERIAL NOT NULL,
	id_posgrado_contrato_detalle INT NOT NULL,
    id_posgrado_transaccion_detalle INT NOT NULL,
	monto_desglosado FLOAT,
	descripcion VARCHAR(100), -- -- Una Descripcion del mes de transaccion o las Observaciones de Que tranacaciones de esta realizando
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrados_transaccion_detalles_desglose PRIMARY KEY(id_transaccion_desglose),
	CONSTRAINT fk_transaccion_posgrados_contratos_detalles_desglose FOREIGN KEY(id_posgrado_contrato_detalle) REFERENCES posgrados_contratos_detalles(id_posgrado_contrato_detalle),
    CONSTRAINT fk_transaccion_posgrados_transaccion_detalles_desglose FOREIGN KEY(id_posgrado_transaccion_detalle) REFERENCES posgrados_transacciones_detalles(id_posgrado_transaccion_detalle)
);

CREATE TABLE montos_excedentes(
	id_monto_excedente SERIAL NOT NULL,
	id_posgrado_transaccion_detalle INT NOT NULL,
	monto_excedente FLOAT,
	procesando VARCHAR(1) DEFAULT '0',
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_montos_excedentes PRIMARY KEY(id_monto_excedente),
	CONSTRAINT fk_montos_excedentes_posgrados_transacciones FOREIGN KEY(id_posgrado_transaccion_detalle) REFERENCES posgrados_transacciones_detalles(id_posgrado_transaccion_detalle)
);

CREATE TABLE tramites_documentos(
	id_tramite_documento SERIAL NOT NULL,
	nombre VARCHAR(80),
	descripcion VARCHAR(250),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_tramites_documentos PRIMARY KEY(id_tramite_documento)
);

CREATE TABLE niveles_academicos_tramites_documentos(
	id_nivel_academico_tramite_documento SERIAL NOT NULL,
	id_nivel_academico INT NOT NULL,
	id_tramite_documento INT NOT NULL,
	fecha TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_niveles_academicos_tramites_documentos PRIMARY KEY(id_nivel_academico_tramite_documento),
	CONSTRAINT fk_niveles_academicos_niveles_academicos_tramites_documentos FOREIGN KEY(id_nivel_academico) REFERENCES niveles_academicos(id_nivel_academico),
	CONSTRAINT fk_tramites_documentos_niveles_academicos_tramites_documentos FOREIGN KEY(id_tramite_documento) REFERENCES tramites_documentos(id_tramite_documento)
);

CREATE TABLE posgrado_alumnos_documentos(
	id_posgrado_alumno_documento SERIAL NOT NULL,
	id_persona_alumno_posgrado INT NOT NULL,
	id_nivel_academico_tramite_documento INT NOT NULL,
	fecha_subida TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
	archivo VARCHAR(100),
	verificado VARCHAR(1) DEFAULT 'N',
	fecha_verificacion TIMESTAMP,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrado_alumnos_documentos PRIMARY KEY(id_posgrado_alumno_documento),
	CONSTRAINT fk_personas_alumnos_posgrado_documentos FOREIGN KEY(id_persona_alumno_posgrado) REFERENCES personas_alumnos_posgrados(id_persona_alumno_posgrado),
	CONSTRAINT fk_niveles_academicos_tramites_documentos_documentos FOREIGN KEY(id_nivel_academico_tramite_documento) REFERENCES niveles_academicos_tramites_documentos(id_nivel_academico_tramite_documento)
);
-- -- Tabla suelta remitido a un email y luego importado al sistema
CREATE TABLE extractos_bancarios(
	id_extracto_bancario SERIAL NOT NULL,
	nombre_completo VARCHAR(200),
	carnet_identidad VARCHAR(20),
	numero_codigo VARCHAR(50),
	monto FLOAT,
	fecha DATE,
    hora TIME,
    procesando VARCHAR(1) DEFAULT '0',
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_extractos_bancarios PRIMARY KEY(id_extracto_bancario)
);
-- --------------------------------------------------------------------------------------------------------------
-- ------------------------------------- POSTGRADO ACADEMICO ----------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------

CREATE TABLE posgrado_niveles( -- -- Basicas - Intermedio - Avanzada
    id_posgrado_nivel SERIAL NOT NULL,
    nombre VARCHAR(100) NOT NULL,
	descripcion VARCHAR(100) NULL,
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrado_niveles PRIMARY KEY(id_posgrado_nivel)
);

CREATE TABLE posgrado_materias (
    id_posgrado_materia SERIAL NOT NULL,
    id_posgrado_programa INT NOT NULL,
	id_posgrado_nivel INT NOT NULL,
	sigla VARCHAR(6) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    nivel_curso INT,
	cantidad_hora_teorica INT DEFAULT 0,
    cantidad_hora_practica INT DEFAULT 0,
    cantidad_hora_laboratorio INT DEFAULT 0,
	cantidad_hora_plataforma INT DEFAULT 0,
	cantidad_hora_virtual INT DEFAULT 0,
	cantidad_credito INT DEFAULT 0,
    color VARCHAR(7) DEFAULT '#000000',
	icono  VARCHAR(35) DEFAULT '',
	imagen VARCHAR(250) DEFAULT '',
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_postgrado_materias PRIMARY KEY(id_posgrado_materia),
	CONSTRAINT fk_posgrados_programas_postgrado_materias FOREIGN KEY(id_posgrado_programa) REFERENCES posgrados_programas(id_posgrado_programa),
	CONSTRAINT fk_posgrado_niveles_postgrado_materias FOREIGN KEY(id_posgrado_nivel) REFERENCES posgrado_niveles(id_posgrado_nivel)
);

CREATE TABLE posgrado_tipos_evaluaciones_notas (
	id_posgrado_tipo_evaluacion_nota SERIAL NOT NULL,
	nombre VARCHAR(3) NOT NULL,
	configuracion JSONB NOT NULL,
	nota_minima_aprobacion INT, -- -- 51 o en otros casos 56 o 70 depende del postgrado
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrado_tipos_evaluaciones_notas PRIMARY KEY(id_posgrado_tipo_evaluacion_nota)
);

CREATE TABLE posgrado_asignaciones_docentes ( -- -- Fecha de inicio de clases y fin de clases
	id_posgrado_asignacion_docente SERIAL NOT NULL,
    id_persona_docente INT NOT NULL,
    id_posgrado_materia INT NOT NULL,
    id_posgrado_tipo_evaluacion_nota INT DEFAULT 0,
	id_gestion_periodo INT NOT NULL,
	tipo_calificacion VARCHAR(3) DEFAULT 'N', -- -- sobre 100 o directamente ponderado de acuerdo a sistema de evaluacion
	grupo VARCHAR(3),
	cupo_maximo_estudiante INT DEFAULT 0,
    finaliza_planilla_calificacion VARCHAR(1) DEFAULT 'N', 
	fecha_limite_examen_final TIMESTAMP WITHOUT TIME ZONE,
    fecha_limite_nota_2da_instancia TIMESTAMP WITHOUT TIME ZONE,
    fecha_limite_nota_examen_mesa TIMESTAMP WITHOUT TIME ZONE,
	fecha_finalizacion_planilla TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    hash VARCHAR(500),
	codigo_barras VARCHAR(500),
	codigo_qr VARCHAR(500),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrado_asignaciones_docentes PRIMARY KEY(id_posgrado_asignacion_docente),
	CONSTRAINT fk_personas_docentes_posgrado_asignaciones_docentes FOREIGN KEY(id_persona_docente) REFERENCES personas_docentes(id_persona_docente),
	CONSTRAINT fk_posgrado_materias_posgrado_asignaciones_docentes FOREIGN KEY(id_posgrado_materia) REFERENCES posgrado_materias(id_posgrado_materia),
	CONSTRAINT fk_posgrado_tipos_evaluaciones_notas_posg_asig_doc FOREIGN KEY(id_posgrado_tipo_evaluacion_nota) REFERENCES posgrado_tipos_evaluaciones_notas(id_posgrado_tipo_evaluacion_nota),
	CONSTRAINT fk_gestiones_periodos_posgrado_asignaciones_docentes FOREIGN KEY(id_gestion_periodo) REFERENCES gestiones_periodos(id_gestion_periodo)
);

CREATE TABLE posgrado_calificaciones (
	id_postgrado_calificacion SERIAL NOT NULL,
    id_persona_alumno_posgrado INT NOT NULL,
    id_posgrado_asignacion_docente INT NOT NULL,
	tipo_programacion INT DEFAULT 0, -- -- 0 = Nuevo, 1 = Repitente, este dato se lo debe poner en el momento de la programacion automatica
	control_asistencia JSONB,
	configuracion JSONB, -- -- La configuracion de la calificacion, Ejm.: [{"campo:"calificacion1","descripcion":"Practica de...."},{"campo":"calicacion2","descripcion":"examen de..."},{"campo":"calificacion9","descripcion":"Foro de .."},{"campo":"calificacion15","descripcion":"Nota Final"}]
	calificacion1 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion2 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion3 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion4 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion5 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion6 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion7 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion8 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion9 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion10 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion11 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion12 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion13 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion14 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion15 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion16 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion17 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion18 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion19 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	calificacion20 FLOAT DEFAULT 0, -- -- Esta se tranfiere de la plataforma o directo
	nota_final FLOAT DEFAULT 0, -- --Aqui se copia la nota final de las calificaciones
    nota_2da_instancia FLOAT DEFAULT 0,
    nota_examen_mesa FLOAT DEFAULT 0,
    observacion VARCHAR(1) DEFAULT 'R', -- -- A=Aprobado, R=Reprobado, X=Abandono
	tipo VARCHAR(1) DEFAULT 'N', -- N=normal, C=convalidado, H=homologado, S=Compensado
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrado_calificaciones PRIMARY KEY(id_postgrado_calificacion),
	CONSTRAINT fk_posgrado_personas_alumnos_posgrado_calificaciones FOREIGN KEY(id_persona_alumno_posgrado) REFERENCES personas_alumnos_posgrados(id_persona_alumno_posgrado),
	CONSTRAINT fk_posgrado_asignaciones_docentes_posgrado_calificaciones FOREIGN KEY(id_posgrado_asignacion_docente) REFERENCES posgrado_asignaciones_docentes(id_posgrado_asignacion_docente)
);

CREATE TABLE posgrado_asignaciones_horarios ( 
    id_posgrado_asignacion_horario SERIAL NOT NULL,
    id_posgrado_asignacion_docente INT NOT NULL,
    id_ambiente INT NOT NULL, -- -- Es un ambiente virtual
    id_dia INT NOT NULL,
    id_hora_clase INT NOT NULL,
	clase_link VARCHAR(255), -- -- El link Google Classroom o ZOOM
	clase_descripcion VARCHAR(500), -- -- Detalles del enlace
	fecha_registro DATE DEFAULT now(),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrado_asignaciones_horarios PRIMARY KEY(id_posgrado_asignacion_horario),
	CONSTRAINT fk_posg_asig_doc_posgrado_asig_horarios FOREIGN KEY(id_posgrado_asignacion_docente) REFERENCES posgrado_asignaciones_docentes(id_posgrado_asignacion_docente),
	CONSTRAINT fk_ambientes_posgrado_asignaciones_horarios FOREIGN KEY(id_ambiente) REFERENCES ambientes(id_ambiente),
	CONSTRAINT fk_dias_posgrado_asignaciones_horarios FOREIGN KEY(id_dia) REFERENCES dias(id_dia),
	CONSTRAINT fk_horas_clases_posgrado_asignaciones_horarios FOREIGN KEY(id_hora_clase) REFERENCES horas_clases(id_hora_clase)
);

CREATE TABLE posgrado_clases_videos (
    id_posgrado_clase_video SERIAL NOT NULL,
    id_posgrado_asignacion_horario INT NOT NULL,
	clase_link VARCHAR(255), -- -- El link de la clase particular
	clase_fecha DATE,
	clase_hora_inicio TIMESTAMP,
	clase_hora_fin TIMESTAMP,
	clase_duracion TIMESTAMP,
	fecha_registro DATE DEFAULT now(),
	estado VARCHAR(1) DEFAULT 'S',
	CONSTRAINT pk_posgrado_clases_videos PRIMARY KEY(id_posgrado_clase_video),
	CONSTRAINT fk_posgrado_asignaciones_horarios_posgrado_clases_videos FOREIGN KEY(id_posgrado_asignacion_horario) REFERENCES posgrado_asignaciones_horarios(id_posgrado_asignacion_horario)
);