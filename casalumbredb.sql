
-- Create the datbase name: casalumbre_db;
CREATE DATABASE casalumbre_db;

-- Use this database;
USE casalumbre_db;

-- Create the TipoContenedor table to store different container types and their capacities

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.TipoContenedor', 'U') IS NOT NULL
DROP TABLE dbo.TipoContenedor;
GO

-- Create the table
CREATE TABLE dbo.TipoContenedor (
    ID_Tipo INT NOT NULL IDENTITY(1,1),    -- Unique identifier for each container type
    Nombre VARCHAR(32) NOT NULL,           -- Name of the container type
    Capacidad DECIMAL(10, 2) NOT NULL,     -- Capacity of the container type
    PRIMARY KEY (ID_Tipo)                  -- Set ID_Tipo as the primary key
);

-- Insert data into the TipoContenedor table

INSERT INTO TipoContenedor (Nombre, Capacidad) VALUES
('TANQUE 1', 50000),
('TANQUE 2', 50000),
('TANQUE 3', 50000),
('TANQUE 4', 50000),
('TANQUE 5', 30000),
('TANQUE 6', 30000),
('TANQUE 7', 30000),
('TANQUE 8', 30000),
('TANQUE 9', 30000),
('TANQUE A', 30000),
('TANQUE B', 30000),
('TANQUE C', 30000),
('TANQUE D', 30000),
('TANQUE E', 30000),
('TOTE XX', 1000),
('PORRÓN XX', 20),
('TAMBO XX', 200);

-- Create the EstatusContenedor table to store the status of containers

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.EstatusContenedor', 'U') IS NOT NULL
DROP TABLE dbo.EstatusContenedor;
GO

-- Create the table
CREATE TABLE dbo.EstatusContenedor (
    ID_Estatus INT NOT NULL IDENTITY(1,1),    -- Unique identifier for each status
    Descripcion VARCHAR(32) NOT NULL,         -- Description of the status
    PRIMARY KEY (ID_Estatus)                  -- Set ID_Estatus as the primary key
);

-- Insert data into the EstatusContenedor table

INSERT INTO EstatusContenedor (Descripcion) VALUES
('EN USO'),
('DISPONIBLE'),
('NO DISPONIBLE'),
('DAÑADO'),
('CUARENTENA');

-- Create the UbicacionContenedor table to store the locations of containers

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.UbicacionContenedor', 'U') IS NOT NULL
DROP TABLE dbo.UbicacionContenedor;
GO

-- Create the table
CREATE TABLE dbo.UbicacionContenedor (
    ID_Ubicacion INT NOT NULL IDENTITY(1,1),    -- Unique identifier for each location
    Descripcion VARCHAR(32) NOT NULL,           -- Description of the location
    PRIMARY KEY (ID_Ubicacion)                  -- Set ID_Ubicacion as the primary key
);

-- Insert data into the UbicacionContenedor table

INSERT INTO UbicacionContenedor (Descripcion) VALUES
('DM4'),
('ODT-ENV'),
('BETA'),
('ODT1'),
('LAB');

-- Create the EstatusLiquido table to store the status of liquids

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.EstatusLiquido', 'U') IS NOT NULL
DROP TABLE dbo.EstatusLiquido;
GO

-- Create the table
CREATE TABLE dbo.EstatusLiquido (
    ID_Estatus INT NOT NULL IDENTITY(1,1),    -- Unique identifier for each liquid status
    Descripcion VARCHAR(32) NOT NULL,         -- Description of the liquid status
    PRIMARY KEY (ID_Estatus)                  -- Set ID_Estatus as the primary key
);

-- Insert data into the EstatusLiquido table

INSERT INTO EstatusLiquido (Descripcion) VALUES
('CUARENTENA'),
('APROBADO 1'),
('APROBADO 2'),
('EN PROCESO');

-- Create the Proveedores table to store supplier information

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.Provedores', 'U') IS NOT NULL
DROP TABLE dbo.Provedores;
GO

-- Create the table
CREATE TABLE dbo.Provedores (
    ID_Proveedor INT NOT NULL IDENTITY(1,1),    -- Unique identifier for each supplier
    Nombre VARCHAR(32) NOT NULL,                -- Name of the supplier
    PRIMARY KEY (ID_Proveedor)                  -- Set ID_Proveedor as the primary key
);

-- Insert data into the Proveedores table

INSERT INTO Provedores (Nombre) VALUES
('Proveedor 1'),
('Proveedor 2'),
('Proveedor 3'),
('Proveedor 4'),
('Proveedor 5');

-- Create the Liquidos table to store liquid information and their relationships

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.Liquidos', 'U') IS NOT NULL
DROP TABLE dbo.Liquidos;
GO

-- Create the table
CREATE TABLE dbo.Liquidos (
    ID_Liquido INT NOT NULL IDENTITY(1,1),    -- Unique identifier for each liquid
    Codigo VARCHAR(32) NOT NULL,              -- Code for the liquid
    Tipo_Liquido VARCHAR(5) CHECK (Tipo_Liquido IN ('Alpha', 'Beta')) NOT NULL, -- Type of the liquid
    ID_Liquido_A INT NOT NULL DEFAULT 1,      -- Reference to another liquid (self-referencing)
    ID_Liquido_B INT NOT NULL DEFAULT 1,      -- Reference to another liquid (self-referencing)
    Cantidad_total DECIMAL(10, 1) NOT NULL,   -- Total amount of the liquid
    Fecha_creacion DATETIME DEFAULT GETDATE(),-- Creation date and time of the record
    Provedor INT NOT NULL,                    -- Reference to the supplier
    Metanol DECIMAL(5, 2),                    -- Methanol content
    Alcoholes_superiores DECIMAL(5, 2),       -- Higher alcohols content
    [%_Alcohol_vol] DECIMAL(5, 2),            -- Alcohol by volume percentage
    Orden_produccion INT NOT NULL,            -- Production order identifier
    PRIMARY KEY (ID_Liquido),                 -- Set ID_Liquido as the primary key
    FOREIGN KEY (ID_Liquido_A) REFERENCES dbo.Liquidos(ID_Liquido), -- Self-referencing foreign key
    FOREIGN KEY (ID_Liquido_B) REFERENCES dbo.Liquidos(ID_Liquido), -- Self-referencing foreign key
    FOREIGN KEY (Provedor) REFERENCES dbo.Provedores(ID_Proveedor) -- Foreign key to Proveedores table
);

-- Insert data into the Liquidos table

-- Insert the 'Ninguno' record to handle base liquids
INSERT INTO Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Fecha_creacion, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion) VALUES
('Ninguno', 'Alpha', 1, 1, 0, GETDATE(), 1, 0, 0, 0, 1); -- 1

-- Insert base liquids
INSERT INTO Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Fecha_creacion, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion) VALUES
('ESPADÍN', 'Alpha', 1, 1, 500, GETDATE(), 1, 0.1, 0.2, 40.0, 2), -- 2
('TOBALÁ', 'Beta', 1, 1, 300, GETDATE(), 2, 0.1, 0.2, 42.0, 3), -- 3
('MEZCAL DM', 'Alpha', 1, 1, 700, GETDATE(), 3, 0.2, 0.3, 45.0, 4), -- 4
('MEZCAL ODT', 'Beta', 1, 1, 600, GETDATE(), 4, 0.1, 0.1, 38.0, 5), -- 5
('CABEZAS', 'Alpha', 1, 1, 100, GETDATE(), 5, 0.3, 0.4, 50.0, 6), -- 6
('CORAZON', 'Beta', 1, 1, 200, GETDATE(), 1, 0.2, 0.2, 48.0, 7), -- 7
('COLAS', 'Alpha', 1, 1, 150, GETDATE(), 2, 0.1, 0.3, 35.0, 8), -- 8
('ORDINARIO', 'Beta', 1, 1, 250, GETDATE(), 3, 0.2, 0.4, 46.0, 9), -- 9
('AGUA', 'Alpha', 1, 1, 800, GETDATE(), 4, 0.0, 0.0, 0.0, 10), -- 10
('MEZCAL A', 'Beta', 1, 1, 400, GETDATE(), 5, 0.1, 0.1, 44.0, 11); -- 11

-- Insert some combinations of the base liquids
INSERT INTO Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Fecha_creacion, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion) VALUES
('COMBINADO 1', 'Alpha', 2, 3, 400, GETDATE(), 1, 0.15, 0.25, 43.0, 12), -- 12
('COMBINADO 2', 'Beta', 4, 5, 500, GETDATE(), 2, 0.2, 0.3, 41.0, 13), -- 13
('COMBINADO 3', 'Alpha', 6, 7, 350, GETDATE(), 3, 0.25, 0.35, 47.0, 14), -- 14
('COMBINADO 4', 'Beta', 8, 9, 450, GETDATE(), 4, 0.1, 0.2, 39.0, 15), -- 15
('COMBINADO 5', 'Alpha', 10, 2, 300, GETDATE(), 5, 0.2, 0.3, 45.0, 16); -- 16

-- Create the Contenedores table to store container information

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.Contenedores', 'U') IS NOT NULL
DROP TABLE dbo.Contenedores;
GO

-- Create the table
CREATE TABLE dbo.Contenedores (
    ID_Contenedor INT NOT NULL IDENTITY(1,1),  -- Unique identifier for each container
    Nombre VARCHAR(32) NOT NULL,               -- Name of the container, maybe drop it in the future?
    Tipo INT NOT NULL,                         -- Reference to the container type
    Ubicacion INT NOT NULL,                    -- Reference to the container location
    Fecha_ingreso DATETIME DEFAULT GETDATE(),  -- Ingress date and time of the container
    Fecha_baja DATETIME NULL,                  -- Date and time when the container was decommissioned (nullable)
    Estatus INT NOT NULL,                      -- Reference to the container status
    PRIMARY KEY (ID_Contenedor),               -- Set ID_Contenedor as the primary key
    FOREIGN KEY (Tipo) REFERENCES dbo.TipoContenedor(ID_Tipo),         -- Foreign key to TipoContenedor table
    FOREIGN KEY (Ubicacion) REFERENCES dbo.UbicacionContenedor(ID_Ubicacion), -- Foreign key to UbicacionContenedor table
    FOREIGN KEY (Estatus) REFERENCES dbo.EstatusContenedor(ID_Estatus) -- Foreign key to EstatusContenedor table
);

-- Insert data into the Contenedores table

-- Insert active containers (Fecha_baja is NULL)
INSERT INTO Contenedores (Nombre, Tipo, Ubicacion, Fecha_ingreso, Fecha_baja, Estatus) VALUES
('Contenedor 1', 1, 1, GETDATE(), NULL, 1), -- ID_Tipo 1, ID_Ubicacion 1, ID_Estatus 1 (EN USO)
('Contenedor 2', 2, 2, GETDATE(), NULL, 2), -- ID_Tipo 2, ID_Ubicacion 2, ID_Estatus 2 (DISPONIBLE)
('Contenedor 3', 3, 3, GETDATE(), NULL, 3), -- ID_Tipo 3, ID_Ubicacion 3, ID_Estatus 3 (NO DISPONIBLE)
('Contenedor 4', 4, 4, GETDATE(), NULL, 4), -- ID_Tipo 4, ID_Ubicacion 4, ID_Estatus 4 (DAÑADO)
('Contenedor 5', 5, 5, GETDATE(), NULL, 2); -- ID_Tipo 5, ID_Ubicacion 5, ID_Estatus 2 (DISPONIBLE)

-- Insert containers that have been decommissioned (Fecha_baja is specified)
INSERT INTO Contenedores (Nombre, Tipo, Ubicacion, Fecha_ingreso, Fecha_baja, Estatus) VALUES
('Contenedor 6', 6, 1, '2022-01-01 12:00:00', '2023-01-01 12:00:00', 3), -- ID_Tipo 6, ID_Ubicacion 1, ID_Estatus 3 (NO DISPONIBLE)
('Contenedor 7', 7, 2, '2022-02-01 12:00:00', '2023-02-01 12:00:00', 4), -- ID_Tipo 7, ID_Ubicacion 2, ID_Estatus 4 (DAÑADO)
('Contenedor 8', 8, 3, '2022-03-01 12:00:00', '2023-03-01 12:00:00', 5), -- ID_Tipo 8, ID_Ubicacion 3, ID_Estatus 5 (CUARENTENA)
('Contenedor 9', 9, 4, '2022-04-01 12:00:00', '2023-04-01 12:00:00', 3), -- ID_Tipo 9, ID_Ubicacion 4, ID_Estatus 3 (NO DISPONIBLE)
('Contenedor 10', 10, 5, '2022-05-01 12:00:00', '2023-05-01 12:00:00', 4); -- ID_Tipo 10, ID_Ubicacion 5, ID_Estatus 4 (DAÑADO)

-- Create the ContenedorLiquido table to store the relationship between containers and liquids

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.ContenedorLiquido', 'U') IS NOT NULL
DROP TABLE dbo.ContenedorLiquido;
GO

-- Create the table
CREATE TABLE dbo.ContenedorLiquido (
    ID_Producto INT NOT NULL IDENTITY(1,1),     -- Unique identifier for each record
    ID_Contenedor INT NOT NULL,                 -- Reference to the container
    ID_Liquido INT NOT NULL,                    -- Reference to the liquid
    Cantidad_dentro DECIMAL(10, 2) NOT NULL,    -- Amount of liquid inside the container
    Persona_encargada VARCHAR(32) NOT NULL,     -- Person in charge of the transfer
    Fecha_transferencia DATETIME DEFAULT GETDATE(), -- Date and time of the transfer
    Estatus_Liquido INT NOT NULL,               -- Status of the liquid
    PRIMARY KEY (ID_Producto),                  -- Set ID_Producto as the primary key
    FOREIGN KEY (ID_Contenedor) REFERENCES dbo.Contenedores(ID_Contenedor), -- Foreign key to Contenedores table
    FOREIGN KEY (ID_Liquido) REFERENCES dbo.Liquidos(ID_Liquido),           -- Foreign key to Liquidos table
    FOREIGN KEY (Estatus_Liquido) REFERENCES dbo.EstatusLiquido(ID_Estatus) -- Foreign key to EstatusLiquido table
);

-- Insert data into the ContenedorLiquido table

INSERT INTO ContenedorLiquido (ID_Contenedor, ID_Liquido, Cantidad_dentro, Persona_encargada, Fecha_transferencia, Estatus_Liquido) VALUES
(1, 2, 100.0, 'Usuario1', '2023-06-15 10:00:00', 1), -- Contenedor 1, ESPADÍN, CUARENTENA
(2, 3, 200.0, 'Usuario2', '2023-06-20 11:00:00', 2), -- Contenedor 2, TOBALÁ, APROBADO 1
(3, 4, 150.0, 'Usuario3', '2023-06-25 12:00:00', 3), -- Contenedor 3, MEZCAL DM, APROBADO 2
(4, 5, 300.0, 'Usuario4', '2023-06-30 13:00:00', 4), -- Contenedor 4, MEZCAL ODT, EN PROCESO
(5, 6, 400.0, 'Usuario5', '2023-07-05 14:00:00', 1), -- Contenedor 5, CABEZAS, CUARENTENA
(1, 7, 250.0, 'Usuario1', '2023-07-10 15:00:00', 2), -- Contenedor 1, CORAZON, APROBADO 1
(2, 8, 100.0, 'Usuario2', '2023-07-15 16:00:00', 3), -- Contenedor 2, COLAS, APROBADO 2
(3, 9, 350.0, 'Usuario3', '2023-07-20 17:00:00', 4), -- Contenedor 3, ORDINARIO, EN PROCESO
(4, 10, 200.0, 'Usuario4', '2023-07-25 18:00:00', 1), -- Contenedor 4, AGUA, CUARENTENA
(5, 11, 500.0, 'Usuario5', '2023-07-30 19:00:00', 2), -- Contenedor 5, MEZCAL A, APROBADO 1
(1, 12, 150.0, 'Usuario1', '2023-08-01 08:00:00', 3), -- Contenedor 1, COMBINADO 1, APROBADO 2
(2, 13, 250.0, 'Usuario2', '2023-08-05 09:00:00', 4), -- Contenedor 2, COMBINADO 2, EN PROCESO
(3, 14, 300.0, 'Usuario3', GETDATE(), 1), -- Contenedor 3, COMBINADO 3, CUARENTENA
(4, 15, 400.0, 'Usuario4', GETDATE(), 2), -- Contenedor 4, COMBINADO 4, APROBADO 1
(5, 16, 200.0, 'Usuario5', GETDATE(), 3); -- Contenedor 5, COMBINADO 5, APROBADO 2

-- Create the ProductoTerminado table to store information about finished products

-- Drop the table if it already exists to avoid errors
IF OBJECT_ID('dbo.ProductoTerminado', 'U') IS NOT NULL
DROP TABLE dbo.ProductoTerminado;
GO

-- Create the table
CREATE TABLE dbo.ProductoTerminado (
    ID_ProductoTerminado INT NOT NULL IDENTITY(1,1), -- Unique identifier for each finished product
    ID_Producto INT NOT NULL,                       -- Reference to the product in ContenedorLiquido
    Fecha_termino DATE NOT NULL,                    -- Date when the product was finished
    Numero_botellas INT NOT NULL,                   -- Number of bottles produced
    PRIMARY KEY (ID_ProductoTerminado),             -- Set ID_ProductoTerminado as the primary key
    FOREIGN KEY (ID_Producto) REFERENCES dbo.ContenedorLiquido(ID_Producto) -- Foreign key to ContenedorLiquido table
);

-- Insert data into the ProductoTerminado table

INSERT INTO ProductoTerminado (ID_Producto, Fecha_termino, Numero_botellas) VALUES
(1, '2023-07-01', 100), -- Referencia a ID_Producto 1 en ContenedorLiquido
(2, '2023-07-02', 200), -- Referencia a ID_Producto 2 en ContenedorLiquido
(3, '2023-07-03', 150), -- Referencia a ID_Producto 3 en ContenedorLiquido
(4, '2023-07-04', 300), -- Referencia a ID_Producto 4 en ContenedorLiquido
(5, '2023-07-05', 400), -- Referencia a ID_Producto 5 en ContenedorLiquido
(6, '2023-07-06', 250), -- Referencia a ID_Producto 6 en ContenedorLiquido
(7, '2023-07-07', 100), -- Referencia a ID_Producto 7 en ContenedorLiquido
(8, '2023-07-08', 350), -- Referencia a ID_Producto 8 en ContenedorLiquido
(9, '2023-07-09', 200), -- Referencia a ID_Producto 9 en ContenedorLiquido
(10, '2023-07-10', 500); -- Referencia a ID_Producto 10 en ContenedorLiquido


------------------------------------------- PROCEDURES ----------------------------------------------------------

-- This stored procedure retrieves the history of liquids for a specific container. 
-- It returns details about the container, liquid, quantity inside, responsible person,
-- transfer date, and the status of the liquid.

-- Drop the stored procedure if it already exists
IF OBJECT_ID('GetHistorialLiquidosContenedor', 'P') IS NOT NULL
DROP PROCEDURE GetHistorialLiquidosContenedor;
GO

GO
CREATE PROCEDURE GetHistorialLiquidosContenedor
    @ID_Contenedor INT
AS
BEGIN
    SELECT 
        cl.ID_Contenedor,
        c.Nombre AS Nombre_Contenedor,
        cl.ID_Liquido,
        l.Codigo AS Codigo_Liquido,
        cl.Cantidad_dentro,
        cl.Persona_encargada,
        cl.Fecha_transferencia,
        el.Descripcion AS Estatus_Liquido
    FROM 
        ContenedorLiquido cl
    JOIN 
        Contenedores c ON cl.ID_Contenedor = c.ID_Contenedor
    JOIN 
        Liquidos l ON cl.ID_Liquido = l.ID_Liquido
    JOIN 
        EstatusLiquido el ON cl.Estatus_Liquido = el.ID_Estatus
    WHERE 
        cl.ID_Contenedor = @ID_Contenedor;
END;
GO

-- Call the stored procedure GetHistorialLiquidosContenedor with a specific container ID
EXEC GetHistorialLiquidosContenedor @ID_Contenedor = 1;

-- Drop the stored procedure if it already exists
IF OBJECT_ID('GetCapacidadDisponibleContenedor', 'P') IS NOT NULL
DROP PROCEDURE GetCapacidadDisponibleContenedor;
GO

-- Create the stored procedure to get the capacity and name of a specific container based on its ID
CREATE PROCEDURE GetCapacidadDisponibleContenedor
    @ID_Contenedor INT
AS
BEGIN
    SELECT 
        tc.Nombre AS Nombre_Contenedor,
        tc.Capacidad
    FROM 
        dbo.Contenedores c
    JOIN 
        dbo.TipoContenedor tc ON c.Tipo = tc.ID_Tipo
    WHERE 
        c.ID_Contenedor = @ID_Contenedor;
END;
GO

-- Call the stored procedure
EXEC GetCapacidadDisponibleContenedor @ID_Contenedor = 2;

-- Drop the stored procedure if it already exists
IF OBJECT_ID('InsertarNuevoContenedorLiquido', 'P') IS NOT NULL
DROP PROCEDURE InsertarNuevoContenedorLiquido;
GO

-- Create the stored procedure to insert a new record into the ContenedorLiquido table
CREATE PROCEDURE InsertarNuevoContenedorLiquido
    @ID_Contenedor INT,
    @ID_Liquido INT,
    @Cantidad_dentro DECIMAL(10, 2),
    @Persona_encargada VARCHAR(255),
    @Fecha_transferencia DATETIME,
    @Estatus_Liquido INT
AS
BEGIN
    INSERT INTO dbo.ContenedorLiquido (ID_Contenedor, ID_Liquido, Cantidad_dentro, Persona_encargada, Fecha_transferencia, Estatus_Liquido)
    VALUES (@ID_Contenedor, @ID_Liquido, @Cantidad_dentro, @Persona_encargada, @Fecha_transferencia, @Estatus_Liquido);
END;
GO

-- Call the stored procedure to insert a new record
EXEC InsertarNuevoContenedorLiquido 
    @ID_Contenedor = 1,
    @ID_Liquido = 2,
    @Cantidad_dentro = 100.00,
    @Persona_encargada = 'Usuario1',
    @Fecha_transferencia = '2023-06-15 10:00:00.000',
    @Estatus_Liquido = 1;
GO

-- Drop the stored procedure if it already exists
IF OBJECT_ID('InsertarNuevoLiquido', 'P') IS NOT NULL
DROP PROCEDURE InsertarNuevoLiquido;
GO

-- Create the stored procedure to insert a new record into the Liquidos table
CREATE PROCEDURE InsertarNuevoLiquido
    @Codigo VARCHAR(255),
    @Tipo_Liquido VARCHAR(255),
    @ID_Liquido_A INT,
    @ID_Liquido_B INT,
    @Cantidad_total DECIMAL(10, 2),
    @Fecha_creacion DATETIME,
    @Provedor INT,
    @Metanol DECIMAL(10, 2),
    @Alcoholes_superiores DECIMAL(10, 2),
    @Porcentaje_Alcohol_vol DECIMAL(10, 2),
    @Orden_produccion INT
AS
BEGIN
    INSERT INTO dbo.Liquidos 
    (
        Codigo,
        Tipo_Liquido,
        ID_Liquido_A,
        ID_Liquido_B,
        Cantidad_total,
        Fecha_creacion,
        Provedor,
        Metanol,
        Alcoholes_superiores,
        [%_Alcohol_vol],
        Orden_produccion
    )
    VALUES 
    (
        @Codigo,
        @Tipo_Liquido,
        @ID_Liquido_A,
        @ID_Liquido_B,
        @Cantidad_total,
        @Fecha_creacion,
        @Provedor,
        @Metanol,
        @Alcoholes_superiores,
        @Porcentaje_Alcohol_vol,
        @Orden_produccion
    );
END;
GO

-- Call the stored procedure to insert a new record
EXEC InsertarNuevoLiquido 
    @Codigo = 'NuevoCodigo',
    @Tipo_Liquido = 'Alpha',
    @ID_Liquido_A = 1,
    @ID_Liquido_B = 1,
    @Cantidad_total = 100.00,
    @Fecha_creacion = '2024-07-30 13:16:58.970',
    @Provedor = 1,
    @Metanol = 0.10,
    @Alcoholes_superiores = 1.20,
    @Porcentaje_Alcohol_vol = 40.00,
    @Orden_produccion = 17;
GO

---------------------------------- TEST CASES --------------------------------------------
-- This code will be removed in the future, so be carefully.
SELECT * FROM Liquidos;

SELECT * FROM EstatusContenedor;

SELECT * FROM Contenedores;

SELECT * FROM ContenedorLiquido;

SELECT * FROM EstatusLiquido;

SELECT * FROM ProductoTerminado;

-- Insert containers that have been decommissioned (Fecha_baja is specified)
INSERT INTO Contenedores (Nombre, Tipo, Ubicacion, Fecha_ingreso, Fecha_baja, Estatus) VALUES
('Contenedor 11', 6, 1, GETDATE(), NULL, 2) -- ID_Tipo 6, ID_Ubicacion 1, ID_Estatus 3 (NO DISPONIBLE)

-- Combinación de COMBINADO 5 (ID 16) y COMBINADO 1 (ID 12)
INSERT INTO dbo.Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion)
VALUES ('COMBINADO 16-12', 'Alpha', 16, 12, 700.0, 5, 0.175, 0.275, 44.00, 29);

-- Combinación de COMBINADO 6 (ID 18) y MEZCAL DM (ID 4)
INSERT INTO dbo.Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion)
VALUES ('COMBINADO 18-4', 'Alpha', 18, 4, 1500.0, 1, 0.175, 0.30, 43.00, 30);

-- Combinación de COMBINADO 18-4 (ID 18) y COMBINADO 16-12 (ID 19)
INSERT INTO dbo.Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion)
VALUES ('COMBINADO 18-19', 'Alpha', 18, 19, 2200.0, 1, 0.175, 0.275, 43.50, 31);

-- Combinación de COMBINADO 18-19 (ID 20) y MEZCAL ODT (ID 5)
INSERT INTO dbo.Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion)
VALUES ('COMBINADO 20-5', 'Alpha', 20, 5, 2800.0, 1, 0.1375, 0.1875, 40.75, 32);

-- Combinación de COMBINADO 20-5 (ID 21) y COMBINADO 16-12 (ID 19)
INSERT INTO dbo.Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion)
VALUES ('COMBINADO 21-19', 'Alpha', 21, 19, 3500.0, 1, 0.15625, 0.23125, 42.375, 33);

-- Combinación de COMBINADO 15-14 
INSERT INTO dbo.Liquidos (Codigo, Tipo_Liquido, ID_Liquido_A, ID_Liquido_B, Cantidad_total, Provedor, Metanol, Alcoholes_superiores, [%_Alcohol_vol], Orden_produccion)
VALUES ('COMBINADO 21-19', 'Beta', 15, 14, 3500.0, 1, 0.15625, 0.23125, 42.375, 34);

DELETE FROM Liquidos;
DELETE FROM ProductoTerminado;
DELETE FROM ContenedorLiquido;
DELETE FROM Contenedores;

USE master;
DROP DATABASE casalumbre_db;
GO

USE master;
GO

ALTER DATABASE casalumbre_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE casalumbre_db;
GO

-- Eliminar el procedimiento almacenado si ya existe
IF OBJECT_ID('ObtenerLiquidosBase', 'P') IS NOT NULL
DROP PROCEDURE ObtenerLiquidosBase;
GO

CREATE PROCEDURE ObtenerLiquidosBase
    @ID_Liquido INT
AS
BEGIN
    WITH CTE_Liquidos AS (
        -- Selecciona el líquido inicial
        SELECT 
            ID_Liquido,
            Codigo,
            ID_Liquido_A,
            ID_Liquido_B,
            CAST(ID_Liquido AS VARCHAR(MAX)) AS Rastro,
            0 AS Nivel -- Nivel inicial
        FROM Liquidos
        WHERE ID_Liquido = @ID_Liquido

        UNION ALL

        -- Une recursivamente con la tabla de líquidos
        SELECT 
            l.ID_Liquido,
            l.Codigo,
            l.ID_Liquido_A,
            l.ID_Liquido_B,
            CAST(cte.Rastro + '->' + CAST(l.ID_Liquido AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS Rastro,
            cte.Nivel + 1 -- Incrementar el nivel
        FROM Liquidos l
        INNER JOIN CTE_Liquidos cte ON l.ID_Liquido IN (cte.ID_Liquido_A, cte.ID_Liquido_B)
        WHERE CHARINDEX('->' + CAST(l.ID_Liquido AS VARCHAR(MAX)) + '->', '->' + cte.Rastro + '->') = 0 -- Evitar ciclos y duplicados
    )
    SELECT *
    FROM CTE_Liquidos
    WHERE ID_Liquido != 1 -- Excluir ID_Liquido = 1 si este no debe ser mostrado
    ORDER BY Nivel, Rastro -- Ordenar por nivel y rastro
    OPTION (MAXRECURSION 1000); -- Aumentar las recursiones a 1000
END
GO

-- CREATE PROCEDURE ObtenerLiquidosBase
--     @ID_Liquido INT
-- AS
-- BEGIN
--     WITH CTE_Liquidos AS (
--         -- Selecciona el líquido inicial
--         SELECT 
--             ID_Liquido,
--             Codigo,
--             ID_Liquido_A,
--             ID_Liquido_B,
--             CAST(ID_Liquido AS VARCHAR(MAX)) AS Rastro,
--             0 AS Nivel -- Nivel inicial
--         FROM Liquidos
--         WHERE ID_Liquido = @ID_Liquido

--         UNION ALL

--         -- Une recursivamente con la tabla de líquidos
--         SELECT 
--             l.ID_Liquido,
--             l.Codigo,
--             l.ID_Liquido_A,
--             l.ID_Liquido_B,
--             CAST(cte.Rastro + '->' + CAST(l.ID_Liquido AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS Rastro,
--             cte.Nivel + 1 -- Incrementar el nivel
--         FROM Liquidos l
--         INNER JOIN CTE_Liquidos cte ON l.ID_Liquido IN (cte.ID_Liquido_A, cte.ID_Liquido_B)
--         WHERE CHARINDEX(CAST(l.ID_Liquido AS VARCHAR(MAX)), cte.Rastro) = 0 -- Evitar ciclos
--     )
--     SELECT *
--     FROM CTE_Liquidos
--     ORDER BY Nivel, Rastro -- Ordenar por nivel y rastro
--     OPTION (MAXRECURSION 1000); -- Aumentar las recursiones a 1000
-- END
-- GO

EXEC ObtenerLiquidosBase @ID_Liquido = 23;

-- CREATE PROCEDURE ObtenerLiquidosBase
--     @ID_Liquido INT
-- AS
-- BEGIN
--     WITH CTE_Liquidos AS (
--         -- Selecciona el líquido inicial
--         SELECT 
--             ID_Liquido,
--             Codigo,
--             Tipo_Liquido,
--             ID_Liquido_A,
--             ID_Liquido_B,
--             Cantidad_total,
--             Fecha_creacion,
--             Provedor,
--             Metanol,
--             Alcoholes_superiores,
--             [%_Alcohol_vol],
--             Orden_produccion,
--             CAST(ID_Liquido AS VARCHAR(MAX)) AS Rastro,
--             0 AS Nivel -- Nivel inicial
--         FROM Liquidos
--         WHERE ID_Liquido = @ID_Liquido

--         UNION ALL

--         -- Une recursivamente con la tabla de líquidos
--         SELECT 
--             l.ID_Liquido,
--             l.Codigo,
--             l.Tipo_Liquido,
--             l.ID_Liquido_A,
--             l.ID_Liquido_B,
--             l.Cantidad_total,
--             l.Fecha_creacion,
--             l.Provedor,
--             l.Metanol,
--             l.Alcoholes_superiores,
--             l.[%_Alcohol_vol],
--             l.Orden_produccion,
--             CAST(cte.Rastro + '->' + CAST(l.ID_Liquido AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS Rastro,
--             cte.Nivel + 1 -- Incrementar el nivel
--         FROM Liquidos l
--         INNER JOIN CTE_Liquidos cte ON l.ID_Liquido IN (cte.ID_Liquido_A, cte.ID_Liquido_B)
--         WHERE CHARINDEX(CAST(l.ID_Liquido AS VARCHAR(MAX)), cte.Rastro) = 0 -- Evitar ciclos
--     )
--     SELECT *
--     FROM CTE_Liquidos
--     ORDER BY Nivel, Rastro -- Ordenar por nivel y rastro
--     OPTION (MAXRECURSION 1000); -- Aumentar las recursiones a 1000
-- END
-- GO

-- CREATE PROCEDURE ObtenerLiquidosBase
--     @ID_Liquido INT
-- AS
-- BEGIN
--     WITH CTE_Liquidos AS (
--         -- Selecciona el líquido inicial
--         SELECT 
--             ID_Liquido,
--             Codigo,
--             Tipo_Liquido,
--             ID_Liquido_A,
--             ID_Liquido_B,
--             Cantidad_total,
--             Fecha_creacion,
--             Provedor,
--             Metanol,
--             Alcoholes_superiores,
--             [%_Alcohol_vol],
--             Orden_produccion,
--             CAST(ID_Liquido AS VARCHAR(MAX)) AS Rastro -- Añadir columna para el rastro
--         FROM Liquidos
--         WHERE ID_Liquido = @ID_Liquido

--         UNION ALL

--         -- Une recursivamente con la tabla de líquidos
--         SELECT 
--             l.ID_Liquido,
--             l.Codigo,
--             l.Tipo_Liquido,
--             l.ID_Liquido_A,
--             l.ID_Liquido_B,
--             l.Cantidad_total,
--             l.Fecha_creacion,
--             l.Provedor,
--             l.Metanol,
--             l.Alcoholes_superiores,
--             l.[%_Alcohol_vol],
--             l.Orden_produccion,
--             CAST(cte.Rastro + '->' + CAST(l.ID_Liquido AS VARCHAR(MAX)) AS VARCHAR(MAX)) AS Rastro -- Actualizar el rastro
--         FROM Liquidos l
--         INNER JOIN CTE_Liquidos cte ON l.ID_Liquido IN (cte.ID_Liquido_A, cte.ID_Liquido_B)
--         WHERE CHARINDEX(CAST(l.ID_Liquido AS VARCHAR(MAX)), cte.Rastro) = 0 -- Evitar ciclos
--     )
--     SELECT *
--     FROM CTE_Liquidos
--     OPTION (MAXRECURSION 1000); -- Aumentar las recursiones a 1000
-- END
-- GO
-- -- Crear el procedimiento almacenado ajustado
-- CREATE PROCEDURE ObtenerLiquidosBase
--     @ID_Liquido INT
-- AS
-- BEGIN
--     WITH CTE_Liquidos AS (
--         -- Selecciona el líquido inicial
--         SELECT 
--             ID_Liquido,
--             Codigo,
--             Tipo_Liquido,
--             ID_Liquido_A,
--             ID_Liquido_B,
--             Cantidad_total,
--             Fecha_creacion,
--             Provedor,
--             Metanol,
--             Alcoholes_superiores,
--             [%_Alcohol_vol],
--             Orden_produccion
--         FROM Liquidos
--         WHERE ID_Liquido = @ID_Liquido

--         UNION ALL

--         -- Une recursivamente con la tabla de líquidos
--         SELECT 
--             l.ID_Liquido,
--             l.Codigo,
--             l.Tipo_Liquido,
--             l.ID_Liquido_A,
--             l.ID_Liquido_B,
--             l.Cantidad_total,
--             l.Fecha_creacion,
--             l.Provedor,
--             l.Metanol,
--             l.Alcoholes_superiores,
--             l.[%_Alcohol_vol],
--             l.Orden_produccion
--         FROM Liquidos l
--         INNER JOIN CTE_Liquidos cte ON l.ID_Liquido IN (cte.ID_Liquido_A, cte.ID_Liquido_B)
--     )
--     SELECT *
--     FROM CTE_Liquidos
--     OPTION (MAXRECURSION 1000); -- Limitar las recursiones a 100
-- END
-- GO

-- -- Eliminar el procedimiento almacenado si ya existe
-- IF OBJECT_ID('ObtenerLiquidosBase', 'P') IS NOT NULL
-- DROP PROCEDURE ObtenerLiquidosBase;
-- GO

-- -- Crear el procedimiento almacenado ajustado
-- CREATE PROCEDURE ObtenerLiquidosBase
--     @ID_Liquido INT
-- AS
-- BEGIN
--     WITH CTE_Liquidos AS (
--         -- Selecciona el líquido inicial
--         SELECT 
--             ID_Liquido,
--             Codigo,
--             Tipo_Liquido,
--             ID_Liquido_A,
--             ID_Liquido_B,
--             Cantidad_total,
--             Fecha_creacion,
--             Provedor,
--             Metanol,
--             Alcoholes_superiores,
--             [%_Alcohol_vol],
--             Orden_produccion
--         FROM Liquidos
--         WHERE ID_Liquido = @ID_Liquido

--         UNION ALL

--         -- Une recursivamente con la tabla de líquidos
--         SELECT 
--             l.ID_Liquido,
--             l.Codigo,
--             l.Tipo_Liquido,
--             l.ID_Liquido_A,
--             l.ID_Liquido_B,
--             l.Cantidad_total,
--             l.Fecha_creacion,
--             l.Provedor,
--             l.Metanol,
--             l.Alcoholes_superiores,
--             l.[%_Alcohol_vol],
--             l.Orden_produccion
--         FROM Liquidos l
--         INNER JOIN CTE_Liquidos cte ON l.ID_Liquido IN (cte.ID_Liquido_A, cte.ID_Liquido_B)
--         WHERE l.ID_Liquido_A <> l.ID_Liquido_B -- Evitar bucles infinitos
--     )
--     SELECT *
--     FROM CTE_Liquidos
--     OPTION (MAXRECURSION 100); -- Limitar las recursiones a 100
-- END
-- GO

-- -- Query para dropear el procedimiento almacenado si existe
-- IF OBJECT_ID('dbo.ObtenerCombinacionesPorNiveles', 'P') IS NOT NULL
--     DROP PROCEDURE dbo.ObtenerCombinacionesPorNiveles;
-- GO

-- -- Procedimiento almacenado para obtener los líquidos con los que fue construido un líquido combinado por niveles
-- CREATE PROCEDURE dbo.ObtenerCombinacionesPorNiveles
--     @ID_Liquido INT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     -- CTE recursivo para obtener los niveles de combinaciones de líquidos
--     WITH CTE_Liquidos AS (
--         -- Nivel 0: Inicia con el líquido dado
--         SELECT 
--             ID_Liquido, 
--             Codigo, 
--             Tipo_Liquido, 
--             ID_Liquido_A, 
--             ID_Liquido_B, 
--             Cantidad_total, 
--             Fecha_creacion, 
--             Provedor, 
--             Metanol, 
--             Alcoholes_superiores, 
--             [%_Alcohol_vol], 
--             Orden_produccion,
--             0 AS Nivel,
--             ID_Liquido AS Raiz_ID
--         FROM dbo.Liquidos
--         WHERE ID_Liquido = @ID_Liquido

--         UNION ALL

--         -- Recursivamente agrega los líquidos base
--         SELECT 
--             l1.ID_Liquido, 
--             l1.Codigo, 
--             l1.Tipo_Liquido, 
--             l1.ID_Liquido_A, 
--             l1.ID_Liquido_B, 
--             l1.Cantidad_total, 
--             l1.Fecha_creacion, 
--             l1.Provedor, 
--             l1.Metanol, 
--             l1.Alcoholes_superiores, 
--             l1.[%_Alcohol_vol], 
--             l1.Orden_produccion,
--             cte.Nivel + 1 AS Nivel,
--             cte.Raiz_ID
--         FROM dbo.Liquidos l1
--         INNER JOIN CTE_Liquidos cte
--             ON l1.ID_Liquido = cte.ID_Liquido_A
--         WHERE l1.ID_Liquido_A != 1 OR l1.ID_Liquido_B != 1

--         UNION ALL

--         SELECT 
--             l2.ID_Liquido, 
--             l2.Codigo, 
--             l2.Tipo_Liquido, 
--             l2.ID_Liquido_A, 
--             l2.ID_Liquido_B, 
--             l2.Cantidad_total, 
--             l2.Fecha_creacion, 
--             l2.Provedor, 
--             l2.Metanol, 
--             l2.Alcoholes_superiores, 
--             l2.[%_Alcohol_vol], 
--             l2.Orden_produccion,
--             cte.Nivel + 1 AS Nivel,
--             cte.Raiz_ID
--         FROM dbo.Liquidos l2
--         INNER JOIN CTE_Liquidos cte
--             ON l2.ID_Liquido = cte.ID_Liquido_B
--         WHERE l2.ID_Liquido_A != 1 OR l2.ID_Liquido_B != 1
--     )
--     -- Selecciona y ordena los resultados del CTE
--     SELECT 
--         Raiz_ID,
--         Nivel,
--         ID_Liquido,
--         Codigo,
--         Tipo_Liquido,
--         ID_Liquido_A,
--         ID_Liquido_B,
--         Cantidad_total,
--         Fecha_creacion,
--         Provedor,
--         Metanol,
--         Alcoholes_superiores,
--         [%_Alcohol_vol],
--         Orden_produccion
--     FROM CTE_Liquidos
--     ORDER BY Raiz_ID, Nivel, ID_Liquido;
-- END;
-- GO

-- Ejemplo de ejecución del procedimiento almacenado
-- EXEC dbo.ObtenerCombinacionesPorNiveles @ID_Liquido = 22;

-- -- Query para dropear el procedimiento almacenado si existe
-- IF OBJECT_ID('ObtenerCombinacionesPorNiveles', 'P') IS NOT NULL
--     DROP PROCEDURE ObtenerCombinacionesPorNiveles;
-- GO

-- -- Procedimiento almacenado para obtener los líquidos con los que fue construido un líquido combinado por niveles
-- CREATE PROCEDURE ObtenerCombinacionesPorNiveles
--     @ID_Liquido INT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     -- CTE recursivo para obtener los niveles de combinaciones de líquidos
--     WITH CTE_Liquidos AS (
--         -- Nivel 0: Inicia con el líquido dado
--         SELECT 
--             ID_Liquido, 
--             Codigo, 
--             Tipo_Liquido, 
--             ID_Liquido_A, 
--             ID_Liquido_B, 
--             Cantidad_total, 
--             Fecha_creacion, 
--             Provedor, 
--             Metanol, 
--             Alcoholes_superiores, 
--             [%_Alcohol_vol], 
--             Orden_produccion,
--             0 AS Nivel
--         FROM dbo.Liquidos
--         WHERE ID_Liquido = @ID_Liquido

--         UNION ALL

--         -- Recursivamente agrega los líquidos base
--         SELECT 
--             l.ID_Liquido, 
--             l.Codigo, 
--             l.Tipo_Liquido, 
--             l.ID_Liquido_A, 
--             l.ID_Liquido_B, 
--             l.Cantidad_total, 
--             l.Fecha_creacion, 
--             l.Provedor, 
--             l.Metanol, 
--             l.Alcoholes_superiores, 
--             l.[%_Alcohol_vol], 
--             l.Orden_produccion,
--             cte.Nivel + 1 AS Nivel
--         FROM dbo.Liquidos l
--         INNER JOIN CTE_Liquidos cte
--             ON l.ID_Liquido IN (cte.ID_Liquido_A, cte.ID_Liquido_B)
--         WHERE l.ID_Liquido_A != 1 OR l.ID_Liquido_B != 1
--     )
--     -- Selecciona y ordena los resultados del CTE
--     SELECT * 
--     FROM CTE_Liquidos
--     ORDER BY Nivel, ID_Liquido;
-- END;
-- GO

-- Ejemplo de ejecución del procedimiento almacenado
-- EXEC ObtenerCombinacionesPorNiveles @ID_Liquido = 22;

-- Para obtener la lista de sesiones activas
SELECT session_id, status, start_time, command, database_id, user_id, blocking_session_id, wait_type
FROM sys.dm_exec_requests;