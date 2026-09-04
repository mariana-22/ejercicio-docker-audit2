CREATE DATABASE IF NOT EXISTS legacydb;
USE legacydb;

CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO usuarios (nombre, email) VALUES
    ('Ana Pérez', 'ana.perez@technova.com'),
    ('Luis Gómez', 'luis.gomez@technova.com'),
    ('Carla Ruiz', 'carla.ruiz@technova.com');