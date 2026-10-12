-- =====================================================================
-- PROYECTO FINAL: Taller de Mantenimiento de Vehículos (Script Maestro)
-- NUEVA BASE DE DATOS: TallerVehiculosDB
-- MATERIA: Bases de Datos II
-- =====================================================================

CREATE DATABASE TallerVehiculosDB;
GO

USE TallerVehiculosDB;
GO

-- =====================================================================
-- 1. CREACIÓN DE LAS 15 TABLAS (ESTRUCTURA Y RESTRICCIONES)
-- =====================================================================

-- NIVEL 1: CATÁLOGOS INDEPENDIENTES
CREATE TABLE Clientes (
    cliente_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(150),
    fecha_registro DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Cargos (
    cargo_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_cargo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150)
);
GO

CREATE TABLE Proveedores (
    proveedor_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_empresa VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(150),
    persona_contacto VARCHAR(100)
);
GO

CREATE TABLE Metodos_Pago (
    metodo_pago_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_metodo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100)
);
GO

CREATE TABLE Servicios_Catalogo (
    servicio_catalogo_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_servicio VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10,2) CHECK (precio_base >= 0)
);
GO

-- NIVEL 2: DEPENDIENTES DIRECTOS
CREATE TABLE Vehiculos (
    vehiculo_id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INT CHECK (anio >= 1900),
    placa VARCHAR(20) UNIQUE NOT NULL,
    color VARCHAR(30),
    tipo_vehiculo VARCHAR(50),
    CONSTRAINT FK_Vehiculos_Clientes FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);
GO

CREATE TABLE Empleados (
    empleado_id INT IDENTITY(1,1) PRIMARY KEY,
    cargo_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_contratacion DATE DEFAULT GETDATE(),
    estado VARCHAR(20) DEFAULT 'Activo',
    CONSTRAINT FK_Empleados_Cargos FOREIGN KEY (cargo_id) REFERENCES Cargos(cargo_id)
);
GO

CREATE TABLE Inventario (
    inventario_id INT IDENTITY(1,1) PRIMARY KEY,
    proveedor_id INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    cantidad_stock INT CHECK (cantidad_stock >= 0) NOT NULL,
    precio_compra DECIMAL(10,2) CHECK (precio_compra >= 0) NOT NULL,
    precio_venta DECIMAL(10,2) CHECK (precio_venta >= 0) NOT NULL,
    fecha_ingreso DATE DEFAULT GETDATE(),
    CONSTRAINT FK_Inventario_Proveedores FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id)
);
GO

CREATE TABLE Mecanicos_Especialidades (
    especialidad_id INT IDENTITY(1,1) PRIMARY KEY,
    empleado_id INT NOT NULL,
    nombre_especialidad VARCHAR(100) NOT NULL,
    nivel_experiencia VARCHAR(30),
    CONSTRAINT FK_Mecanicos_Empleados FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
);
GO

CREATE TABLE Citas (
    cita_id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NOT NULL,
    vehiculo_id INT NOT NULL,
    fecha_cita DATETIME NOT NULL,
    motivo VARCHAR(255),
    estado VARCHAR(30) DEFAULT 'Programada',
    CONSTRAINT FK_Citas_Clientes FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id),
    CONSTRAINT FK_Citas_Vehiculos FOREIGN KEY (vehiculo_id) REFERENCES Vehiculos(vehiculo_id)
);
GO

-- NIVEL 3: NÚCLEO OPERATIVO Y TRANSACCIONAL
CREATE TABLE Orden_Servicio (
    orden_id INT IDENTITY(1,1) PRIMARY KEY,
    vehiculo_id INT NOT NULL,
    empleado_id INT NOT NULL,
    fecha_entrada DATETIME DEFAULT GETDATE(),
    fecha_salida DATETIME,
    descripcion_problema TEXT NOT NULL,
    estado VARCHAR(30) DEFAULT 'En Proceso',
    total_servicio DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT FK_OrdenServicio_Vehiculos FOREIGN KEY (vehiculo_id) REFERENCES Vehiculos(vehiculo_id),
    CONSTRAINT FK_OrdenServicio_Empleados FOREIGN KEY (empleado_id) REFERENCES Empleados(empleado_id)
);
GO

CREATE TABLE Detalle_Orden_Servicios (
    detalle_orden_id INT IDENTITY(1,1) PRIMARY KEY,
    orden_id INT NOT NULL,
    servicio_catalogo_id INT NOT NULL,
    costo_aplicado DECIMAL(10,2) CHECK (costo_aplicado >= 0) NOT NULL,
    observaciones VARCHAR(200),
    CONSTRAINT FK_DetOrden_Orden FOREIGN KEY (orden_id) REFERENCES Orden_Servicio(orden_id),
    CONSTRAINT FK_DetOrden_ServCat FOREIGN KEY (servicio_catalogo_id) REFERENCES Servicios_Catalogo(servicio_catalogo_id)
);
GO

CREATE TABLE Facturacion (
    factura_id INT IDENTITY(1,1) PRIMARY KEY,
    orden_id INT NOT NULL,
    metodo_pago_id INT NOT NULL,
    fecha_factura DATETIME DEFAULT GETDATE(),
    monto_total DECIMAL(10,2) NOT NULL,
    estado VARCHAR(30) DEFAULT 'Pagada',
    observaciones TEXT,
    CONSTRAINT FK_Facturacion_OrdenServicio FOREIGN KEY (orden_id) REFERENCES Orden_Servicio(orden_id),
    CONSTRAINT FK_Facturacion_MetodoPago FOREIGN KEY (metodo_pago_id) REFERENCES Metodos_Pago(metodo_pago_id)
);
GO

CREATE TABLE Detalle_Factura (
    detalle_factura_id INT IDENTITY(1,1) PRIMARY KEY,
    factura_id INT NOT NULL,
    inventario_id INT NOT NULL,
    cantidad INT CHECK (cantidad > 0) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_DetalleFactura_Facturacion FOREIGN KEY (factura_id) REFERENCES Facturacion(factura_id),
    CONSTRAINT FK_DetalleFactura_Inventario FOREIGN KEY (inventario_id) REFERENCES Inventario(inventario_id)
);
GO

CREATE TABLE Bitacora_Auditoria (
    auditoria_id INT IDENTITY(1,1) PRIMARY KEY,
    tabla_afectada VARCHAR(50) NOT NULL,
    accion VARCHAR(50) NOT NULL,
    usuario_bd VARCHAR(50) DEFAULT SYSTEM_USER,
    fecha_evento DATETIME DEFAULT GETDATE(),
    detalle VARCHAR(255)
);
GO

-- =====================================================================
-- 2. ÍNDICES
-- =====================================================================
CREATE INDEX IX_Vehiculos_Placa ON Vehiculos(placa);
CREATE INDEX IX_Clientes_Email ON Clientes(email);
CREATE INDEX IX_OrdenServicio_Fechas ON Orden_Servicio(fecha_entrada);
GO

-- =====================================================================
-- 3. OBJETOS AVANZADOS
-- =====================================================================

-- Usuarios y Logins (Con validación por si ya existen en la instancia)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'UserAdministrador')
    CREATE LOGIN UserAdministrador WITH PASSWORD = 'PasswordSeguro123*';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'UserCajero')
    CREATE LOGIN UserCajero WITH PASSWORD = 'PasswordSeguro123*';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'UserMecanico')
    CREATE LOGIN UserMecanico WITH PASSWORD = 'PasswordSeguro123*';
GO

CREATE USER AdminDB FOR LOGIN UserAdministrador;
CREATE USER CajeroDB FOR LOGIN UserCajero;
CREATE USER MecanicoDB FOR LOGIN UserMecanico;
GO

-- Vistas (Por lo menos tres)
CREATE VIEW vw_VehiculosClientes AS
SELECT v.vehiculo_id, c.nombre + ' ' + c.apellido AS Propietario, c.telefono, v.marca, v.modelo, v.placa, v.anio
FROM Vehiculos v INNER JOIN Clientes c ON v.cliente_id = c.cliente_id;
GO

CREATE VIEW vw_OrdenesActivas AS
SELECT o.orden_id, v.placa AS PlacaVehiculo, e.nombre + ' ' + e.apellido AS MecanicoAsignado, o.fecha_entrada, o.estado, o.descripcion_problema
FROM Orden_Servicio o INNER JOIN Vehiculos v ON o.vehiculo_id = v.vehiculo_id INNER JOIN Empleados e ON o.empleado_id = e.empleado_id
WHERE o.estado = 'En Proceso';
GO

CREATE VIEW vw_ResumenFacturacion AS
SELECT f.factura_id, f.fecha_factura, c.nombre + ' ' + c.apellido AS Cliente, mp.nombre_metodo AS MetodoPago, f.monto_total, f.estado
FROM Facturacion f INNER JOIN Orden_Servicio o ON f.orden_id = o.orden_id INNER JOIN Vehiculos v ON o.vehiculo_id = v.vehiculo_id INNER JOIN Clientes c ON v.cliente_id = c.cliente_id INNER JOIN Metodos_Pago mp ON f.metodo_pago_id = mp.metodo_pago_id;
GO

-- Triggers (Por lo menos tres)
CREATE TRIGGER trg_ActualizarStockFactura ON Detalle_Factura AFTER INSERT AS
BEGIN
    UPDATE i SET i.cantidad_stock = i.cantidad_stock - ins.cantidad
    FROM Inventario i INNER JOIN inserted ins ON i.inventario_id = ins.inventario_id;
END;
GO

CREATE TRIGGER trg_AuditoriaPrecioInventario ON Inventario AFTER UPDATE AS
BEGIN
    IF UPDATE(precio_venta)
    BEGIN
        INSERT INTO Bitacora_Auditoria (tabla_afectada, accion, detalle)
        SELECT 'Inventario', 'UPDATE PRECIO', 'Producto ID: ' + CAST(i.inventario_id AS VARCHAR) + ' - Precio anterior: ' + CAST(d.precio_venta AS VARCHAR) + ' -> Nuevo precio: ' + CAST(i.precio_venta AS VARCHAR)
        FROM inserted i INNER JOIN deleted d ON i.inventario_id = d.inventario_id;
    END
END;
GO

CREATE TRIGGER trg_CerrarOrdenAlFacturar ON Facturacion AFTER INSERT AS
BEGIN
    UPDATE o SET o.estado = 'Finalizada', o.fecha_salida = GETDATE()
    FROM Orden_Servicio o INNER JOIN inserted ins ON o.orden_id = ins.orden_id;
END;
GO

-- Stored Procedures (Por lo menos tres)
CREATE PROCEDURE sp_RegistrarOrdenServicio @vehiculo_id INT, @empleado_id INT, @descripcion_problema TEXT AS
BEGIN
    INSERT INTO Orden_Servicio (vehiculo_id, empleado_id, descripcion_problema, estado, total_servicio)
    VALUES (@vehiculo_id, @empleado_id, @descripcion_problema, 'En Proceso', 0.00);
END;
GO

CREATE PROCEDURE sp_GenerarFactura @orden_id INT, @metodo_pago_id INT, @monto_total DECIMAL(10,2), @observaciones TEXT AS
BEGIN
    INSERT INTO Facturacion (orden_id, metodo_pago_id, monto_total, observaciones)
    VALUES (@orden_id, @metodo_pago_id, @monto_total, @observaciones);
END;
GO

CREATE PROCEDURE sp_ConsultarHistorialVehiculo @placa VARCHAR(20) AS
BEGIN
    SELECT v.placa, v.marca, v.modelo, o.orden_id, o.fecha_entrada, o.fecha_salida, o.descripcion_problema, o.estado
    FROM Vehiculos v INNER JOIN Orden_Servicio o ON v.vehiculo_id = o.vehiculo_id
    WHERE v.placa = @placa;
END;
GO

-- Sinónimos (Por lo menos tres)
CREATE SYNONYM syn_Clientes FOR Clientes;
CREATE SYNONYM syn_Vehiculos FOR Vehiculos;
CREATE SYNONYM syn_Facturas FOR Facturacion;
GO