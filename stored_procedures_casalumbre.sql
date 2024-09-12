
-- Use this database;
USE casalumbre_db;

--- STORED PROCEDURES TO BE CONSUMED BY POWER APPS OR WHATEVER OTHER APP ---

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

-- Create the stored procedure to get the data from one container -- PARA VACIAR SOLO UN PROCEDURE O QUE NO TENGA NADA O QUE SEA LA PRIMER DE LA LISTA DE LIQUIDOS
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
EXEC sp_obtener_datos_contenedor @id_contenedor = 14;

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

-- Drop the procedure if exists
IF OBJECT_ID('dbo.sp_insertar_transaccion_liquido_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_insertar_transaccion_liquido_contenedor;
GO

CREATE PROCEDURE sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino INT,
    @id_liquido INT,
    @cantidad_liquido_lts DECIMAL(10,2),
    @persona_encargada VARCHAR(32),
    @id_estatus_liquido INT
AS
BEGIN
    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;

        -- Validación: verificar si el contenedor de destino es válido
        IF NOT EXISTS (
            SELECT 1 
            FROM contenedores 
            WHERE id_contenedor = @id_contenedor_destino
              AND fecha_baja IS NULL
              AND id_estatus < 3
        )
        BEGIN
            RAISERROR('El contenedor de destino no es válido o está dado de baja.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Insertar en transacciones_liquido_contenedor
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

        -- Actualizar el estatus del contenedor de destino si existe
        UPDATE
            contenedores
        SET
            id_estatus = 1
        WHERE
            id_contenedor = @id_contenedor_destino;

        -- Commit the transaction
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

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 6, 
    @id_liquido = 1, 
    @cantidad_liquido_lts = 500.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 7, 
    @id_liquido = 2, 
    @cantidad_liquido_lts = 300.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 8, 
    @id_liquido = 3, 
    @cantidad_liquido_lts = 1000.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 9, 
    @id_liquido = 4, 
    @cantidad_liquido_lts = 800.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 10, 
    @id_liquido = 5, 
    @cantidad_liquido_lts = 600.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 11, 
    @id_liquido = 6, 
    @cantidad_liquido_lts = 900.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 12, 
    @id_liquido = 7, 
    @cantidad_liquido_lts = 700.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 13, 
    @id_liquido = 8, 
    @cantidad_liquido_lts = 400.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 14, 
    @id_liquido = 9, 
    @cantidad_liquido_lts = 100.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

EXEC sp_insertar_transaccion_liquido_contenedor
    @id_contenedor_destino = 15, 
    @id_liquido = 10, 
    @cantidad_liquido_lts = 750.00, 
    @persona_encargada = 'manolo@gmail.com',
    @id_estatus_liquido = 2;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_insertar_transferencia_liquido_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_insertar_transferencia_liquido_contenedor;
GO

-- Create stored procedure to insert a transaction in liquido_contenedor table
CREATE PROCEDURE sp_insertar_transferencia_liquido_contenedor
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

-- Call the stored procedure to insert a trasaction liquido to container, USE ONLY FOR ONE TRASACTION - IN TEST STATUS
EXEC sp_insertar_transferencia_liquido_contenedor
    @id_contenedor_origen = 9,
    @id_contenedor_destino = 14, 
    @id_liquido = 4, 
    @cantidad_liquido_lts = 1000.00, 
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
    @metanol DECIMAL(5,2),
    @alcoholes_sup DECIMAL(5, 2),
    @porcentaje_alcohol_vol DECIMAL(5, 2),
    @orden_produccion INT
AS
BEGIN
    DECLARE @id_nuevo_liquido INT;

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
    );
    
    -- Get the last inserted ID
    SET @id_nuevo_liquido = SCOPE_IDENTITY();

    -- Return the newly inserted ID
    SELECT @id_nuevo_liquido AS id_nuevo_liquido;
END;
GO

-- Call the stored procedure to insert a new liquid
EXEC sp_insertar_liquido
    @codigo = 'LIQUIDO BR',
    @id_tipo = 1,
    @cantidad_total_lts = 300.00,
    @id_proveedor = 5,
    @metanol = 1.35,
    @alcoholes_sup = 0.24,
    @porcentaje_alcohol_vol = 45.85,
    @orden_produccion = 1010;

SELECT * FROM liquidos;

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

-- Drop the procedure if it exists ------------------------------------------------------------------------------ TH
IF OBJECT_ID('dbo.sp_insertar_liquido_combinado_p', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_insertar_liquido_combinado_p;
GO

CREATE PROCEDURE sp_insertar_liquido_combinado_p
    @nombre VARCHAR(32),
    @id_tipo INT,
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

    -- Begin the transaction
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @id_liquido_combinado INT;
        DECLARE @id_combinacion INT;
        DECLARE @id_liquido_componente INT;
        DECLARE @cantidad_total_componentes DECIMAL(10, 2) = 0;
        DECLARE @cantidad_liquido_destino DECIMAL(10, 2);

        -- Obtener la cantidad de líquido actual en el contenedor de destino
        -- Creamos una tabla temporal para almacenar los resultados del procedimiento almacenado
        CREATE TABLE #TempTable (
            id_liquido_contendor INT,
            id_liquido INT,
            cantidad_liquido_lts DECIMAL(18, 2),
            capacidad_lts DECIMAL(18, 2),
            codigo VARCHAR(50),
            descripcion VARCHAR(100)
        );

        -- Insertamos los resultados del procedimiento almacenado en la tabla temporal
        INSERT INTO #TempTable
        EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor_destino;

        SELECT @cantidad_liquido_destino = cantidad_liquido_lts
        FROM #TempTable;

        -- Calcular la cantidad total de los componentes del líquido
        SELECT @cantidad_total_componentes = SUM(cantidad_liquido_componente_lts)
        FROM OPENJSON(@composicion_liquidos_json)
        WITH
        (
            id_contenedor_componente INT '$.id_contenedor_componente',
            cantidad_liquido_componente_lts DECIMAL(10, 2) '$.cantidad_liquido_componente_lts'
        );

        -- Sumar la cantidad en el contenedor de destino a la cantidad total de componentes
        DECLARE @cantidad_generada_lts DECIMAL(10, 2);
        SET @cantidad_generada_lts = @cantidad_total_componentes + ISNULL(@cantidad_liquido_destino, 0);

        IF EXISTS (SELECT 1 FROM contenedores WHERE id_contenedor = @id_contenedor_destino AND id_estatus = 2)
        BEGIN
            UPDATE contenedores
            SET id_estatus = 1
            WHERE id_contenedor = @id_contenedor_destino;
        END

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

        -- Process the JSON to insert into combinaciones_detalle table
        DECLARE @id_contenedor_componente INT;
        DECLARE @cantidad_liquido_componente_lts DECIMAL(10, 2);

        DECLARE cur CURSOR FOR
        SELECT 
            id_contenedor_componente,
            cantidad_liquido_componente_lts
        FROM 
            OPENJSON(@composicion_liquidos_json)
        WITH
        (
            id_contenedor_componente INT '$.id_contenedor_componente',
            cantidad_liquido_componente_lts DECIMAL(10, 2) '$.cantidad_liquido_componente_lts'
        );

        OPEN cur;

        FETCH NEXT FROM cur INTO @id_contenedor_componente, @cantidad_liquido_componente_lts;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Crear una tabla temporal para almacenar el resultado de sp_obtener_datos_validos_liquido_contenedor
            DECLARE @resultado TABLE (
                id_liquido INT,
                codigo_liquido VARCHAR(255), 
                cantidad_liquido_dentro_lts DECIMAL(10, 2),
                ultimo_id_liquido_contenedor INT
            );

            -- Insertar los resultados del procedimiento en la tabla temporal
            INSERT INTO @resultado
            EXEC sp_obtener_datos_validos_liquido_contenedor @id_contenedor = @id_contenedor_componente;

            -- Obtener el id_liquido de la tabla temporal
            SELECT @id_liquido_componente = id_liquido
            FROM @resultado;

            -- Verificar que el id_liquido_componente no sea NULL
            IF @id_liquido_componente IS NULL
            BEGIN
                ROLLBACK TRANSACTION;
                THROW 50001, 'Error: El id_liquido obtenido es NULL o no válido.', 1;
            END

            -- Insert into combinaciones_detalle
            INSERT INTO combinaciones_detalle
            (
                id_combinacion,
                id_liquido,
                cantidad_lts
            )
            VALUES
            (
                @id_combinacion,
                @id_liquido_componente,
                @cantidad_liquido_componente_lts
            );

            FETCH NEXT FROM cur INTO @id_contenedor_componente, @cantidad_liquido_componente_lts;
        END;

        CLOSE cur;
        DEALLOCATE cur;

        -- Update the quantities in the containers
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
            cantidad_liquido_componente_lts DECIMAL (10, 2) '$.cantidad_liquido_componente_lts'
        ) c ON t.id_contenedor = c.id_contenedor_componente AND t.id_liquido = @id_liquido_componente;

        -- Insert the combined liquid in the destination container
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

        -- Commit the transaction if everything is successful
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If there is an error, rollback the transaction
        ROLLBACK TRANSACTION;

        -- Raise the error again to the caller
        THROW;
    END CATCH;
END;
GO

IF OBJECT_ID('dbo.sp_insertar_liquido_combinado_c', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_insertar_liquido_combinado_c;
GO

CREATE PROCEDURE sp_insertar_liquido_combinado_c
    @nombre VARCHAR(32),
    @id_tipo INT,
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

    -- Begin the transaction
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @id_liquido_combinado INT;
        DECLARE @id_combinacion INT;
        DECLARE @id_liquido_componente INT;
        DECLARE @cantidad_total_componentes DECIMAL(10, 2) = 0;
        DECLARE @cantidad_liquido_destino DECIMAL(10, 2);

        -- Obtener la cantidad de líquido actual en el contenedor de destino
        CREATE TABLE #TempTable (
            id_liquido_contendor INT,
            id_liquido INT,
            cantidad_liquido_lts DECIMAL(18, 2),
            capacidad_lts DECIMAL(18, 2),
            codigo VARCHAR(50),
            descripcion VARCHAR(100)
        );

        -- Insertamos los resultados del procedimiento almacenado en la tabla temporal
        INSERT INTO #TempTable
        EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor_destino;

        SELECT @cantidad_liquido_destino = cantidad_liquido_lts
        FROM #TempTable;

        -- Calcular la cantidad total de los componentes del líquido
        SELECT @cantidad_total_componentes = SUM(cantidad_liquido_componente_lts)
        FROM OPENJSON(@composicion_liquidos_json)
        WITH
        (
            id_contenedor_componente INT '$.id_contenedor_componente',
            cantidad_liquido_componente_lts DECIMAL(10, 2) '$.cantidad_liquido_componente_lts'
        );

        -- Sumar la cantidad en el contenedor de destino a la cantidad total de componentes
        DECLARE @cantidad_generada_lts DECIMAL(10, 2);
        SET @cantidad_generada_lts = @cantidad_total_componentes

        IF EXISTS (SELECT 1 FROM contenedores WHERE id_contenedor = @id_contenedor_destino AND id_estatus = 2)
        BEGIN
            UPDATE contenedores
            SET id_estatus = 1
            WHERE id_contenedor = @id_contenedor_destino;
        END

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

        -- Process the JSON to insert into combinaciones_detalle table
        DECLARE @id_contenedor_componente INT;
        DECLARE @cantidad_liquido_componente_lts DECIMAL(10, 2);

        DECLARE cur CURSOR FOR
        SELECT 
            id_contenedor_componente,
            cantidad_liquido_componente_lts
        FROM 
            OPENJSON(@composicion_liquidos_json)
        WITH
        (
            id_contenedor_componente INT '$.id_contenedor_componente',
            cantidad_liquido_componente_lts DECIMAL(10, 2) '$.cantidad_liquido_componente_lts'
        );

        OPEN cur;

        FETCH NEXT FROM cur INTO @id_contenedor_componente, @cantidad_liquido_componente_lts;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Crear una tabla temporal para almacenar el resultado de sp_obtener_datos_validos_liquido_contenedor
            DECLARE @resultado TABLE (
                id_liquido INT,
                codigo_liquido VARCHAR(255), 
                cantidad_liquido_dentro_lts DECIMAL(10, 2),
                ultimo_id_liquido_contenedor INT
            );

            -- Insertar los resultados del procedimiento en la tabla temporal
            INSERT INTO @resultado
            EXEC sp_obtener_datos_validos_liquido_contenedor @id_contenedor = @id_contenedor_componente;

            -- Obtener el id_liquido de la tabla temporal
            SELECT @id_liquido_componente = id_liquido
            FROM @resultado;

            -- Verificar que el id_liquido_componente no sea NULL
            IF @id_liquido_componente IS NULL
            BEGIN
                ROLLBACK TRANSACTION;
                THROW 50001, 'Error: El id_liquido obtenido es NULL o no válido.', 1;
            END

            -- Insert into combinaciones_detalle
            INSERT INTO combinaciones_detalle
            (
                id_combinacion,
                id_liquido,
                cantidad_lts
            )
            VALUES
            (
                @id_combinacion,
                @id_liquido_componente,
                @cantidad_liquido_componente_lts
            );

            -- Update the quantities in the containers
            UPDATE 
                t
            SET 
                t.cantidad_liquido_lts = t.cantidad_liquido_lts - @cantidad_liquido_componente_lts
            FROM
                transacciones_liquido_contenedor t
            WHERE
                t.id_contenedor = @id_contenedor_componente AND t.id_liquido = @id_liquido_componente;

            -- Fetch the next component
            FETCH NEXT FROM cur INTO @id_contenedor_componente, @cantidad_liquido_componente_lts;
        END;

        CLOSE cur;
        DEALLOCATE cur;

        -- Insert the combined liquid in the destination container
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

        -- Commit the transaction if everything is successful
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If there is an error, rollback the transaction
        ROLLBACK TRANSACTION;

        -- Raise the error again to the caller
        THROW;
    END CATCH;
END;
GO

EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 6;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 8;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 9;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 10;

EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 11;
SELECT * FROM transacciones_liquido_contenedor;
SELECT * FROM liquidos;

EXEC sp_insertar_liquido_combinado_c
    @nombre = 'LIQUIDO COMBINADO 6->7',
    @id_tipo = 2,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1021,
    @id_estatus = 2,
    @id_contenedor_destino = 7,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 6,
            "cantidad_liquido_componente_lts": 2500.00
        },
        {
            "id_contenedor_componente": 7,
            "cantidad_liquido_componente_lts": 20000.00
        }
        ]';

EXEC sp_insertar_liquido_combinado_c
    @nombre = 'LIQUIDO COMBINADO 8->9->10',
    @id_tipo = 2,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1022,
    @id_estatus = 2,
    @id_contenedor_destino = 10,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 8,
            "cantidad_liquido_componente_lts": 2500.00
        },
        {
            "id_contenedor_componente": 9, 
            "cantidad_liquido_componente_lts": 3000.00
        },
                {
            "id_contenedor_componente": 10, 
            "cantidad_liquido_componente_lts": 3000.00
        }
        ]';

EXEC sp_insertar_liquido_combinado_c
    @nombre = 'LIQUIDO COMBINADO 7->10->11',
    @id_tipo = 2,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1023,
    @id_estatus = 2,
    @id_contenedor_destino = 11,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 7,
            "cantidad_liquido_componente_lts": 2500.00
        },
        {
            "id_contenedor_componente": 10, 
            "cantidad_liquido_componente_lts": 10000.00
        },
        {
            "id_contenedor_componente": 11, 
            "cantidad_liquido_componente_lts": 10000.00
        }
        ]';

EXEC sp_insertar_liquido_combinado_c
    @nombre = 'LIQUIDO COMBINADO 12->13->14->15',
    @id_tipo = 2,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1024,
    @id_estatus = 2,
    @id_contenedor_destino = 15,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 12,
            "cantidad_liquido_componente_lts": 2500.00
        },
        {
            "id_contenedor_componente": 13, 
            "cantidad_liquido_componente_lts": 2000.00
        },
        {
            "id_contenedor_componente": 14, 
            "cantidad_liquido_componente_lts": 2000.00
        },
        {
            "id_contenedor_componente": 15, 
            "cantidad_liquido_componente_lts": 2000.00
        }
        ]';

EXEC sp_insertar_liquido_combinado_c
    @nombre = 'LIQUIDO COMBINADO 11->15',
    @id_tipo = 2,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1025,
    @id_estatus = 2,
    @id_contenedor_destino = 15,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 11,
            "cantidad_liquido_componente_lts": 2500.00
        },
        {
            "id_contenedor_componente": 15,
            "cantidad_liquido_componente_lts": 2500.00
        }
        ]';

SELECT * FROM transacciones_liquido_contenedor;
SELECT * FROM liquidos;
EXEC sp_obtener_trazabilidad_liquido_t @id_contenedor_b = 15;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 15;

EXEC sp_insertar_liquido_combinado_p
    @nombre = 'LIQUIDO COMBINADO 11->13',
    @id_tipo = 2,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1011,
    @id_estatus = 2,
    @id_contenedor_destino = 15,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 11,
            "cantidad_liquido_componente_lts": 1000.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 6->7',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1011,
    @id_estatus = 2,
    @id_contenedor_destino = 19,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 6, 
            "cantidad_liquido_componente_lts": 70.00
        }, 
        {
            "id_contenedor_componente": 7, 
            "cantidad_liquido_componente_lts": 30.00
        }
        ]';

EXEC sp_insertar_liquido_combinado_p
    @nombre = 'LIQUIDO COMBINADO 8->9->10',
    @id_tipo = 2,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1012,
    @id_estatus = 2,
    @id_contenedor_destino = 10,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 8,
            "cantidad_liquido_componente_lts": 50.00
        }, 
        {
            "id_contenedor_componente": 9,
            "cantidad_liquido_componente_lts": 50.00
        },
        {
            "id_contenedor_componente": 10,
            "cantidad_liquido_componente_lts": 50.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 7->10',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1013,
    @id_estatus = 2,
    @id_contenedor_destino = 10,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 7,
            "cantidad_liquido_componente_lts": 100.00
        }, 
        {
            "id_contenedor_componente": 10, 
            "cantidad_liquido_componente_lts": 150.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 6->8',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1014,
    @id_estatus = 2,
    @id_contenedor_destino = 8,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 6,
            "cantidad_liquido_componente_lts": 200.00
        }, 
        {
            "id_contenedor_componente": 8,
            "cantidad_liquido_componente_lts": 500.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 8->10',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1015,
    @id_estatus = 2,
    @id_contenedor_destino = 10,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 8,
            "cantidad_liquido_componente_lts": 50.00
        }, 
        {
            "id_contenedor_componente": 10, 
            "cantidad_liquido_componente_lts": 150.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 12->13',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1016,
    @id_estatus = 2,
    @id_contenedor_destino = 13,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 12,
            "cantidad_liquido_componente_lts": 10.00
        }, 
        {
            "id_contenedor_componente": 13,
            "cantidad_liquido_componente_lts": 250.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 14->15',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1017,
    @id_estatus = 2,
    @id_contenedor_destino = 15,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 14,
            "cantidad_liquido_componente_lts": 40.00
        }, 
        {
            "id_contenedor_componente": 15,
            "cantidad_liquido_componente_lts": 900.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 15->13',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1018,
    @id_estatus = 2,
    @id_contenedor_destino = 13,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 13,
            "cantidad_liquido_componente_lts": 150.00
        }, 
        {
            "id_contenedor_componente": 15,
            "cantidad_liquido_componente_lts": 150.00
        }
        ]';

EXEC sp_insertar_liquido_combinado
    @nombre = 'LIQUIDO COMBINADO 13->10',
    @id_tipo = 2,
    @cantidad_generada_lts = 1000.00,
    @id_proveedor = 3,
    @metanol = 10.15,
    @alcoholes_sup = 0.1,
    @porcentaje_alcohol_vol = 40.60,
    @orden_produccion = 1019,
    @id_estatus = 2,
    @id_contenedor_destino = 10,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json = 
        N'[
        {
            "id_contenedor_componente": 13,
            "cantidad_liquido_componente_lts": 45.00
        }, 
        {
            "id_contenedor_componente": 10,
            "cantidad_liquido_componente_lts": 80.00
        }
        ]';


EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 13;
EXEC sp_obtener_datos_validos_liquido_contenedor @id_contenedor = 13;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_trazabilidad_liquido_t', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_trazabilidad_liquido_t;
GO

CREATE PROCEDURE sp_obtener_trazabilidad_liquido_t
    @id_contenedor_b INT
AS
BEGIN
    -- id_liquido INT,
    --     codigo_liquido VARCHAR(32),
    --     cantidad_liquido_dentro_lts DECIMAL(18, 2),
    --     ultimo_id_liquido_contenedor INT
    CREATE TABLE #TempTable (
       id_liquido_contendor INT, -- CAMBIAR EL NOMBRE DE ESTA COLUMNAAAAAAA ------------------------------------------------------------------
       id_liquido INT,
       cantidad_liquido_lts DECIMAL(18, 2),
       capacidad_lts DECIMAL(18, 2),
       codigo VARCHAR(32),
       descripcion VARCHAR(32)
    );

    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor_b;

    DECLARE @id_liquido_c INT;
    SELECT @id_liquido_c = id_liquido FROM #TempTable;

    WITH CTE_trazabilidad AS (
        SELECT
            t.id_combinacion,
            l.fecha_produccion,
            l.id_liquido AS id_liquido_combinado,
            l.codigo AS codigo_liquido_combinado,
            l.id_tipo AS tipo_liquido_combinado,
            l.orden_produccion,
            td.id_liquido AS id_liquido_componente,
            lc.codigo AS codigo_componente,
            lc.id_tipo AS tipo_componente,
            td.cantidad_lts,
            1 AS nivel,
            ROW_NUMBER() OVER (ORDER BY t.id_combinacion) AS traza  -- Asignar traza a nivel 0
        FROM 
            combinaciones t
        JOIN
            combinaciones_detalle td ON t.id_combinacion = td.id_combinacion
        JOIN
            liquidos l ON t.id_liquido_combinado = l.id_liquido
        JOIN
            liquidos lc ON td.id_liquido = lc.id_liquido
        WHERE
            l.id_liquido = @id_liquido_c  -- Cambiado a @id_liquido_c
        
        UNION ALL

        SELECT
            t.id_combinacion,
            l.fecha_produccion,
            l.id_liquido AS id_liquido_combinado,
            l.codigo AS codigo_liquido_combinado,
            l.id_tipo AS tipo_liquido_combinado,
            l.orden_produccion,
            td.id_liquido AS id_liquido_componente,
            lc.codigo AS codigo_componente,
            lc.id_tipo AS tipo_componente,
            td.cantidad_lts,
            cte.nivel + 1,
            cte.traza  -- Propagar la traza del nivel superior
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
    ORDER BY nivel, id_combinacion, id_liquido_combinado, id_liquido_componente;
END;
GO

EXEC sp_obtener_trazabilidad_liquido_t @id_contenedor_b = 15;

SELECT * FROM transacciones_liquido_contenedor;

EXEC sp_actualizar_estatus_liquido 
    @id_contenedor = 6, 
    @id_nuevo_estatus = 4;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_datos_contenedor_liquido', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_contenedor_liquido;
GO

CREATE PROCEDURE dbo.sp_obtener_datos_contenedor_liquido
    @id_contenedor INT
AS
BEGIN
    SELECT TOP 1
        t.id_liquido_contendor,
        l.id_liquido,
        t.cantidad_liquido_lts,
        tc.capacidad_lts,
        l.codigo,
        e.descripcion
    FROM
        transacciones_liquido_contenedor t
    JOIN
        contenedores c ON c.id_contenedor = t.id_contenedor
    JOIN
        tipos_contenedor tc ON tc.id_tipo_contenedor = c.id_tipo
    JOIN
        liquidos l ON l.id_liquido = t.id_liquido
    JOIN
        estatus_liquido e ON e.id_estatus_liquido = t.id_estatus
    WHERE
        c.id_contenedor = @id_contenedor
    ORDER BY 
        t.id_liquido_contendor DESC;
END;
GO

EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 10;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_insertar_producto_terminado', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_insertar_producto_terminado;
GO

CREATE PROCEDURE sp_insertar_producto_terminado
    @id_contenedor INT,
    @cantidad_terminada_lts INT,
    @persona_encargada VARCHAR(32)
AS
BEGIN
    -- Variable para almacenar el id_liquido y la cantidad actual de líquido
    DECLARE @id_liquido_dentro INT;
    DECLARE @cantidad_restante_lts INT;

    -- Obtener el id_liquido más reciente del contenedor especificado
    SELECT TOP 1
        @id_liquido_dentro = t.id_liquido
    FROM 
        transacciones_liquido_contenedor t
    WHERE
        t.id_contenedor = @id_contenedor
    ORDER BY 
        t.id_liquido_contendor DESC;

    -- Actualizar la cantidad de líquido en el contenedor
    UPDATE
        transacciones_liquido_contenedor
    SET 
        cantidad_liquido_lts = cantidad_liquido_lts - @cantidad_terminada_lts
    WHERE
        id_contenedor = @id_contenedor
        AND id_liquido = @id_liquido_dentro;

    -- Obtener la cantidad restante después de la actualización
    SELECT @cantidad_restante_lts = cantidad_liquido_lts
    FROM 
        transacciones_liquido_contenedor
    WHERE
        id_contenedor = @id_contenedor
        AND id_liquido = @id_liquido_dentro;

    -- Si la cantidad restante es igual a 0, actualizar el estado del contenedor
    IF @cantidad_restante_lts = 0
    BEGIN
        -- Llamar al procedimiento almacenado para actualizar el estatus
        EXEC sp_actualizar_estatus_contenedor 
            @id_contenedor = @id_contenedor, 
            @id_nuevo_estatus = 2;
    END

    -- Insertar los datos en la tabla productos_terminados
    INSERT INTO productos_terminados
    (
        id_liquido,
        cantidad_liquido_terminada_lts,
        persona_encargada
    )
    VALUES
    (
        @id_liquido_dentro,
        @cantidad_terminada_lts,
        @persona_encargada
    );
END;
GO

EXEC sp_insertar_producto_terminado 
    @id_contenedor = 15,
    @cantidad_terminada_lts = 850,
    @persona_encargada = 'manolo@gmail.com';

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_ obtener_tipos_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_tipos_contenedor;
GO

CREATE PROCEDURE sp_obtener_tipos_contenedor
AS
BEGIN
    SELECT * FROM tipos_contenedor;
END;
GO

EXEC sp_obtener_tipos_contenedor;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_ubicaciones_contenedor', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_ubicaciones_contenedor;
GO

CREATE PROCEDURE sp_obtener_ubicaciones_contenedor
AS
BEGIN
    SELECT * FROM ubicaciones_contenedor;
END;
GO

EXEC sp_obtener_ubicaciones_contenedor;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_estatus_contenedor', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_estatus_contenedor;
GO

CREATE PROCEDURE sp_obtener_estatus_contenedor
AS
BEGIN
    SELECT * FROM estatus_contenedor;
END;
GO

EXEC sp_obtener_estatus_contenedor;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_insertar_contenedor', 'P') IS NOT NULL
DROP PROCEDURE sp_insertar_contenedor;
GO

CREATE PROCEDURE sp_insertar_contenedor
    @nombre VARCHAR(32),
    @id_tipo INT,
    @id_ubicacion INT,
    @id_estatus INT
AS
BEGIN
    -- Insertar el nuevo registro en la tabla 'contenedores'
    INSERT INTO contenedores
    (
        nombre,
        id_tipo,
        id_ubicacion,
        id_estatus
    )
    VALUES
    (
        @nombre,
        @id_tipo,
        @id_ubicacion,
        @id_estatus
    );

    -- Devolver la ID del nuevo contenedor
    SELECT SCOPE_IDENTITY() AS id_contenedor;
END;
GO

EXEC sp_insertar_contenedor
    @nombre = 'TANQUE W',
    @id_tipo = 5,
    @id_ubicacion = 5,
    @id_estatus = 2;

-- -- Drop the procedure if it exists
-- IF OBJECT_ID('dbo.sp_actualizar_estatus_contenedor_x', 'P') IS NOT NULL
--     DROP PROCEDURE sp_actualizar_estatus_contenedor_x;
-- GO

-- CREATE PROCEDURE sp_actualizar_estatus_contenedor_x
--     @id_contenedor INT
-- AS
-- BEGIN
--     -- Crear una tabla temporal para almacenar los resultados del procedimiento
--     DECLARE @tempTable TABLE (
--         cantidad_luiquido_lts DECIMAL(18, 2),
--         capacidad_lts DECIMAL(18, 2),
--         codigo NVARCHAR(100),
--         descripcion NVARCHAR(255)
--     );

--     -- Insertar los datos del procedimiento en la tabla temporal
--     INSERT INTO @tempTable
--     EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

--     -- Verificar si la cantidad de líquido es menor a 1
--     IF NOT EXISTS (SELECT 1 FROM @tempTable WHERE cantidad_luiquido_lts < 1)
--     BEGIN
--         -- Lanzar un error si la cantidad no es menor a 1
--         RAISERROR('La cantidad de líquido no es menor a 1 lts.', 16, 1);
--         RETURN;
--     END;

--     -- Actualizar el estatus del contenedor directamente
--     UPDATE contenedores
--     SET id_estatus = 3
--     WHERE id_contenedor = @id_contenedor;
-- END;
-- GO

-- EXEC sp_actualizar_estatus_contenedor @id_contenedor = 13;

SELECT * FROM estatus_contenedor;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_contenedores_disponibles', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_contenedores_disponibles;
GO

CREATE PROCEDURE sp_obtener_contenedores_disponibles
AS
BEGIN
    SELECT * FROM contenedores WHERE id_estatus <> 3 AND fecha_baja IS NULL;
END;
GO

EXEC sp_obtener_contenedores_disponibles;

-- Drop the procedure if it exists
DROP VIEW vw_obtener_datos_contenedor_liquido;
GO
CREATE VIEW vw_obtener_datos_contenedor_liquido
AS
WITH LiquidoOrdenado AS (
    SELECT
        t.id_contenedor,
        l.id_liquido,
        t.cantidad_liquido_lts,
        tc.capacidad_lts,
        l.codigo,
        e.descripcion,
        t.id_estatus,
        ROW_NUMBER() OVER (PARTITION BY t.id_contenedor ORDER BY t.id_liquido_contendor DESC) AS rn
    FROM
        transacciones_liquido_contenedor t
    JOIN
        contenedores c ON c.id_contenedor = t.id_contenedor
    JOIN
        tipos_contenedor tc ON tc.id_tipo_contenedor = c.id_tipo
    JOIN
        liquidos l ON l.id_liquido = t.id_liquido
    JOIN
        estatus_liquido e ON e.id_estatus_liquido = t.id_estatus
)
SELECT
    id_contenedor,
    id_liquido,
    cantidad_liquido_lts,
    capacidad_lts,
    codigo,
    descripcion,
    id_estatus
FROM
    LiquidoOrdenado
WHERE
    rn = 1; -- Nos quedamos solo con el registro más reciente por contenedor
GO

SELECT * FROM vw_obtener_datos_contenedor_liquido;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_contenedores_ex_nd', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_contenedores_ex_nd;
GO

CREATE PROCEDURE sp_obtener_contenedores_ex_nd
AS
BEGIN
    -- Seleccionamos todos los contenedores activos y hacemos un JOIN con la vista que contiene los datos del líquido
    SELECT 
        c.id_contenedor,
        c.nombre,
        c.id_tipo,
        c.id_ubicacion,
        c.fecha_alta,
        c.fecha_baja,
        c.id_estatus AS id_estatus_contenedor,
        e.descripcion AS descripcion_estatus_contenedor,
        l.id_liquido,
        l.cantidad_liquido_lts,
        l.capacidad_lts,
        l.codigo,
        l.descripcion AS descripcion_estatus_liquido,
        l.id_estatus AS id_estatus_liquido
    FROM 
        contenedores c
    JOIN
        estatus_contenedor e ON c.id_estatus = e.id_estatus_contenedor
    LEFT JOIN 
        vw_obtener_datos_contenedor_liquido l
    ON 
        c.id_contenedor = l.id_contenedor
    WHERE 
        c.id_estatus <> 3
        AND c.fecha_baja IS NULL;
END;
GO

EXEC sp_obtener_contenedores_ex_nd;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_actualizar_estatus_contenedor', 'P') IS NOT NULL
    DROP PROCEDURE sp_actualizar_estatus_contenedor;
GO

CREATE PROCEDURE sp_actualizar_estatus_contenedor
    @id_contenedor INT,
    @id_nuevo_estatus INT
AS
BEGIN
    -- Crear la tabla temporal para almacenar los resultados
    CREATE TABLE #TempTable (
        id_liquido_contenedor INT,
        id_liquido INT,
        cantidad_liquido_lts DECIMAL(18, 2),
        capacidad_lts DECIMAL(18, 2),
        codigo VARCHAR(50),
        descripcion VARCHAR(100)
    );

    -- Insertar los resultados del procedimiento almacenado en la tabla temporal
    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

    -- Verificar si la cantidad de líquido es mayor a 0 o no está definida
    IF EXISTS (
        SELECT 1
        FROM #TempTable
        WHERE ISNULL(cantidad_liquido_lts, 0) > 0
    )
    BEGIN
        RAISERROR('El contenedor con ID %d no está vacío.', 16, 1, @id_contenedor);
        RETURN;
    END

    -- Si el contenedor está vacío, actualizar el estatus
    UPDATE contenedores
    SET id_estatus = @id_nuevo_estatus
    WHERE id_contenedor = @id_contenedor;

    -- Eliminar la tabla temporal
    DROP TABLE #TempTable;
END;
GO

SELECT * FROM estatus_contenedor;
SELECT * FROM transacciones_liquido_contenedor;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 15;
SELECT * FROM contenedores;

EXEC sp_actualizar_estatus_contenedor
    @id_contenedor = 15,
    @id_nuevo_estatus = 3;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_actualizar_estatus_liquido', 'P') IS NOT NULL
DROP PROCEDURE sp_actualizar_estatus_liquido;
GO

CREATE PROCEDURE sp_actualizar_estatus_liquido
    @id_contenedor INT,
    @id_nuevo_estatus INT
AS
BEGIN
    -- Creamos una tabla temporal para almacenar los resultados del procedimiento almacenado
    CREATE TABLE #TempTable (
        id_liquido_contendor INT,
        id_liquido INT,
        cantidad_liquido_lts DECIMAL(18, 2),
        capacidad_lts DECIMAL(18, 2),
        codigo VARCHAR(50),
        descripcion VARCHAR(100)
    );

    -- Insertamos los resultados del procedimiento almacenado en la tabla temporal
    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

    -- Declaramos una variable para almacenar el id_liquido_contendor
    DECLARE @id_liquido_contendor INT;

    -- Asignamos el valor de id_liquido_contendor desde la tabla temporal
    SELECT TOP 1 @id_liquido_contendor = id_liquido_contendor FROM #TempTable;

    -- Actualizamos el estatus en la tabla transacciones_liquido_contenedor
    UPDATE
        transacciones_liquido_contenedor
    SET
        id_estatus = @id_nuevo_estatus
    WHERE
        id_liquido_contendor = @id_liquido_contendor;

    -- Eliminamos la tabla temporal
    DROP TABLE #TempTable;
END;
GO

EXEC sp_actualizar_estatus_liquido
    @id_contenedor = 10,
    @id_nuevo_estatus = 1;

SELECT * FROM liquidos;
SELECT * FROM transacciones_liquido_contenedor;

EXEC sp_insertar_liquido_combinado
    @nombre = 'PRUEBA D',
    @id_tipo = 2,
    @cantidad_generada_lts = 500.0,
    @id_proveedor = 3,
    @metanol = 20,
    @alcoholes_sup = 10.30,
    @porcentaje_alcohol_vol = 50.0,
    @orden_produccion = 1045,
    @id_estatus = 2,
    @id_contenedor_destino = 13,
    @persona_encargada = 'manolo@gmail.com',
    @composicion_liquidos_json =
        N'[
        {
            "id_contenedor_componente": 15,
            "cantidad_liquido_componente_lts": 500.00
        }
        ]';

EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 15;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 13;


IF OBJECT_ID('dbo.sp_obtener_liquidos_base', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_liquidos_base;
GO

-- Drop procedure if exists
CREATE PROCEDURE sp_obtener_liquidos_base
AS
BEGIN
    SELECT * FROM liquidos_base_com;
END;
GO

EXEC sp_obtener_liquidos_base;

SELECT * FROM tipo_liquido;
SELECT * FROM liquidos;
SELECT * FROM liquidos_base_com;

EXEC sp_obtener_datos_contenedor @id_contenedor = 13;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 13;

-- Drop the procedure if it exists
IF OBJECT_ID('dbo.sp_obtener_datos_contenedor_vacio', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_contenedor_vacio;
GO

-- Create the stored procedure to get the data from one container -- PARA VACIAR SOLO UN PROCEDURE O QUE NO TENGA NADA O QUE SEA LA PRIMER DE LA LISTA DE LIQUIDOS
CREATE PROCEDURE sp_obtener_datos_contenedor_vacio
    @id_contenedor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el contenedor existe y es un contenedor con un estatus válido
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

    -- Crear la tabla temporal para almacenar los resultados
    CREATE TABLE #TempTable (
        id_liquido_contenedor INT,
        id_liquido INT,
        cantidad_liquido_lts DECIMAL(18, 2),
        capacidad_lts DECIMAL(18, 2),
        codigo VARCHAR(50),
        descripcion VARCHAR(100)
    );

    -- Insertar los resultados del procedimiento almacenado en la tabla temporal
    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

    -- Verificar si la cantidad de líquido es 0 o NULL
    IF EXISTS (
        SELECT 1
        FROM #TempTable
        WHERE cantidad_liquido_lts > 0
    )
    BEGIN
        RAISERROR('El contenedor con ID %d no está vacío.', 16, 1, @id_contenedor);
        RETURN;
    END

    -- Si el contenedor está vacío o la cantidad es NULL, seleccionar los datos del contenedor
    SELECT
        c.id_contenedor, 
        c.nombre,
        c.id_estatus,
        t.capacidad_lts -- Asumiendo que capacidad_lts está en la tabla tipos_contenedor
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

EXEC sp_obtener_datos_contenedor_vacio @id_contenedor = 15;

SELECT * FROM transacciones_liquido_contenedor;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 15;

EXEC sp_insertar_producto_terminado 
    @id_contenedor = 15,
    @cantidad_terminada_lts = 2700,
    @persona_encargada = 'manolo@gmail.com';


SELECT * FROM transacciones_liquido_contenedor;
EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 15;
EXEC sp_obtener_trazabilidad_liquido_t @id_contenedor_b = 15;

SELECT * FROM combinaciones;

IF OBJECT_ID('dbo.sp_obtener_info_contenedor_liquido', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_info_contenedor_liquido;
GO

CREATE PROCEDURE sp_obtener_info_contenedor_liquido
    @id_contenedor INT
AS
BEGIN
    -- Validación para verificar si el contenedor existe
    IF NOT EXISTS (
        SELECT 1 
        FROM contenedores 
        WHERE id_contenedor = @id_contenedor
    )
    BEGIN
        -- Si el contenedor no existe, se lanza un error personalizado
        RAISERROR('El contenedor con ID %d no existe.', 16, 1, @id_contenedor);
        RETURN;
    END

    -- Validación para verificar si el contenedor está relacionado con algún líquido
    IF NOT EXISTS (
        SELECT 1 
        FROM transacciones_liquido_contenedor 
        WHERE id_contenedor = @id_contenedor
    )
    BEGIN
        -- Si el contenedor no está relacionado con ningún líquido, se lanza un error personalizado
        RAISERROR('El contenedor con ID %d no está relacionado con ningún líquido.', 16, 1, @id_contenedor);
        RETURN;
    END

    -- Si las validaciones pasan, continúa con la consulta
    SELECT TOP 1
        t.id_liquido_contendor,
        t.id_estatus,
        l.id_liquido,
        l.cantidad_total_lts,
        l.fecha_produccion,
        l.orden_produccion,
        t.cantidad_liquido_lts,
        l.id_tipo,
        tc.capacidad_lts,
        l.codigo,
        e.descripcion
    FROM
        transacciones_liquido_contenedor t
    JOIN
        contenedores c ON c.id_contenedor = t.id_contenedor
    JOIN
        tipos_contenedor tc ON tc.id_tipo_contenedor = c.id_tipo
    JOIN
        liquidos l ON l.id_liquido = t.id_liquido
    JOIN
        estatus_liquido e ON e.id_estatus_liquido = t.id_estatus
    WHERE
        c.id_contenedor = @id_contenedor
    ORDER BY 
        t.id_liquido_contendor DESC;
END;
GO

EXEC sp_obtener_info_contenedor_liquido @id_contenedor = 15;
EXEC sp_obtener_info_contenedor_liquido @id_contenedor = 9;

SELECT * FROM liquidos;

SELECT * FROM contenedores;


SELECT * FROM transacciones_liquido_contenedor;
SELECT * FROM liquidos;

EXEC sp_actualizar_estatus_liquido @id_contenedor = 6, @id_nuevo_estatus = 4;

EXEC sp_obtener_datos_contenedor_vacio @id_contenedor = 6;

EXEC sp_actualizar_estatus_contenedor @id_contenedor = 15, @id_nuevo_estatus  = 2;

EXEC sp_obtener_datos_contenedor_vacio @id_contenedor = 15;

SELECT * FROM transacciones_liquido_contenedor;

EXEC sp_actualizar_estatus_liquido @id_contenedor = 15, @id_nuevo_estatus = 4;

EXEC sp_obtener_datos_validos_liquido_contenedor @id_contenedor = 14;

EXEC sp_obtener_datos_contenedor @id_contenedor = 14;

EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = 15;

SELECT * FROM estatus_contenedor;

SELECT * FROM contenedores;


EXEC sp_insertar_producto_terminado 
    @id_contenedor = 15,
    @cantidad_terminada_lts = 50000,
    @persona_encargada = 'manolo@gmail.com';

IF OBJECT_ID('dbo.sp_eliminar_contenedor', 'P') IS NOT NULL
    DROP PROCEDURE sp_eliminar_contenedor;
GO

CREATE PROCEDURE sp_eliminar_contenedor
    @id_contenedor INT,
    @id_nuevo_estatus INT
AS
BEGIN
    -- Crear la tabla temporal para almacenar los resultados
    CREATE TABLE #TempTable (
        id_liquido_contenedor INT,
        id_liquido INT,
        cantidad_liquido_lts DECIMAL(18, 2),
        capacidad_lts DECIMAL(18, 2),
        codigo VARCHAR(50),
        descripcion VARCHAR(100)
    );

    -- Insertar los resultados del procedimiento almacenado en la tabla temporal
    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

    -- Verificar si la cantidad de líquido es mayor a 0 o no está definida
    IF EXISTS (
        SELECT 1
        FROM #TempTable
        WHERE ISNULL(cantidad_liquido_lts, 0) > 0
    )
    BEGIN
        RAISERROR('El contenedor con ID %d no está vacío.', 16, 1, @id_contenedor);
        RETURN;
    END

    -- Si el contenedor está vacío, actualizar el estatus
    UPDATE contenedores
    SET id_estatus = @id_nuevo_estatus,
    fecha_baja = GETDATE()
    WHERE id_contenedor = @id_contenedor;

    -- Eliminar la tabla temporal
    DROP TABLE #TempTable;
END;
GO