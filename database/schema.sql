-- =====================================================================
-- SiConJ - Esquema MySQL 8 (catálogo + imágenes + clientes + admin + pedidos)
--
-- Local:   CREATE DATABASE catalogo_coleccionables CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
--          USE catalogo_coleccionables;   y luego ejecutar este archivo.
-- Railway: elegir la base "railway" del servicio MySQL y ejecutar este archivo
--          (no usar CREATE DATABASE / USE: la base ya existe).
--
-- Se puede ejecutar más de una vez: todo usa IF NOT EXISTS / INSERT IGNORE.
-- Los PIN y claves del admin NO se guardan aquí: la API los crea (con hash)
-- al arrancar, a partir de variables de entorno.
-- =====================================================================
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- 1. CATÁLOGOS DE APOYO
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CATEGORIA (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    imagen_icon VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- (La API todavía no usa FRANQUICIA ni FABRICANTE; quedan listas para una etapa futura.)
CREATE TABLE IF NOT EXISTS FRANQUICIA (
    id_franquicia INT AUTO_INCREMENT PRIMARY KEY,
    nombre_franquicia VARCHAR(100) NOT NULL UNIQUE,
    pais_origen VARCHAR(100) NULL,
    logo_url VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS FABRICANTE (
    id_fabricante INT AUTO_INCREMENT PRIMARY KEY,
    nombre_fabricante VARCHAR(100) NOT NULL UNIQUE,
    web_url VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS CONDICION (
    id_condicion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_condicion VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    escala VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ESTADO_DISPONIBILIDAD (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. IMÁGENES SUBIDAS POR EL ADMIN
-- Se guardan en la base (no en disco) porque el disco de un contenedor
-- en Railway se borra en cada despliegue.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS IMAGEN_ARCHIVO (
    id_imagen INT AUTO_INCREMENT PRIMARY KEY,
    contenido MEDIUMBLOB NOT NULL,
    tipo_mime VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. PRODUCTO (ficha) e INSTANCIA (unidades con precio, condición y stock)
-- imagen_base guarda la ruta "/api/imagenes/{id}" o 'default.png' si no hay foto.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PRODUCTO_CATALOGO (
    id_producto_catalogo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(200) NOT NULL,
    descripcion_corta VARCHAR(255) NULL,
    descripcion_extendida TEXT NULL,
    ano_lanzamiento INT NULL,
    imagen_base VARCHAR(255) NOT NULL DEFAULT 'default.png',
    ean_upc VARCHAR(50) NULL,
    tipo_articulo VARCHAR(50) NULL,

    fk_categoria INT NOT NULL,
    fk_franquicia INT NULL,
    fk_fabricante INT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_cat_categoria FOREIGN KEY (fk_categoria)
        REFERENCES CATEGORIA(id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cat_franquicia FOREIGN KEY (fk_franquicia)
        REFERENCES FRANQUICIA(id_franquicia) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_cat_fabricante FOREIGN KEY (fk_fabricante)
        REFERENCES FABRICANTE(id_fabricante) ON DELETE SET NULL ON UPDATE CASCADE,

    INDEX idx_nombre_cat (nombre_producto),
    INDEX idx_fk_categoria (fk_categoria),
    INDEX idx_fk_franquicia (fk_franquicia)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS INSTANCIA_INVENTARIO (
    id_instancia INT AUTO_INCREMENT PRIMARY KEY,
    precio_venta DECIMAL(10, 2) NOT NULL CHECK (precio_venta >= 0),
    cantidad_stock INT NOT NULL DEFAULT 1 CHECK (cantidad_stock >= 0),
    notas_condicion TEXT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    fk_producto_catalogo INT NOT NULL,
    fk_condicion INT NOT NULL,
    fk_estado_disponibilidad INT NOT NULL,

    CONSTRAINT fk_inv_producto FOREIGN KEY (fk_producto_catalogo)
        REFERENCES PRODUCTO_CATALOGO(id_producto_catalogo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inv_condicion FOREIGN KEY (fk_condicion)
        REFERENCES CONDICION(id_condicion) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inv_estado FOREIGN KEY (fk_estado_disponibilidad)
        REFERENCES ESTADO_DISPONIBILIDAD(id_estado) ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_fk_producto (fk_producto_catalogo),
    INDEX idx_fk_condicion (fk_condicion),
    INDEX idx_fk_estado (fk_estado_disponibilidad)
) ENGINE=InnoDB;

-- (Sin uso por ahora: galería de fotos extra por unidad.)
CREATE TABLE IF NOT EXISTS IMAGEN_ADICIONAL_INVENTARIO (
    id_imagen_adicional INT AUTO_INCREMENT PRIMARY KEY,
    imagen_url VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fk_instancia INT NOT NULL,
    CONSTRAINT fk_img_instancia FOREIGN KEY (fk_instancia)
        REFERENCES INSTANCIA_INVENTARIO(id_instancia) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. ACCESO: CLIENTES Y ADMINISTRADOR
-- CLIENTE.clave_hash = HMAC-SHA256 de la clave generada (la clave en sí no se guarda).
-- ADMIN_ACCESO: una sola fila (id 1) con el hash BCrypt del PIN y de la clave.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CLIENTE (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    clave_hash CHAR(64) NOT NULL UNIQUE,
    acepta_ofertas TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ADMIN_ACCESO (
    id_admin INT PRIMARY KEY,
    pin_hash VARCHAR(100) NOT NULL,
    clave_hash VARCHAR(100) NOT NULL,
    intentos_fallidos INT NOT NULL DEFAULT 0,
    bloqueado_hasta DATETIME NULL,
    CONSTRAINT chk_admin_unico CHECK (id_admin = 1)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. PEDIDOS (registro en vivo de lo que piden los clientes)
-- Estados: Pendiente (reserva el stock) -> Completado (vendido) o Cancelado (devuelve stock)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PEDIDO (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    nota VARCHAR(300) NULL,
    total DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    fk_cliente INT NOT NULL,

    CONSTRAINT fk_ped_cliente FOREIGN KEY (fk_cliente)
        REFERENCES CLIENTE(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ped_estado CHECK (estado IN ('Pendiente', 'Completado', 'Cancelado')),

    INDEX idx_ped_cliente (fk_cliente),
    INDEX idx_ped_estado (estado)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS PEDIDO_DETALLE (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario >= 0),

    fk_pedido INT NOT NULL,
    fk_instancia INT NOT NULL,

    CONSTRAINT fk_det_pedido FOREIGN KEY (fk_pedido)
        REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_det_instancia FOREIGN KEY (fk_instancia)
        REFERENCES INSTANCIA_INVENTARIO(id_instancia) ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_det_pedido (fk_pedido),
    INDEX idx_det_instancia (fk_instancia)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. DATOS INICIALES (ids fijos: la API usa 1 = Disponible, 2 = Reservado, 3 = Agotado)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO ESTADO_DISPONIBILIDAD (id_estado, nombre_estado, descripcion) VALUES
    (1, 'Disponible', 'Hay unidades para vender'),
    (2, 'Reservado',  'Pedida por un cliente, venta aún no confirmada'),
    (3, 'Agotado',    'Vendida o sin existencias');

INSERT IGNORE INTO CONDICION (id_condicion, nombre_condicion, descripcion) VALUES
    (1, 'Nuevo sellado',        'Sin abrir, en su empaque original'),
    (2, 'Como nuevo',           'Abierto, sin señales de uso'),
    (3, 'Usado buen estado',    'Uso normal, sin daños importantes'),
    (4, 'Usado con detalles',   'Tiene detalles visibles (ver notas)');

INSERT IGNORE INTO CATEGORIA (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Videojuegos',             'Videojuegos físicos'),
    (2, 'Tarjetas coleccionables', 'Pokémon, Magic, Yu-Gi-Oh! y más'),
    (3, 'Autos a escala',          'Hot Wheels y die-cast'),
    (4, 'Figuras y otros',         'Figuras de acción y artículos variados');
