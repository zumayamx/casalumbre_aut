-- Use this database;
USE casalumbre_db;

------------------------- PROCEDIMIENTOS ALMACENADOS PARA LA FUNCIÓN AÑADIR EN POWER APPS -------------------------------

-- Procedimiento para obtener todos los liquidos base más solicitados
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





-- Procecimiento para obtener los datos de un contenedor si este esta vacío
IF OBJECT_ID('dbo.sp_obtener_datos_contenedor_vacio', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_contenedor_vacio;
GO

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

    -- Declarar variable para almacenar la cantidad de líquido
    DECLARE @cantidad_liquido DECIMAL(18, 2);

    -- Asignar la cantidad de líquido a la variable
    SELECT @cantidad_liquido = cantidad_liquido_lts FROM #TempTable;

    -- Si el contenedor está vacío o la cantidad es NULL, seleccionar los datos del contenedor
    SELECT
        c.id_contenedor, 
        c.nombre,
        c.id_estatus,
        t.capacidad_lts, -- Asumiendo que capacidad_lts está en la tabla tipos_contenedor
        @cantidad_liquido AS cantidad_liquido
    FROM 
        contenedores c
    JOIN 
        tipos_contenedor t ON c.id_tipo = t.id_tipo_contenedor
    WHERE 
        c.id_contenedor = @id_contenedor
        AND c.fecha_baja IS NULL
        AND c.id_estatus < 3;

    -- Limpiar la tabla temporal
    DROP TABLE #TempTable;

END;
GO





-- Procedimeinto para insertar un nuevo liquido
IF OBJECT_ID('dbo.sp_insertar_liquido', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_insertar_liquido;
GO

CREATE PROCEDURE sp_insertar_liquido
    @codigo VARCHAR(32),
    @id_tipo INT,
    @cantidad_total_lts DECIMAL(10, 2),
    @id_proveedor INT,
    @metanol_mg_100mlAA DECIMAL(5,2) = NULL,
    @alcoholes_superiores_mg_100mlAA DECIMAL(5, 2) = NULL,
    @porcentaje_alcohol_vol DECIMAL(5, 2) = NULL,
    @orden_produccion INT,
    @extracto_seco_gL DECIMAL(18, 5) = NULL, -- Parámetros opcionales con valores por defecto
    @aldehidos_mg_100mlAA DECIMAL(18, 5) = NULL,
    @furfural_mg_100mlAA DECIMAL(18, 5) = NULL,
    @plomo_mg_L DECIMAL(18, 5) = NULL,
    @arsenico_mg_L DECIMAL(18, 5) = NULL
AS
BEGIN
    DECLARE @id_nuevo_liquido INT;

    -- Insertar el nuevo registro en la tabla liquidos
    INSERT INTO liquidos
    (
        codigo,
        id_tipo,
        cantidad_total_lts,
        id_proveedor,
        metanol_mg_100mlAA,
        alcoholes_superiores_mg_100mlAA,
        alcohol_vol_20_c_porcentaje,
        orden_produccion,
        extracto_seco_gL,
        aldehidos_mg_100mlAA,
        furfural_mg_100mlAA,
        plomo_mg_L,
        arsenico_mg_L
    )
    VALUES
    (
        @codigo,
        @id_tipo,
        @cantidad_total_lts,
        @id_proveedor,
        @metanol_mg_100mlAA,
        @alcoholes_superiores_mg_100mlAA,
        @porcentaje_alcohol_vol / 100.0, -- Convertir el porcentaje a decimal (0 - 1)
        @orden_produccion,
        @extracto_seco_gL,
        @aldehidos_mg_100mlAA,
        @furfural_mg_100mlAA,
        @plomo_mg_L,
        @arsenico_mg_L
    );

    -- Obtener el ID del nuevo líquido
    SET @id_nuevo_liquido = SCOPE_IDENTITY();

    -- Devolver el ID del nuevo líquido
    SELECT @id_nuevo_liquido AS id_nuevo_liquido;
END;
GO





-- Procedimiento para isertar una nueva transacción de un liquido a un contenedor
-- Este procedimiento también es usado en la función transferir de Power Apps
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
        -- Iniciar la transacción
        BEGIN TRANSACTION;

        -- Verificar si el contenedor de destino es válido
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

        -- Confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Deshacer lo anterior si ocurre un error
        ROLLBACK TRANSACTION;
        -- Lanzar el error
        THROW;
    END CATCH;
END;
GO




------------------------- PROCEDIMINETOS ALMACENADOS PARA LA FUNCIÓN TRANSFERIR EN POWER APPS  -------------------------------

-- Obtener los datos de un liquido dentro de un contenedor si este es válido
-- Este procedimeinto también es usado en la función de salida de producto en Power Apps
IF OBJECT_ID('dbo.sp_obtener_datos_validos_liquido_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_validos_liquido_contenedor;
GO

CREATE PROCEDURE sp_obtener_datos_validos_liquido_contenedor
    @id_contenedor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para almacenar los datos del último líquido en el contenedor
    DECLARE @ultimo_id_liquido INT;
    DECLARE @ultimo_id_liquido_contenedor INT;
    DECLARE @cantidad_liquido_lts DECIMAL(10, 2);

    -- Obtener el último registro del líquido en el contenedor
    SELECT TOP 1
        @ultimo_id_liquido = t.id_liquido,
        @ultimo_id_liquido_contenedor = t.id_liquido_contenedor,
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
    ORDER BY t.id_liquido_contenedor DESC;

    -- Verificar si no se encontró un líquido válido
    IF @ultimo_id_liquido IS NULL OR @cantidad_liquido_lts <= 0.00
    BEGIN
        RAISERROR ('No se encontró un líquido válido en el contenedor o el contenedor está dañado.', 16, 1);
        RETURN;
    END

    -- Seleccionar todos los datos del líquido
    SELECT
        l.id_liquido,
        l.codigo,
        l.id_tipo,
        l.cantidad_total_lts,
        l.fecha_produccion,
        l.id_proveedor,
        l.alcohol_vol_20_c_porcentaje,
        l.extracto_seco_gL,
        l.metanol_mg_100mlAA,
        l.alcoholes_superiores_mg_100mlAA,
        l.aldehidos_mg_100mlAA,
        l.furfural_mg_100mlAA,
        l.plomo_mg_L,
        l.arsenico_mg_L,
        @cantidad_liquido_lts AS cantidad_liquido_dentro_lts,
        @ultimo_id_liquido_contenedor AS ultimo_id_liquido_contenedor
    FROM 
        liquidos l
    WHERE 
        l.id_liquido = @ultimo_id_liquido;
END;
GO





-- Procedimiento para obtener datos de un contenedor si esta activo
IF OBJECT_ID('dbo.sp_obtener_datos_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_contenedor;
GO

CREATE PROCEDURE sp_obtener_datos_contenedor
    @id_contenedor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el contenedor existe y si esta activo
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

    SELECT 
        c.nombre,
        c.id_estatus,
        t.capacidad_lts
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





-- Procedimiento para insertar una transferencia de un liquido a otro contendor, es decir solo pasar un liquido a otro contenedor
-- diferente de sp_insertar_transaccion_liquido_contenedor
IF OBJECT_ID('dbo.sp_insertar_transferencia_liquido_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_insertar_transferencia_liquido_contenedor;
GO

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
        -- Iniciar transferencia
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

        -- Verificar si el contendor destino existe, si es así actualizar su estado a (EN USO, id_estatus = 1)
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

        -- Verificar si el contenedor origen existe y tiene un líqudo para transferir
        IF EXISTS (SELECT 1 FROM transacciones_liquido_contenedor WHERE id_contenedor = @id_contenedor_origen AND id_liquido = @id_liquido)
        BEGIN
            -- Actualizar la cantidad de líquido en el contenedor origen
            UPDATE
                transacciones_liquido_contenedor
            SET
                cantidad_liquido_lts = cantidad_liquido_lts - @cantidad_liquido_lts
            WHERE
                id_contenedor = @id_contenedor_origen
                AND id_liquido = @id_liquido;

            -- Asegurarse que el contenedor origen no se queda con una cantidad negativa
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

        -- Confirmar si la transacción fue exitosa
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Deshacer todo lo anterior si ocurre un error
        ROLLBACK TRANSACTION;
        -- Lanzar el error
        THROW;
    END CATCH;
END;
GO




-- Procedimiento para insertar un líquido combinado, es decir cuando se juntan dos o más líquidos ALFA (ID: 1) O BETA (ID: 2)
-- Este es el procedimiento más importante hasta el momento, se encarga de la logica principal para obtener la trazabilidad posteriormente
-- Se recomineda tener al menos una versión estable de este antes de realizar modificaciones
IF OBJECT_ID('dbo.sp_insertar_liquido_combinado', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_insertar_liquido_combinado;
GO

CREATE PROCEDURE sp_insertar_liquido_combinado
    @nombre VARCHAR(32),
    @id_tipo INT,
    @id_proveedor INT,
    @orden_produccion INT,
    @id_estatus INT,
    @id_contenedor_destino INT,
    @persona_encargada VARCHAR(32),
    @composicion_liquidos_json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @id_liquido_combinado INT;
        DECLARE @id_combinacion INT;
        DECLARE @id_liquido_componente INT;
        DECLARE @cantidad_total_componentes DECIMAL(18, 4) = 0;
        DECLARE @cantidad_generada_lts DECIMAL(18, 4);

        -- Variables para almacenar los cálculos acumulados con mayor precisión
        DECLARE @extracto_seco_gL_total DECIMAL(18, 5) = 0;
        DECLARE @alcohol_vol_20_c_porcentaje_total DECIMAL(18, 5) = 0;
        DECLARE @metanol_mg_100mlAA_total DECIMAL(18, 5) = 0;
        DECLARE @alcoholes_superiores_mg_100mlAA_total DECIMAL(18, 5) = 0;
        DECLARE @aldehidos_mg_100mlAA_total DECIMAL(18, 5) = 0;
        DECLARE @furfural_mg_100mlAA_total DECIMAL(18, 5) = 0;
        DECLARE @plomo_mg_L_total DECIMAL(18, 5) = 0;
        DECLARE @arsenico_mg_L_total DECIMAL(18, 5) = 0;
        DECLARE @alcohol_sum DECIMAL(18, 5) = 0;
        DECLARE @furfural_sum DECIMAL(18, 5) = 0;
        DECLARE @extracto_seco_sum DECIMAL(18, 5) = 0;
        DECLARE @metanol_sum DECIMAL(18, 5) = 0;
        DECLARE @alcoholes_sup_sum DECIMAL(18, 5) = 0;
        DECLARE @aldehidos_sum DECIMAL(18, 5) = 0;
        DECLARE @plomo_sum DECIMAL(18, 5) = 0;
        DECLARE @arsenico_sum DECIMAL(18, 5) = 0;

        -- Calcular la cantidad total de los componentes del líquido en litros
        SELECT @cantidad_total_componentes = SUM(cantidad_liquido_componente_lts)
        FROM OPENJSON(@composicion_liquidos_json)
        WITH
        (
            id_contenedor_componente INT '$.id_contenedor_componente',
            cantidad_liquido_componente_lts DECIMAL(18, 4) '$.cantidad_liquido_componente_lts'
        );

        -- La cantidad generada será igual a la cantidad total de componentes
        SET @cantidad_generada_lts = @cantidad_total_componentes;

        -- Verificar si el contenedor destino está vacío y actualizar a "EN USO"
        IF EXISTS (SELECT 1 FROM contenedores WHERE id_contenedor = @id_contenedor_destino AND id_estatus = 2)
        BEGIN
            UPDATE contenedores
            SET id_estatus = 1
            WHERE id_contenedor = @id_contenedor_destino;
        END;

        -- Insertar el nuevo registro en la tabla combinaciones antes de procesar los detalles
        INSERT INTO combinaciones
        (
            id_liquido_combinado
        )
        VALUES
        (
            NULL -- Aún no tenemos el id_liquido_combinado
        );

        -- Obtener el ID de la combinación para usarlo en combinaciones_detalle
        SET @id_combinacion = SCOPE_IDENTITY();

        -- Validar que se obtuvo un ID de combinación válido
        IF @id_combinacion IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50001, 'Error: No se pudo obtener el ID de la combinación.', 1;
        END

        -- Procesar el JSON dentro de la tabla combinaciones_detalle
        DECLARE @id_contenedor_componente INT;
        DECLARE @cantidad_liquido_componente_lts DECIMAL(18, 4);
        DECLARE @porcentaje DECIMAL(10, 2);

        DECLARE cur CURSOR FOR
        SELECT 
            id_contenedor_componente,
            cantidad_liquido_componente_lts
        FROM 
            OPENJSON(@composicion_liquidos_json)
        WITH
        (
            id_contenedor_componente INT '$.id_contenedor_componente',
            cantidad_liquido_componente_lts DECIMAL(18, 4) '$.cantidad_liquido_componente_lts'
        );

        OPEN cur;
        FETCH NEXT FROM cur INTO @id_contenedor_componente, @cantidad_liquido_componente_lts;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Crear una tabla temporal para almacenar el resultado de sp_obtener_datos_validos_liquido_contenedor
            DECLARE @resultado TABLE (
                id_liquido INT,
                codigo VARCHAR(32), 
                id_tipo INT,
                cantidad_total_lts DECIMAL(18, 4),
                fecha_produccion DATE,
                id_proveedor INT,
                alcohol_vol_20_c_porcentaje DECIMAL(18, 5),
                extracto_seco_gL DECIMAL(18, 5),
                metanol_mg_100mlAA DECIMAL(18, 5),
                alcoholes_superiores_mg_100mlAA DECIMAL(18, 5),
                aldehidos_mg_100mlAA DECIMAL(18, 5),
                furfural_mg_100mlAA DECIMAL(18, 5),
                plomo_mg_L DECIMAL(18, 5),
                arsenico_mg_L DECIMAL(18, 5),
                cantidad_liquido_dentro_lts DECIMAL(18, 4),
                ultimo_id_liquido_contenedor INT
            );

            -- Insertar los resultados del procedimiento en la tabla temporal
            INSERT INTO @resultado
            EXEC sp_obtener_datos_validos_liquido_contenedor @id_contenedor = @id_contenedor_componente;

            -- Obtener el ID del líquido componente
            SELECT @id_liquido_componente = id_liquido
            FROM @resultado;

            -- Verificar que el ID del líquido componente no sea NULL
            IF @id_liquido_componente IS NULL
            BEGIN
                ROLLBACK TRANSACTION;
                THROW 50001, 'Error: El id_liquido obtenido es NULL o no válido.', 1;
            END

            DECLARE @mla DECIMAL(18, 5) = 0;
            SELECT @mla = r.alcohol_vol_20_c_porcentaje FROM @resultado r;

            -- Acumular los valores para cada componente
            SELECT @extracto_seco_gL_total = (r.extracto_seco_gL * @cantidad_liquido_componente_lts),
                   @alcohol_vol_20_c_porcentaje_total = (r.alcohol_vol_20_c_porcentaje * @cantidad_liquido_componente_lts),
                   @metanol_mg_100mlAA_total = (r.metanol_mg_100mlAA * @cantidad_liquido_componente_lts * r.alcohol_vol_20_c_porcentaje),
                   @alcoholes_superiores_mg_100mlAA_total = (r.alcoholes_superiores_mg_100mlAA * @cantidad_liquido_componente_lts * r.alcohol_vol_20_c_porcentaje),
                   @aldehidos_mg_100mlAA_total = (r.aldehidos_mg_100mlAA * @cantidad_liquido_componente_lts * r.alcohol_vol_20_c_porcentaje),
                   @furfural_mg_100mlAA_total = (r.furfural_mg_100mlAA * @cantidad_liquido_componente_lts * r.alcohol_vol_20_c_porcentaje),
                   @plomo_mg_L_total = (r.plomo_mg_L * @cantidad_liquido_componente_lts),
                   @arsenico_mg_L_total = (r.arsenico_mg_L * @cantidad_liquido_componente_lts)
            FROM @resultado r;

            
            SET @alcohol_sum = @alcohol_sum + @alcohol_vol_20_c_porcentaje_total;
            SET @furfural_sum = @furfural_sum + @furfural_mg_100mlAA_total;
            SET @extracto_seco_sum = @extracto_seco_sum + @extracto_seco_gL_total;
            SET @metanol_sum = @metanol_sum + @metanol_mg_100mlAA_total;
            SET @alcoholes_sup_sum = @alcoholes_sup_sum + @alcoholes_superiores_mg_100mlAA_total;
            SET @aldehidos_sum = @aldehidos_sum + @aldehidos_mg_100mlAA_total;
            SET @plomo_sum = @plomo_sum + @plomo_mg_L_total;
            SET @arsenico_sum = @arsenico_sum + @arsenico_mg_L_total;

            -- Calcular el porcentaje del componente
            SET @porcentaje = (@cantidad_liquido_componente_lts / @cantidad_generada_lts) * 100;

            -- Insertar en la tabla combinaciones_detalle
            INSERT INTO combinaciones_detalle
            (
                id_combinacion,
                id_liquido,
                cantidad_lts,
                porcentaje
            )
            VALUES
            (
                @id_combinacion,
                @id_liquido_componente,
                @cantidad_liquido_componente_lts,
                @porcentaje
            );

            -- Actualizar las cantidades en los contenedores de cada componente
            UPDATE 
                t
            SET 
                t.cantidad_liquido_lts = t.cantidad_liquido_lts - @cantidad_liquido_componente_lts
            FROM
                transacciones_liquido_contenedor t
            WHERE
                t.id_contenedor = @id_contenedor_componente AND t.id_liquido = @id_liquido_componente;

            FETCH NEXT FROM cur INTO @id_contenedor_componente, @cantidad_liquido_componente_lts;
        END;

        CLOSE cur;
        DEALLOCATE cur;

        -- Calcular el valor final del nuevo líquido para todos los componentes
        SET @extracto_seco_gL_total = @extracto_seco_sum / @cantidad_generada_lts;
        SET @alcohol_vol_20_c_porcentaje_total = @alcohol_sum / @cantidad_generada_lts;
        SET @metanol_mg_100mlAA_total = @metanol_sum/ (@cantidad_generada_lts * @alcohol_vol_20_c_porcentaje_total);
        SET @alcoholes_superiores_mg_100mlAA_total = @alcoholes_sup_sum/ (@cantidad_generada_lts * @alcohol_vol_20_c_porcentaje_total);
        SET @aldehidos_mg_100mlAA_total = @aldehidos_sum / (@cantidad_generada_lts * @alcohol_vol_20_c_porcentaje_total);
        SET @furfural_mg_100mlAA_total = @furfural_sum / (@cantidad_generada_lts * @alcohol_vol_20_c_porcentaje_total);
        SET @plomo_mg_L_total = @plomo_sum / @cantidad_generada_lts;
        SET @arsenico_mg_L_total = @arsenico_sum / @cantidad_generada_lts;

        -- Insertar el nuevo registro en la tabla liquidos después de calcular todas las propiedades
        INSERT INTO liquidos
        (
            codigo,
            id_tipo,
            cantidad_total_lts,
            id_proveedor,
            extracto_seco_gL, 
            alcohol_vol_20_c_porcentaje, 
            metanol_mg_100mlAA, 
            alcoholes_superiores_mg_100mlAA, 
            aldehidos_mg_100mlAA, 
            furfural_mg_100mlAA, 
            plomo_mg_L, 
            arsenico_mg_L, 
            orden_produccion
        )
        VALUES
        (
            @nombre,
            @id_tipo,
            @cantidad_generada_lts,
            @id_proveedor,
            @extracto_seco_gL_total, 
            @alcohol_vol_20_c_porcentaje_total, 
            @metanol_mg_100mlAA_total, 
            @alcoholes_superiores_mg_100mlAA_total, 
            @aldehidos_mg_100mlAA_total, 
            @furfural_mg_100mlAA_total, 
            @plomo_mg_L_total, 
            @arsenico_mg_L_total, 
            @orden_produccion
        );

        -- Actualizar la tabla combinaciones con el id_liquido_combinado
        SET @id_liquido_combinado = SCOPE_IDENTITY();

        UPDATE combinaciones
        SET id_liquido_combinado = @id_liquido_combinado
        WHERE id_combinacion = @id_combinacion;

        -- **Insertar en la tabla transacciones_liquido_contenedor**
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

        -- Confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Deshacer todo en caso de error
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO





-- Procedimiento para obtener los estados de un líquido
IF OBJECT_ID('dbo.sp_obtener_estatus_liquidos', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_estatus_liquidos;
GO

CREATE PROCEDURE sp_obtener_estatus_liquidos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM estatus_liquido;
END;
GO




IF OBJECT_ID('dbo.sp_obtener_datos_validos_liquido_contenedor_destino', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_validos_liquido_contenedor_destino;
GO

CREATE PROCEDURE sp_obtener_datos_validos_liquido_contenedor_destino
    @id_contenedor INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables para almacenar los datos del último líquido en el contenedor
    DECLARE @ultimo_id_liquido INT;
    DECLARE @ultimo_id_liquido_contenedor INT;
    DECLARE @cantidad_liquido_lts DECIMAL(10, 2);

    -- Obtener el último registro del líquido en el contenedor
    SELECT TOP 1
        @ultimo_id_liquido = t.id_liquido,
        @ultimo_id_liquido_contenedor = t.id_liquido_contenedor,
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
    ORDER BY t.id_liquido_contenedor DESC;

    -- Verificar si no se encontró un líquido válido
    IF @ultimo_id_liquido IS NULL
    BEGIN
        RAISERROR ('No se encontró un líquido válido en el contenedor o el contenedor está dañado.', 16, 1);
        RETURN;
    END

    SELECT
        @ultimo_id_liquido AS id_liquido,
        l.codigo AS codigo_liquido,
        @cantidad_liquido_lts AS cantidad_liquido_dentro_lts,
        @ultimo_id_liquido_contenedor AS ultimo_id_liquido_contenedor
    FROM 
        liquidos l
    WHERE 
        l.id_liquido = @ultimo_id_liquido
END;
GO




IF OBJECT_ID('dbo.sp_obtener_propiedades_contenedor_liquido', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_propiedades_contenedor_liquido;
GO

CREATE PROCEDURE sp_obtener_propiedades_contenedor_liquido
    @id_contenedor INT
AS
BEGIN
    SELECT TOP 1
        t.id_liquido_contenedor,
        l.id_liquido,
        t.cantidad_liquido_lts,
        tc.capacidad_lts,
        l.codigo,
        e.descripcion,
        l.fecha_produccion,
        l.alcohol_vol_20_c_porcentaje,
        l.extracto_seco_gL,
        l.metanol_mg_100mlAA,
        l.alcoholes_superiores_mg_100mlAA,
        l.aldehidos_mg_100mlAA,
        l.furfural_mg_100mlAA,
        l.plomo_mg_L,
        l.arsenico_mg_L,
        l.cantidad_total_lts,
        l.orden_produccion
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
        t.id_liquido_contenedor DESC;
END;
GO





------------------------- PROCEDIMIENTOS ALMACENADOS PARA LA FUNCIÓN INSPECCIONAR EN POWER APPS -------------------------------

-- Procedimiento para obtener la información de un líquido dentro de un contenedor, solo si este esta relacionado con algún líquido
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

    -- Seleccionar la información actual del líquido que se encuentra dentro del contenedor
    SELECT TOP 1
        t.id_liquido_contenedor,
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
        t.id_liquido_contenedor DESC;
END;
GO




-- Procedimiento alamcenado para obtener la trazabilidad del líquido
IF OBJECT_ID('dbo.sp_obtener_trazabilidad_liquido', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_trazabilidad_liquido;
GO

CREATE PROCEDURE sp_obtener_trazabilidad_liquido
    @id_contenedor INT
AS
BEGIN
    -- Crear tabla temporar para guardar los datos del procedimeinto almacenado sp_obtener_datos_contenedor_liquido
    -- Obtener el ID de líquido actual dentro del contenedor
    CREATE TABLE #TempTable (
       id_liquido_contenedor INT,
       id_liquido INT,
       cantidad_liquido_lts DECIMAL(18, 2),
       capacidad_lts DECIMAL(18, 2),
       codigo VARCHAR(32),
       descripcion VARCHAR(32)
    );

    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

    DECLARE @id_liquido_b INT;
    SELECT @id_liquido_b = id_liquido FROM #TempTable;

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
            SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) AS total_cantidad_combinacion, -- Suma de cantidad total de la combinación
            td.cantidad_lts / SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) * 100 AS porcentaje, -- Cálculo del porcentaje
            1 AS nivel,
            ROW_NUMBER() OVER (ORDER BY t.id_combinacion) AS traza  -- Asignar traza a nivel 1
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
            l.orden_produccion,
            td.id_liquido AS id_liquido_componente,
            lc.codigo AS codigo_componente,
            lc.id_tipo AS tipo_componente,
            td.cantidad_lts,
            SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) AS total_cantidad_combinacion,
            td.cantidad_lts / SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) * 100 AS porcentaje, -- Cálculo del porcentaje
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




-- Procedimiento para obtener la trazabilidad de un líquido agrpando los duplicados
IF OBJECT_ID('dbo.sp_obtener_trazabilidad_liquido_agrupado', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_trazabilidad_liquido_agrupado;
GO


CREATE PROCEDURE sp_obtener_trazabilidad_liquido_agrupado
    @id_contenedor INT
AS
BEGIN
    -- Crear una tabla temporal para almacenar los datos
    CREATE TABLE #TempTable (
       id_liquido_contenedor INT,
       id_liquido INT,
       cantidad_liquido_lts DECIMAL(18, 2),
       capacidad_lts DECIMAL(18, 2),
       codigo VARCHAR(32),
       descripcion VARCHAR(32)
    );

    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

    -- Declarar variable para obtener el id_liquido
    DECLARE @id_liquido_b INT;
    SELECT @id_liquido_b = id_liquido FROM #TempTable;

    -- Crear tabla temporal para los resultados antes de la CTE
    CREATE TABLE #TempResult (
        id_liquido_componente INT,
        codigo_componente VARCHAR(32),
        tipo_componente INT,
        cantidad_lts DECIMAL(18, 2),
        total_cantidad_combinacion DECIMAL(18, 2),
        porcentaje_recursivo DECIMAL(18, 2),
        nivel INT,
        traza INT
    );

    -- CTE para realizar el trazado del líquido
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
            SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) AS total_cantidad_combinacion,
            td.cantidad_lts / SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) * 100 AS porcentaje,
            CAST(td.cantidad_lts / SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) * 100 AS DECIMAL(18, 2)) AS porcentaje_recursivo,
            1 AS nivel,
            ROW_NUMBER() OVER (ORDER BY t.id_combinacion) AS traza
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
            l.orden_produccion,
            td.id_liquido AS id_liquido_componente,
            lc.codigo AS codigo_componente,
            lc.id_tipo AS tipo_componente,
            td.cantidad_lts,
            SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) AS total_cantidad_combinacion,
            td.cantidad_lts / SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) * 100 AS porcentaje,
            CAST(td.cantidad_lts / SUM(td.cantidad_lts) OVER (PARTITION BY t.id_combinacion) * 100 * cte.porcentaje_recursivo / 100 AS DECIMAL(18, 2)) AS porcentaje_recursivo,
            cte.nivel + 1,
            cte.traza
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

    -- Insertar los resultados de la CTE en la tabla temporal
    INSERT INTO #TempResult
    SELECT 
        id_liquido_componente,
        codigo_componente,
        tipo_componente,
        SUM(cantidad_lts) AS cantidad_lts,
        SUM(total_cantidad_combinacion) AS total_cantidad_combinacion,
        SUM(porcentaje_recursivo) AS porcentaje_recursivo,
        MIN(nivel) AS nivel,
        MIN(traza) AS traza
    FROM 
        CTE_trazabilidad
    GROUP BY 
        id_liquido_componente,
        codigo_componente,
        tipo_componente
    ORDER BY 
        id_liquido_componente;
    
    CREATE TABLE #TempActualTable (
        id_liquido_contenedor INT,
        id_estatus INT,
        id_liquido INT,
        cantidad_total_lts DECIMAL(18, 2),
        fecha_produccion DATE,
        orden_produccion INT,
        cantidad_liquido_lts DECIMAL(18, 2),
        id_tipo INT,
        capacidad_lts DECIMAL(18, 2),
        codigo VARCHAR(32),
        descripcion VARCHAR(32)
    );

    -- Obtener el líquido actual y almacenarlo en la tabla temporal
    INSERT INTO #TempActualTable
    EXEC sp_obtener_info_contenedor_liquido @id_contenedor = @id_contenedor;

    -- Insertar el líquido actual en el conjunto de trazabilidad
    INSERT INTO #TempResult (id_liquido_componente, codigo_componente, tipo_componente, cantidad_lts, total_cantidad_combinacion, porcentaje_recursivo, nivel, traza)
    SELECT
        id_liquido AS id_liquido_componente,
        codigo AS codigo_componente,
        id_tipo AS tipo_componente,
        cantidad_liquido_lts AS cantidad_lts,
        cantidad_total_lts AS total_cantidad_combinacion,
        100 AS porcentaje_recursivo,
        0 AS nivel,
        0 AS traza
    FROM
        #TempActualTable;

    -- Limpiar las tablas temporales
    DROP TABLE #TempTable;
    DROP TABLE #TempActualTable;

    -- Devolver el resultado final
    SELECT * FROM #TempResult;

    -- Limpiar la tabla temporal de resultado
    DROP TABLE #TempResult;
END;
GO





-- Procedimiento almacenado para obtener los datos de un líquido dentro de un contenedor, sin ninguna válidación
IF OBJECT_ID('dbo.sp_obtener_datos_contenedor_liquido', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_datos_contenedor_liquido;
GO

CREATE PROCEDURE sp_obtener_datos_contenedor_liquido
    @id_contenedor INT
AS
BEGIN
    SELECT TOP 1
        t.id_liquido_contenedor,
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
        t.id_liquido_contenedor DESC;
END;
GO





-- Procedimineto almacenado para obtener las propiedades de un líquido dentro de un contenedor
IF OBJECT_ID('dbo.sp_obtener_propiedades_contenedor_liquido_transpuesta', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_propiedades_contenedor_liquido_transpuesta;
GO

CREATE PROCEDURE [dbo].[sp_obtener_propiedades_contenedor_liquido_transpuesta]
    @id_contenedor INT
AS
BEGIN
    -- Crear una tabla temporal para almacenar las propiedades del líquido
    CREATE TABLE #TempPropiedades (
        id_liquido_contenedor INT,
        id_liquido INT,
        cantidad_liquido_lts DECIMAL(18, 2),
        capacidad_lts DECIMAL(18, 2),
        codigo VARCHAR(50),
        descripcion VARCHAR(100),
        fecha_produccion DATE,
        alcohol_vol_20_c_porcentaje DECIMAL(18, 5),
        extracto_seco_gL DECIMAL(18, 5),
        metanol_mg_100mlAA DECIMAL(18, 5),
        alcoholes_superiores_mg_100mlAA DECIMAL(18, 5),
        aldehidos_mg_100mlAA DECIMAL(18, 5),
        furfural_mg_100mlAA DECIMAL(18, 5),
        plomo_mg_L DECIMAL(18, 5),
        arsenico_mg_L DECIMAL(18, 5),
        cantidad_total_lts DECIMAL(18, 2),
        orden_produccion INT
    );

    -- Insertar los resultados del SELECT en la tabla temporal
    INSERT INTO #TempPropiedades
    SELECT TOP 1
        t.id_liquido_contenedor,
        l.id_liquido,
        t.cantidad_liquido_lts,
        tc.capacidad_lts,
        l.codigo,
        e.descripcion,
        l.fecha_produccion,
        l.alcohol_vol_20_c_porcentaje,
        l.extracto_seco_gL,
        l.metanol_mg_100mlAA,
        l.alcoholes_superiores_mg_100mlAA,
        l.aldehidos_mg_100mlAA,
        l.furfural_mg_100mlAA,
        l.plomo_mg_L,
        l.arsenico_mg_L,
        l.cantidad_total_lts,
        l.orden_produccion
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
        t.id_liquido_contenedor DESC;

    -- Transponer los datos almacenados en la tabla temporal
    SELECT propiedad, unidad_medida, valor
FROM (
    SELECT 1 AS orden, 'VOLUMEN' AS propiedad, 'L' AS unidad_medida, FORMAT(cantidad_liquido_lts, 'N2') AS valor FROM #TempPropiedades
    UNION ALL
    SELECT 2, 'CAPACIDAD CONTENEDOR', 'L', FORMAT(capacidad_lts, 'N2') FROM #TempPropiedades
    UNION ALL
    SELECT 3, 'ALC. VOL. A 20°C', '%', CAST(alcohol_vol_20_c_porcentaje * 100 AS VARCHAR(50)) FROM #TempPropiedades
    UNION ALL
    SELECT 4, 'EXTRACTO SECO', 'g/L', CAST(extracto_seco_gL AS VARCHAR(50)) FROM #TempPropiedades
    UNION ALL
    SELECT 5, 'METANOL', 'mg/100ml AA', CAST(metanol_mg_100mlAA AS VARCHAR(50)) FROM #TempPropiedades
    UNION ALL
    SELECT 6, 'ALCOHOLES SUPERIORES', 'mg/100ml AA', CAST(alcoholes_superiores_mg_100mlAA AS VARCHAR(50)) FROM #TempPropiedades
    UNION ALL
    SELECT 7, 'ALDEHIDOS', 'mg/100ml AA', CAST(aldehidos_mg_100mlAA AS VARCHAR(50)) FROM #TempPropiedades
    UNION ALL
    SELECT 8, 'FURFURAL', 'mg/100ml AA', CAST(furfural_mg_100mlAA AS VARCHAR(50)) FROM #TempPropiedades
    UNION ALL
    SELECT 9, 'PLOMO', 'mg/L', CAST(plomo_mg_L AS VARCHAR(50)) FROM #TempPropiedades
    UNION ALL
    SELECT 10, 'ARSÉNICO', 'mg/L', CAST(arsenico_mg_L AS VARCHAR(50)) FROM #TempPropiedades
) AS PropiedadesOrdenadas
ORDER BY orden;

    -- Eliminar la tabla temporal
    DROP TABLE #TempPropiedades;
END;
GO





------------------------- PROCEDIMINETOS ALMACENADOS PARA LA FUNCIÓN SALIDA DE PRODUCTO EN POWER APPS -------------------------------

-- Procedimiento almacenado para insertar un producto termiando
IF OBJECT_ID('dbo.sp_insertar_producto_terminado', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_insertar_producto_terminado;
GO

CREATE PROCEDURE sp_insertar_producto_terminado
    @id_contenedor INT,
    @cantidad_terminada_lts INT,
    @persona_encargada VARCHAR(32)
AS
BEGIN
    -- Variable para almacenar el id_liquido y la cantidad actual de líquido, probablemente cambiar a DECIMAL(18, 4)
    DECLARE @id_liquido_dentro INT;
    DECLARE @cantidad_restante_lts INT;
    DECLARE @id_liquido_contenedor INT;

    -- Obtener el id_liquido más reciente del contenedor especificado
    SELECT TOP 1
        @id_liquido_dentro = t.id_liquido,
        @id_liquido_contenedor = t.id_liquido_contenedor
    FROM 
        transacciones_liquido_contenedor t
    WHERE
        t.id_contenedor = @id_contenedor
    ORDER BY 
        t.id_liquido_contenedor DESC;

    -- Actualizar la cantidad de líquido en el contenedor
    UPDATE
        transacciones_liquido_contenedor
    SET 
        cantidad_liquido_lts = cantidad_liquido_lts - @cantidad_terminada_lts,
        id_liquido = NULL
    WHERE
        id_liquido_contenedor = @id_liquido_contenedor;

    -- Obtener la cantidad restante después de la actualización
    SELECT @cantidad_restante_lts = cantidad_liquido_lts
    FROM 
        transacciones_liquido_contenedor
    WHERE
        id_liquido_contenedor = @id_liquido_contenedor;

    -- Si la cantidad restante es igual o menor a 0, actualizar el estado del contenedor
    IF @cantidad_restante_lts <= 0
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





------------------------- PROCEDIMIENTOS ALMACENADOS PARA LA FUNCIÓN ADMINISTRAR CONTENEDORES DE POWER APPS  -------------------------------

-- Procedimiento para registrar un nuevo contenedor
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
    -- Insertar el nuevo registro en la tabla contenedores
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

    -- Obtener el ID del contenedor nuevo (acaba de ser insertado)
    SELECT SCOPE_IDENTITY() AS id_contenedor;
END;
GO





-- Procedimiento para obtener los tipos de los contenedor, estos definen su capacidad
IF OBJECT_ID('dbo.sp_ obtener_tipos_contenedor', 'P') IS NOT NULL
DROP PROCEDURE dbo.sp_obtener_tipos_contenedor;
GO

CREATE PROCEDURE sp_obtener_tipos_contenedor
AS
BEGIN
    SELECT * FROM tipos_contenedor;
END;
GO





-- Procedimiento para obtener los estados de los contenedores
IF OBJECT_ID('dbo.sp_obtener_estatus_contenedor', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_estatus_contenedor;
GO

CREATE PROCEDURE sp_obtener_estatus_contenedor
AS
BEGIN
    SELECT * FROM estatus_contenedor;
END;
GO





-- Procedimiento para obtener las ubicaciones de los contenedores
IF OBJECT_ID('dbo.sp_obtener_ubicaciones_contenedor', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_ubicaciones_contenedor;
GO

CREATE PROCEDURE sp_obtener_ubicaciones_contenedor
AS
BEGIN
    SELECT * FROM ubicaciones_contenedor;
END;
GO





-- Vista para obtener los datos de todos los contenedores disponibles y el líquido que contienen dentro
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
        ROW_NUMBER() OVER (PARTITION BY t.id_contenedor ORDER BY t.id_liquido_contenedor DESC) AS rn
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





-- Procedimiento para obtener los contenedores con estado DISPONIBLE, es decir fecha de baja es NULL
-- Este procedimiento tambien es utilizado en la sub-función reimprimir QR de Power Apps
IF OBJECT_ID('dbo.sp_obtener_contenedores_disponibles', 'P') IS NOT NULL
DROP PROCEDURE sp_obtener_contenedores_disponibles;
GO

CREATE PROCEDURE sp_obtener_contenedores_disponibles
AS
BEGIN
    SELECT * FROM contenedores WHERE id_estatus <> 3 AND fecha_baja IS NULL;
END;
GO





-- Procedimeinto para eliminar un contenedor
IF OBJECT_ID('dbo.sp_eliminar_contenedor', 'P') IS NOT NULL
    DROP PROCEDURE sp_eliminar_contenedor;
GO

CREATE PROCEDURE sp_eliminar_contenedor
    @id_contenedor INT
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

    -- Si el contenedor está vacío, actualizar el estatus a NO DISPONIBLE y definir su fecha de baja al momento de la solicitud
    UPDATE contenedores
    SET id_estatus = 3,
    fecha_baja = GETDATE()
    WHERE id_contenedor = @id_contenedor;

    -- Eliminar la tabla temporal
    DROP TABLE #TempTable;
END;
GO





-- Procedimiento para obtener los contenedores disponibles, excepto los eliminados (id_estatus = 3)
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





-- Procedimiento para actualziar el estado de un líquido
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
        id_liquido_contenedor INT,
        id_liquido INT,
        cantidad_liquido_lts DECIMAL(18, 2),
        capacidad_lts DECIMAL(18, 2),
        codigo VARCHAR(50),
        descripcion VARCHAR(100)
    );

    -- Insertamos los resultados del procedimiento almacenado en la tabla temporal
    INSERT INTO #TempTable
    EXEC sp_obtener_datos_contenedor_liquido @id_contenedor = @id_contenedor;

    -- Declaramos una variable para almacenar el id_liquido_contenedor
    DECLARE @id_liquido_contenedor INT;

    -- Asignamos el valor de id_liquido_contenedor desde la tabla temporal
    SELECT TOP 1 @id_liquido_contenedor = id_liquido_contenedor FROM #TempTable;

    -- Actualizamos el estatus en la tabla transacciones_liquido_contenedor
    UPDATE
        transacciones_liquido_contenedor
    SET
        id_estatus = @id_nuevo_estatus
    WHERE
        id_liquido_contenedor = @id_liquido_contenedor;

    -- Eliminamos la tabla temporal
    DROP TABLE #TempTable;
END;
GO




-- Procedimiento almacenado para actualizar el estado de un contenedor
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
    -- IF EXISTS (
    --     SELECT 1
    --     FROM #TempTable
    --     WHERE ISNULL(cantidad_liquido_lts, 0) > 0
    -- )
    -- BEGIN
    --     RAISERROR('El contenedor con ID %d no está vacío.', 16, 1, @id_contenedor);
    --     RETURN;
    -- END

    -- Si el contenedor está vacío, actualizar el estatus
    UPDATE contenedores
    SET id_estatus = @id_nuevo_estatus
    WHERE id_contenedor = @id_contenedor;

    -- Eliminar la tabla temporal
    DROP TABLE #TempTable;
END;
GO

