/* ============================================================
Este es un cambio minimo para la rama vistas
   PROYECTO: Hotel "Estrella del Valle"
   MOTOR   : SQL Server / SQL Server Express
   OBJETIVO: BD empresarial para reservaciones, clientes y pagos
   INCLUYE:
     - Creación de BD y tablas
     - Datos de ejemplo
     - Consultas básicas y avanzadas
     - Lógica de conjuntos y transacciones
     - DML (INSERT, UPDATE, DELETE)
     - Procedimientos almacenados
     - Funciones
     - Vistas
     - Triggers
     - CTEs
     - Backups y RESTORE (comentados)
-- Línea desde FEATURE/VISTAS
   ============================================================ */

---------------------------------------------------------------
-- PASO 1. CREAR BASE DE DATOS
---------------------------------------------------------------
IF DB_ID('HotelEstrellaDelValle') IS NOT NULL
BEGIN
    ALTER DATABASE HotelEstrellaDelValle 
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HotelEstrellaDelValle;
END;
GO

CREATE DATABASE HotelEstrellaDelValle;
GO

USE HotelEstrellaDelValle;
GO

---------------------------------------------------------------
-- PASO 2. CREAR TABLAS PRINCIPALES
---------------------------------------------------------------

-------------------------
-- Tabla: Clientes
-------------------------
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL
    DROP TABLE dbo.Clientes;
GO

CREATE TABLE dbo.Clientes (
    IdCliente      INT IDENTITY(1,1) CONSTRAINT PK_Clientes PRIMARY KEY,
    Nombre         NVARCHAR(50)  NOT NULL,
    Apellidos      NVARCHAR(70)  NOT NULL,
    Telefono       VARCHAR(20)   NULL,
    Email          NVARCHAR(100) NULL,
    Estado         VARCHAR(10)   NOT NULL 
        CONSTRAINT CK_Clientes_Estado
        CHECK (Estado IN ('ACTIVO','INACTIVO'))
        DEFAULT 'ACTIVO'
);
GO

-------------------------
-- Tabla: Habitaciones
-------------------------
IF OBJECT_ID('dbo.Habitaciones', 'U') IS NOT NULL
    DROP TABLE dbo.Habitaciones;
GO

CREATE TABLE dbo.Habitaciones (
    IdHabitacion     INT IDENTITY(1,1) CONSTRAINT PK_Habitaciones PRIMARY KEY,
    Numero           INT           NOT NULL UNIQUE,
    Tipo             VARCHAR(20)   NOT NULL 
        CONSTRAINT CK_Habitaciones_Tipo
        CHECK (Tipo IN ('SENCILLA','DOBLE','SUITE')),
    PrecioPorNoche   DECIMAL(10,2) NOT NULL 
        CONSTRAINT CK_Habitaciones_Precio CHECK (PrecioPorNoche >= 0),
    Activa           BIT NOT NULL DEFAULT 1
);
GO

-------------------------
-- Tabla: Reservaciones
-------------------------
IF OBJECT_ID('dbo.Reservaciones', 'U') IS NOT NULL
    DROP TABLE dbo.Reservaciones;
GO

CREATE TABLE dbo.Reservaciones (
    IdReserva       INT IDENTITY(1,1) CONSTRAINT PK_Reservaciones PRIMARY KEY,
    IdCliente       INT NOT NULL,
    IdHabitacion    INT NOT NULL,
    FechaEntrada    DATE NOT NULL,
    FechaSalida     DATE NOT NULL,
    CantidadNoches  INT           NULL,
    MontoTotal      DECIMAL(10,2) NULL,
    EstadoReserva   VARCHAR(20) NOT NULL
        CONSTRAINT CK_Reservaciones_Estado
        CHECK (EstadoReserva IN ('ACTIVA','CANCELADA','FINALIZADA')) 
        DEFAULT 'ACTIVA',

    CONSTRAINT FK_Reservaciones_Clientes
        FOREIGN KEY (IdCliente) REFERENCES dbo.Clientes(IdCliente),

    CONSTRAINT FK_Reservaciones_Habitaciones
        FOREIGN KEY (IdHabitacion) REFERENCES dbo.Habitaciones(IdHabitacion),

    CONSTRAINT CK_Reservaciones_Fechas
        CHECK (FechaSalida > FechaEntrada)
);
GO

-------------------------
-- Tabla: Pagos
-------------------------
IF OBJECT_ID('dbo.Pagos', 'U') IS NOT NULL
    DROP TABLE dbo.Pagos;
GO

CREATE TABLE dbo.Pagos (
    IdPago       INT IDENTITY(1,1) CONSTRAINT PK_Pagos PRIMARY KEY,
    IdReserva    INT NOT NULL,
    Monto        DECIMAL(10,2) NOT NULL 
        CONSTRAINT CK_Pagos_Monto CHECK (Monto >= 0),
    FechaPago    DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    MetodoPago   VARCHAR(20) NOT NULL
        CONSTRAINT CK_Pagos_Metodo
        CHECK (MetodoPago IN ('EFECTIVO','TARJETA','TRANSFERENCIA')),

    CONSTRAINT FK_Pagos_Reservaciones
        FOREIGN KEY (IdReserva) REFERENCES dbo.Reservaciones(IdReserva)
);
GO

-------------------------
-- Tabla: LogHabitaciones (para trigger)
-------------------------
IF OBJECT_ID('dbo.LogHabitaciones', 'U') IS NOT NULL
    DROP TABLE dbo.LogHabitaciones;
GO

CREATE TABLE dbo.LogHabitaciones (
    IdLog         INT IDENTITY(1,1) CONSTRAINT PK_LogHabitaciones PRIMARY KEY,
    IdHabitacion  INT NOT NULL,
    Usuario       NVARCHAR(128) NOT NULL,
    Fecha         DATETIME      NOT NULL DEFAULT SYSDATETIME(),
    TipoCambio    VARCHAR(50)   NOT NULL,
    CONSTRAINT FK_LogHabitaciones_Habitaciones
        FOREIGN KEY (IdHabitacion) REFERENCES dbo.Habitaciones(IdHabitacion)
);
GO

---------------------------------------------------------------
-- PASO 3. INSERCIÓN DE DATOS
--  - 10 clientes
--  - 10 habitaciones
--  - 15 reservaciones
--  - 15 pagos
---------------------------------------------------------------

-------------------------
-- Insertar Clientes
-------------------------
INSERT INTO dbo.Clientes (Nombre, Apellidos, Telefono, Email, Estado)
VALUES
(N'Juan',   N'Pérez López',      '8888-0001', N'juan.perez@example.com',   'ACTIVO'),
(N'Ana',    N'Gómez Castro',     '8888-0002', N'ana.gomez@example.com',    'ACTIVO'),
(N'Carlos', N'Rodríguez Mora',   '8888-0003', N'carlos.rod@example.com',   'ACTIVO'),
(N'Laura',  N'Salas Rojas',      '8888-0004', N'laura.salas@example.com',  'INACTIVO'),
(N'Mario',  N'Hernández Díaz',   '8888-0005', N'mario.hdz@example.com',    'ACTIVO'),
(N'Sofía',  N'Navarro Pineda',   '8888-0006', N'sofia.nav@example.com',    'ACTIVO'),
(N'Andrés', N'Córdoba Jiménez',  '8888-0007', N'andres.cj@example.com',    'ACTIVO'),
(N'Lucía',  N'Campos Aguilar',   '8888-0008', N'lucia.campos@example.com', 'INACTIVO'),
(N'Pedro',  N'Chacón Vargas',    '8888-0009', N'pedro.cv@example.com',     'ACTIVO'),
(N'Elena',  N'Montealegre Ruiz', '8888-0010', N'elena.mr@example.com',     'ACTIVO');
GO

-------------------------
-- Insertar Habitaciones
-------------------------
INSERT INTO dbo.Habitaciones (Numero, Tipo, PrecioPorNoche, Activa)
VALUES
(101, 'SENCILLA', 45000, 1),
(102, 'SENCILLA', 45000, 1),
(103, 'DOBLE',    65000, 1),
(104, 'DOBLE',    65000, 1),
(105, 'SUITE',   120000, 1),
(201, 'SENCILLA', 48000, 1),
(202, 'DOBLE',    70000, 1),
(203, 'SUITE',   130000, 1),
(204, 'SENCILLA', 46000, 1),
(205, 'SUITE',   140000, 0);
GO

-------------------------
-- Insertar Reservaciones (fechas relativas a hoy)
-------------------------
DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

INSERT INTO dbo.Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal, EstadoReserva)
VALUES
(
    1,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 101),
    DATEADD(DAY, -10, @Hoy),
    DATEADD(DAY, -8,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    2,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 102),
    DATEADD(DAY, -7,  @Hoy),
    DATEADD(DAY, -5,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    3,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 103),
    DATEADD(DAY, -3,  @Hoy),
    DATEADD(DAY, -1,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    4,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 104),
    DATEADD(DAY, -2,  @Hoy),
    DATEADD(DAY,  1,  @Hoy),
    NULL, NULL, 'ACTIVA'
),
(
    5,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 105),
    DATEADD(DAY,  1,  @Hoy),
    DATEADD(DAY,  4,  @Hoy),
    NULL, NULL, 'ACTIVA'
),
(
    6,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 201),
    DATEADD(DAY, -15, @Hoy),
    DATEADD(DAY, -13, @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    7,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 202),
    DATEADD(DAY, -20, @Hoy),
    DATEADD(DAY, -16, @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    8,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 203),
    DATEADD(DAY, -1,  @Hoy),
    DATEADD(DAY,  2,  @Hoy),
    NULL, NULL, 'ACTIVA'
),
(
    9,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 204),
    DATEADD(DAY, -30, @Hoy),
    DATEADD(DAY, -28, @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    10,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 205),
    DATEADD(DAY, -40, @Hoy),
    DATEADD(DAY, -35, @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    1,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 103),
    DATEADD(DAY, -5,  @Hoy),
    DATEADD(DAY, -3,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    2,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 104),
    DATEADD(DAY, -12, @Hoy),
    DATEADD(DAY, -9,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    3,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 201),
    DATEADD(DAY, -8,  @Hoy),
    DATEADD(DAY, -6,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    4,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 202),
    DATEADD(DAY,  3,  @Hoy),
    DATEADD(DAY,  6,  @Hoy),
    NULL, NULL, 'ACTIVA'
),
(
    5,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 203),
    DATEADD(DAY,  5,  @Hoy),
    DATEADD(DAY,  7,  @Hoy),
    NULL, NULL, 'ACTIVA'
);
GO

-------------------------
-- Insertar Pagos (15 pagos)
-------------------------
DECLARE @HoyPagos DATE = CAST(GETDATE() AS DATE);

INSERT INTO dbo.Pagos (IdReserva, Monto, FechaPago, MetodoPago)
VALUES
(1,  90000,  DATEADD(DAY, -9,  @HoyPagos), 'EFECTIVO'),
(2,  90000,  DATEADD(DAY, -4,  @HoyPagos), 'TARJETA'),
(3, 130000,  DATEADD(DAY, -1,  @HoyPagos), 'TARJETA'),
(6,  96000,  DATEADD(DAY, -14, @HoyPagos), 'EFECTIVO'),
(7, 280000,  DATEADD(DAY, -19, @HoyPagos), 'TRANSFERENCIA'),
(9,  92000,  DATEADD(DAY, -29, @HoyPagos), 'EFECTIVO'),
(10,700000,  DATEADD(DAY, -36, @HoyPagos), 'TRANSFERENCIA'),
(11,130000,  DATEADD(DAY, -4,  @HoyPagos), 'TARJETA'),
(12,195000,  DATEADD(DAY, -11, @HoyPagos), 'EFECTIVO'),
(13, 96000,  DATEADD(DAY, -7,  @HoyPagos), 'EFECTIVO'),
(1,  10000,  DATEADD(DAY, -8,  @HoyPagos), 'EFECTIVO'),
(3,  20000,  DATEADD(DAY,  0,  @HoyPagos), 'TARJETA'),
(6,  15000,  DATEADD(DAY, -13, @HoyPagos), 'TRANSFERENCIA'),
(7,  30000,  DATEADD(DAY, -18, @HoyPagos), 'TARJETA'),
(9,  5000,   DATEADD(DAY, -28, @HoyPagos), 'EFECTIVO');
GO

---------------------------------------------------------------
-- PASO 4. CONSULTAS BÁSICAS
---------------------------------------------------------------

-- 4.1 Listar todos los clientes ordenados por apellido
SELECT *
FROM dbo.Clientes
ORDER BY Apellidos, Nombre;
GO

-- 4.2 Listar habitaciones de mayor a menor precio
SELECT *
FROM dbo.Habitaciones
ORDER BY PrecioPorNoche DESC;
GO

-- 4.3 Mostrar reservaciones en un rango de fechas (último mes)
DECLARE @HoyRango DATE = CAST(GETDATE() AS DATE);
DECLARE @HaceUnMes DATE = DATEADD(MONTH, -1, @HoyRango);

SELECT *
FROM dbo.Reservaciones
WHERE FechaEntrada BETWEEN @HaceUnMes AND @HoyRango
ORDER BY FechaEntrada;
GO

---------------------------------------------------------------
-- PASO 5. CONSULTAS AVANZADAS (JOIN, SUBCONSULTAS, WHERE)
---------------------------------------------------------------

-- 5.1 JOIN entre Reservaciones, Habitaciones y Clientes
SELECT 
    r.IdReserva,
    c.Nombre + ' ' + c.Apellidos AS Cliente,
    h.Numero AS NumeroHabitacion,
    h.Tipo,
    r.FechaEntrada,
    r.FechaSalida,
    r.EstadoReserva
FROM dbo.Reservaciones r
JOIN dbo.Clientes     c ON r.IdCliente    = c.IdCliente
JOIN dbo.Habitaciones h ON r.IdHabitacion = h.IdHabitacion
ORDER BY r.FechaEntrada;
GO

-- 5.2 JOIN para pagos por cliente
SELECT 
    c.IdCliente,
    c.Nombre + ' ' + c.Apellidos AS Cliente,
    r.IdReserva,
    p.IdPago,
    p.Monto,
    p.FechaPago,
    p.MetodoPago
FROM dbo.Pagos p
JOIN dbo.Reservaciones r ON p.IdReserva = r.IdReserva
JOIN dbo.Clientes     c ON r.IdCliente  = c.IdCliente
ORDER BY c.Apellidos, c.Nombre, p.FechaPago;
GO

-- 5.3 Subconsulta: clientes que han hecho más de una reserva
SELECT 
    c.IdCliente,
    c.Nombre,
    c.Apellidos,
    (SELECT COUNT(*) 
     FROM dbo.Reservaciones r 
     WHERE r.IdCliente = c.IdCliente) AS TotalReservas
FROM dbo.Clientes c
WHERE (SELECT COUNT(*) 
       FROM dbo.Reservaciones r 
       WHERE r.IdCliente = c.IdCliente) > 1;
GO

-- 5.4 Consultas con WHERE (>, <, LIKE, BETWEEN)
-- Clientes cuyo apellido contiene 'a'
SELECT * 
FROM dbo.Clientes 
WHERE Apellidos LIKE '%a%';

-- Habitaciones con precio entre 50,000 y 120,000
SELECT * 
FROM dbo.Habitaciones 
WHERE PrecioPorNoche BETWEEN 50000 AND 120000;

-- Reservaciones futuras (mayores a hoy)
DECLARE @HoyFuturo DATE = CAST(GETDATE() AS DATE);
SELECT * 
FROM dbo.Reservaciones 
WHERE FechaEntrada > @HoyFuturo;
GO

---------------------------------------------------------------
-- PASO 6. LÓGICA DE CONJUNTOS Y TRANSACCIONES
---------------------------------------------------------------

-- 6.1 UNION entre clientes activos e inactivos
SELECT IdCliente, Nombre, Apellidos, Estado
FROM dbo.Clientes
WHERE Estado = 'ACTIVO'
UNION
SELECT IdCliente, Nombre, Apellidos, Estado
FROM dbo.Clientes
WHERE Estado = 'INACTIVO';
GO

-- 6.2 INTERSECT: clientes que tienen reservaciones Y pagos
SELECT DISTINCT r.IdCliente
FROM dbo.Reservaciones r
INTERSECT
SELECT DISTINCT r2.IdCliente
FROM dbo.Reservaciones r2
JOIN dbo.Pagos p ON r2.IdReserva = p.IdReserva;
GO

-- 6.3 EXCEPT: habitaciones que NO tienen reservación
SELECT h.IdHabitacion, h.Numero
FROM dbo.Habitaciones h
EXCEPT
SELECT DISTINCT r.IdHabitacion, h.Numero
FROM dbo.Reservaciones r
JOIN dbo.Habitaciones h ON r.IdHabitacion = h.IdHabitacion;
GO

---------------------------------------------------------------
-- 6.4 TRANSACCIÓN: nueva reservación + pago
---------------------------------------------------------------
DECLARE 
    @HoyTran          DATE = CAST(GETDATE() AS DATE),
    @IdClienteTran    INT = 1,
    @IdHabitacionTran INT = (SELECT TOP 1 IdHabitacion FROM dbo.Habitaciones WHERE Numero = 101),
    @FechaEntradaTran DATE = DATEADD(DAY, 2, @HoyTran),
    @FechaSalidaTran  DATE = DATEADD(DAY, 5, @HoyTran),
    @MetodoPagoTran   VARCHAR(20) = 'TARJETA',
    @IdReservaNueva   INT,
    @PrecioNocheTran  DECIMAL(10,2),
    @NochesTran       INT,
    @MontoTran        DECIMAL(10,2);

BEGIN TRY
    BEGIN TRAN;

    SELECT @PrecioNocheTran = PrecioPorNoche
    FROM dbo.Habitaciones
    WHERE IdHabitacion = @IdHabitacionTran;

    IF @PrecioNocheTran IS NULL
        RAISERROR('La habitación no existe.', 16, 1);

    SET @NochesTran = DATEDIFF(DAY, @FechaEntradaTran, @FechaSalidaTran);
    IF @NochesTran <= 0 SET @NochesTran = 1;

    SET @MontoTran = @NochesTran * @PrecioNocheTran;

    INSERT INTO dbo.Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal, EstadoReserva)
    VALUES (@IdClienteTran, @IdHabitacionTran, @FechaEntradaTran, @FechaSalidaTran, @NochesTran, @MontoTran, 'ACTIVA');

    SET @IdReservaNueva = SCOPE_IDENTITY();

    INSERT INTO dbo.Pagos (IdReserva, Monto, FechaPago, MetodoPago)
    VALUES (@IdReservaNueva, @MontoTran, @HoyTran, @MetodoPagoTran);

    COMMIT TRAN;
    PRINT 'Transacción completada correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT 'Error en la transacción: ' + ERROR_MESSAGE();
END CATCH;
GO

---------------------------------------------------------------
-- PASO 7. MANIPULACIÓN DE DATOS (INSERT, UPDATE, DELETE)
---------------------------------------------------------------

-- 7.1 Actualizar precio de una habitación según tipo
UPDATE dbo.Habitaciones
SET PrecioPorNoche = PrecioPorNoche * 1.10  -- +10%
WHERE Tipo = 'SENCILLA';
GO

-- 7.2 Eliminar pagos de una reserva cancelada
DECLARE @IdReservaCancelada INT = 2;

UPDATE dbo.Reservaciones
SET EstadoReserva = 'CANCELADA'
WHERE IdReserva = @IdReservaCancelada;

DELETE FROM dbo.Pagos
WHERE IdReserva = @IdReservaCancelada;
GO

-- 7.3 Insertar una reserva nueva con cálculo dinámico del monto total
DECLARE
    @HoyIns        DATE = CAST(GETDATE() AS DATE),
    @IdClienteIns  INT = 3,
    @IdHabIns      INT = (SELECT TOP 1 IdHabitacion FROM dbo.Habitaciones WHERE Numero = 103),
    @FecEntIns     DATE = DATEADD(DAY, 10, @HoyIns),
    @FecSalIns     DATE = DATEADD(DAY, 13, @HoyIns),
    @PrecioIns     DECIMAL(10,2),
    @NochesIns     INT,
    @MontoIns      DECIMAL(10,2);

SELECT @PrecioIns = PrecioPorNoche 
FROM dbo.Habitaciones 
WHERE IdHabitacion = @IdHabIns;

SET @NochesIns = DATEDIFF(DAY, @FecEntIns, @FecSalIns);
IF @NochesIns <= 0 SET @NochesIns = 1;

SET @MontoIns = @NochesIns * @PrecioIns;

INSERT INTO dbo.Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal, EstadoReserva)
VALUES (@IdClienteIns, @IdHabIns, @FecEntIns, @FecSalIns, @NochesIns, @MontoIns, 'ACTIVA');
GO

---------------------------------------------------------------
-- PASO 8. OBJETOS AVANZADOS
-- 8.1 FUNCIONES
-- 8.2 PROCEDIMIENTOS
-- 8.3 VISTAS
-- 8.4 TRIGGERS
-- 8.5 CTEs
---------------------------------------------------------------

-------------------------
-- 8.1 FUNCIONES
-------------------------

-- fn_CalcularNoches(FechaEntrada, FechaSalida)
IF OBJECT_ID('dbo.fn_CalcularNoches', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalcularNoches;
GO

CREATE FUNCTION dbo.fn_CalcularNoches
(
    @FechaEntrada DATE,
    @FechaSalida  DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Noches INT;
    SET @Noches = DATEDIFF(DAY, @FechaEntrada, @FechaSalida);
    IF @Noches <= 0 SET @Noches = 1;
    RETURN @Noches;
END;
GO

-- fn_CalcularMonto(PrecioNoche, Noches)
IF OBJECT_ID('dbo.fn_CalcularMonto', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalcularMonto;
GO

CREATE FUNCTION dbo.fn_CalcularMonto
(
    @PrecioNoche DECIMAL(10,2),
    @Noches      INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN (@PrecioNoche * @Noches);
END;
GO

-------------------------
-- 8.2 PROCEDIMIENTOS ALMACENADOS
-------------------------

-- 1) sp_RegistrarReserva
IF OBJECT_ID('dbo.sp_RegistrarReserva', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarReserva;
GO

CREATE PROCEDURE dbo.sp_RegistrarReserva
(
    @IdCliente     INT,
    @IdHabitacion  INT,
    @FechaEntrada  DATE,
/* ============================================================
   PROYECTO: Hotel "Estrella del Valle"
   MOTOR   : SQL Server / SQL Server Express
   OBJETIVO: BD empresarial para reservaciones, clientes y pagos
   INCLUYE:
     - Creación de BD y tablas
     - Datos de ejemplo
     - Consultas básicas y avanzadas
     - Lógica de conjuntos y transacciones
     - DML (INSERT, UPDATE, DELETE)
     - Procedimientos almacenados
     - Funciones
     - Vistas
     - Triggers
     - CTEs
     - Backups y RESTORE (comentados)
   ============================================================ */

---------------------------------------------------------------
-- PASO 1. CREAR BASE DE DATOS
---------------------------------------------------------------
IF DB_ID('HotelEstrellaDelValle') IS NOT NULL
BEGIN
    ALTER DATABASE HotelEstrellaDelValle 
        SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HotelEstrellaDelValle;
END;
GO

CREATE DATABASE HotelEstrellaDelValle;
GO

USE HotelEstrellaDelValle;
GO

---------------------------------------------------------------
-- PASO 2. CREAR TABLAS PRINCIPALES
---------------------------------------------------------------

-------------------------
-- Tabla: Clientes
-------------------------
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL
    DROP TABLE dbo.Clientes;
GO

CREATE TABLE dbo.Clientes (
    IdCliente      INT IDENTITY(1,1) CONSTRAINT PK_Clientes PRIMARY KEY,
    Nombre         NVARCHAR(50)  NOT NULL,
    Apellidos      NVARCHAR(70)  NOT NULL,
    Telefono       VARCHAR(20)   NULL,
    Email          NVARCHAR(100) NULL,
    Estado         VARCHAR(10)   NOT NULL 
        CONSTRAINT CK_Clientes_Estado
        CHECK (Estado IN ('ACTIVO','INACTIVO'))
        DEFAULT 'ACTIVO'
);
GO

-------------------------
-- Tabla: Habitaciones
-------------------------
IF OBJECT_ID('dbo.Habitaciones', 'U') IS NOT NULL
    DROP TABLE dbo.Habitaciones;
GO

CREATE TABLE dbo.Habitaciones (
    IdHabitacion     INT IDENTITY(1,1) CONSTRAINT PK_Habitaciones PRIMARY KEY,
    Numero           INT           NOT NULL UNIQUE,
    Tipo             VARCHAR(20)   NOT NULL 
        CONSTRAINT CK_Habitaciones_Tipo
        CHECK (Tipo IN ('SENCILLA','DOBLE','SUITE')),
    PrecioPorNoche   DECIMAL(10,2) NOT NULL 
        CONSTRAINT CK_Habitaciones_Precio CHECK (PrecioPorNoche >= 0),
    Activa           BIT NOT NULL DEFAULT 1
);
GO

-------------------------
-- Tabla: Reservaciones
-------------------------
IF OBJECT_ID('dbo.Reservaciones', 'U') IS NOT NULL
    DROP TABLE dbo.Reservaciones;
GO

CREATE TABLE dbo.Reservaciones (
    IdReserva       INT IDENTITY(1,1) CONSTRAINT PK_Reservaciones PRIMARY KEY,
    IdCliente       INT NOT NULL,
    IdHabitacion    INT NOT NULL,
    FechaEntrada    DATE NOT NULL,
    FechaSalida     DATE NOT NULL,
    CantidadNoches  INT           NULL,
    MontoTotal      DECIMAL(10,2) NULL,
    EstadoReserva   VARCHAR(20) NOT NULL
        CONSTRAINT CK_Reservaciones_Estado
        CHECK (EstadoReserva IN ('ACTIVA','CANCELADA','FINALIZADA')) 
        DEFAULT 'ACTIVA',

    CONSTRAINT FK_Reservaciones_Clientes
        FOREIGN KEY (IdCliente) REFERENCES dbo.Clientes(IdCliente),

    CONSTRAINT FK_Reservaciones_Habitaciones
        FOREIGN KEY (IdHabitacion) REFERENCES dbo.Habitaciones(IdHabitacion),

    CONSTRAINT CK_Reservaciones_Fechas
        CHECK (FechaSalida > FechaEntrada)
);
GO

-------------------------
-- Tabla: Pagos
-------------------------
IF OBJECT_ID('dbo.Pagos', 'U') IS NOT NULL
    DROP TABLE dbo.Pagos;
GO

CREATE TABLE dbo.Pagos (
    IdPago       INT IDENTITY(1,1) CONSTRAINT PK_Pagos PRIMARY KEY,
    IdReserva    INT NOT NULL,
    Monto        DECIMAL(10,2) NOT NULL 
        CONSTRAINT CK_Pagos_Monto CHECK (Monto >= 0),
    FechaPago    DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    MetodoPago   VARCHAR(20) NOT NULL
        CONSTRAINT CK_Pagos_Metodo
        CHECK (MetodoPago IN ('EFECTIVO','TARJETA','TRANSFERENCIA')),

    CONSTRAINT FK_Pagos_Reservaciones
        FOREIGN KEY (IdReserva) REFERENCES dbo.Reservaciones(IdReserva)
);
GO

-------------------------
-- Tabla: LogHabitaciones (para trigger)
-------------------------
IF OBJECT_ID('dbo.LogHabitaciones', 'U') IS NOT NULL
    DROP TABLE dbo.LogHabitaciones;
GO

CREATE TABLE dbo.LogHabitaciones (
    IdLog         INT IDENTITY(1,1) CONSTRAINT PK_LogHabitaciones PRIMARY KEY,
    IdHabitacion  INT NOT NULL,
    Usuario       NVARCHAR(128) NOT NULL,
    Fecha         DATETIME      NOT NULL DEFAULT SYSDATETIME(),
    TipoCambio    VARCHAR(50)   NOT NULL,
    CONSTRAINT FK_LogHabitaciones_Habitaciones
        FOREIGN KEY (IdHabitacion) REFERENCES dbo.Habitaciones(IdHabitacion)
);
GO

---------------------------------------------------------------
-- PASO 3. INSERCIÓN DE DATOS
--  - 10 clientes
--  - 10 habitaciones
--  - 15 reservaciones
--  - 15 pagos
---------------------------------------------------------------

-------------------------
-- Insertar Clientes
-------------------------
INSERT INTO dbo.Clientes (Nombre, Apellidos, Telefono, Email, Estado)
VALUES
(N'Juan',   N'Pérez López',      '8888-0001', N'juan.perez@example.com',   'ACTIVO'),
(N'Ana',    N'Gómez Castro',     '8888-0002', N'ana.gomez@example.com',    'ACTIVO'),
(N'Carlos', N'Rodríguez Mora',   '8888-0003', N'carlos.rod@example.com',   'ACTIVO'),
(N'Laura',  N'Salas Rojas',      '8888-0004', N'laura.salas@example.com',  'INACTIVO'),
(N'Mario',  N'Hernández Díaz',   '8888-0005', N'mario.hdz@example.com',    'ACTIVO'),
(N'Sofía',  N'Navarro Pineda',   '8888-0006', N'sofia.nav@example.com',    'ACTIVO'),
(N'Andrés', N'Córdoba Jiménez',  '8888-0007', N'andres.cj@example.com',    'ACTIVO'),
(N'Lucía',  N'Campos Aguilar',   '8888-0008', N'lucia.campos@example.com', 'INACTIVO'),
(N'Pedro',  N'Chacón Vargas',    '8888-0009', N'pedro.cv@example.com',     'ACTIVO'),
(N'Elena',  N'Montealegre Ruiz', '8888-0010', N'elena.mr@example.com',     'ACTIVO');
GO

-------------------------
-- Insertar Habitaciones
-------------------------
INSERT INTO dbo.Habitaciones (Numero, Tipo, PrecioPorNoche, Activa)
VALUES
(101, 'SENCILLA', 45000, 1),
(102, 'SENCILLA', 45000, 1),
(103, 'DOBLE',    65000, 1),
(104, 'DOBLE',    65000, 1),
(105, 'SUITE',   120000, 1),
(201, 'SENCILLA', 48000, 1),
(202, 'DOBLE',    70000, 1),
(203, 'SUITE',   130000, 1),
(204, 'SENCILLA', 46000, 1),
(205, 'SUITE',   140000, 0);
GO

-------------------------
-- Insertar Reservaciones (fechas relativas a hoy)
-------------------------
DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

INSERT INTO dbo.Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal, EstadoReserva)
VALUES
(
    1,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 101),
    DATEADD(DAY, -10, @Hoy),
    DATEADD(DAY, -8,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    2,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 102),
    DATEADD(DAY, -7,  @Hoy),
    DATEADD(DAY, -5,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    3,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 103),
    DATEADD(DAY, -3,  @Hoy),
    DATEADD(DAY, -1,  @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    4,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 104),
    DATEADD(DAY, -2,  @Hoy),
    DATEADD(DAY,  1,  @Hoy),
    NULL, NULL, 'ACTIVA'
),
(
    5,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 105),
    DATEADD(DAY,  1,  @Hoy),
    DATEADD(DAY,  4,  @Hoy),
    NULL, NULL, 'ACTIVA'
),
(
    6,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 201),
    DATEADD(DAY, -15, @Hoy),
    DATEADD(DAY, -13, @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    7,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 202),
    DATEADD(DAY, -20, @Hoy),
    DATEADD(DAY, -16, @Hoy),
    NULL, NULL, 'FINALIZADA'
),
(
    8,
    (SELECT IdHabitacion FROM dbo.Habitaciones WHERE Numero = 203),
    DATEADD(DAY, -1,  @Hoy),
    DATEADD(DAY,  2,  @Hoy),
    NULL, NULL, 'ACTIVA'
),
