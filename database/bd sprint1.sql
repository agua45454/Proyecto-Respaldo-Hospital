-- =========================================================
-- Base de Datos: Sistema Hospitalario
-- KAN-3: Diseño y script de BD en SQL Server
-- =========================================================

CREATE DATABASE HospitalDB;
GO

USE HospitalDB;
GO

-- =========================================================
-- Tabla: Roles (Paciente, Médico, Administrador...)
-- =========================================================
CREATE TABLE Roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

-- =========================================================
-- Tabla: Usuarios (login y autenticación - KAN-2)
-- =========================================================
CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    activo BIT DEFAULT 1,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (id_rol)
        REFERENCES Roles(id_rol)
);

-- =========================================================
-- Tabla: Pacientes (datos de registro - KAN-1 / HU-01)
-- =========================================================
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
    CONSTRAINT FK_Pacientes_Usuarios FOREIGN KEY (id_usuario)
        REFERENCES Usuarios(id_usuario)
);

-- =========================================================
-- Tabla: Médicos
-- =========================================================
CREATE TABLE Medicos (
    id_medico INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    colegiatura VARCHAR(30) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    CONSTRAINT FK_Medicos_Usuarios FOREIGN KEY (id_usuario)
        REFERENCES Usuarios(id_usuario)
);

-- =========================================================
-- Datos iniciales de Roles
-- =========================================================
INSERT INTO Roles (nombre_rol) VALUES ('Paciente');
INSERT INTO Roles (nombre_rol) VALUES ('Medico');
INSERT INTO Roles (nombre_rol) VALUES ('Administrador');
GO