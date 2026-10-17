/*
Proyecto: RetailPro
Entrega: Pre-entrega 5 - Consultas con JOINs
Archivo: m5_consultas_joins.sql
Motor: PostgreSQL
Base de datos: Ventas_Tech_DB

Tablas usadas:
- ventas: id_venta, id_cliente, id_producto, cantidad, precio_unitario,
  fecha_venta, origen_venta
- clientes: id_cliente, nombre, email, fecha_registro, segmento, region
- productos: id_producto, nombre_producto, categoria, precio

Si tus nombres de tablas/columnas de M3 son diferentes, adaptá los nombres
antes de ejecutar. El archivo m3_esquema_retailpro.sql incluido en el paquete
es un esquema de referencia ejecutable con datos de ejemplo.
*/

-- ============================================================
-- CONSULTA 1 - Vista base del proyecto (INNER JOIN)
-- Propósito: crear una vista enriquecida de ventas con información
-- del cliente y del producto para analizar por fecha, región,
-- segmento y categoría en Power BI.
SELECT
    v.fecha_venta,
    v.id_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.segmento,
    c.region,
    p.id_producto,
    p.nombre_producto AS descripcion_producto,
    p.categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
ORDER BY v.fecha_venta, v.id_venta;

-- Hallazgo: la vista permite analizar la facturación por región, segmento
-- y categoría. Con los datos de ejemplo, la venta de mayor importe es una
-- notebook por $850.000; ejecutá la consulta para revisar todas las filas.


-- ============================================================
-- CONSULTA 2 - Clientes sin ventas (LEFT JOIN)
-- Propósito: encontrar clientes registrados que nunca compraron,
-- para que CRM pueda planificar acciones de contacto.
SELECT
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro, c.id_cliente;

-- Hallazgo: en los datos de ejemplo aparece 1 cliente sin compras.
-- CRM puede usar ese registro para una acción de bienvenida/reactivación.
-- Si usás tu base real, reemplazá esta cifra por el conteo observado.


-- ============================================================
-- CONSULTA 3 - Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento,
-- para que el área de Producto revise promoción, stock o catálogo.
SELECT
    p.id_producto,
    p.nombre_producto,
    p.categoria,
    p.precio
FROM productos AS p
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.categoria, p.nombre_producto;

-- Hallazgo: en los datos de ejemplo aparece 1 producto sin ventas.
-- El área de Producto puede revisar si requiere promoción o si corresponde
-- mantenerlo en el catálogo. En la base real, informá el conteo obtenido.


-- ============================================================
-- CONSULTA 4 - Consolidado por canal (UNION ALL)
-- Propósito: consolidar ventas Online y Presencial y comparar la
-- facturación total por origen. La etiqueta canal se crea como literal.
-- origen_venta se usa únicamente para separar las filas de cada SELECT.
SELECT
    canal,
    SUM(total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Online' AS canal
    FROM ventas
    WHERE origen_venta = 'Online'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Presencial' AS canal
    FROM ventas
    WHERE origen_venta = 'Presencial'
) AS consolidado
GROUP BY canal
ORDER BY canal;

-- Hallazgo: con los datos de ejemplo, Online suma $946.000 y Presencial
-- suma $1.116.000; Presencial genera $170.000 más. Son cifras del ejemplo,
-- no resultados de tu base original: actualizalas después de ejecutar allí.
