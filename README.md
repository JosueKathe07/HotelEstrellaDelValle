# HotelEstrellaDelValle
Descripción del Proyecto

El proyecto Hotel Estrella del Valle consiste en el diseño e implementación de una base de datos empresarial en SQL Server para gestionar clientes, habitaciones, reservaciones y pagos del hotel.
Este proyecto también incluye el uso profesional de Git y GitHub, aplicando buenas prácticas de control de versiones y flujo de trabajo colaborativo.

El objetivo es contar con una solución inicial que permita consultas avanzadas, auditorías, lógica transaccional y componentes SQL reales para soportar un sistema de reservaciones en etapas posteriores.

🎯 Objetivos del Proyecto
Objetivo General

Diseñar e implementar un sistema de base de datos funcional que permita gestionar clientes, reservaciones, habitaciones y pagos, cumpliendo con estándares profesionales de SQL, auditoría, consultas avanzadas, triggers y transacciones.

Objetivos Específicos

Crear e implementar una base de datos completa en SQL Server.

Diseñar tablas con llaves primarias y foráneas.

Insertar datos reales y consistentes.

Implementar consultas básicas y avanzadas.

Desarrollar procedimientos almacenados, funciones y vistas.

Crear triggers para automatización y auditoría.

Implementar CTE para análisis empresarial.

Configurar un flujo profesional con Git y GitHub.

Generar transacciones con manejo de errores.

Realizar backups y restauraciones de la base de datos.

🗂️ Tecnologías Utilizadas

SQL Server

T-SQL

Git

GitHub

Git Bash

Modelo relacional

Transact-SQL avanzado

🛠️ Estructura del Proyecto
📁 Archivos incluidos

01_creacion_bd.sql → creación de la base de datos y tablas

02_insercion_datos.sql → carga de datos iniciales

03_consultas.sql → consultas básicas y avanzadas

04_procedimientos.sql → stored procedures

05_funciones.sql → funciones en SQL

06_vistas.sql → vistas empresariales

07_triggers.sql → triggers de auditoría y automatización

08_ctes.sql → consultas con CTE

09_transacciones.sql → manejo transaccional completo

10_backup_restore.sql → comandos de backup y restore

README.md → documentación del proyecto

🏗️ Modelo de Datos
Tablas principales:

Clientes

Habitaciones

Reservaciones

Pagos

LogHabitaciones (auditoría)

Todas las tablas cuentan con:

Llave primaria

Relaciones mediante llaves foráneas

Integridad referencial

Tipos de datos adecuados

📊 Consultas Implementadas
✔ Consultas básicas:

Clientes ordenados por apellido

Habitaciones ordenadas por precio

Reservaciones por rango de fechas

✔ Consultas avanzadas:

JOIN entre clientes, reservaciones y habitaciones

JOIN para pagos por cliente

Subconsulta para clientes con más de 1 reserva

WHERE con LIKE, BETWEEN, operadores lógicos

✔ Lógica de conjuntos:

UNION entre clientes activos e inactivos

INTERSECT entre clientes con pagos y reservas

EXCEPT para habitaciones sin reserva

⚙️ Componentes SQL Avanzados
🟦 Procedimientos almacenados

sp_RegistrarReserva

sp_ActualizarDatosCliente

sp_ReporteIngresosPorMes

🟩 Funciones

fn_CalcularNoches

fn_CalcularMonto

🟨 Vistas

vw_ReservasDetalle

vw_PagosPorCliente

vw_IngresosHabitaciones

🟥 Triggers

Trigger para calcular noches y monto total automáticamente

Trigger para registrar cambios en habitaciones en LogHabitaciones

🟪 CTE Implementadas

Ingresos totales por cliente

Ocupación mensual de habitaciones

🔄 Transacciones

Incluye una transacción que:

Registra una nueva reservación

Inserta el pago asociado

Realiza cálculos dinámicos

Valida errores con TRY/CATCH

Hace COMMIT si todo sale bien

Hace ROLLBACK si ocurre algún error

🌐 Control de Versiones con Git

El proyecto utiliza Git y GitHub aplicando:

Ramas principales:

main

develop

Ramas de desarrollo:

feature/tablas

feature/procedimientos

feature/vistas

Pull requests

Resolución de conflictos

Mensajes de commit limpios y descriptivos
