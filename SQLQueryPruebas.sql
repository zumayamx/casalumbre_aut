CREATE DATABASE casalumbre_pruebas;

CREATE TABLE Liquidos (
    ID_Liquido INT IDENTITY(1,1) PRIMARY KEY,
    Codigo VARCHAR(50),
    Tipo_Liquido VARCHAR(50),
    Cantidad_total FLOAT,
    Fecha_creacion DATE,
    Proveedor VARCHAR(100),
    Metanol FLOAT,
    Alcoholes_superiores FLOAT,
    Porcentaje_Alcohol_vol FLOAT,
    Orden_produccion VARCHAR(50)
);

CREATE TABLE Transacciones (
    ID_Transaccion INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    ID_Liquido_Combinado INT,
    FOREIGN KEY (ID_Liquido_Combinado) REFERENCES Liquidos(ID_Liquido)
);

CREATE TABLE TransaccionDetalles (
    ID_Transaccion INT,
    ID_Liquido INT,
    Cantidad FLOAT,
    FOREIGN KEY (ID_Transaccion) REFERENCES Transacciones(ID_Transaccion),
    FOREIGN KEY (ID_Liquido) REFERENCES Liquidos(ID_Liquido),
    PRIMARY KEY (ID_Transaccion, ID_Liquido)
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'Agua', 'Beta', 300.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'Aceite', 'Beta', 700.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'LQ-2024-002', 'Combinado', 700.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'ALCO', 'Beta', 1000.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'ZURE', 'Beta', 1000.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'ALCO-ZURE-LQ', 'Beta', 1000.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'XURE4', 'Beta', 1000.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'YUHU', 'Beta', 1000.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'XURE4-YUHU', 'Beta', 1000.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);

INSERT INTO Liquidos (
    Codigo, Tipo_Liquido, Cantidad_total, Fecha_creacion, Proveedor, Metanol, Alcoholes_superiores, Porcentaje_Alcohol_vol, Orden_produccion
) VALUES (
    'XURE4-YUHU-ALCO-ZURE-LQ', 'Combinado', 1000.0, '2024-08-01', 'Proveedor XYZ', 0.0, 0.0, 0.0, 'OP-2024-002'
);


SELECT * FROM Liquidos;

INSERT INTO Transacciones (Fecha, ID_Liquido_Combinado)
VALUES ('2024-08-01', 10);

SELECT * FROM Transacciones;

INSERT INTO TransaccionDetalles (ID_Transaccion, ID_Liquido, Cantidad)
VALUES (5, 6, 300.0); -- 300 unidades de Aceite

INSERT INTO TransaccionDetalles (ID_Transaccion, ID_Liquido, Cantidad)
VALUES (5, 9, 300.0); -- 300 unidades de Aceite

INSERT INTO TransaccionDetalles (ID_Transaccion, ID_Liquido, Cantidad)
VALUES (2, 3, 300.0); -- 300 unidades de Aceite

SELECT * FROM TransaccionDetalles;

SELECT 
    t.ID_Transaccion,
    t.Fecha,
    l.ID_Liquido AS ID_Liquido_Combinado,
    l.Codigo AS Codigo_Combinado,
    l.Tipo_Liquido AS Tipo_Combinado,
    td.ID_Liquido AS ID_Liquido_Componente,
    lc.Codigo AS Codigo_Componente,
    lc.Tipo_Liquido AS Tipo_Componente,
    td.Cantidad
FROM 
    Transacciones t
JOIN 
    TransaccionDetalles td ON t.ID_Transaccion = td.ID_Transaccion
JOIN 
    Liquidos l ON t.ID_Liquido_Combinado = l.ID_Liquido
JOIN 
    Liquidos lc ON td.ID_Liquido = lc.ID_Liquido
WHERE 
    l.ID_Liquido = 10;

-- Supongamos que el nuevo ID_Transaccion para este registro es 1

WITH CTE_Trazabilidad AS (
    -- Selecciona los componentes directos del líquido combinado inicial
    SELECT 
        t.ID_Transaccion,
        t.Fecha,
        l.ID_Liquido AS ID_Liquido_Combinado,
        l.Codigo AS Codigo_Combinado,
        l.Tipo_Liquido AS Tipo_Combinado,
        td.ID_Liquido AS ID_Liquido_Componente,
        lc.Codigo AS Codigo_Componente,
        lc.Tipo_Liquido AS Tipo_Componente,
        td.Cantidad,
        0 AS Nivel -- Nivel inicial
    FROM 
        Transacciones t
    JOIN 
        TransaccionDetalles td ON t.ID_Transaccion = td.ID_Transaccion
    JOIN 
        Liquidos l ON t.ID_Liquido_Combinado = l.ID_Liquido
    JOIN 
        Liquidos lc ON td.ID_Liquido = lc.ID_Liquido
    WHERE 
        l.ID_Liquido = 10 -- ID del líquido combinado inicial

    UNION ALL

    -- Recursivamente selecciona los componentes de los líquidos combinados
    SELECT 
        t.ID_Transaccion,
        t.Fecha,
        l.ID_Liquido AS ID_Liquido_Combinado,
        l.Codigo AS Codigo_Combinado,
        l.Tipo_Liquido AS Tipo_Combinado,
        td.ID_Liquido AS ID_Liquido_Componente,
        lc.Codigo AS Codigo_Componente,
        lc.Tipo_Liquido AS Tipo_Componente,
        td.Cantidad,
        cte.Nivel + 1 -- Incrementar el nivel
    FROM 
        CTE_Trazabilidad cte
    JOIN 
        Transacciones t ON cte.ID_Liquido_Componente = t.ID_Liquido_Combinado
    JOIN 
        TransaccionDetalles td ON t.ID_Transaccion = td.ID_Transaccion
    JOIN 
        Liquidos l ON t.ID_Liquido_Combinado = l.ID_Liquido
    JOIN 
        Liquidos lc ON td.ID_Liquido = lc.ID_Liquido
)
SELECT *
FROM CTE_Trazabilidad
ORDER BY Nivel, ID_Transaccion, ID_Liquido_Combinado, ID_Liquido_Componente;