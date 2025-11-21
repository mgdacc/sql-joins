-- =============================================================================
-- ||                    EJEMPLOS DETALLADOS DE SQL JOINs                     ||
-- =============================================================================
-- 
-- Este script crea un conjunto de tablas de ejemplo y luego ejecuta una
-- consulta para cada tipo principal de JOIN, con explicaciones detalladas.
-- Puedes ejecutar este script completo en tu cliente de SQL.
-- ¡Guíate de la imagen que hay en el README.md! 
--

-- =============================================================================
-- PASO 1: CONFIGURACIÓN - CREACIÓN DE TABLAS Y DATOS DE EJEMPLO
-- =============================================================================

-- Habilitar claves foráneas en SQLite (ignorado por otros sistemas)
PRAGMA foreign_keys = ON;

-- Borrar tablas si existen para asegurar un inicio limpio
DROP TABLE IF EXISTS Pedidos;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Empleados;
DROP TABLE IF EXISTS Camisetas;
DROP TABLE IF EXISTS Pantalones;


-- Tabla de Clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nombre VARCHAR(100)
);

-- Tabla de Pedidos (con una clave foránea que apunta a Clientes)
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,
    Monto DECIMAL(10, 2),
    ClienteID INT,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Tabla de Empleados (para el ejemplo de SELF JOIN)
CREATE TABLE Empleados (
    EmpleadoID INT PRIMARY KEY,
    Nombre VARCHAR(100),
    JefeID INT -- Esta columna apunta a otro EmpleadoID en la misma tabla
);

-- Tablas sin relación para el ejemplo de CROSS JOIN
CREATE TABLE Camisetas (Color VARCHAR(50));
CREATE TABLE Pantalones (Estilo VARCHAR(50));


-- --- Insertar Datos de Ejemplo ---

-- Clientes
INSERT INTO Clientes (ClienteID, Nombre) VALUES
(1, 'Juan Pérez'),      -- Cliente con 2 pedidos
(2, 'Ana Gómez'),       -- Cliente con 1 pedido
(3, 'Luis Rodríguez'); -- << Cliente SIN pedidos (importante para LEFT JOIN)

-- Pedidos
INSERT INTO Pedidos (PedidoID, Monto, ClienteID) VALUES
(101, 250.00, 1),    -- Pedido de Juan
(102, 150.50, 2),    -- Pedido de Ana
(103, 500.75, 1),    -- Otro pedido de Juan
(104, 75.00, NULL);  -- << Pedido "huérfano" SIN cliente (importante para RIGHT JOIN)

-- Empleados
INSERT INTO Empleados (EmpleadoID, Nombre, JefeID) VALUES
(1, 'Carlos Director', NULL), -- El jefe supremo, no tiene jefe
(2, 'Beatriz Gerente', 1),    -- Su jefe es Carlos
(3, 'David Analista', 2),     -- Su jefa es Beatriz
(4, 'Elena Analista', 2);     -- Su jefa es Beatriz

-- Camisetas y Pantalones
INSERT INTO Camisetas (Color) VALUES ('Roja'), ('Azul'), ('Verde');
INSERT INTO Pantalones (Estilo) VALUES ('Vaquero'), ('Deportivo');


-- =============================================================================
-- PASO 2: EJEMPLOS DE CADA TIPO DE JOIN
-- =============================================================================

-- ===== 1. INNER JOIN =====
-- Propósito: Devuelve solo las filas que tienen una coincidencia en AMBAS tablas.
-- Pregunta: ¿Qué clientes han realizado pedidos y cuáles son esos pedidos?

SELECT
    C.Nombre AS NombreCliente,
    P.PedidoID,
    P.Monto
FROM
    Clientes AS C
INNER JOIN 
    Pedidos AS P ON C.ClienteID = P.ClienteID;

-- Resultado Esperado:
-- Se mostrarán 3 filas. Juan Pérez aparecerá dos veces (tiene 2 pedidos) y Ana Gómez una vez.
-- Luis Rodríguez (sin pedidos) y el Pedido 104 (sin cliente) NO aparecerán.


-- ===== 2. LEFT JOIN =====
-- Propósito: Devuelve TODAS las filas de la tabla de la izquierda (Clientes) y las
--            coincidencias de la derecha (Pedidos). Si no hay coincidencia,
--            las columnas de la derecha muestran NULL.
-- Pregunta: Muéstrame TODOS los clientes y, si han hecho un pedido, sus detalles.

SELECT
    C.Nombre AS NombreCliente,
    P.PedidoID,
    P.Monto
FROM
    Clientes AS C
LEFT JOIN 
    Pedidos AS P ON C.ClienteID = P.ClienteID;

-- Resultado Esperado:
-- Se mostrarán 4 filas. Los 3 pedidos coincidentes de Juan y Ana,
-- Y una fila para Luis Rodríguez con PedidoID y Monto como NULL, porque no tiene pedidos.


-- ===== 3. RIGHT JOIN =====
-- Propósito: Devuelve TODAS las filas de la tabla de la derecha (Pedidos) y las
--            coincidencias de la izquierda (Clientes). Si no hay coincidencia,
--            las columnas de la izquierda muestran NULL.
-- Pregunta: Muéstrame TODOS los pedidos y, si tienen un cliente asociado, su nombre.
-- (Nota: En SQLite y MySQL, esto se simula con un LEFT JOIN invirtiendo las tablas).

SELECT
    C.Nombre AS NombreCliente,
    P.PedidoID,
    P.Monto
FROM
    Clientes AS C
RIGHT JOIN 
    Pedidos AS P ON C.ClienteID = P.ClienteID;
-- Alternativa para SQLite/MySQL:
-- SELECT C.Nombre, P.PedidoID, P.Monto FROM Pedidos AS P LEFT JOIN Clientes AS C ON P.ClienteID = C.ClienteID;

-- Resultado Esperado:
-- Se mostrarán 4 filas. Los 3 pedidos de Juan y Ana,
-- Y una fila para el Pedido 104, con NombreCliente como NULL, porque no tiene un cliente asociado.


-- ===== 4. FULL OUTER JOIN (Simulado con UNION) =====
-- Propósito: Devuelve TODAS las filas de AMBAS tablas. Une las que coinciden y
--            rellena con NULL las que no.
-- Pregunta: Dame una lista completa de todos los clientes y todos los pedidos,
--           coincidan o no.
-- (Nota: SQLite y MySQL no tienen FULL OUTER JOIN, así que lo simulamos
--        combinando un LEFT JOIN y un RIGHT JOIN con UNION).

SELECT C.Nombre, P.PedidoID, P.Monto FROM Clientes AS C LEFT JOIN Pedidos AS P ON C.ClienteID = P.ClienteID
UNION
SELECT C.Nombre, P.PedidoID, P.Monto FROM Pedidos AS P LEFT JOIN Clientes AS C ON P.ClienteID = C.ClienteID;
-- En PostgreSQL u Oracle, la sintaxis sería:
-- SELECT C.Nombre, P.PedidoID, P.Monto FROM Clientes AS C FULL OUTER JOIN Pedidos AS P ON C.ClienteID = P.ClienteID;

-- Resultado Esperado:
-- Se mostrarán 5 filas en total:
-- - Los 3 pedidos que coinciden.
-- - La fila de Luis Rodríguez (cliente sin pedido).
-- - La fila del Pedido 104 (pedido sin cliente).


-- ===== 5. SELF JOIN =====
-- Propósito: Unir una tabla consigo misma para comparar filas dentro de la misma tabla.
-- Pregunta: Muéstrame cada empleado junto al nombre de su respectivo jefe.

SELECT
    Empleado.Nombre AS NombreEmpleado,
    Jefe.Nombre AS NombreJefe
FROM
    Empleados AS Empleado
INNER JOIN 
    Empleados AS Jefe ON Empleado.JefeID = Jefe.EmpleadoID;

-- Resultado Esperado:
-- Se mostrarán 3 filas, mostrando a Beatriz, David y Elena con sus respectivos jefes.
-- Carlos Director no aparecerá en la columna de Empleado porque su JefeID es NULL,
-- por lo que no cumple la condición del INNER JOIN.


-- ===== 6. CROSS JOIN =====
-- Propósito: Crea un "producto cartesiano", combinando cada fila de la primera
--            tabla con cada fila de la segunda tabla.
-- Pregunta: Muéstrame todas las combinaciones posibles de colores de camiseta y estilos de pantalón.

SELECT
    C.Color,
    P.Estilo
FROM
    Camisetas AS C
CROSS JOIN 
    Pantalones AS P;

-- Resultado Esperado:
-- Se mostrarán 3 x 2 = 6 filas, con todas las combinaciones posibles.
-- (Roja, Vaquero), (Roja, Deportivo), (Azul, Vaquero), etc.
