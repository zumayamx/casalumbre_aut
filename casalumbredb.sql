
-- Create the datbase name: casalumbre_db;
CREATE DATABASE casalumbre_db;

-- Use this database;
USE casalumbre_db;

-- Drop the table if it exists
IF OBJECT_ID('dbo.tipos_contenedor', 'U') IS NOT NULL
DROP TABLE dbo.tipos_contenedor;
GO

-- Create the table with the updated column name
CREATE TABLE tipos_contenedor (
    id_tipo_contenedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the type of container
    nombre VARCHAR(32) NOT NULL, -- Name of the container type
    capacidad_lts DECIMAL(10, 2) NOT NULL -- Capacity of the container in liters
);

-- Insert multiple container types into the tipos_contenedor table
INSERT INTO tipos_contenedor (nombre, capacidad_lts) VALUES 
('TANQUE 1', 50000.00),
('TANQUE 2', 50000.00),
('TANQUE 3', 50000.00),
('TANQUE 4', 50000.00),
('TANQUE 5', 30000.00),
('TANQUE 6', 30000.00),
('TANQUE 7', 30000.00),
('TANQUE 8', 30000.00),
('TANQUE 9', 30000.00),
('TANQUE A', 30000.00),
('TANQUE B', 30000.00),
('TANQUE C', 30000.00),
('TANQUE D', 30000.00),
('TANQUE E', 30000.00),
('TOTE XX', 1000.00),
('PORRÓN XX', 20.00),
('TAMBO XX', 200.00);

-- Drop the table if it exists
IF OBJECT_ID('dbo.ubicaciones_contenedor', 'U') IS NOT NULL
DROP TABLE dbo.ubicaciones_contenedor;
GO

-- Create the table with the correct structure
CREATE TABLE ubicaciones_contenedor (
    id_ubicacion_contenedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the container location
    descripcion VARCHAR(32) NOT NULL -- Description of the container location
);

-- Insert multiple container locations into the ubicaciones_contenedor table
INSERT INTO ubicaciones_contenedor (descripcion) VALUES 
('DM4'),
('ODT-ENV'),
('BETA'),
('ODT1'),
('LAB');

-- Drop the table if it exists
IF OBJECT_ID('dbo.estatus_contenedor', 'U') IS NOT NULL
DROP TABLE dbo.estatus_contenedor;
GO

-- Create the table with the correct structure
CREATE TABLE estatus_contenedor (
    id_estatus_contenedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the container status
    descripcion VARCHAR(32) NOT NULL -- Description of the container status
);

-- Insert multiple status descriptions into the estatus_contenedor table
INSERT INTO estatus_contenedor (descripcion) VALUES 
('EN USO'),
('DISPONIBLE'),
('NO DISPONIBLE'),
('DAÑADO'),
('CUARENTENA');

-- Drop the table if it exists
IF OBJECT_ID('dbo.contenedores', 'U') IS NOT NULL
DROP TABLE dbo.contenedores;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE contenedores (
    id_contenedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the container
    nombre VARCHAR(32) NOT NULL, -- Name of the container
    id_tipo INT NOT NULL, -- Foreign key referencing tipos_contenedor
    id_ubicacion INT NOT NULL, -- Foreign key referencing ubicaciones_contenedor
    fecha_alta DATE DEFAULT GETDATE(), -- Registration date of the container
    fecha_baja DATE, -- Deregistration date of the container
    id_estatus INT NOT NULL, -- Foreign key referencing estatus_contenedor
    FOREIGN KEY (id_tipo) REFERENCES tipos_contenedor(id_tipo_contenedor),
    FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones_contenedor(id_ubicacion_contenedor),
    FOREIGN KEY (id_estatus) REFERENCES estatus_contenedor(id_estatus_contenedor)
);

-- Insert 15 container records into the contenedores table

-- 5 containers that have been decommissioned (fecha_baja not null)
INSERT INTO contenedores (nombre, id_tipo, id_ubicacion, fecha_alta, fecha_baja, id_estatus) VALUES
('TANQUE A', 1, 1, '2021-01-01', '2022-01-01', 4), -- 4 - DAÑADO
('TANQUE B', 2, 2, '2021-02-01', '2022-02-01', 4), -- 4 - DAÑADO
('TANQUE C', 3, 3, '2021-03-01', '2022-03-01', 4), -- 4 - DAÑADO
('TANQUE D', 4, 4, '2021-04-01', '2022-04-01', 4), -- 4 - DAÑADO
('TANQUE E', 5, 5, '2021-05-01', '2022-05-01', 4); -- 4 - DAÑADO

-- 10 active containers (fecha_baja is null)
INSERT INTO contenedores (nombre, id_tipo, id_ubicacion, fecha_alta, id_estatus) VALUES
('TANQUE F', 1, 1, '2022-06-01', 1), -- 1 - EN USO
('TANQUE G', 2, 2, '2022-07-01', 1), -- 1 - EN USO
('TANQUE H', 3, 3, '2022-08-01', 1), -- 1 - EN USO
('TANQUE I', 4, 4, '2022-09-01', 1), -- 1 - EN USO
('TANQUE J', 5, 5, '2022-10-01', 1), -- 1 - EN USO
('TANQUE K', 1, 1, '2022-11-01', 1), -- 1 - EN USO
('TANQUE L', 2, 2, '2022-12-01', 1), -- 1 - EN USO
('TANQUE M', 3, 3, '2023-01-01', 1), -- 1 - EN USO
('TANQUE N', 4, 4, '2023-02-01', 1), -- 1 - EN USO
('TANQUE O', 5, 5, '2023-03-01', 1); -- 1 - EN USO

-- Drop the table if it exists
IF OBJECT_ID('dbo.estatus_liquido', 'U') IS NOT NULL
DROP TABLE dbo.estatus_liquido;
GO

-- Create the table with the correct structure
CREATE TABLE estatus_liquido (
    id_estatus_liquido INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the liquid status
    descripcion VARCHAR(32) NOT NULL -- Description of the liquid status
);

-- Insert multiple status descriptions into the estatus_liquido table
INSERT INTO estatus_liquido (descripcion) VALUES 
('CUARENTENA'),
('APROBADO 1'),
('APROBADO 2'),
('EN PROCESO');

-- Drop the table if it exists
IF OBJECT_ID('dbo.proveedores', 'U') IS NOT NULL
DROP TABLE dbo.proveedores;
GO

-- Create the table with the correct structure
CREATE TABLE proveedores (
    id_proveedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the supplier
    nombre VARCHAR(32) NOT NULL -- Name of the supplier
);

-- Insert multiple supplier names into the proveedores table
INSERT INTO proveedores (nombre) VALUES 
('Proveedor A'),
('Proveedor B'),
('Proveedor C'),
('Proveedor D'),
('Proveedor E');

-- Drop the table if it exists
IF OBJECT_ID('dbo.tipo_liquido', 'U') IS NOT NULL
DROP TABLE dbo.tipo_liquido;
GO

-- Create the table with the correct structure
CREATE TABLE tipo_liquido (
    id_tipo_liquido INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the liquid type
    descripcion VARCHAR(32) NOT NULL -- Description of the liquid type
);

-- Insert the initial liquid types into the tipo_liquido table
INSERT INTO tipo_liquido (descripcion) VALUES 
('alpha'),
('beta');

-- Drop the table if it exists
IF OBJECT_ID('dbo.liquidos', 'U') IS NOT NULL
DROP TABLE dbo.liquidos;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE liquidos (
    id_liquido INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the liquid
    codigo VARCHAR(32) NOT NULL, -- Code of the liquid
    id_tipo INT NOT NULL, -- Foreign key referencing tipo_liquido
    cantidad_total_lts DECIMAL(10, 2) NOT NULL, -- Total amount of liquid in liters
    fecha_produccion DATE DEFAULT GETDATE(), -- Production date of the liquid
    id_proveedor INT NOT NULL, -- Foreign key referencing proveedores
    metanol DECIMAL(5, 2), -- Amount of methanol
    alcoholes_sup DECIMAL(5, 2), -- Amount of superior alcohols
    porcentaje_alchol_vol DECIMAL(5, 2), -- Percentage of alcohol by volume
    orden_produccion INT NOT NULL, -- Production order
    id_estatus INT NOT NULL, -- Foreign key referencing estatus_liquido
    FOREIGN KEY (id_tipo) REFERENCES tipo_liquido(id_tipo_liquido),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor),
    FOREIGN KEY (id_estatus) REFERENCES estatus_liquido(id_estatus_liquido)
);

-- Insert multiple liquid records into the liquidos table

-- Ensure the estatus is not CUARENTENA
INSERT INTO liquidos (codigo, id_tipo, cantidad_total_lts, fecha_produccion, id_proveedor, metanol, alcoholes_sup, porcentaje_alchol_vol, orden_produccion, id_estatus) VALUES
('ESPADÍN', 1, 500.00, GETDATE(), 1, 1.50, 0.20, 40.00, 1001, 2), -- 2 - APROBADO 1
('TOBALÁ', 1, 300.00, GETDATE(), 2, 1.20, 0.30, 38.00, 1002, 2), -- 2 - APROBADO 1
('MEZCAL DM', 1, 1000.00, GETDATE(), 3, 2.00, 0.10, 42.00, 1003, 2), -- 2 - APROBADO 1
('MEZCAL ODT', 1, 800.00, GETDATE(), 4, 1.80, 0.25, 39.00, 1004, 3), -- 3 - APROBADO 2
('CABEZAS', 1, 600.00, GETDATE(), 5, 1.60, 0.15, 41.00, 1005, 3), -- 3 - APROBADO 2
('CORAZON', 1, 900.00, GETDATE(), 1, 1.70, 0.22, 40.50, 1006, 2), -- 2 - APROBADO 1
('COLAS', 1, 700.00, GETDATE(), 2, 1.40, 0.18, 39.50, 1007, 2), -- 2 - APROBADO 1
('ORDINARIO', 1, 400.00, GETDATE(), 3, 1.30, 0.20, 38.50, 1008, 2), -- 2 - APROBADO 1
('AGUA', 1, 100.00, GETDATE(), 4, 0.00, 0.00, 0.00, 1009, 3), -- 3 - APROBADO 2
('MEZCAL A', 1, 750.00, GETDATE(), 5, 1.50, 0.25, 40.00, 1010, 2); -- 2 - APROBADO 1

-- Drop the table if it exists
IF OBJECT_ID('dbo.contenedores_liquido', 'U') IS NOT NULL
DROP TABLE dbo.contenedores_liquido;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE trasacciones_liquido_contenedor (
    id_liquido_contendor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the container-liquid relation
    id_contenedor INT NOT NULL, -- Foreign key referencing contenedores
    id_liquido INT NOT NULL, -- Foreign key referencing liquidos
    cantidad_liquido_lts DECIMAL(10, 2) NOT NULL, -- Amount of liquid in the container in liters
    persona_encargada VARCHAR(32) NOT NULL, -- Person responsible for the operation
    FOREIGN KEY (id_contenedor) REFERENCES contenedores(id_contenedor),
    FOREIGN KEY (id_liquido) REFERENCES liquidos(id_liquido)
);

-- Insert 5 container-liquid relations into the contenedores_liquido table

-- Ensure the containers are "EN USO" and the liquids are not "CUARENTENA"
INSERT INTO trasacciones_liquido_contenedor (id_contenedor, id_liquido, cantidad_liquido_lts, persona_encargada) VALUES
(1, 1, 300.00, 'User A'), -- Contenedor 1 (EN USO), Liquido 1 (not CUARENTENA)
(2, 2, 200.00, 'User B'), -- Contenedor 2 (EN USO), Liquido 2 (not CUARENTENA)
(3, 3, 500.00, 'User C'), -- Contenedor 3 (EN USO), Liquido 3 (not CUARENTENA)
(4, 4, 400.00, 'User D'), -- Contenedor 4 (EN USO), Liquido 4 (not CUARENTENA)
(5, 5, 350.00, 'User E'); -- Contenedor 5 (EN USO), Liquido 5 (not CUARENTENA)

-- Drop the table if it exists
IF OBJECT_ID('dbo.productos_terminados', 'U') IS NOT NULL
DROP TABLE dbo.productos_terminados;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE productos_terminados (
    id_producto_terminado INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the finished product
    id_liquido_contenedor INT NOT NULL, -- Foreign key referencing contenedores_liquido
    fecha_termino DATE NOT NULL DEFAULT GETDATE(), -- Date when the product was finished, default to current date
    cantidad_liquido_terminada_lts DECIMAL(10, 2), -- Number of bottles produced
    FOREIGN KEY (id_liquido_contenedor) REFERENCES trasacciones_liquido_contenedor(id_liquido_contendor)
);

----- REMEMBER ISERT DUMMY DATA INTO productos_teminados ------

-- Drop the table if it exists
IF OBJECT_ID('dbo.combinaciones', 'U') IS NOT NULL
DROP TABLE dbo.combinaciones;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE combinaciones (
    id_combinacion INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the combination
    id_liquido_base INT NOT NULL, -- Foreign key referencing liquidos
    FOREIGN KEY (id_liquido_base) REFERENCES liquidos(id_liquido)
);

-- Drop the table if it exists
IF OBJECT_ID('dbo.combinaciones_detalle', 'U') IS NOT NULL
DROP TABLE dbo.combinaciones_detalle;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE combinaciones_detalle (
    id_combinacion INT NOT NULL, -- Foreign key referencing combinaciones
    id_liquido INT NOT NULL, -- Foreign key referencing liquidos
    cantidad_lts DECIMAL(10, 2) NOT NULL CHECK (cantidad_lts > 0), -- Amount of liquid in liters, must be greater than 0
    FOREIGN KEY (id_combinacion) REFERENCES combinaciones(id_combinacion),
    FOREIGN KEY (id_liquido) REFERENCES liquidos(id_liquido)
);

--- SOTORED PROCEDURES TO BE CONSUMED BY POWER APPS OR WHATEVER OTHER APP ---

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_datos_liquidos', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_liquidos;
GO

-- Create the stored procedure to get data from liquidos
CREATE PROCEDURE sp_obtener_datos_liquidos
AS
BEGIN
    SET NOCOUNT ON;

    -- Select id_liquido and codigo from liquidos table
    SELECT id_liquido, codigo, cantidad_total_lts
    FROM liquidos;
END;
GO

-- Call stored procedure
EXEC sp_obtener_datos_liquidos;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_datos_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_contenedor;
GO

-- Create the stored procedure to get data from one container by it's unique id
CREATE PROCEDURE sp_obtener_datos_contenedor
    @id_contenedor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Select nombre, id_tipo, id_estatus, fecha_baja and capacidad_lts from contenedores table
    -- Join with tipos_contenedor to get the capacity
    SELECT 
        c.nombre,
        c.id_estatus,
        fecha_baja,
        t.capacidad_lts -- Assuming capacidad_lts is the capacity column in tipos_contenedor
    FROM 
        contenedores c
    JOIN 
        tipos_contenedor t ON c.id_tipo = t.id_tipo_contenedor
    WHERE 
        c.id_contenedor = @id_contenedor;
END;
GO

-- Call stored procedure
EXEC sp_obtener_datos_contenedor @id_contenedor = 4;
SELECT * FROM contenedores;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_estatus_liquidos', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_estatus_liquidos;
GO

-- Create stored procedure to get the status of liquids
CREATE PROCEDURE sp_obtener_estatus_liquidos
AS
BEGIN
    SET NOCOUNT ON;
    -- Select descripcion from estatus_liquido table
    SELECT descripcion
    FROM estatus_liquido;
END;
GO

-- Call the procedure to get estatus of liquids
EXEC sp_obtener_estatus_liquidos;

SELECT * FROM liquidos;
SELECT * FROM proveedores;
