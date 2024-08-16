
-- Use this database;
USE casalumbre_db;

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

-- Insert multiple container locations into the ubicaciones_contenedor table
INSERT INTO ubicaciones_contenedor (descripcion) VALUES 
('DM4'),
('ODT-ENV'),
('BETA'),
('ODT1'),
('LAB');

-- Insert multiple status descriptions into the estatus_contenedor table
INSERT INTO estatus_contenedor (descripcion) VALUES 
('EN USO'),
('DISPONIBLE'),
('NO DISPONIBLE'),
('DAÑADO'),
('CUARENTENA');

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

-- Insert multiple status descriptions into the estatus_liquido table
INSERT INTO estatus_liquido (descripcion) VALUES 
('CUARENTENA'),
('APROBADO 1'),
('APROBADO 2'),
('EN PROCESO');

-- Insert multiple supplier names into the proveedores table
INSERT INTO proveedores (nombre) VALUES 
('Proveedor A'),
('Proveedor B'),
('Proveedor C'),
('Proveedor D'),
('Proveedor E');

-- Insert the initial liquid types into the tipo_liquido table
INSERT INTO tipo_liquido (descripcion) VALUES 
('alpha'),
('beta');

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

-- Ensure the containers are "EN USO" and the liquids are not "CUARENTENA"
INSERT INTO transacciones_liquido_contenedor (id_contenedor, id_liquido, cantidad_liquido_lts, persona_encargada, id_estatus) VALUES
(1, 1, 300.00, 'User A', 2), -- Contenedor 1 (EN USO), Liquido 1 (not CUARENTENA)
(2, 2, 200.00, 'User B', 2), -- Contenedor 2 (EN USO), Liquido 2 (not CUARENTENA)
(3, 3, 500.00, 'User C', 2), -- Contenedor 3 (EN USO), Liquido 3 (not CUARENTENA)
(4, 4, 400.00, 'User D', 2), -- Contenedor 4 (EN USO), Liquido 4 (not CUARENTENA)
(5, 5, 350.00, 'User E', 2); -- Contenedor 5 (EN USO), Liquido 5 (not CUARENTENA)

----- REMEMBER ISERT DUMMY DATA INTO productos_teminados ------
