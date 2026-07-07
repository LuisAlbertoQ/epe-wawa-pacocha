-- =====================================================================
--  BASE DE DATOS: geneapp  —  Sistema Wawa Pacocha (E2 / CE022)
--  Motor: MySQL 8.0+   |   Charset: utf8mb4
-- =====================================================================
DROP DATABASE IF EXISTS geneapp;
CREATE DATABASE geneapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE geneapp;


-- ===== 1. TABLAS — MODULO GANADERIA =====
-- ─── TABLA: usuarios ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuarios (
  id           BIGINT          NOT NULL AUTO_INCREMENT,
  password     VARCHAR(128)    NOT NULL,
  last_login   DATETIME(6)     NULL,
  is_superuser TINYINT(1)      NOT NULL DEFAULT 0,
  username     VARCHAR(150)    NOT NULL,
  first_name   VARCHAR(150)    NOT NULL DEFAULT '',
  last_name    VARCHAR(150)    NOT NULL DEFAULT '',
  email        VARCHAR(254)    NOT NULL DEFAULT '',
  is_staff     TINYINT(1)      NOT NULL DEFAULT 0,
  is_active    TINYINT(1)      NOT NULL DEFAULT 1,
  date_joined  DATETIME(6)     NOT NULL,
  telefono     VARCHAR(15)     NOT NULL,
  created_at   DATETIME(6)     NOT NULL,
  updated_at   DATETIME(6)     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_username  (username),
  UNIQUE KEY uq_usuarios_telefono  (telefono)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: animales ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS animales (
  id               BIGINT         NOT NULL AUTO_INCREMENT,
  uid              CHAR(32)        NOT NULL,
  usuario_id       BIGINT         NOT NULL,  -- registrado_por (auditoría)
  arete            VARCHAR(50)    NOT NULL,
  especie          VARCHAR(10)    NOT NULL
                   CHECK (especie IN ('alpaca','llama','ovino')),
  sexo             VARCHAR(10)    NOT NULL
                   CHECK (sexo IN ('hembra','macho')),
  fecha_nacimiento DATE           NOT NULL,
  nombre           VARCHAR(100)   NOT NULL DEFAULT '',
  raza             VARCHAR(10)    NOT NULL DEFAULT ''
                   CHECK (raza IN ('','huacaya','suri')),
  color                   VARCHAR(30)  NOT NULL DEFAULT '',
  clasificacion           VARCHAR(10)  NOT NULL DEFAULT ''
                          CHECK (clasificacion IN ('','blanca','color')),
  etapa                   VARCHAR(10)  NOT NULL DEFAULT 'cria'
                          CHECK (etapa IN ('cria','adulto')),
  seleccionado            TINYINT(1)   NOT NULL DEFAULT 0,
  diametro_fibra          DECIMAL(5,2) NULL,
  coeficiente_variacion   DECIMAL(5,2) NULL,
  desviacion_estandar     DECIMAL(5,2) NULL,
  factor_confort          DECIMAL(5,2) NULL,
  indice_curvatura        DECIMAL(6,2) NULL,
  padre_id         BIGINT         NULL,
  madre_id         BIGINT         NULL,
  foto             VARCHAR(100)   NULL,
  observaciones    LONGTEXT       NOT NULL,
  activo           TINYINT(1)     NOT NULL DEFAULT 1,
  sync_status      VARCHAR(15)    NOT NULL DEFAULT 'sincronizado'
                   CHECK (sync_status IN ('pendiente','sincronizado','error')),
  created_at       DATETIME(6)    NOT NULL,
  updated_at       DATETIME(6)    NOT NULL,
  deleted_at       DATETIME(6)    NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_animales_uid               (uid),
  UNIQUE KEY uq_animales_arete            (arete),
  CONSTRAINT fk_animales_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
  CONSTRAINT fk_animales_padre
    FOREIGN KEY (padre_id)   REFERENCES animales(id) ON DELETE SET NULL,
  CONSTRAINT fk_animales_madre
    FOREIGN KEY (madre_id)   REFERENCES animales(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: producciones — Módulo Móvil (RF09) ────────────────
CREATE TABLE IF NOT EXISTS producciones (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  uid             CHAR(32)      NOT NULL,
  animal_id       BIGINT        NOT NULL,
  fecha_esquila   DATE          NOT NULL,
  peso_vellon_kg  DECIMAL(6,2)  NOT NULL,
  rendimiento_pct DECIMAL(5,2)  NULL,
  observaciones   LONGTEXT      NOT NULL,
  sync_status     VARCHAR(15)   NOT NULL DEFAULT 'sincronizado'
                  CHECK (sync_status IN ('pendiente','sincronizado','error')),
  created_at      DATETIME(6)   NOT NULL,
  updated_at      DATETIME(6)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_producciones_uid (uid),
  CONSTRAINT fk_producciones_animal
    FOREIGN KEY (animal_id) REFERENCES animales(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ===== 2. TABLAS — MODULO TIENDA =====
-- ============================================================
-- MÓDULO TIENDA VIRTUAL (app Django: tienda)
-- Comparte la misma base de datos 'geneapp' (MySQL 8.0+)
-- ============================================================

-- ─── TABLA: artesanos ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS artesanos (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(150) NOT NULL,
  contacto    VARCHAR(50)  NOT NULL DEFAULT '',
  activo      TINYINT(1)   NOT NULL DEFAULT 1,
  created_at  DATETIME(6)  NOT NULL,
  updated_at  DATETIME(6)  NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: lotes ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS lotes (
  id            BIGINT        NOT NULL AUTO_INCREMENT,
  codigo_lote   VARCHAR(30)   NOT NULL,
  tipo_fibra    VARCHAR(10)   NOT NULL
                CHECK (tipo_fibra IN ('alpaca','llama','ovino')),
  animal_id     BIGINT        NULL,
  fecha_ingreso DATE          NOT NULL,
  cantidad_kg   DECIMAL(8,2)  NOT NULL DEFAULT 0,
  created_at    DATETIME(6)   NOT NULL,
  updated_at    DATETIME(6)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_lotes_codigo (codigo_lote),
  CONSTRAINT fk_lotes_animal
    FOREIGN KEY (animal_id) REFERENCES animales(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: procesos_lote ───────────────────────────────────
CREATE TABLE IF NOT EXISTS procesos_lote (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  lote_id         BIGINT       NOT NULL,
  etapa           VARCHAR(20)  NOT NULL
                  CHECK (etapa IN ('clasificacion','lavado','escarmenado',
                         'peinado','hilado','emparejado','torcido','enconado')),
  orden_secuencia TINYINT      NOT NULL,
  fecha_proceso   DATE         NOT NULL,
  observaciones   VARCHAR(255) NOT NULL DEFAULT '',
  created_at      DATETIME(6)  NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_procesos_lote_lote
    FOREIGN KEY (lote_id) REFERENCES lotes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: productos ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS productos (
  id               BIGINT       NOT NULL AUTO_INCREMENT,
  nombre           VARCHAR(150) NOT NULL,
  descripcion      TEXT         NOT NULL,
  categoria        VARCHAR(20)  NOT NULL
                   CHECK (categoria IN ('fibra','artesanal','semi_industrial')),
  artesano_id      BIGINT       NULL,
  lote_id          BIGINT       NULL,
  imagen_principal VARCHAR(150) NULL,
  activo           TINYINT(1)   NOT NULL DEFAULT 1,
  created_at       DATETIME(6)  NOT NULL,
  updated_at       DATETIME(6)  NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_productos_artesano
    FOREIGN KEY (artesano_id) REFERENCES artesanos(id) ON DELETE SET NULL,
  CONSTRAINT fk_productos_lote
    FOREIGN KEY (lote_id) REFERENCES lotes(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: variantes_producto ──────────────────────────────
CREATE TABLE IF NOT EXISTS variantes_producto (
  id           BIGINT        NOT NULL AUTO_INCREMENT,
  producto_id  BIGINT        NOT NULL,
  talla        VARCHAR(15)   NOT NULL,
  color        VARCHAR(30)   NOT NULL,
  tipo_prenda  VARCHAR(30)   NOT NULL DEFAULT '',
  sku          VARCHAR(40)   NOT NULL,
  precio_base  DECIMAL(8,2)  NOT NULL,
  stock        INT           NOT NULL DEFAULT 0,
  created_at   DATETIME(6)   NOT NULL,
  updated_at   DATETIME(6)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_variantes_sku (sku),
  CONSTRAINT fk_variantes_producto
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: precios_temporada ───────────────────────────────
CREATE TABLE IF NOT EXISTS precios_temporada (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  variante_id      BIGINT        NOT NULL,
  nombre_temporada VARCHAR(50)   NOT NULL,
  precio_especial  DECIMAL(8,2)  NOT NULL,
  fecha_inicio     DATE          NOT NULL,
  fecha_fin        DATE          NOT NULL,
  activo           TINYINT(1)    NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  CONSTRAINT fk_precios_temporada_variante
    FOREIGN KEY (variante_id) REFERENCES variantes_producto(id) ON DELETE CASCADE,
  CONSTRAINT chk_precios_temporada_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: pedidos ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pedidos (
  id               BIGINT        NOT NULL AUTO_INCREMENT,
  cliente_nombre   VARCHAR(150)  NOT NULL,
  cliente_contacto VARCHAR(50)   NOT NULL,
  estado           VARCHAR(15)   NOT NULL DEFAULT 'pendiente'
                   CHECK (estado IN ('pendiente','pagado','cancelado')),
  total            DECIMAL(10,2) NOT NULL,
  created_at       DATETIME(6)   NOT NULL,
  updated_at       DATETIME(6)   NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: detalle_pedido ──────────────────────────────────
CREATE TABLE IF NOT EXISTS detalle_pedido (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  pedido_id       BIGINT        NOT NULL,
  variante_id     BIGINT        NOT NULL,
  cantidad        INT           NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(8,2)  NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_detalle_pedido_pedido
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
  CONSTRAINT fk_detalle_pedido_variante
    FOREIGN KEY (variante_id) REFERENCES variantes_producto(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: pagos ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pagos (
  id                     BIGINT        NOT NULL AUTO_INCREMENT,
  pedido_id              BIGINT        NOT NULL,
  metodo                 VARCHAR(10)   NOT NULL
                         CHECK (metodo IN ('yape','plin')),
  comprobante_imagen     VARCHAR(150)  NOT NULL,
  estado                 VARCHAR(15)   NOT NULL DEFAULT 'pendiente'
                         CHECK (estado IN ('pendiente','confirmado','rechazado')),
  confirmado_por         BIGINT        NULL,
  fecha_confirmacion     DATETIME(6)   NULL,
  gateway_transaccion_id VARCHAR(100)  NULL,
  created_at             DATETIME(6)   NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pagos_pedido (pedido_id),
  CONSTRAINT fk_pagos_pedido
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
  CONSTRAINT fk_pagos_confirmado_por
    FOREIGN KEY (confirmado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── TABLA: eventos_feria ───────────────────────────────────
CREATE TABLE IF NOT EXISTS eventos_feria (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  titulo       VARCHAR(150) NOT NULL,
  descripcion  TEXT         NOT NULL,
  fecha_evento DATE         NULL,
  ubicacion    VARCHAR(150) NOT NULL DEFAULT '',
  activo       TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ===== 3. TABLA DE AUDITORIA =====
-- Tabla de auditoria para cambios de seleccion de animales
CREATE TABLE IF NOT EXISTS auditoria_animal (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  animal_id     BIGINT NOT NULL,
  seleccionado_anterior TINYINT(1),
  seleccionado_nuevo    TINYINT(1),
  cambiado_en   DATETIME NOT NULL DEFAULT NOW()
) ENGINE=InnoDB;


-- ===== 4. INDICES =====
-- Índices de rendimiento para las consultas más frecuentes

-- Lista principal de animales activos de la empresa
CREATE INDEX idx_animales_activo
  ON animales (activo);

-- Búsqueda por arete
CREATE INDEX idx_animales_arete
  ON animales (arete);

-- Filtro por especie (animales activos)
CREATE INDEX idx_animales_activo_especie
  ON animales (activo, especie);

-- Sincronización incremental (updated_at)
CREATE INDEX idx_animales_updated
  ON animales (updated_at);

-- Búsqueda de ancestros (árbol genealógico)
CREATE INDEX idx_animales_padre ON animales (padre_id);
CREATE INDEX idx_animales_madre ON animales (madre_id);

-- Filtro de animales seleccionados para reproducción/feria (RF05)
CREATE INDEX idx_animales_seleccionado
  ON animales (usuario_id, seleccionado);

-- Filtro combinado por raza y etapa productiva (RF03, RF04)
CREATE INDEX idx_animales_raza_etapa
  ON animales (usuario_id, raza, etapa);

-- Historial de esquila/producción de un animal, ordenado por fecha (RF09)
CREATE INDEX idx_producciones_animal_fecha
  ON producciones (animal_id, fecha_esquila);

-- Sincronización incremental de producciones (RF15–RF18)
CREATE INDEX idx_producciones_sync
  ON producciones (sync_status);

-- Búsqueda y filtrado de variantes por talla/color/tipo (RF21, RF28)
CREATE INDEX idx_variante_busqueda
  ON variantes_producto (producto_id, talla, color);

-- Lookup directo de un lote por su código (trazabilidad)
CREATE INDEX idx_lote_codigo ON lotes (codigo_lote);

-- Reconstrucción ordenada de la trazabilidad de un lote (RF25, RNF13)
CREATE INDEX idx_proceso_lote
  ON procesos_lote (lote_id, orden_secuencia);

-- Filtro de catálogo por categoría (RF27, RF28)
CREATE INDEX idx_producto_categoria
  ON productos (categoria, activo);

-- Panel de administración: pedidos pendientes de confirmar (RF32)
CREATE INDEX idx_pedido_estado ON pedidos (estado, created_at);


-- ===== 5. DATOS DE PRUEBA (SEED) =====
-- ─── DATOS DE PRUEBA (SEED) ──────────────────────────────
-- Insertar usuario criador de prueba
INSERT INTO usuarios (password, is_superuser, username, first_name, last_name,
  email, is_staff, is_active, date_joined, telefono,
  created_at, updated_at)
VALUES ('pbkdf2_sha256$260000$test$HASH', 0, '987654321', 'Juan',
  'Quispe', 'juan@example.com', 0, 1,
  NOW(), '987654321', NOW(), NOW());

-- Insertar animales de prueba
INSERT INTO animales (uid, usuario_id, arete, especie, sexo,
  fecha_nacimiento, nombre, raza, color, clasificacion, etapa, seleccionado,
  diametro_fibra, coeficiente_variacion, desviacion_estandar, factor_confort,
  indice_curvatura, observaciones, activo, sync_status, created_at, updated_at)
VALUES
  (REPLACE(UUID(),'-',''), 1, 'A-001', 'alpaca', 'hembra',
   '2022-03-15', 'Nina', 'huacaya', 'blanco', 'blanca', 'adulto', 1,
   18.50, 16.20, 3.10, 92.50, 32.40, '', 1, 'sincronizado', NOW(), NOW()),
  (REPLACE(UUID(),'-',''), 1, 'A-002', 'alpaca', 'macho',
   '2021-07-20', 'Puma', 'suri', 'café', 'color', 'adulto', 0,
   21.30, 18.90, 3.80, 88.10, 29.70, '', 1, 'sincronizado', NOW(), NOW()),
  (REPLACE(UUID(),'-',''), 1, 'L-001', 'llama', 'hembra',
   '2020-11-05', 'Sisa', '', '', '', 'adulto', 0,
   NULL, NULL, NULL, NULL, NULL, '', 1, 'sincronizado', NOW(), NOW());

-- Vincular padre/madre (Puma es padre de Nina - ejemplo ilustrativo)
UPDATE animales
SET padre_id = (SELECT id FROM (SELECT id FROM animales WHERE arete='A-002') AS tmp)
WHERE arete = 'A-001';

-- Insertar producción (esquila) de prueba — Módulo Móvil (RF09)
INSERT INTO producciones (uid, animal_id, fecha_esquila, peso_vellon_kg,
  rendimiento_pct, observaciones, sync_status, created_at, updated_at)
VALUES
  (REPLACE(UUID(),'-',''), 1, '2026-04-10', 3.85, 78.50, '', 'sincronizado', NOW(), NOW()),
  (REPLACE(UUID(),'-',''), 2, '2026-04-11', 4.20, 81.00, '', 'sincronizado', NOW(), NOW());

-- ─── DATOS DE PRUEBA (SEED) — Módulo Tienda Virtual ─────────
INSERT INTO artesanos (nombre, contacto, activo, created_at, updated_at)
VALUES ('María Ccama', '987000111', 1, NOW(), NOW());

INSERT INTO lotes (codigo_lote, tipo_fibra, animal_id, fecha_ingreso, cantidad_kg, created_at, updated_at)
VALUES ('LOTE-2026-001', 'alpaca', 1, '2026-02-10', 12.50, NOW(), NOW());

INSERT INTO procesos_lote (lote_id, etapa, orden_secuencia, fecha_proceso, created_at)
VALUES
  (1, 'clasificacion', 1, '2026-02-11', NOW()),
  (1, 'lavado',         2, '2026-02-12', NOW()),
  (1, 'hilado',         3, '2026-02-15', NOW());

INSERT INTO productos (nombre, descripcion, categoria, artesano_id, lote_id, activo, created_at, updated_at)
VALUES ('Chompa Huacaya', 'Chompa de fibra de alpaca Huacaya', 'artesanal', 1, 1, 1, NOW(), NOW());

INSERT INTO variantes_producto (producto_id, talla, color, tipo_prenda, sku, precio_base, stock, created_at, updated_at)
VALUES
  (1, 'M', 'rojo', 'baby', 'CHOMPA-HUA-M-ROJO', 180.00, 5, NOW(), NOW()),
  (1, 'S', 'azul', 'baby', 'CHOMPA-HUA-S-AZUL', 170.00, 3, NOW(), NOW());

INSERT INTO precios_temporada (variante_id, nombre_temporada, precio_especial, fecha_inicio, fecha_fin, activo)
VALUES (1, 'Navidad 2026', 150.00, '2026-12-01', '2026-12-25', 1);


-- ===== 6. FUNCIONES =====
DELIMITER $$
CREATE FUNCTION fn_animales_activos ()
RETURNS INT READS SQL DATA
BEGIN
  DECLARE v_total INT;
  SELECT COUNT(*) INTO v_total
  FROM animales WHERE activo = 1;
  RETURN v_total;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION fn_precio_vigente (p_variante_id BIGINT)
RETURNS DECIMAL(8,2) READS SQL DATA
BEGIN
  DECLARE v_precio_base    DECIMAL(8,2);
  DECLARE v_precio_temp    DECIMAL(8,2);
  SELECT precio_base INTO v_precio_base
  FROM variantes_producto WHERE id = p_variante_id;
  SELECT precio_especial INTO v_precio_temp
  FROM precios_temporada
  WHERE variante_id = p_variante_id
    AND activo = 1
    AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
  LIMIT 1;
  RETURN COALESCE(v_precio_temp, v_precio_base);
END$$
DELIMITER ;


-- ===== 7. PROCEDIMIENTOS =====
DELIMITER $$
CREATE PROCEDURE sp_resumen_animales ()
BEGIN
  SELECT
    COUNT(*) AS total,
    SUM(sexo = 'macho')   AS machos,
    SUM(sexo = 'hembra')  AS hembras,
    SUM(especie = 'alpaca') AS alpacas,
    SUM(especie = 'llama')  AS llamas,
    SUM(especie = 'ovino')  AS ovinos
  FROM animales
  WHERE activo = 1;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_confirmar_pago (
  IN p_pago_id BIGINT,
  IN p_admin_id BIGINT
)
BEGIN
  DECLARE v_pedido_id BIGINT;
  DECLARE v_estado_actual VARCHAR(15);

  START TRANSACTION;

  SELECT pedido_id, estado INTO v_pedido_id, v_estado_actual
  FROM pagos WHERE id = p_pago_id FOR UPDATE;

  IF v_estado_actual = 'confirmado' THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Este pago ya fue confirmado anteriormente.';
  END IF;

  UPDATE pagos
  SET estado = 'confirmado',
      confirmado_por = p_admin_id,
      fecha_confirmacion = NOW(6)
  WHERE id = p_pago_id;

  UPDATE pedidos SET estado = 'pagado', updated_at = NOW(6)
  WHERE id = v_pedido_id;

  -- El descuento de stock real lo aplica tg_descontar_stock
  -- al detectar el cambio de estado del pedido a 'pagado'.

  COMMIT;
END$$
DELIMITER ;


-- ===== 8. TRIGGERS =====
-- Trigger: auto-rellenar deleted_at cuando activo pasa a 0
DELIMITER $$
CREATE TRIGGER tg_set_deleted_at
BEFORE UPDATE ON animales
FOR EACH ROW
BEGIN
  IF NEW.activo = 0 AND OLD.activo = 1 AND NEW.deleted_at IS NULL THEN
    SET NEW.deleted_at = NOW(6);
  END IF;
  IF NEW.activo = 1 AND OLD.activo = 0 THEN
    SET NEW.deleted_at = NULL;
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER tg_auditoria_seleccion
AFTER UPDATE ON animales
FOR EACH ROW
BEGIN
  IF OLD.seleccionado <> NEW.seleccionado THEN
    INSERT INTO auditoria_animal (animal_id, seleccionado_anterior, seleccionado_nuevo)
    VALUES (NEW.id, OLD.seleccionado, NEW.seleccionado);
  END IF;
END$$
DELIMITER ;

-- Evita generar una línea de pedido sin stock suficiente (RF30)
DELIMITER $$
CREATE TRIGGER tg_validar_stock_pedido
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
  DECLARE v_stock INT;
  SELECT stock INTO v_stock
  FROM variantes_producto WHERE id = NEW.variante_id;
  IF v_stock < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Stock insuficiente para la variante seleccionada.';
  END IF;
END$$
DELIMITER ;

-- Descuenta el stock de cada variante cuando el pedido pasa a 'pagado'
DELIMITER $$
CREATE TRIGGER tg_descontar_stock
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
  IF NEW.estado = 'pagado' AND OLD.estado <> 'pagado' THEN
    UPDATE variantes_producto vp
    JOIN detalle_pedido dp ON dp.variante_id = vp.id
    SET vp.stock = vp.stock - dp.cantidad
    WHERE dp.pedido_id = NEW.id;
  END IF;
END$$
DELIMITER ;

-- Refuerza a nivel de trigger lo que ya garantiza UNIQUE(pedido_id) (RNF12)
DELIMITER $$
CREATE TRIGGER tg_evitar_pago_duplicado
BEFORE INSERT ON pagos
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT 1 FROM pagos WHERE pedido_id = NEW.pedido_id) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ya existe un registro de pago para este pedido.';
  END IF;
END$$
DELIMITER ;


-- ===== CONSULTAS DE DEMOSTRACION =====

-- Q1: Animales activos de la empresa
SELECT id, uid, arete, especie, sexo, fecha_nacimiento, nombre, raza
FROM   animales
WHERE  activo = 1
ORDER  BY created_at DESC
LIMIT  20 OFFSET 0;

-- Q2: Búsqueda de animales por arete o nombre
SELECT id, uid, arete, nombre, especie, sexo
FROM   animales
WHERE  activo = 1
  AND  (arete LIKE '%A-00%' OR nombre LIKE '%A-00%');
-- '%A-00%' = '%<texto>%'

-- Q3: Detalle con padre y madre (JOIN auto-referenciado)
SELECT
  a.uid, a.arete, a.especie, a.sexo, a.fecha_nacimiento,
  a.nombre, a.raza, a.observaciones,
  p.arete AS padre_arete, p.nombre AS padre_nombre,
  m.arete AS madre_arete, m.nombre AS madre_nombre
FROM  animales a
LEFT  JOIN animales p ON a.padre_id = p.id
LEFT  JOIN animales m ON a.madre_id = m.id
WHERE a.uid = (SELECT uid FROM animales WHERE arete='A-001');

-- Q4: Resumen estadístico del hato de la empresa (GROUP BY)
SELECT
  especie,
  sexo,
  COUNT(*) AS total
FROM  animales
WHERE activo = 1
GROUP BY especie, sexo
ORDER BY especie, sexo;

-- Q5: Árbol genealógico con CTE recursivo
WITH RECURSIVE arbol AS (
  -- Nodo raíz
  SELECT id, uid, arete, nombre, especie, sexo,
         padre_id, madre_id, 0 AS nivel
  FROM   animales
  WHERE  uid = (SELECT uid FROM animales WHERE arete='A-001')
  UNION ALL
  -- Recursión: padres del nodo actual
  SELECT a.id, a.uid, a.arete, a.nombre, a.especie, a.sexo,
         a.padre_id, a.madre_id, ar.nivel + 1
  FROM   animales a
  JOIN   arbol ar ON (a.id = ar.padre_id OR a.id = ar.madre_id)
  WHERE  ar.nivel < 3
)
SELECT * FROM arbol ORDER BY nivel;

-- Q6: Animales con sync_status='pendiente'
SELECT uid, arete, especie, sync_status, updated_at
FROM   animales
WHERE  sync_status = 'pendiente'
ORDER  BY updated_at ASC;

-- Q7: Cambios incrementales desde last_sync (todo el hato)
SELECT uid, arete, especie, sexo, fecha_nacimiento,
       nombre, raza, observaciones, activo,
       sync_status, updated_at, deleted_at
FROM   animales
WHERE  updated_at > '2020-01-01 00:00:00'
ORDER  BY updated_at ASC;

-- Q8: Inventario de animales activos por especie y etapa
SELECT
  especie,
  etapa,
  COUNT(*) AS total_animales,
  SUM(CASE WHEN seleccionado=1 THEN 1 ELSE 0 END) AS seleccionados
FROM  animales
WHERE activo = 1
GROUP BY especie, etapa
ORDER BY especie, etapa;

-- Q15: Animales seleccionados + promedio de finura + último registro de esquila
SELECT
  a.uid, a.arete, a.nombre, a.raza, a.clasificacion, a.etapa,
  a.diametro_fibra, a.factor_confort,
  (SELECT SUM(pr.peso_vellon_kg) FROM producciones pr
     WHERE pr.animal_id = a.id) AS peso_vellon_acumulado,
  (SELECT MAX(pr.fecha_esquila) FROM producciones pr
     WHERE pr.animal_id = a.id) AS ultima_esquila
FROM   animales a
WHERE  a.seleccionado = 1
  AND  a.activo = 1
ORDER  BY a.diametro_fibra ASC;

-- Q9: Precio vigente (temporada activa si existe, si no, precio base)
SELECT
  vp.id, vp.sku, vp.precio_base,
  COALESCE(pt.precio_especial, vp.precio_base) AS precio_vigente,
  pt.nombre_temporada
FROM   variantes_producto vp
LEFT JOIN precios_temporada pt
  ON  pt.variante_id = vp.id
  AND pt.activo = 1
  AND CURDATE() BETWEEN pt.fecha_inicio AND pt.fecha_fin
WHERE  vp.id = 1;

-- Q10: Stock por combinación exacta
SELECT talla, color, tipo_prenda, sku, stock
FROM   variantes_producto
WHERE  producto_id = 1
ORDER  BY talla, color;

-- Q11: Trazabilidad completa (ficha del producto para el comprador)
SELECT
  p.nombre AS producto, p.categoria, a.nombre AS artesano,
  l.codigo_lote, l.tipo_fibra, l.fecha_ingreso,
  an.arete AS animal_origen, an.especie, an.raza, an.diametro_fibra,
  pl.etapa, pl.orden_secuencia, pl.fecha_proceso
FROM   productos p
LEFT JOIN artesanos a  ON p.artesano_id = a.id
LEFT JOIN lotes l      ON p.lote_id = l.id
LEFT JOIN animales an  ON l.animal_id = an.id
LEFT JOIN procesos_lote pl ON pl.lote_id = l.id
WHERE  p.id = 1
ORDER  BY pl.orden_secuencia ASC;

-- Q12: Pedidos con pago pendiente de revisión
SELECT
  pe.id AS pedido_id, pe.cliente_nombre, pe.cliente_contacto, pe.total,
  pa.metodo, pa.comprobante_imagen, pa.created_at AS comprobante_subido
FROM   pedidos pe
JOIN   pagos pa ON pa.pedido_id = pe.id
WHERE  pe.estado = 'pendiente'
  AND  pa.estado = 'pendiente'
ORDER  BY pa.created_at ASC;

-- Q13: Variantes más vendidas (sólo pedidos pagados)
SELECT
  vp.sku, p.nombre AS producto, vp.talla, vp.color,
  SUM(dp.cantidad) AS unidades_vendidas,
  SUM(dp.cantidad * dp.precio_unitario) AS ingreso_total
FROM   detalle_pedido dp
JOIN   pedidos pe          ON dp.pedido_id = pe.id
JOIN   variantes_producto vp ON dp.variante_id = vp.id
JOIN   productos p          ON vp.producto_id = p.id
WHERE  pe.estado = 'pagado'
GROUP  BY vp.id, p.nombre, vp.talla, vp.color
ORDER  BY unidades_vendidas DESC
LIMIT  10;

-- Q14: Verificación de stock previo a confirmar el pedido
SELECT vp.id, vp.sku, vp.stock,
  (vp.stock >= 1) AS stock_suficiente
FROM   variantes_producto vp
WHERE  vp.id = 1
FOR UPDATE;
-- FOR UPDATE bloquea la fila durante la transacción del checkout,
-- evitando condiciones de carrera entre compradores concurrentes.

-- =====================================================================
--  9. SEGURIDAD: USUARIOS Y ROLES (Administración de la BD — CE0224)
--  Alineado con E2 §7.1 (Usuarios y roles) y §7.5 (Respaldo).
--  Principio de mínimo privilegio: cada usuario solo tiene lo que necesita.
-- =====================================================================

-- Usuario de APLICACIÓN (lo usa el backend Django/API): solo DML, sin DDL
CREATE USER IF NOT EXISTS 'geneapp_app'@'localhost'
  IDENTIFIED BY '<password_fuerte>';
GRANT SELECT, INSERT, UPDATE, DELETE
  ON geneapp.* TO 'geneapp_app'@'localhost';
-- Ejecutar procedimientos/funciones de negocio (sp_confirmar_pago, etc.)
GRANT EXECUTE ON geneapp.* TO 'geneapp_app'@'localhost';

-- Usuario de SOLO LECTURA (reportes/analytics, CSV/PDF)
CREATE USER IF NOT EXISTS 'geneapp_readonly'@'localhost'
  IDENTIFIED BY '<password_fuerte>';
GRANT SELECT ON geneapp.* TO 'geneapp_readonly'@'localhost';

-- Usuario de RESPALDO (usado por mysqldump en el cron diario — ver §7.5)
CREATE USER IF NOT EXISTS 'backup_user'@'localhost'
  IDENTIFIED BY '<password_fuerte>';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER
  ON geneapp.* TO 'backup_user'@'localhost';

-- Usuario ADMINISTRADOR de BD (solo DBA, nunca la aplicación)
CREATE USER IF NOT EXISTS 'geneapp_admin'@'localhost'
  IDENTIFIED BY '<password_fuerte>';
GRANT ALL PRIVILEGES ON geneapp.* TO 'geneapp_admin'@'localhost';

FLUSH PRIVILEGES;

-- Verificación de privilegios otorgados:
--   SHOW GRANTS FOR 'geneapp_app'@'localhost';
--   SHOW GRANTS FOR 'geneapp_readonly'@'localhost';
--   SHOW GRANTS FOR 'backup_user'@'localhost';
