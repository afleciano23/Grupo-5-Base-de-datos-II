-- Creamos y usamos la base de datos para el proyecto
CREATE DATABASE TallerMantenimientoDB;
GO

USE TallerMantenimientoDB;
GO

-- ==========================================
-- NIVEL 1: TABLAS INDEPENDIENTES (CATÁLOGOS)
-- ==========================================

-- 1. Tabla CLIENTES
CREATE TABLE Clientes (
    cliente_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(150)
);
GO

-- 2. Tabla CARGOS (para los empleados)
CREATE TABLE Cargos (
    cargo_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_cargo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150)
);
GO

-- 3. Tabla PROVEEDORES (para el inventario de repuestos)
CREATE TABLE Proveedores (
    proveedor_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_empresa VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(150),
    persona_contacto VARCHAR(100)
);
GO




USE TallerMantenimientoDB;
GO

-- ==========================================
-- NIVEL 2: TABLAS CON DEPENDENCIAS (HIJAS)
-- ==========================================

-- 4. Tabla VEHICULOS (Depende de Clientes)
CREATE TABLE Vehiculos (
    vehiculo_id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INT,
    placa VARCHAR(20) UNIQUE NOT NULL,
    color VARCHAR(30),
    tipo_vehiculo VARCHAR(50),
    CONSTRAINT FK_Vehiculos_Clientes FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);
GO

-- 5. Tabla EMPLEADOS (Depende de Cargos)
CREATE TABLE Empleados (
    empleado_id INT IDENTITY(1,1) PRIMARY KEY,
    cargo_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_contratacion DATE,
    estado VARCHAR(20),
    CONSTRAINT FK_Empleados_Cargos FOREIGN KEY (cargo_id) REFERENCES Cargos(cargo_id)
);
GO

-- 6. Tabla INVENTARIO (Depende de Proveedores)
CREATE TABLE Inventario (
    inventario_id INT IDENTITY(1,1) PRIMARY KEY,
    proveedor_id INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    cantidad_stock INT NOT NULL,
    precio_compra DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    fecha_ingreso DATE,
    CONSTRAINT FK_Inventario_Proveedores FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id)
);
GO



-- =====================================================
-- NIVEL 3: NÚCLEO OPERATIVO Y TRANSACCIONAL
-- =====================================================

-- 7. Tabla ORDEN_SERVICIO (Depende de Vehiculos y Empleados)
CREATE TABLE Orden_Servicio (
    orden_id INT IDENTITY(1,1) PRIMARY KEY,
    vehiculo_id INT NOT NULL,
    empleado_id INT NOT NULL,
    fecha_entrada DATETIME NOT NULL,
    fecha_salida DATETIME,
    descripcion_problema TEXT NOT NULL,
    estado VARCHAR(30) NOT NULL,
    total_servicio DECIMAL(10,2),
    CONSTRAINT FK_OrdenServicio_Vehiculos FOREIGN KEY (vehiculo_id) REFERENCES Vehiculos(vehiculo_id),
    CONSTRAINT FK_OrdenServicio_Empleados FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
);
GO

-- 8. Tabla FACTURACION (Depende de Orden_Servicio)
CREATE TABLE Facturacion (
    factura_id INT IDENTITY(1,1) PRIMARY KEY,
    orden_id INT NOT NULL,
    fecha_factura DATETIME NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    estado VARCHAR(30) NOT NULL,
    observaciones TEXT,
    CONSTRAINT FK_Facturacion_OrdenServicio FOREIGN KEY (orden_id) REFERENCES Orden_Servicio(orden_id)
);
GO

-- 9. Tabla DETALLE_FACTURA (Depende de Facturacion e Inventario)
CREATE TABLE Detalle_Factura (
    detalle_id INT IDENTITY(1,1) PRIMARY KEY,
    factura_id INT NOT NULL,
    inventario_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_DetalleFactura_Facturacion FOREIGN KEY (factura_id) REFERENCES Facturacion(factura_id),
    CONSTRAINT FK_DetalleFactura_Inventario FOREIGN KEY (inventario_id) REFERENCES Inventario(inventario_id)
);
GO