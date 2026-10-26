-- SiConJ v2: ejecutar en la MISMA base que usa la API, después de respaldarla.
-- No borra datos. Se puede repetir; las columnas existentes se conservan.
-- Selecciona la base en MySQL Workbench antes de ejecutar TODO el archivo.
-- Si existen dos tablas cuyos nombres difieren solo en mayúsculas, revisar antes.
SET NAMES utf8mb4;
SET @base_siconj = DATABASE();

SET @tabla_siconj = (SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = @base_siconj AND LOWER(TABLE_NAME) = 'instancia_inventario' LIMIT 1);

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND COLUMN_NAME = 'oculto'),
    'SELECT ''oculto: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD COLUMN `oculto` TINYINT(1) NOT NULL DEFAULT 0'));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;

SET @tabla_siconj = (SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = @base_siconj AND LOWER(TABLE_NAME) = 'pedido' LIMIT 1);

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND COLUMN_NAME = 'tipo_entrega'),
    'SELECT ''tipo_entrega: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD COLUMN `tipo_entrega` VARCHAR(10) NOT NULL DEFAULT ''Recoger'''));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND COLUMN_NAME = 'direccion'),
    'SELECT ''direccion: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD COLUMN `direccion` VARCHAR(300) NULL'));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND COLUMN_NAME = 'latitud'),
    'SELECT ''latitud: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD COLUMN `latitud` DECIMAL(9,6) NULL'));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND COLUMN_NAME = 'longitud'),
    'SELECT ''longitud: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD COLUMN `longitud` DECIMAL(9,6) NULL'));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND COLUMN_NAME = 'entrega_fecha'),
    'SELECT ''entrega_fecha: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD COLUMN `entrega_fecha` DATE NULL'));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND COLUMN_NAME = 'entrega_franja'),
    'SELECT ''entrega_franja: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD COLUMN `entrega_franja` VARCHAR(20) NULL'));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;

SET @sql_siconj = IF(
    EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS
            WHERE CONSTRAINT_SCHEMA = @base_siconj AND TABLE_NAME = @tabla_siconj AND CONSTRAINT_NAME = 'chk_ped_entrega'),
    'SELECT ''chk_ped_entrega: ya existe'' AS resultado',
    CONCAT('ALTER TABLE `', REPLACE(@tabla_siconj, '`', '``'), '` ADD CONSTRAINT chk_ped_entrega CHECK (tipo_entrega IN (''Recoger'', ''Domicilio''))'));
PREPARE paso_siconj FROM @sql_siconj;
EXECUTE paso_siconj;
DEALLOCATE PREPARE paso_siconj;


-- 3) Ajustes (punto de recogida) y horarios de entrega
CREATE TABLE IF NOT EXISTS AJUSTE (
    clave VARCHAR(50) PRIMARY KEY,
    valor VARCHAR(500) NOT NULL DEFAULT ''
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS HORARIO_ENTREGA (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    dia_semana TINYINT NOT NULL,          -- 0 = domingo, 1 = lunes ... 6 = sábado
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT chk_hor_dia CHECK (dia_semana BETWEEN 0 AND 6),
    CONSTRAINT chk_hor_rango CHECK (hora_fin > hora_inicio),
    INDEX idx_hor_dia (dia_semana)
) ENGINE=InnoDB;

INSERT IGNORE INTO AJUSTE (clave, valor) VALUES
    ('recogida_nombre',       'Punto de recogida (por definir)'),
    ('recogida_direccion',    ''),
    ('recogida_indicaciones', ''),
    ('recogida_horario',      '');

-- Horarios de EJEMPLO (solo si la tabla está vacía). El admin los cambia en la pestaña "Entregas".
INSERT INTO HORARIO_ENTREGA (dia_semana, hora_inicio, hora_fin)
SELECT d, i, f FROM (
    SELECT 1 AS d, '17:00:00' AS i, '19:00:00' AS f
    UNION ALL SELECT 2, '17:00:00', '19:00:00'
    UNION ALL SELECT 3, '17:00:00', '19:00:00'
    UNION ALL SELECT 4, '17:00:00', '19:00:00'
    UNION ALL SELECT 5, '17:00:00', '19:00:00'
    UNION ALL SELECT 6, '09:00:00', '17:00:00'
) AS base
WHERE NOT EXISTS (SELECT 1 FROM HORARIO_ENTREGA);


SELECT 'Migración v2 terminada; revisar que no haya errores anteriores.' AS resultado;
