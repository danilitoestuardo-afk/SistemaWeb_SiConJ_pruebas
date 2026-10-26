-- Selecciona la base de datos de la API antes de ejecutar.
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND (
 (LOWER(TABLE_NAME) = 'instancia_inventario' AND COLUMN_NAME = 'oculto') OR
 (LOWER(TABLE_NAME) = 'pedido' AND COLUMN_NAME IN ('tipo_entrega','direccion','latitud','longitud','entrega_fecha','entrega_franja')))
ORDER BY TABLE_NAME, ORDINAL_POSITION;
-- Deben aparecer siete filas arriba.
SELECT * FROM AJUSTE;
SELECT * FROM HORARIO_ENTREGA;
