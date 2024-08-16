
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

-- Drop the table if it exists
IF OBJECT_ID('dbo.ubicaciones_contenedor', 'U') IS NOT NULL
DROP TABLE dbo.ubicaciones_contenedor;
GO

-- Create the table with the correct structure
CREATE TABLE ubicaciones_contenedor (
    id_ubicacion_contenedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the container location
    descripcion VARCHAR(32) NOT NULL -- Description of the container location
);

-- Drop the table if it exists
IF OBJECT_ID('dbo.estatus_contenedor', 'U') IS NOT NULL
DROP TABLE dbo.estatus_contenedor;
GO

-- Create the table with the correct structure
CREATE TABLE estatus_contenedor (
    id_estatus_contenedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the container status
    descripcion VARCHAR(32) NOT NULL -- Description of the container status
);

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

-- Drop the table if it exists
IF OBJECT_ID('dbo.estatus_liquido', 'U') IS NOT NULL
DROP TABLE dbo.estatus_liquido;
GO

-- Create the table with the correct structure
CREATE TABLE estatus_liquido (
    id_estatus_liquido INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the liquid status
    descripcion VARCHAR(32) NOT NULL -- Description of the liquid status
);

-- Drop the table if it exists
IF OBJECT_ID('dbo.proveedores', 'U') IS NOT NULL
DROP TABLE dbo.proveedores;
GO

-- Create the table with the correct structure
CREATE TABLE proveedores (
    id_proveedor INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the supplier
    nombre VARCHAR(32) NOT NULL -- Name of the supplier
);

-- Drop the table if it exists
IF OBJECT_ID('dbo.tipo_liquido', 'U') IS NOT NULL
DROP TABLE dbo.tipo_liquido;
GO

-- Create the table with the correct structure
CREATE TABLE tipo_liquido (
    id_tipo_liquido INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Unique identifier for the liquid type
    descripcion VARCHAR(32) NOT NULL -- Description of the liquid type
);

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
