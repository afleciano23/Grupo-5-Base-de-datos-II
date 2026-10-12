USE TallerVehiculosDB;
GO

-- 1. Catálogos Base (Nivel 1)
INSERT INTO Clientes (nombre, apellido, telefono, email, direccion) VALUES
('Carlos', 'Pérez', '809-555-0192', 'carlos.perez@email.com', 'Av. 27 de Febrero, Santo Domingo'),
('María', 'Gómez', '829-555-8833', 'maria.gomez@email.com', 'Calle El Sol, Santiago');
GO

INSERT INTO Cargos (nombre_cargo, descripcion) VALUES
('Mecánico Senior', 'Especialista en motor y transmisión'),
('Asesor de Servicio', 'Atención al cliente y recepción de vehículos'),
('Cajero', 'Gestión de pagos y facturación');
GO

INSERT INTO Proveedores (nombre_empresa, telefono, email, direccion, persona_contacto) VALUES
('Repuestos Autocentro SRL', '809-533-1122', 'ventas@autocentro.com', 'Zona Industrial de Herrera', 'Roberto Mendez'),
('Lubricantes y Más', '809-567-4455', 'contacto@lubricantes.com', 'Ensanche La Fe', 'Ana Rosa');
GO

INSERT INTO Metodos_Pago (nombre_metodo, descripcion) VALUES
('Efectivo', 'Pago en moneda nacional'),
('Tarjeta de Crédito', 'Visa / MasterCard'),
('Transferencia Bancaria', 'Transferencia directa');
GO

INSERT INTO Servicios_Catalogo (nombre_servicio, descripcion, precio_base) VALUES
('Cambio de Aceite y Filtro', 'Sustitución de aceite de motor y filtro de aceite', 1500.00),
('Alineación y Balanceo', 'Servicio de geometría de dirección y ruedas', 1200.00),
('Diagnóstico Computarizado', 'Escaneo general de sensores y computadora del vehículo', 2000.00);
GO


-- 2. Tablas Dependientes (Nivel 2)
INSERT INTO Vehiculos (cliente_id, marca, modelo, anio, placa, color, tipo_vehiculo) VALUES
(1, 'Toyota', 'Corolla', 2018, 'A123456', 'Gris', 'Sedán'),
(2, 'Honda', 'Civic', 2020, 'B789012', 'Negro', 'Sedán');
GO

INSERT INTO Empleados (cargo_id, nombre, apellido, telefono, email, estado) VALUES
(1, 'Juan', 'Martínez', '809-111-2233', 'j.martinez@taller.com', 'Activo'),
(2, 'Laura', 'Jiménez', '809-444-5566', 'l.jimenez@taller.com', 'Activo');
GO

INSERT INTO Inventario (proveedor_id, nombre_producto, descripcion, cantidad_stock, precio_compra, precio_venta) VALUES
(1, 'Filtro de Aceite Toyota', 'Filtro original para motores 1.8L', 25, 300.00, 600.00),
(1, 'Aceite Sintético 5W-30 (Galón)', 'Aceite de motor de alta durabilidad', 40, 800.00, 1400.00),
(2, 'Pastillas de Freno Delanteras', 'Juego de pastillas cerámicas', 15, 1200.00, 2500.00);
GO

INSERT INTO Mecanicos_Especialidades (empleado_id, nombre_especialidad, nivel_experiencia) VALUES
(1, 'Motor y Suspensión', 'Senior');
GO

INSERT INTO Citas (cliente_id, vehiculo_id, fecha_cita, motivo, estado) VALUES
(1, 1, '2026-10-15 09:00:00', 'Mantenimiento rutinario de 50,000 km', 'Programada');
GO


-- 3. Núcleo Transaccional (Nivel 3)
-- Registrar una orden de servicio usando el Stored Procedure que creamos
EXEC sp_RegistrarOrdenServicio @vehiculo_id = 1, @empleado_id = 1, @descripcion_problema = 'Vehículo presenta ruido en la suspensión delantera y requiere cambio de aceite.';
GO

-- Verificamos la orden creada y generamos su factura usando el SP
-- (Asumiendo que la orden generada fue la ID = 1)
EXEC sp_GenerarFactura @orden_id = 1, @metodo_pago_id = 2, @monto_total = 2100.00, @observaciones = 'Pago realizado con tarjeta de crédito sin inconvenientes.';
GO