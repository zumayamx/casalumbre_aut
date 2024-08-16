
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
('TANQUE A', 1, 1, '2021-01-01', '2022-01-01', 4), -- 4 - DAÑADO?
('TANQUE B', 2, 2, '2021-02-01', '2022-02-01', 4), -- 4 - DAÑADO?
('TANQUE C', 3, 3, '2021-03-01', '2022-03-01', 4), -- 4 - DAÑADO?
('TANQUE D', 4, 4, '2021-04-01', '2022-04-01', 4), -- 4 - DAÑADO?
('TANQUE E', 5, 5, '2021-05-01', '2022-05-01', 4); -- 4 - DAÑADO?

-- 10 active containers (fecha_baja is null)
INSERT INTO contenedores (nombre, id_tipo, id_ubicacion, fecha_alta, id_estatus) VALUES
('TANQUE F', 1, 1, '2022-06-01', 2), -- 2 - DISPONIBLE
('TANQUE G', 2, 2, '2022-07-01', 2), -- 2 - DISPONIBLE
('TANQUE H', 3, 3, '2022-08-01', 2), -- 2 - DISPONIBLE
('TANQUE I', 4, 4, '2022-09-01', 2), -- 2 - DISPONIBLE
('TANQUE J', 5, 5, '2022-10-01', 2), -- 2 - DISPONIBLE
('TANQUE K', 1, 1, '2022-11-01', 2), -- 2 - DISPONIBLE
('TANQUE L', 2, 2, '2022-12-01', 2), -- 2 - DISPONIBLE
('TANQUE M', 3, 3, '2023-01-01', 2), -- 2 - DISPONIBLE
('TANQUE N', 4, 4, '2023-02-01', 2), -- 2 - DISPONIBLE
('TANQUE O', 5, 5, '2023-03-01', 2); -- 4 - DISPONIBLE

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
    FOREIGN KEY (id_tipo) REFERENCES tipo_liquido(id_tipo_liquido),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

-- Insert multiple liquid records into the liquidos table

-- Ensure the estatus is not CUARENTENA
INSERT INTO liquidos (codigo, id_tipo, cantidad_total_lts, fecha_produccion, id_proveedor, metanol, alcoholes_sup, porcentaje_alchol_vol, orden_produccion) VALUES
('ESPADÍN', 1, 500.00, GETDATE(), 1, 1.50, 0.20, 40.00, 1001), -- 2 - APROBADO 1
('TOBALÁ', 1, 300.00, GETDATE(), 2, 1.20, 0.30, 38.00, 1002), -- 2 - APROBADO 1
('MEZCAL DM', 1, 1000.00, GETDATE(), 3, 2.00, 0.10, 42.00, 1003), -- 2 - APROBADO 1
('MEZCAL ODT', 1, 800.00, GETDATE(), 4, 1.80, 0.25, 39.00, 1004), -- 3 - APROBADO 2
('CABEZAS', 1, 600.00, GETDATE(), 5, 1.60, 0.15, 41.00, 1005), -- 3 - APROBADO 2
('CORAZON', 1, 900.00, GETDATE(), 1, 1.70, 0.22, 40.50, 1006), -- 2 - APROBADO 1
('COLAS', 1, 700.00, GETDATE(), 2, 1.40, 0.18, 39.50, 1007), -- 2 - APROBADO 1
('ORDINARIO', 1, 400.00, GETDATE(), 3, 1.30, 0.20, 38.50, 1008), -- 2 - APROBADO 1
('AGUA', 1, 100.00, GETDATE(), 4, 0.00, 0.00, 0.00, 1009), -- 3 - APROBADO 2
('MEZCAL A', 1, 750.00, GETDATE(), 5, 1.50, 0.25, 40.00, 1010); -- 2 - APROBADO 1

-- Drop the table if it exists
IF OBJECT_ID('dbo.transacciones_liquido_contenedor', 'U') IS NOT NULL
DROP TABLE dbo.transacciones_liquido_contenedor;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE transacciones_liquido_contenedor (
    id_liquido_contendor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the container-liquid relation
    id_contenedor INT NOT NULL, -- Foreign key referencing contenedores
    id_liquido INT NOT NULL, -- Foreign key referencing liquidos
    cantidad_liquido_lts DECIMAL(10, 2) NOT NULL, -- Amount of liquid in the container in liters
    persona_encargada VARCHAR(32) NOT NULL, -- Person responsible for the operation
    id_estatus INT NOT NULL, -- Foreign key referencing estatus_liquido
    fecha_transaccion DATE DEFAULT GETDATE(), -- Date of trasaction to get an historial
    FOREIGN KEY (id_contenedor) REFERENCES contenedores(id_contenedor),
    FOREIGN KEY (id_liquido) REFERENCES liquidos(id_liquido),
    FOREIGN KEY (id_estatus) REFERENCES estatus_liquido(id_estatus_liquido)
);

-- Insert 5 container-liquid relations into the contenedores_liquido table

-- Ensure the containers are "EN USO" and the liquids are not "CUARENTENA"
INSERT INTO transacciones_liquido_contenedor (id_contenedor, id_liquido, cantidad_liquido_lts, persona_encargada, id_estatus) VALUES
(1, 1, 300.00, 'User A', 2), -- Contenedor 1 (EN USO), Liquido 1 (not CUARENTENA)
(2, 2, 200.00, 'User B', 2), -- Contenedor 2 (EN USO), Liquido 2 (not CUARENTENA)
(3, 3, 500.00, 'User C', 2), -- Contenedor 3 (EN USO), Liquido 3 (not CUARENTENA)
(4, 4, 400.00, 'User D', 2), -- Contenedor 4 (EN USO), Liquido 4 (not CUARENTENA)
(5, 5, 350.00, 'User E', 2); -- Contenedor 5 (EN USO), Liquido 5 (not CUARENTENA)

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
    FOREIGN KEY (id_liquido_contenedor) REFERENCES transacciones_liquido_contenedor(id_liquido_contendor)
);

----- REMEMBER ISERT DUMMY DATA INTO productos_teminados ------

-- Drop the table if it exists
IF OBJECT_ID('dbo.combinaciones', 'U') IS NOT NULL
DROP TABLE dbo.combinaciones;
GO

-- Create the table with the correct structure and foreign keys
CREATE TABLE combinaciones (
    id_combinacion INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the combination
    id_liquido_combinado INT NOT NULL, -- Foreign key referencing liquidos
    FOREIGN KEY (id_liquido_combinado) REFERENCES liquidos(id_liquido)
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

-- Create the stored procedure to get the data from one container
CREATE PROCEDURE sp_obtener_datos_contenedor
    @id_contenedor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Select nombre and capacidad_lts from contenedores table
    -- Join with tipos_contenedor to get the capacity
        -- Verificar si el contenedor existe
    IF NOT EXISTS (
        SELECT 1 
        FROM contenedores 
        WHERE id_contenedor = @id_contenedor
          AND fecha_baja IS NULL
          AND id_estatus < 3
    )
    BEGIN
        RAISERROR('El contenedor con ID %d no existe o no está activo.', 16, 1, @id_contenedor);
        RETURN;
    END

    -- Select nombre and capacidad_lts from contenedores table
    -- Join with tipos_contenedor to get the capacity
    SELECT 
        c.nombre,
        c.id_estatus,
        t.capacidad_lts -- Assuming capacidad_lts is the capacity column in tipos_contenedor
    FROM 
        contenedores c
    JOIN 
        tipos_contenedor t ON c.id_tipo = t.id_tipo_contenedor
    WHERE 
        c.id_contenedor = @id_contenedor
        AND c.fecha_baja IS NULL
        AND c.id_estatus < 3;
END;
GO

-- Call stored procedure
EXEC sp_obtener_datos_contenedor @id_contenedor = 15;
SELECT * FROM estatus_contenedor;
SELECT * FROM contenedores;
SELECT * FROM transacciones_liquido_contenedor;
SELECT * FROM liquidos;
SELECT * FROM estatus_liquido;
SELECT * FROM contenedores;
EXEC sp_obtener_datos_validos_liquido_contenedor @id_contenedor = 11;

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
    SELECT * FROM estatus_liquido;
END;
GO

-- Call the procedure to get estatus of liquids
EXEC sp_obtener_estatus_liquidos;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_insertar_transaccion_liquido_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_insertar_transaccion_liquido_contenedor;
GO

-- Create stored procedure to insert a transaction in liquido_contenedor table
CREATE PROCEDURE sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_origen INT,
    @id_contenedor_destino INT,
    @id_liquido INT,
    @cantidad_liquido_lts DECIMAL(10, 2),
    @persona_encargada VARCHAR(32),
    @id_estatus_liquido INT
AS
BEGIN
    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;
        
        -- Insert into transacciones_liquido_contenedor
        INSERT INTO transacciones_liquido_contenedor
        (
            id_contenedor,
            id_liquido,
            cantidad_liquido_lts,
            persona_encargada,
            id_estatus
        )
        VALUES 
        (
            @id_contenedor_destino,
            @id_liquido,
            @cantidad_liquido_lts,
            @persona_encargada,
            @id_estatus_liquido
        );

        -- Check if the destination container exists before attempting the update
        IF EXISTS (SELECT 1 FROM contenedores WHERE id_contenedor = @id_contenedor_destino)
        BEGIN
            UPDATE
                contenedores
            SET
                id_estatus = 1
            WHERE
                id_contenedor = @id_contenedor_destino;
        END
        ELSE
        BEGIN
            RAISERROR('El contenedor de destino especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if the origin container and liquid exists before attempting the update
        IF EXISTS (SELECT 1 FROM transacciones_liquido_contenedor WHERE id_contenedor = @id_contenedor_origen AND id_liquido = @id_liquido)
        BEGIN
            -- Update the quantity of liquid in the origin container
            UPDATE
                transacciones_liquido_contenedor
            SET
                cantidad_liquido_lts = cantidad_liquido_lts - @cantidad_liquido_lts
            WHERE
                id_contenedor = @id_contenedor_origen
                AND id_liquido = @id_liquido;

            -- Ensure the update was successful (no negative quantities)
            IF (SELECT cantidad_liquido_lts FROM transacciones_liquido_contenedor WHERE id_contenedor = @id_contenedor_origen AND id_liquido = @id_liquido) < 0
            BEGIN
                RAISERROR('La cantidad de líquido en el contenedor de origen no puede ser negativa.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        ELSE
        BEGIN
            RAISERROR('El contenedor de origen o el líquido especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Commit the transaction if everything is successful
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction if an error occurs
        ROLLBACK TRANSACTION;
        -- Re-throw the error to the caller
        THROW;
    END CATCH;
END;
GO

SELECT * FROM contenedores;
SELECT * FROM transacciones_liquido_contenedor;
SELECT * FROM liquidos;

-- Call the stored procedure to insert a trasaction liquido to container, USE ONLY FOR ONE TRASACTION - IN TEST STATUS
EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_origen = 15,
    @id_contenedor_destino = 6, 
    @id_liquido = 1, 
    @cantidad_liquido_lts = 300.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_insertar_liquido', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_insertar_liquido;
GO

-- Create procedure to insert a new liquid in liquidos table
CREATE PROCEDURE sp_insertar_liquido
    @codigo VARCHAR(32),
    @id_tipo INT,
    @cantidad_total_lts DECIMAL(10, 2),
    @id_proveedor INT,
    @metanol DECIMAL (5,2),
    @alcoholes_sup DECIMAL(5, 2),
    @porcentaje_alcohol_vol DECIMAL(5, 2),
    @orden_produccion INT
AS
BEGIN
    -- Insert new liquid in liquidos table
    INSERT INTO liquidos
    (
        codigo,
        id_tipo,
        cantidad_total_lts,
        id_proveedor,
        metanol,
        alcoholes_sup,
        porcentaje_alchol_vol,
        orden_produccion
    )
    VALUES
    (
        @codigo,
        @id_tipo,
        @cantidad_total_lts,
        @id_proveedor,
        @metanol,
        @alcoholes_sup,
        @porcentaje_alcohol_vol,
        @orden_produccion
        
    )
END;
GO

-- Call the stored procedure to insert a new liquid
EXEC sp_insertar_liquido
    @codigo = 'LIQUIDO B',
    @id_tipo = 1,
    @cantidad_total_lts = 300.00,
    @id_proveedor = 5,
    @metanol = 1.35,
    @alcoholes_sup = 0.24,
    @porcentaje_alcohol_vol = 45.85,
    @orden_produccion = 1010;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_proveedores', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_proveedores;
GO

CREATE PROCEDURE sp_obtener_proveedores
AS
BEGIN
    SET NOCOUNT ON;
    -- Select all from proveedores (id_provedor, nombre)
    SELECT * FROM proveedores;
END;
GO

-- Call stored procedure to get proveedores
EXEC sp_obtener_proveedores;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_datos_validos_liquido_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_validos_liquido_contenedor;
GO

-- Create procedure to validate a liquid in a container
CREATE PROCEDURE sp_obtener_datos_validos_liquido_contenedor
    @id_contenedor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para almacenar los datos del último líquido en el contenedor
    DECLARE @ultimo_id_liquido INT;
    DECLARE @ultimo_id_liquido_contendor INT;
    DECLARE @cantidad_liquido_lts DECIMAL(10, 2);

    -- Obtener el último registro del líquido en el contenedor
    SELECT TOP 1
        @ultimo_id_liquido = t.id_liquido,
        @ultimo_id_liquido_contendor = t.id_liquido_contendor,
        @cantidad_liquido_lts = t.cantidad_liquido_lts
    FROM 
        transacciones_liquido_contenedor t
    JOIN
        contenedores c ON c.id_contenedor = @id_contenedor
    WHERE
        t.id_contenedor = @id_contenedor
        AND t.id_estatus > 1
        AND c.id_estatus < 3
        AND c.fecha_baja IS NULL
    ORDER BY t.id_liquido_contendor DESC;

    -- Verificar si no se encontró un líquido válido
    IF @ultimo_id_liquido IS NULL OR @cantidad_liquido_lts <= 0.00
    BEGIN
        RAISERROR ('No se encontró un líquido válido en el contenedor o el contenedor está dañado.', 16, 1);
        RETURN;
    END

    SELECT
        @ultimo_id_liquido AS id_liquido,
        l.codigo AS codigo_liquido,
        @cantidad_liquido_lts AS cantidad_liquido_dentro_lts,
        @ultimo_id_liquido_contendor AS ultimo_id_liquido_contenedor
    FROM 
        liquidos l
    WHERE 
        l.id_liquido = @ultimo_id_liquido
END;
GO

-- Call the stored procedure to obtain unique id of liquid
EXEC sp_obtener_datos_validos_liquido_contenedor
    @id_contenedor = 6;

-- Drop procedure if exists
IF OBJECT_ID('dbo.sp_obtener_datos_liquido', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_liquido;
GO

-- Create procedure to get the info of one liquid - FILL WITH ALL FIELD YOU NEED
CREATE PROCEDURE sp_obtener_datos_liquido
    @id_liquido INT
AS
BEGIN
    SELECT
        codigo AS codigo_liquido
    FROM
        liquidos l
    WHERE
        l.id_liquido = @id_liquido
END;
GO

-- Call the stored procedure
EXEC sp_obtener_datos_liquido @id_liquido = 5;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_insertar_liquido_combinado', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_insertar_liquido_combinado;
GO

-- Create procedure to to insert one combinated liquid
CREATE PROCEDURE sp_insertar_liquido_combinado
    @nombre VARCHAR(32),
    @id_tipo INT,
    @cantidad_generada_lts DECIMAL(10, 2),
    @id_proveedor INT,
    @metanol DECIMAL(10, 2),
    @alcoholes_sup DECIMAL(10, 2),
    @porcentaje_alcohol_vol DECIMAL(10, 2),
    @orden_produccion INT,
    @id_estatus INT,
    @id_contenedor_destino INT,
    @persona_encargada VARCHAR(32),
    @composicion_liquidos_json NVARCHAR(MAX) -- This JSON contains data for each liquid component in the combined liquid
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_liquido_combinado INT;
    DECLARE @id_combinacion INT;

    -- Insertar el nuevo registro en la tabla liquidos
    INSERT INTO liquidos
    (
        codigo,
        id_tipo,
        cantidad_total_lts,
        id_proveedor,
        metanol,
        alcoholes_sup,
        porcentaje_alchol_vol,
        orden_produccion
    )
    VALUES
    (
        @nombre,
        @id_tipo,
        @cantidad_generada_lts,
        @id_proveedor,
        @metanol,
        @alcoholes_sup,
        @porcentaje_alcohol_vol,
        @orden_produccion
    );

    -- Retrieve the id_liquido_combinado of the liquid that was just inserted.
    SET @id_liquido_combinado = SCOPE_IDENTITY();

    -- Insert in combinaciones table
    INSERT INTO combinaciones
    (
        id_liquido_combinado
    )
    VALUES
    (
        @id_liquido_combinado
    );

    SET @id_combinacion = SCOPE_IDENTITY();

    -- Insert into the combinaciones_detalle table to specify the components of the combined liquid.
    INSERT INTO combinaciones_detalle
    (
        id_combinacion,
        id_liquido,
        cantidad_lts
    )
    SELECT 
        @id_combinacion,
        id_liquido_componente,
        cantidad_liquido_componente_lts
    FROM
        OPENJSON(@composicion_liquidos_json)
    WITH
    (
        id_liquido_componente INT '$.id_liquido_componente',
        cantidad_liquido_componente_lts DECIMAL(10, 2) '$.cantidad_liquido_componente_lts'
    );

    UPDATE 
        t
    SET 
        t.cantidad_liquido_lts = t.cantidad_liquido_lts - c.cantidad_liquido_componente_lts
    FROM
        transacciones_liquido_contenedor t
    JOIN 
        OPENJSON(@composicion_liquidos_json)
    WITH
    (
        id_contenedor_componente INT '$.id_contenedor_componente',
        id_liquido_componente INT '$.id_liquido_componente',
        cantidad_liquido_componente_lts DECIMAL (10, 2) '$.cantidad_liquido_componente_lts'
    ) c ON t.id_contenedor = c.id_contenedor_componente AND t.id_liquido = c.id_liquido_componente; -- UN CONTENEDOR NO TIENE DOS LIQUIDOS MISMOS ?

    -- Finally insert this liquid in a destinity container
    INSERT INTO transacciones_liquido_contenedor
    (
        id_contenedor,
        id_liquido,
        cantidad_liquido_lts,
        persona_encargada,
        id_estatus
    )
    VALUES
    (
        @id_contenedor_destino,
        @id_liquido_combinado,
        @cantidad_generada_lts,
        @persona_encargada,
        @id_estatus
    );
END;
GO

    -- -- Finally update or set the quantity of liquid in 
    -- UPDATE
    --     t
    -- SET
    --     t.cantidad_liquido_lts = @cantidad_generada_lts -- SUPONIENDO QUE LA SUMA LA HACEMOS EN POWER APPS
    -- FROM 
    --     transacciones_liquido_contenedor t
    -- WHERE
    --     t.id_contenedor = @id_contenedor_destino
    --     AND t.id_liquido = @id_liquido_combinado

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 10->11',
    @id_tipo = 2,
    @cantidad_generada_lts = 75.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1093,
    @id_estatus = 2,
    @id_contenedor_destino = 11,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 11, 
            "id_liquido_componente": 6, 
            "cantidad_liquido_componente_lts": 25.00
        }, 
        {
            "id_contenedor_componente": 10, 
            "id_liquido_componente": 13, 
            "cantidad_liquido_componente_lts": 50.00
        }
        ]';

SELECT * FROM liquidos;
SELECT * FROM transacciones_liquido_contenedor;
SELECT * FROM contenedores;
SELECT * FROM combinaciones;
SELECT * FROM combinaciones_detalle;

-- EXEC sp_insertar_liquido_combinado
--     @nombre = 'LIQUIDO COMBINADO 6-7->8',
--     @id_tipo = 2,
--     @cantidad_generada_lts = 75.00,
--     @id_proveedor = 3,
--     @metanol = 10.15,
--     @alcoholes_sup = 0.1,
--     @porcentaje_alcohol_vol = 40.60,
--     @orden_produccion = 1090,
--     @id_estatus = 2,
--     @id_contenedor_destino = 8,
--     @persona_encargada = 'manolo@gmail.com',
--     @composicion_liquidos_json = 
--         N'[
--         {
--             "id_contenedor_componente": 6, 
--             "id_liquido_componente": 1, 
--             "cantidad_liquido_componente_lts": 25.00
--         }, 
--         {
--             "id_contenedor_componente": 7, 
--             "id_liquido_componente": 2, 
--             "cantidad_liquido_componente_lts": 25.00
--         },
--          {
--             "id_contenedor_componente": 8, 
--             "id_liquido_componente": 3, 
--             "cantidad_liquido_componente_lts": 25.00
--         }
--         ]';

-- EXEC sp_insertar_liquido_combinado
--     @nombre = 'LIQUIDO COMBINADO 9->10',
--     @id_tipo = 2,
--     @cantidad_generada_lts = 50.00,
--     @id_proveedor = 3,
--     @metanol = 10.15,
--     @alcoholes_sup = 0.1,
--     @porcentaje_alcohol_vol = 40.60,
--     @orden_produccion = 1091,
--     @id_estatus = 2,
--     @id_contenedor_destino = 10,
--     @persona_encargada = 'manolo@gmail.com',
--     @composicion_liquidos_json = 
--         N'[
--         {
--             "id_contenedor_componente": 9, 
--             "id_liquido_componente": 4, 
--             "cantidad_liquido_componente_lts": 25.00
--         }, 
--         {
--             "id_contenedor_componente": 10, 
--             "id_liquido_componente": 5, 
--             "cantidad_liquido_componente_lts": 25.00
--         }
--         ]';

-- EXEC sp_insertar_liquido_combinado
--     @nombre = 'LIQUIDO COMBINADO 8->10',
--     @id_tipo = 2,
--     @cantidad_generada_lts = 50.00,
--     @id_proveedor = 3,
--     @metanol = 10.15,
--     @alcoholes_sup = 0.1,
--     @porcentaje_alcohol_vol = 40.60,
--     @orden_produccion = 1092,
--     @id_estatus = 2,
--     @id_contenedor_destino = 10,
--     @persona_encargada = 'manolo@gmail.com',
--     @composicion_liquidos_json = 
--         N'[
--         {
--             "id_contenedor_componente": 8, 
--             "id_liquido_componente": 11, 
--             "cantidad_liquido_componente_lts": 25.00
--         }, 
--         {
--             "id_contenedor_componente": 10, 
--             "id_liquido_componente": 12, 
--             "cantidad_liquido_componente_lts": 25.00
--         }
--         ]';

-- EXEC sp_insertar_liquido_combinado
--     @nombre = 'LIQUIDO COMBINADO 10->11',
--     @id_tipo = 2,
--     @cantidad_generada_lts = 75.00,
--     @id_proveedor = 3,
--     @metanol = 10.15,
--     @alcoholes_sup = 0.1,
--     @porcentaje_alcohol_vol = 40.60,
--     @orden_produccion = 1093,
--     @id_estatus = 2,
--     @id_contenedor_destino = 11,
--     @persona_encargada = 'manolo@gmail.com',
--     @composicion_liquidos_json = 
--         N'[
--         {
--             "id_contenedor_componente": 11, 
--             "id_liquido_componente": 6, 
--             "cantidad_liquido_componente_lts": 25.00
--         }, 
--         {
--             "id_contenedor_componente": 10, 
--             "id_liquido_componente": 13, 
--             "cantidad_liquido_componente_lts": 50.00
--         }
--         ]';

IF OBJECT_ID('dbo.sp_obtener_trazabilidad_liquido', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_trazabilidad_liquido;
GO

CREATE PROCEDURE sp_obtener_trazabilidad_liquido
    @id_liquido_b INT
AS
BEGIN
    WITH CTE_trazabilidad AS (
        SELECT
            t.id_combinacion,
            l.fecha_produccion,
            l.id_liquido AS id_liquido_combinado,
            l.codigo AS codigo_liquido_combinado,
            l.id_tipo AS tipo_liquido_combinado,
            td.id_liquido AS id_liquido_componente,
            lc.codigo AS codigo_componente,
            lc.id_tipo AS tipo_componente,
            td.cantidad_lts,
            0 AS nivel
        FROM 
            combinaciones t
        JOIN
            combinaciones_detalle td ON t.id_combinacion = td.id_combinacion
        JOIN
            liquidos l ON t.id_liquido_combinado = l.id_liquido
        JOIN
            liquidos lc ON td.id_liquido = lc.id_liquido
        WHERE
            l.id_liquido = @id_liquido_b
        
        UNION ALL

        SELECT
            t.id_combinacion,
            l.fecha_produccion,
            l.id_liquido AS id_liquido_combinado,
            l.codigo AS codigo_liquido_combinado,
            l.id_tipo AS tipo_liquido_combinado,
            td.id_liquido AS id_liquido_componente,
            lc.codigo AS codigo_componente,
            lc.id_tipo AS tipo_componente,
            td.cantidad_lts,
            cte.nivel + 1
        FROM
            CTE_trazabilidad cte
        JOIN
            combinaciones t ON cte.id_liquido_componente = t.id_liquido_combinado
        JOIN
            combinaciones_detalle td ON t.id_combinacion = td.id_combinacion
        JOIN
            liquidos l ON t.id_liquido_combinado = l.id_liquido
        JOIN
            liquidos lc ON td.id_liquido = lc.id_liquido
    )

    SELECT *
    FROM CTE_trazabilidad
    ORDER BY nivel, id_combinacion, id_liquido_combinado, id_liquido_componente
END;
GO

EXEC sp_obtener_trazabilidad_liquido @id_liquido_b = 14;

SELECT * FROM liquidos;
SELECT * FROM proveedores;
SELECT * FROM contenedores;
SELECT * FROM transacciones_liquido_contenedor;
SELECT * FROM combinaciones;
SELECT * FROM combinaciones_detalle;
SELECT * FROM estatus_contenedor;
SELECT * FROM estatus_liquido;
SELECT * FROM estatus_contenedor;
SELECT * FROM tipos_contenedor;
SELECT * FROM productos_terminados;

-- -- Create stored procedure to get the status of liquids
-- CREATE PROCEDURE sp_obtener_estatus_liquidos
-- AS
-- BEGIN
--     SET NOCOUNT ON;
--     -- Select descripcion from estatus_liquido table
--     SELECT * FROM estatus_liquido;
-- END;
-- GO

-- -- Call the procedure to get estatus of liquids
-- EXEC sp_obtener_estatus_liquidos;

-- -- Drop the procedure if it exists
-- IF OBJECT_ID('dbo.sp_insertar_transaccion_liquido_contenedor', 'P') IS NOT NULL
-- DROP PROCEDURE dbo.sp_insertar_transaccion_liquido_contenedor;
-- GO

-- -- Create stored procedure to insert a transaction in liquido_contenedor table
-- CREATE PROCEDURE sp_insertar_transaccion_liquido_contenedor
--     @id_contenedor_origen INT,
--     @id_contenedor_destino INT,
--     @id_liquido INT,
--     @cantidad_liquido_lts DECIMAL(10, 2),
--     @persona_encargada VARCHAR(32),
--     @id_estatus_liquido INT
-- AS
-- BEGIN
--     -- Insert into transacciones_liquido_contenedor
--     INSERT INTO transacciones_liquido_contenedor
--     (
--         id_contenedor,
--         id_liquido,
--         cantidad_liquido_lts,
--         persona_encargada,
--         id_estatus
--     )
--     VALUES 
--     (
--         @id_contenedor_destino,
--         @id_liquido,
--         @cantidad_liquido_lts,
--         @persona_encargada,
--         @id_estatus_liquido
--     );

--      -- Check if the container exists before attempting the update
--     IF EXISTS (SELECT 1 FROM contenedores WHERE id_contenedor = @id_contenedor_destino)
--     BEGIN
--         UPDATE
--             contenedores
--         SET
--             id_estatus = 1
--         WHERE
--             id_contenedor = @id_contenedor_destino;
--     END
--     ELSE
--     BEGIN
--         RAISERROR('El contenedor especificado no existe.', 16, 1);
--     END;
-- END;
-- GO

