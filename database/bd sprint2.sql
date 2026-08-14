-- =========================================================================
-- SCRIPT COMPLETO DE BASE DE DATOS: SISTEMA HOSPITALARIO (SPRINT 1 Y SPRINT 2)
-- =========================================================================

-- Crear y usar la base de datos
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'HospitalDB')
BEGIN
    CREATE DATABASE HospitalDB;
END
GO

USE HospitalDB;
GO

-- =========================================================
-- PASO 1: LIMPIEZA TOTAL EN ORDEN INVERSO (PARA EVITAR ERRORES DE FK)
-- =========================================================
IF OBJECT_ID('dbo.Citas', 'U') IS NOT NULL DROP TABLE dbo.Citas;
IF OBJECT_ID('dbo.Horarios', 'U') IS NOT NULL DROP TABLE dbo.Horarios;
IF OBJECT_ID('dbo.Consultorios', 'U') IS NOT NULL DROP TABLE dbo.Consultorios;
IF OBJECT_ID('dbo.Medicos', 'U') IS NOT NULL DROP TABLE dbo.Medicos;
IF OBJECT_ID('dbo.Pacientes', 'U') IS NOT NULL DROP TABLE dbo.Pacientes;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Medicos_Especialidades')
BEGIN
    ALTER TABLE dbo.Medicos DROP CONSTRAINT FK_Medicos_Especialidades;
END

IF OBJECT_ID('dbo.Especialidades', 'U') IS NOT NULL DROP TABLE dbo.Especialidades;
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL DROP TABLE dbo.Usuarios;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

-- =========================================================
-- PASO 2: CREACIÓN DE TABLAS BASE (SPRINT 1)
-- =========================================================

-- Tabla: Roles
CREATE TABLE Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);
GO

-- Tabla: Usuarios
CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    activo BIT DEFAULT 1,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (id_rol) REFERENCES Roles(id_rol)
);
GO

-- Tabla: Pacientes
CREATE TABLE Pacientes (
    id_paciente INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(15) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    genero VARCHAR(20),
    CONSTRAINT FK_Pacientes_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);
GO

-- =========================================================
-- PASO 3: CREACIÓN DE TABLAS Y AMPLIACIONES (SPRINT 2)
-- =========================================================

-- Tabla: Especialidades
CREATE TABLE Especialidades (
    id_especialidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL
);
GO

-- Tabla: Medicos (Con la nueva columna id_especialidad)
CREATE TABLE Medicos (
    id_medico INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    colegiatura VARCHAR(30) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    id_especialidad INT NULL,
    CONSTRAINT FK_Medicos_Usuarios FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_Medicos_Especialidades FOREIGN KEY (id_especialidad) REFERENCES Especialidades(id_especialidad)
);
GO

-- Tabla: Consultorios
CREATE TABLE Consultorios (
    id_consultorio INT IDENTITY(1,1) PRIMARY KEY,
    numero VARCHAR(10) NOT NULL UNIQUE,
    piso VARCHAR(10) NULL,
    ubicacion VARCHAR(100) NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Disponible'
        CHECK (estado IN ('Disponible', 'Ocupado', 'Mantenimiento'))
);
GO

-- Tabla: Horarios
CREATE TABLE Horarios (
    id_horario INT IDENTITY(1,1) PRIMARY KEY,
    id_medico INT NOT NULL,
    id_consultorio INT NOT NULL,
    dia_semana VARCHAR(15) NOT NULL
        CHECK (dia_semana IN ('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado','Domingo')),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    disponible BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Horarios_Medicos FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico),
    CONSTRAINT FK_Horarios_Consultorios FOREIGN KEY (id_consultorio) REFERENCES Consultorios(id_consultorio),
    CONSTRAINT CK_Horarios_HoraValida CHECK (hora_fin > hora_inicio)
);
GO

-- Tabla: Citas
CREATE TABLE Citas (
    id_cita INT IDENTITY(1,1) PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    id_consultorio INT NOT NULL,
    id_horario INT NOT NULL,
    fecha DATE NOT NULL,
    hora_cita TIME NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
        CHECK (estado IN ('Pendiente','Confirmada','Cancelada','Atendida')),
    observaciones VARCHAR(255) NULL,
    CONSTRAINT FK_Citas_Pacientes FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente),
    CONSTRAINT FK_Citas_Medicos FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico),
    CONSTRAINT FK_Citas_Consultorios FOREIGN KEY (id_consultorio) REFERENCES Consultorios(id_consultorio),
    CONSTRAINT FK_Citas_Horarios FOREIGN KEY (id_horario) REFERENCES Horarios(id_horario)
);
GO

-- =========================================================
-- PASO 4: DATOS INICIALES, ROLES Y CONSULTORIOS
-- =========================================================

-- Roles base
INSERT INTO Roles (nombre_rol) VALUES ('Paciente');
INSERT INTO Roles (nombre_rol) VALUES ('Medico');
INSERT INTO Roles (nombre_rol) VALUES ('Administrador');
GO

-- Consultorios base
INSERT INTO Consultorios (numero, piso, ubicacion, estado) VALUES
('101', '1', 'Ala Norte', 'Disponible'),
('102', '1', 'Ala Norte', 'Disponible'),
('205', '2', 'Ala Sur', 'Disponible');
GO

-- Especialidades oficiales (Sincronizadas con Chatbot y sistema)
INSERT INTO Especialidades (nombre, descripcion) VALUES
('Medicina General', 'Atención médica primaria y preventiva'),
('Cardiología', 'Atención de enfermedades del corazón'),
('Gastroenterología', 'Atención de afecciones digestivas'),
('Traumatología y Ortopedia', 'Atención de lesiones musculares y óseas'),
('Oftalmología', 'Atención de la salud visual'),
('Dermatología', 'Atención de la piel'),
('Pediatría', 'Atención médica infantil');
GO

-- =========================================================
-- PASO 5: REGISTRO DE PACIENTE DE PRUEBA (Opcional pero útil)
-- =========================================================
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) 
VALUES ('juan@gmail.com', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a', 1, 1);

INSERT INTO Pacientes (id_usuario, nombres, apellidos, dni, fecha_nacimiento, telefono, direccion, genero)
VALUES (SCOPE_IDENTITY(), 'Juan', 'Perez', '74536339', '2021-02-02', '967462534', 'Av Manzanal', 'Masculino');
GO

-- =========================================================
-- PASO 6: REGISTRO DE LOS 7 MÉDICOS OFICIALES, USUARIOS Y HORARIOS
-- =========================================================
DECLARE @pass VARCHAR(255) = '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a';
DECLARE @id_c INT = (SELECT TOP 1 id_consultorio FROM Consultorios);
DECLARE @id_u INT;
DECLARE @id_esp INT;
DECLARE @nuevo_medico_id INT;

----------------------------------------------------------------------------------
-- 1. MEDICINA GENERAL
----------------------------------------------------------------------------------
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) VALUES ('carlos.med@hospital.com', @pass, 2, 1);
SET @id_u = SCOPE_IDENTITY();
SELECT @id_esp = id_especialidad FROM Especialidades WHERE nombre = 'Medicina General';

INSERT INTO Medicos (id_usuario, nombres, apellidos, especialidad, colegiatura, telefono, id_especialidad)
VALUES (@id_u, 'Carlos', 'Mendoza', 'Medicina General', 'CMP-11111', '900000000', @id_esp);
SET @nuevo_medico_id = SCOPE_IDENTITY();

INSERT INTO Horarios (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, disponible)
VALUES (@nuevo_medico_id, @id_c, 'Lunes', '08:00:00', '16:00:00', 1);

----------------------------------------------------------------------------------
-- 2. CARDIOLOGÍA
----------------------------------------------------------------------------------
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) VALUES ('ana.cardio@hospital.com', @pass, 2, 1);
SET @id_u = SCOPE_IDENTITY();
SELECT @id_esp = id_especialidad FROM Especialidades WHERE nombre = 'Cardiología';

INSERT INTO Medicos (id_usuario, nombres, apellidos, especialidad, colegiatura, telefono, id_especialidad)
VALUES (@id_u, 'Ana', 'Soto', 'Cardiología', 'CMP-22222', '900000000', @id_esp);
SET @nuevo_medico_id = SCOPE_IDENTITY();

INSERT INTO Horarios (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, disponible)
VALUES (@nuevo_medico_id, @id_c, 'Lunes', '08:00:00', '16:00:00', 1);

----------------------------------------------------------------------------------
-- 3. GASTROENTEROLOGÍA
----------------------------------------------------------------------------------
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) VALUES ('elena.gastro@hospital.com', @pass, 2, 1);
SET @id_u = SCOPE_IDENTITY();
SELECT @id_esp = id_especialidad FROM Especialidades WHERE nombre = 'Gastroenterología';

INSERT INTO Medicos (id_usuario, nombres, apellidos, especialidad, colegiatura, telefono, id_especialidad)
VALUES (@id_u, 'Elena', 'Mendoza', 'Gastroenterología', 'CMP-33333', '900000000', @id_esp);
SET @nuevo_medico_id = SCOPE_IDENTITY();

INSERT INTO Horarios (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, disponible)
VALUES (@nuevo_medico_id, @id_c, 'Lunes', '08:00:00', '16:00:00', 1);

----------------------------------------------------------------------------------
-- 4. TRAUMATOLOGÍA Y ORTOPEDIA
----------------------------------------------------------------------------------
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) VALUES ('luis.trauma@hospital.com', @pass, 2, 1);
SET @id_u = SCOPE_IDENTITY();
SELECT @id_esp = id_especialidad FROM Especialidades WHERE nombre = 'Traumatología y Ortopedia';

INSERT INTO Medicos (id_usuario, nombres, apellidos, especialidad, colegiatura, telefono, id_especialidad)
VALUES (@id_u, 'Luis', 'Pérez', 'Traumatología y Ortopedia', 'CMP-44444', '900000000', @id_esp);
SET @nuevo_medico_id = SCOPE_IDENTITY();

INSERT INTO Horarios (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, disponible)
VALUES (@nuevo_medico_id, @id_c, 'Lunes', '08:00:00', '16:00:00', 1);

----------------------------------------------------------------------------------
-- 5. DERMATOLOGÍA
----------------------------------------------------------------------------------
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) VALUES ('sofia.derm@hospital.com', @pass, 2, 1);
SET @id_u = SCOPE_IDENTITY();
SELECT @id_esp = id_especialidad FROM Especialidades WHERE nombre = 'Dermatología';

INSERT INTO Medicos (id_usuario, nombres, apellidos, especialidad, colegiatura, telefono, id_especialidad)
VALUES (@id_u, 'Sofía', 'Rojas', 'Dermatología', 'CMP-55555', '900000000', @id_esp);
SET @nuevo_medico_id = SCOPE_IDENTITY();

INSERT INTO Horarios (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, disponible)
VALUES (@nuevo_medico_id, @id_c, 'Lunes', '08:00:00', '16:00:00', 1);

----------------------------------------------------------------------------------
-- 6. OFTALMOLOGÍA
----------------------------------------------------------------------------------
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) VALUES ('jorge.oft@hospital.com', @pass, 2, 1);
SET @id_u = SCOPE_IDENTITY();
SELECT @id_esp = id_especialidad FROM Especialidades WHERE nombre = 'Oftalmología';

INSERT INTO Medicos (id_usuario, nombres, apellidos, especialidad, colegiatura, telefono, id_especialidad)
VALUES (@id_u, 'Jorge', 'Silva', 'Oftalmología', 'CMP-66666', '900000000', @id_esp);
SET @nuevo_medico_id = SCOPE_IDENTITY();

INSERT INTO Horarios (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, disponible)
VALUES (@nuevo_medico_id, @id_c, 'Lunes', '08:00:00', '16:00:00', 1);

----------------------------------------------------------------------------------
-- 7. PEDIATRÍA
----------------------------------------------------------------------------------
INSERT INTO Usuarios (correo, password_hash, id_rol, activo) VALUES ('maria.ped@hospital.com', @pass, 2, 1);
SET @id_u = SCOPE_IDENTITY();
SELECT @id_esp = id_especialidad FROM Especialidades WHERE nombre = 'Pediatría';

INSERT INTO Medicos (id_usuario, nombres, apellidos, especialidad, colegiatura, telefono, id_especialidad)
VALUES (@id_u, 'María', 'Torres', 'Pediatría', 'CMP-77777', '900000000', @id_esp);
SET @nuevo_medico_id = SCOPE_IDENTITY();

INSERT INTO Horarios (id_medico, id_consultorio, dia_semana, hora_inicio, hora_fin, disponible)
VALUES (@nuevo_medico_id, @id_c, 'Lunes', '08:00:00', '16:00:00', 1);
GO

-- =========================================================
-- PASO 7: CONSULTA DE VERIFICACIÓN FINAL
-- =========================================================
SELECT m.id_medico, m.nombres, m.apellidos, e.nombre AS especialidad_oficial, m.colegiatura 
FROM Medicos m 
JOIN Especialidades e ON m.id_especialidad = e.id_especialidad;
GO