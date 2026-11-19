-- Wawa Pacocha · E2 Plataforma de Datos · MySQL 8.0.30
-- Orden de ejecución: 01 → 02 → 03 → 04 → 06 → 07; 05 y 08 son consultas y DML de ejemplo; 09 solo en entorno de pruebas.

-- ===== 4 1 Script de creación de base de datos =====
CREATE DATABASE IF NOT EXISTS wawapacocha
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE wawapacocha;
 
-- Las tablas se crean con las claves foráneas desactivadas (el orden no importa);
-- se reactivan al terminar la sección 4.6.
SET FOREIGN_KEY_CHECKS = 0;

-- ===== 4 2 Script de tablas Módulo Ganadería =====
-- Tabla: usuarios
CREATE TABLE `usuarios` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `password` varchar(128) NOT NULL,
    `last_login` datetime(6) NULL,
    `is_superuser` tinyint(1) NOT NULL,
    `username` varchar(150) NOT NULL UNIQUE,
    `first_name` varchar(150) NOT NULL,
    `last_name` varchar(150) NOT NULL,
    `email` varchar(254) NOT NULL,
    `is_staff` tinyint(1) NOT NULL,
    `is_active` tinyint(1) NOT NULL,
    `date_joined` datetime(6) NOT NULL,
    `telefono` varchar(15) NOT NULL UNIQUE,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `rol` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: razas
CREATE TABLE `razas` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` varchar(50) NOT NULL,
    `especie` varchar(10) NOT NULL,
    UNIQUE (`nombre`, `especie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: animales
CREATE TABLE `animales` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `uid` char(32) NOT NULL UNIQUE,
    `arete` varchar(50) NOT NULL,
    `especie` varchar(10) NOT NULL,
    `sexo` varchar(10) NOT NULL,
    `fecha_nacimiento` date NOT NULL,
    `nombre` varchar(100) NOT NULL,
    `raza` varchar(50) NOT NULL,
    `foto` varchar(100) NULL,
    `observaciones` longtext NOT NULL,
    `sync_status` varchar(15) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `usuario_id` bigint NOT NULL,
    `fecha_estado` datetime(6) NULL,
    `motivo_estado` longtext NOT NULL,
    `peso_nacimiento_kg` decimal(5,2) NULL,
    `estado` varchar(10) NOT NULL,
    `madre_id` bigint NULL,
    `padre_id` bigint NULL,
    `longitud_mecha_nacimiento_cm` decimal(4,1) NULL,
    UNIQUE (`arete`),
    FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
    FOREIGN KEY (`madre_id`) REFERENCES `animales` (`id`),
    FOREIGN KEY (`padre_id`) REFERENCES `animales` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: producciones
CREATE TABLE `producciones` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `uid` char(32) NOT NULL UNIQUE,
    `fecha_esquila` date NOT NULL,
    `observaciones` longtext NOT NULL,
    `sync_status` varchar(15) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `animal_id` bigint NOT NULL,
    `numero_esquila` int unsigned NULL,
    `longitud_mecha_cm` decimal(4,1) NULL,
    `peso_vellon_lb` decimal(6,2) NULL,
    UNIQUE (`animal_id`, `numero_esquila`),
    FOREIGN KEY (`animal_id`) REFERENCES `animales` (`id`),
    INDEX `idx_producciones_animal_fecha` (`animal_id`, `fecha_esquila`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: analisis_fibra
CREATE TABLE `analisis_fibra` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `dmf` decimal(5,2) NOT NULL,
    `cv` decimal(5,2) NOT NULL,
    `desviacion_estandar` decimal(5,2) NOT NULL,
    `factor_confort` decimal(5,2) NOT NULL,
    `indice_curvatura` decimal(5,2) NOT NULL,
    `fecha_analisis` date NOT NULL,
    `observaciones` longtext NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `produccion_id` bigint NOT NULL UNIQUE,
    FOREIGN KEY (`produccion_id`) REFERENCES `producciones` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: fotos_animal (galería del animal; se muestra en «Animales en venta»)
CREATE TABLE `fotos_animal` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `imagen` varchar(100) NOT NULL,
    `descripcion` varchar(120) NOT NULL DEFAULT '',
    `orden` smallint unsigned NOT NULL DEFAULT 0,
    `created_at` datetime(6) NOT NULL,
    `animal_id` bigint NOT NULL,
    FOREIGN KEY (`animal_id`) REFERENCES `animales` (`id`),
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: animales_en_venta
CREATE TABLE `animales_en_venta` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `precio` decimal(10,2) NOT NULL,
    `proposito` varchar(12) NOT NULL,
    `titulo` varchar(120) NOT NULL,
    `descripcion` longtext NOT NULL,
    `imagen` varchar(100) NULL,
    `destacado` tinyint(1) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `animal_id` bigint NOT NULL UNIQUE,
    `estado` varchar(12) NOT NULL,
    FOREIGN KEY (`animal_id`) REFERENCES `animales` (`id`),
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== 4 4 Script de tablas Módulo Tienda Virtual =====
-- Tabla: artesanos
CREATE TABLE `artesanos` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` varchar(150) NOT NULL,
    `contacto` varchar(50) NOT NULL,
    `localidad` varchar(100) NOT NULL,
    `activo` tinyint(1) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: lotes
CREATE TABLE `lotes` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `codigo_lote` varchar(30) NOT NULL UNIQUE,
    `tipo_fibra` varchar(10) NOT NULL,
    `fecha_ingreso` date NOT NULL,
    `cantidad_kg` decimal(8,2) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `animal_id` bigint NULL,
    `produccion_id` bigint NULL,
    FOREIGN KEY (`animal_id`) REFERENCES `animales` (`id`),
    FOREIGN KEY (`produccion_id`) REFERENCES `producciones` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: procesos_lote
CREATE TABLE `procesos_lote` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `etapa` varchar(20) NOT NULL,
    `orden_secuencia` smallint unsigned NOT NULL,
    `fecha_proceso` date NOT NULL,
    `observaciones` varchar(255) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `lote_id` bigint NOT NULL,
    UNIQUE (`lote_id`, `orden_secuencia`),
    FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id`),
    CHECK (`orden_secuencia` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: productos
CREATE TABLE `productos` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` varchar(150) NOT NULL,
    `slug` varchar(170) NOT NULL UNIQUE,
    `descripcion` longtext NOT NULL,
    `categoria` varchar(20) NOT NULL,
    `unidad_venta` varchar(10) NOT NULL DEFAULT 'unidad',
    `imagen_principal` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL,
    `activo` tinyint(1) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `artesano_id` bigint NULL,
    `lote_id` bigint NULL,
    `destacado` tinyint(1) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    FOREIGN KEY (`artesano_id`) REFERENCES `artesanos` (`id`),
    FOREIGN KEY (`lote_id`) REFERENCES `lotes` (`id`),
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: imagenes_producto
CREATE TABLE `imagenes_producto` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `producto_id` bigint NOT NULL,
    FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: variantes_producto
CREATE TABLE `variantes_producto` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `talla` varchar(15) NOT NULL,
    `color` varchar(30) NOT NULL,
    `tipo_prenda` varchar(30) NOT NULL,
    `sku` varchar(40) NOT NULL UNIQUE,
    `precio_base` decimal(10,2) NOT NULL,
    `stock` int unsigned NOT NULL,
    `stock_reservado` int unsigned NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `producto_id` bigint NOT NULL,
    UNIQUE (`producto_id`, `talla`, `color`, `tipo_prenda`),
    FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
    CHECK (`stock` >= 0),
    CHECK (`stock_reservado` >= 0),
    CHECK (`stock_reservado` <= `stock`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: precios_temporada
CREATE TABLE `precios_temporada` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre_temporada` varchar(50) NOT NULL,
    `precio_especial` decimal(10,2) NOT NULL,
    `fecha_inicio` date NOT NULL,
    `fecha_fin` date NOT NULL,
    `activo` tinyint(1) NOT NULL,
    `variante_id` bigint NOT NULL,
    FOREIGN KEY (`variante_id`) REFERENCES `variantes_producto` (`id`),
    CHECK (`fecha_fin` >= `fecha_inicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: pedidos
CREATE TABLE `pedidos` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `codigo` varchar(12) NOT NULL UNIQUE,
    `cliente_nombre` varchar(150) NOT NULL,
    `cliente_contacto` varchar(50) NOT NULL,
    `cliente_referencia` varchar(255) NOT NULL,
    `estado` varchar(15) NOT NULL,
    `total` decimal(10,2) NOT NULL,
    `created_at` datetime(6) NOT NULL,
    `updated_at` datetime(6) NOT NULL,
    `motivo_comprobante` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: detalle_pedido
CREATE TABLE `detalle_pedido` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cantidad` int unsigned NOT NULL,
    `precio_unitario` decimal(10,2) NOT NULL,
    `pedido_id` bigint NOT NULL,
    `variante_id` bigint NOT NULL,
    FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`),
    FOREIGN KEY (`variante_id`) REFERENCES `variantes_producto` (`id`),
    CHECK (`cantidad` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: pagos
CREATE TABLE `pagos` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `metodo` varchar(10) NOT NULL,
    `comprobante_imagen` varchar(100) NOT NULL,
    `estado` varchar(15) NOT NULL,
    `fecha_confirmacion` datetime(6) NULL,
    `gateway_transaccion_id` varchar(100) NOT NULL,
    `observaciones_admin` varchar(255) NOT NULL,
    `huella_comprobante` varchar(64) NOT NULL DEFAULT '',
    `created_at` datetime(6) NOT NULL,
    `confirmado_por_id` bigint NULL,
    `pedido_id` bigint NOT NULL UNIQUE,
    FOREIGN KEY (`confirmado_por_id`) REFERENCES `usuarios` (`id`),
    FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: eventos_feria
CREATE TABLE `eventos_feria` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `titulo` varchar(150) NOT NULL,
    `descripcion` longtext NOT NULL,
    `fecha_evento` date NULL,
    `ubicacion` varchar(150) NOT NULL,
    `activo` tinyint(1) NOT NULL,
    `destacado` tinyint(1) NOT NULL,
    `direccion` varchar(200) NOT NULL,
    `enlace` varchar(300) NOT NULL,
    `fecha_fin` date NULL,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: publicaciones
CREATE TABLE `publicaciones` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `titulo` varchar(180) NOT NULL,
    `resumen` longtext NOT NULL,
    `fuente` varchar(12) NOT NULL,
    `medio` varchar(100) NOT NULL,
    `fecha` date NOT NULL,
    `enlace` varchar(500) NOT NULL,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL,
    `destacado` tinyint(1) NOT NULL,
    `activo` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===== 4 6 Script de tablas Contenido editable CMS  =====
-- Tabla: configuracion_tienda
CREATE TABLE `configuracion_tienda` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre_tienda` varchar(100) NOT NULL,
    `lema` varchar(200) NOT NULL,
    `hero_titulo` varchar(150) NOT NULL,
    `hero_subtitulo` longtext NOT NULL,
    `hero_cta_texto` varchar(50) NOT NULL,
    `telefono_yape` varchar(20) NOT NULL,
    `telefono_plin` varchar(20) NOT NULL,
    `titular_pago` varchar(150) NOT NULL,
    `whatsapp` varchar(20) NOT NULL,
    `correo` varchar(254) NOT NULL,
    `direccion` varchar(200) NOT NULL,
    `facebook` varchar(300) NOT NULL,
    `instagram` varchar(300) NOT NULL,
    `mensaje_envios` varchar(255) NOT NULL,
    `actualizado` datetime(6) NOT NULL,
    `anuncio_activo` tinyint(1) NOT NULL,
    `anuncio_enlace` varchar(300) NOT NULL,
    `anuncio_texto` varchar(200) NOT NULL,
    `cierre_cta_texto` varchar(50) NOT NULL,
    `cierre_texto` longtext NOT NULL,
    `cierre_titulo` varchar(150) NOT NULL,
    `color_acento` varchar(7) NOT NULL,
    `color_borde` varchar(7) NOT NULL,
    `color_fondo` varchar(7) NOT NULL,
    `color_primario` varchar(7) NOT NULL,
    `color_superficie` varchar(7) NOT NULL,
    `hero_alineacion` varchar(10) NOT NULL,
    `hero_altura` smallint unsigned NOT NULL,
    `hero_cta_enlace` varchar(300) NOT NULL,
    `hero_oscurecer` smallint unsigned NOT NULL,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL,
    `logo` varchar(100) NULL,
    `logo_url` varchar(500) NOT NULL,
    `meta_descripcion` varchar(180) NOT NULL,
    `meta_titulo` varchar(70) NOT NULL,
    `mostrar_bloques` tinyint(1) NOT NULL,
    `mostrar_cifras` tinyint(1) NOT NULL,
    `mostrar_destacados` tinyint(1) NOT NULL,
    `mostrar_proceso` tinyint(1) NOT NULL,
    `productos_destacados_max` smallint unsigned NOT NULL,
    `subtitulo_bloques` varchar(200) NOT NULL,
    `subtitulo_destacados` varchar(200) NOT NULL,
    `tiktok` varchar(300) NOT NULL,
    `tipo_media` varchar(10) NOT NULL,
    `titulo_bloques` varchar(100) NOT NULL,
    `titulo_destacados` varchar(100) NOT NULL,
    `video` varchar(100) NULL,
    `video_url` varchar(500) NOT NULL,
    `whatsapp_flotante` tinyint(1) NOT NULL,
    `whatsapp_mensaje` varchar(200) NOT NULL,
    `traza_mostrar` tinyint(1) NOT NULL,
    `traza_mostrar_analisis` tinyint(1) NOT NULL,
    `traza_mostrar_animal` tinyint(1) NOT NULL,
    `traza_mostrar_artesano` tinyint(1) NOT NULL,
    `traza_mostrar_esquila` tinyint(1) NOT NULL,
    `traza_mostrar_lote` tinyint(1) NOT NULL,
    `traza_mostrar_procesos` tinyint(1) NOT NULL,
    `subtitulo_proceso` varchar(200) NOT NULL,
    `titulo_proceso` varchar(100) NOT NULL,
    `animales_destacados_max` smallint unsigned NOT NULL,
    `mostrar_animales` tinyint(1) NOT NULL,
    `mostrar_ferias` tinyint(1) NOT NULL,
    `subtitulo_animales` varchar(200) NOT NULL,
    `subtitulo_ferias` varchar(200) NOT NULL,
    `titulo_animales` varchar(100) NOT NULL,
    `titulo_ferias` varchar(100) NOT NULL,
    `aviso_whatsapp` varchar(200) NOT NULL,
    `horas_reserva` smallint unsigned NOT NULL,
    `pedido_por_whatsapp` tinyint(1) NOT NULL,
    `tema_temporada` varchar(20) NOT NULL DEFAULT 'andino',
    `titulo_nosotros` varchar(100) NOT NULL DEFAULT 'Respaldo y equipo',
    `subtitulo_nosotros` varchar(200) NOT NULL DEFAULT '',
    `nosotros_titulo` varchar(120) NOT NULL DEFAULT 'Quienes estamos detras',
    `nosotros_intro` longtext NOT NULL DEFAULT (''),
    `mostrar_nosotros` tinyint(1) NOT NULL DEFAULT 1,
    `mapa_mostrar` tinyint(1) NOT NULL DEFAULT 1,
    `mapa_titulo` varchar(80) NOT NULL DEFAULT 'Donde estamos',
    `mapa_nota` varchar(200) NOT NULL DEFAULT '',
    `mapa_latitud` decimal(9,6) NOT NULL DEFAULT -15.015153,
    `mapa_longitud` decimal(9,6) NOT NULL DEFAULT -69.365220,
    `mapa_zoom` smallint unsigned NOT NULL DEFAULT 14,
    CHECK (`hero_altura` >= 0),
    CHECK (`hero_oscurecer` >= 0),
    CHECK (`productos_destacados_max` >= 0),
    CHECK (`animales_destacados_max` >= 0),
    CHECK (`horas_reserva` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: bloques_inicio
CREATE TABLE `bloques_inicio` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `titulo` varchar(100) NOT NULL,
    `descripcion` longtext NOT NULL,
    `icono` varchar(20) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `activo` tinyint(1) NOT NULL,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: cifras_inicio
CREATE TABLE `cifras_inicio` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `valor` varchar(20) NOT NULL,
    `etiqueta` varchar(80) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `activo` tinyint(1) NOT NULL,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: diapositivas
CREATE TABLE `diapositivas` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `tipo_media` varchar(10) NOT NULL,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL,
    `video` varchar(100) NULL,
    `video_url` varchar(500) NOT NULL,
    `titulo` varchar(150) NOT NULL,
    `subtitulo` longtext NOT NULL,
    `etiqueta` varchar(50) NOT NULL,
    `cta_texto` varchar(50) NOT NULL,
    `cta_enlace` varchar(300) NOT NULL,
    `alineacion` varchar(10) NOT NULL,
    `oscurecer` smallint unsigned NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `activo` tinyint(1) NOT NULL,
    CHECK (`oscurecer` >= 0),
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: tarjetas_categoria
CREATE TABLE `tarjetas_categoria` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `tipo_media` varchar(10) NOT NULL,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL,
    `video` varchar(100) NULL,
    `video_url` varchar(500) NOT NULL,
    `titulo` varchar(80) NOT NULL,
    `descripcion` varchar(120) NOT NULL,
    `enlace` varchar(300) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `activo` tinyint(1) NOT NULL,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: secciones_pagina
CREATE TABLE `secciones_pagina` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `tipo_media` varchar(10) NOT NULL,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL,
    `video` varchar(100) NULL,
    `video_url` varchar(500) NOT NULL,
    `titulo` varchar(150) NOT NULL,
    `etiqueta` varchar(50) NOT NULL,
    `texto` longtext NOT NULL,
    `cta_texto` varchar(50) NOT NULL,
    `cta_enlace` varchar(300) NOT NULL,
    `disposicion` varchar(12) NOT NULL,
    `fondo_alterno` tinyint(1) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `activo` tinyint(1) NOT NULL,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: enlaces_navegacion
CREATE TABLE `enlaces_navegacion` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ubicacion` varchar(10) NOT NULL,
    `grupo` varchar(40) NOT NULL,
    `texto` varchar(40) NOT NULL,
    `enlace` varchar(300) NOT NULL,
    `icono` varchar(20) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `activo` tinyint(1) NOT NULL,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: textos_interfaz
CREATE TABLE `textos_interfaz` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `clave` varchar(60) NOT NULL UNIQUE,
    `grupo` varchar(14) NOT NULL,
    `descripcion` varchar(160) NOT NULL,
    `valor` varchar(300) NOT NULL,
    `por_defecto` varchar(300) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- Tabla: pasos_proceso
CREATE TABLE `pasos_proceso` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `titulo` varchar(60) NOT NULL,
    `texto` varchar(200) NOT NULL,
    `icono` varchar(20) NOT NULL,
    `orden` smallint unsigned NOT NULL,
    `activo` tinyint(1) NOT NULL,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
SET FOREIGN_KEY_CHECKS = 1;

-- Tabla: convenios (página «Conócenos»: alianzas con instituciones)
CREATE TABLE `convenios` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `entidad` varchar(150) NOT NULL,
    `proposito` longtext NOT NULL,
    `logo` varchar(100) NULL,
    `logo_url` varchar(500) NOT NULL DEFAULT '',
    `enlace` varchar(300) NOT NULL DEFAULT '',
    `desde` date NULL,
    `vigente` tinyint(1) NOT NULL DEFAULT 1,
    `orden` smallint unsigned NOT NULL DEFAULT 0,
    `activo` tinyint(1) NOT NULL DEFAULT 1,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: equipo (página «Conócenos»: personas y sus funciones)
CREATE TABLE `equipo` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre` varchar(120) NOT NULL,
    `rol` varchar(100) NOT NULL,
    `resumen` varchar(200) NOT NULL DEFAULT '',
    `funciones` longtext NOT NULL,
    `credencial` varchar(100) NOT NULL DEFAULT '',
    `foto` varchar(100) NULL,
    `foto_url` varchar(500) NOT NULL DEFAULT '',
    `destacado` tinyint(1) NOT NULL DEFAULT 0,
    `orden` smallint unsigned NOT NULL DEFAULT 0,
    `activo` tinyint(1) NOT NULL DEFAULT 1,
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: reconocimientos (página «Conócenos»: premios recibidos y certificaciones otorgadas)
CREATE TABLE `reconocimientos` (
    `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `direccion` varchar(10) NOT NULL,
    `titulo` varchar(180) NOT NULL,
    `entidad` varchar(150) NOT NULL DEFAULT '',
    `materia` varchar(100) NOT NULL DEFAULT '',
    `en_colaboracion_con` varchar(150) NOT NULL DEFAULT '',
    `descripcion` longtext NOT NULL,
    `fecha` date NULL,
    `imagen` varchar(100) NULL,
    `imagen_url` varchar(500) NOT NULL DEFAULT '',
    `enlace` varchar(300) NOT NULL DEFAULT '',
    `destacado` tinyint(1) NOT NULL DEFAULT 0,
    `orden` smallint unsigned NOT NULL DEFAULT 0,
    `activo` tinyint(1) NOT NULL DEFAULT 1,
    INDEX `idx_recon_dir_activo` (`direccion`, `activo`),
    CHECK (`orden` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ===== 4 8 Restricciones CHECK de dominio e índices adici =====
-- ─── RESTRICCIONES CHECK DE DOMINIO (los estados que Django valida solo en código) ───
ALTER TABLE usuarios         ADD CONSTRAINT chk_usuarios_rol        CHECK (rol IN ('administrador','criador'));
ALTER TABLE razas            ADD CONSTRAINT chk_razas_especie       CHECK (especie IN ('alpaca','llama','ovino'));
ALTER TABLE animales         ADD CONSTRAINT chk_animales_especie    CHECK (especie IN ('alpaca','llama','ovino'));
ALTER TABLE animales         ADD CONSTRAINT chk_animales_sexo       CHECK (sexo IN ('hembra','macho'));
ALTER TABLE animales         ADD CONSTRAINT chk_animales_estado     CHECK (estado IN ('VIVO','VENDIDO','MUERTO'));
ALTER TABLE animales         ADD CONSTRAINT chk_animales_sync       CHECK (sync_status IN ('pendiente','sincronizado','error'));
ALTER TABLE producciones     ADD CONSTRAINT chk_producciones_sync   CHECK (sync_status IN ('pendiente','sincronizado','error'));
ALTER TABLE analisis_fibra   ADD CONSTRAINT chk_analisis_valores    CHECK (dmf > 0 AND cv >= 0 AND factor_confort BETWEEN 0 AND 100);
ALTER TABLE animales_en_venta ADD CONSTRAINT chk_aev_estado         CHECK (estado IN ('no_en_venta','disponible','reservado','vendido'));
ALTER TABLE animales_en_venta ADD CONSTRAINT chk_aev_proposito      CHECK (proposito IN ('reproductor','cria','fibra'));
ALTER TABLE lotes            ADD CONSTRAINT chk_lotes_tipo_fibra    CHECK (tipo_fibra IN ('alpaca','llama','ovino'));
ALTER TABLE procesos_lote    ADD CONSTRAINT chk_procesos_etapa      CHECK (etapa IN ('clasificacion','lavado','escarmenado','peinado','hilado','emparejado','torcido','enconado'));
ALTER TABLE productos        ADD CONSTRAINT chk_productos_categoria CHECK (categoria IN ('fibra','artesanal','semi_industrial'));
ALTER TABLE productos        ADD CONSTRAINT chk_productos_unidad    CHECK (unidad_venta IN ('unidad','kg','lb','madeja','ovillo','rollo'));
ALTER TABLE variantes_producto ADD CONSTRAINT chk_variantes_precio  CHECK (precio_base > 0);
ALTER TABLE pedidos          ADD CONSTRAINT chk_pedidos_estado      CHECK (estado IN ('pendiente','pagado','entregado','cancelado'));
ALTER TABLE pagos            ADD CONSTRAINT chk_pagos_metodo        CHECK (metodo IN ('yape','plin'));
ALTER TABLE pagos            ADD CONSTRAINT chk_pagos_estado        CHECK (estado IN ('pendiente','confirmado','rechazado'));
ALTER TABLE reconocimientos  ADD CONSTRAINT chk_recon_direccion     CHECK (direccion IN ('recibido','otorgado'));
ALTER TABLE configuracion_tienda ADD CONSTRAINT chk_config_mapa  CHECK (mapa_zoom BETWEEN 3 AND 19 AND mapa_latitud BETWEEN -90 AND 90 AND mapa_longitud BETWEEN -180 AND 180);
ALTER TABLE publicaciones    ADD CONSTRAINT chk_publicaciones_fuente CHECK (fuente IN ('prensa','facebook','instagram','tiktok','otro'));
 
-- ─── ÍNDICES ADICIONALES (los declarados en Meta.indexes de Django y dos de sincronización) ───
CREATE INDEX idx_animal_estado          ON animales_en_venta (estado, orden);
CREATE INDEX idx_productos_cat_activo   ON productos (categoria, activo);
CREATE INDEX idx_pedidos_estado_fecha   ON pedidos (estado, created_at DESC);
CREATE INDEX idx_animales_estado        ON animales (estado);
CREATE INDEX idx_animales_updated       ON animales (updated_at);
CREATE INDEX idx_pagos_huella          ON pagos (huella_comprobante);


-- ===== 4 3 Datos de prueba Seed Módulo Ganadería =====
-- ─── DATOS DE PRUEBA: usuarios (el hash es solo de ejemplo; Django genera PBKDF2 reales) ───
INSERT INTO usuarios (id,password,last_login,is_superuser,username,first_name,last_name,email,is_staff,is_active,date_joined,telefono,created_at,updated_at,rol) VALUES
(1,'pbkdf2_sha256$720000$demo$hash-admin',NULL,1,'admin','Administrador','Wawa Pacocha','admin@wawapacocha.pe',1,1,'2026-01-10 08:00:00','951000001','2026-01-10 08:00:00','2026-01-10 08:00:00','administrador'),
(2,'pbkdf2_sha256$720000$demo$hash-rosa',NULL,0,'rmamani','Rosa','Mamani Quispe','rosa@wawapacocha.pe',0,1,'2026-01-12 09:00:00','951000002','2026-01-12 09:00:00','2026-01-12 09:00:00','criador'),
(3,'pbkdf2_sha256$720000$demo$hash-julian',NULL,0,'jcondori','Julián','Condori Apaza','julian@wawapacocha.pe',0,1,'2026-01-15 09:30:00','951000003','2026-01-15 09:30:00','2026-01-15 09:30:00','criador');
 
INSERT INTO razas (id,nombre,especie) VALUES
(1,'Huacaya','alpaca'),(2,'Suri','alpaca'),(3,'K''ara','llama'),(4,'Ch''aku','llama'),(5,'Corriedale','ovino'),(6,'Hampshire Down','ovino'),(7,'Criollo','ovino'),(8,'Junín','ovino');
 
-- Animales (genealogía: Luna y Wayra son hijos de Killa e Inti; Pacha es hija de Luna y Amaru)
INSERT INTO animales (id,uid,arete,especie,sexo,fecha_nacimiento,nombre,raza,foto,observaciones,sync_status,created_at,updated_at,usuario_id,fecha_estado,motivo_estado,peso_nacimiento_kg,estado,madre_id,padre_id,longitud_mecha_nacimiento_cm) VALUES
(1,MD5('animal-1'),'1001','alpaca','hembra','2019-03-12','Killa','Huacaya',NULL,'Madre fundadora del hato','sincronizado','2026-01-20 10:00:00','2026-01-20 10:00:00',2,'2026-01-20 10:00:00','',7.20,'VIVO',NULL,NULL,3.5),
(2,MD5('animal-2'),'1002','alpaca','macho','2018-02-20','Inti','Huacaya',NULL,'Padre fundador del hato','sincronizado','2026-01-20 10:05:00','2026-01-20 10:05:00',2,'2026-01-20 10:05:00','',7.80,'VIVO',NULL,NULL,3.8),
(3,MD5('animal-3'),'1003','alpaca','hembra','2021-01-15','Luna','Huacaya',NULL,'','sincronizado','2026-01-20 10:10:00','2026-01-20 10:10:00',2,'2026-01-20 10:10:00','',7.00,'VIVO',1,2,3.4),
(4,MD5('animal-4'),'1004','alpaca','macho','2022-02-08','Wayra','Suri',NULL,'Buen reproductor','sincronizado','2026-01-20 10:15:00','2026-01-20 10:15:00',2,'2026-01-20 10:15:00','',7.50,'VIVO',1,2,3.6),
(6,MD5('animal-6'),'1006','alpaca','macho','2020-01-10','Amaru','Suri',NULL,'','sincronizado','2026-01-20 10:25:00','2026-01-20 10:25:00',2,'2026-01-20 10:25:00','',8.10,'VIVO',NULL,NULL,4.0),
(5,MD5('animal-5'),'1005','alpaca','hembra','2023-02-18','Pacha','Huacaya',NULL,'','sincronizado','2026-01-20 10:20:00','2026-01-20 10:20:00',2,'2026-01-20 10:20:00','',6.90,'VIVO',3,6,3.3),
(7,MD5('animal-7'),'1007','llama','macho','2020-04-02','Tayta','K''ara',NULL,'','sincronizado','2026-01-20 10:30:00','2026-02-14 12:00:00',2,'2026-02-14 12:00:00','Vendido a comprador de Juliaca',10.50,'VENDIDO',NULL,NULL,2.5),
(8,MD5('animal-8'),'1008','alpaca','hembra','2017-11-30','Mama Ocllo','Suri',NULL,'','sincronizado','2026-01-20 10:35:00','2026-03-02 08:30:00',2,'2026-03-02 08:30:00','Muerte natural',7.30,'MUERTO',NULL,NULL,3.5),
(9,MD5('animal-9'),'2001','llama','hembra','2021-06-01','Sumaq','Ch''aku',NULL,'','pendiente','2026-02-01 11:00:00','2026-02-01 11:00:00',3,'2026-02-01 11:00:00','',9.80,'VIVO',NULL,NULL,2.8);
 
INSERT INTO producciones (id,uid,fecha_esquila,observaciones,sync_status,created_at,updated_at,animal_id,numero_esquila,longitud_mecha_cm,peso_vellon_lb) VALUES
(1,MD5('prod-1'),'2022-11-20','','sincronizado','2026-01-21 09:00:00','2026-01-21 09:00:00',1,1,9.5,5.80),
(2,MD5('prod-2'),'2023-11-18','','sincronizado','2026-01-21 09:05:00','2026-01-21 09:05:00',1,2,10.0,6.10),
(3,MD5('prod-3'),'2022-11-20','','sincronizado','2026-01-21 09:10:00','2026-01-21 09:10:00',2,1,10.5,7.20),
(4,MD5('prod-4'),'2023-11-18','','sincronizado','2026-01-21 09:15:00','2026-01-21 09:15:00',3,1,8.5,4.90),
(5,MD5('prod-5'),'2024-11-16','','sincronizado','2026-01-21 09:20:00','2026-01-21 09:20:00',4,1,9.0,5.30),
(6,MD5('prod-6'),'2023-11-18','Vellón muy uniforme','sincronizado','2026-01-21 09:25:00','2026-01-21 09:25:00',6,1,11.0,6.80),
(7,MD5('prod-7'),'2024-11-16','','sincronizado','2026-01-21 09:30:00','2026-01-21 09:30:00',3,2,9.5,5.60),
(8,MD5('prod-8'),'2024-11-16','','sincronizado','2026-01-21 09:35:00','2026-01-21 09:35:00',1,3,10.2,6.40);
 
INSERT INTO analisis_fibra (id,dmf,cv,desviacion_estandar,factor_confort,indice_curvatura,fecha_analisis,observaciones,created_at,updated_at,produccion_id) VALUES
(1,21.40,20.10,4.30,92.50,28.00,'2023-12-05','','2026-01-22 10:00:00','2026-01-22 10:00:00',2),
(2,24.10,22.40,5.40,84.00,24.50,'2022-12-10','','2026-01-22 10:05:00','2026-01-22 10:05:00',3),
(3,19.80,19.20,3.80,96.20,30.10,'2023-12-05','Fibra de alta finura','2026-01-22 10:10:00','2026-01-22 10:10:00',4),
(4,25.60,23.00,5.90,78.30,22.80,'2023-12-05','','2026-01-22 10:15:00','2026-01-22 10:15:00',6),
(5,21.90,20.50,4.50,91.00,27.20,'2024-12-04','','2026-01-22 10:20:00','2026-01-22 10:20:00',8),
(6,20.50,19.80,4.10,95.00,29.00,'2024-12-04','','2026-01-22 10:25:00','2026-01-22 10:25:00',5);

-- Galería del animal en venta (Wayra)
INSERT INTO fotos_animal (id,imagen,descripcion,orden,created_at,animal_id) VALUES
(1,'animales/galeria/wayra-perfil.jpg','De perfil',1,'2026-03-10 10:05:00',4),
(2,'animales/galeria/wayra-vellon.jpg','Vellón de cerca',2,'2026-03-10 10:06:00',4);

-- ===== 4 5 Datos de prueba Seed Módulo Tienda Virtual =====
INSERT INTO artesanos (id,nombre,contacto,localidad,activo,created_at,updated_at) VALUES
(1,'Asociación Tejedoras de Chucuito','951200001','Chucuito, Puno',1,'2026-02-01 09:00:00','2026-02-01 09:00:00'),
(2,'Taller Hilos del Titicaca','951200002','Juli, Chucuito',1,'2026-02-01 09:10:00','2026-02-01 09:10:00');
 
INSERT INTO lotes (id,codigo_lote,tipo_fibra,fecha_ingreso,cantidad_kg,created_at,updated_at,animal_id,produccion_id) VALUES
(1,'LT-2024-001','alpaca','2024-12-01',12.50,'2026-02-02 09:00:00','2026-02-02 09:00:00',1,8),
(2,'LT-2023-014','alpaca','2023-12-01',8.00,'2026-02-02 09:05:00','2026-02-02 09:05:00',6,6);
 
INSERT INTO procesos_lote (id,etapa,orden_secuencia,fecha_proceso,observaciones,created_at,lote_id) VALUES
(1,'clasificacion',1,'2024-12-03','Fibra clasificada por finura','2026-02-02 09:10:00',1),
(2,'lavado',2,'2024-12-05','','2026-02-02 09:11:00',1),
(3,'escarmenado',3,'2024-12-08','','2026-02-02 09:12:00',1),
(4,'peinado',4,'2024-12-12','','2026-02-02 09:13:00',1),
(5,'hilado',5,'2024-12-18','','2026-02-02 09:14:00',1),
(6,'clasificacion',1,'2023-12-03','','2026-02-02 09:15:00',2),
(7,'lavado',2,'2023-12-06','','2026-02-02 09:16:00',2),
(8,'hilado',3,'2023-12-15','','2026-02-02 09:17:00',2);
 
INSERT INTO productos (id,nombre,slug,descripcion,categoria,imagen_principal,imagen_url,activo,created_at,updated_at,artesano_id,lote_id,destacado,orden) VALUES
(1,'Chompa de alpaca baby','chompa-de-alpaca-baby','Chompa tejida a mano con fibra de alpaca baby.','artesanal',NULL,'',1,'2026-02-03 10:00:00','2026-02-03 10:00:00',1,1,1,1),
(2,'Bufanda tejida a mano','bufanda-tejida-a-mano','Bufanda de alpaca en color natural.','artesanal',NULL,'',1,'2026-02-03 10:05:00','2026-02-03 10:05:00',1,1,1,2),
(3,'Madeja de hilo peinado','madeja-de-hilo-peinado','Hilo de alpaca peinado, listo para tejer.','semi_industrial',NULL,'',1,'2026-02-03 10:10:00','2026-02-03 10:10:00',2,2,0,3),
(4,'Fibra de alpaca clasificada (1 kg)','fibra-de-alpaca-clasificada','Fibra blanca clasificada por finura.','fibra',NULL,'',1,'2026-02-03 10:15:00','2026-02-03 10:15:00',NULL,2,0,4);
 
INSERT INTO imagenes_producto (id,imagen,imagen_url,orden,producto_id) VALUES
(1,NULL,'https://ejemplo.wawapacocha.pe/img/chompa-1.jpg',0,1),
(2,NULL,'https://ejemplo.wawapacocha.pe/img/chompa-2.jpg',1,1),
(3,NULL,'https://ejemplo.wawapacocha.pe/img/bufanda-1.jpg',0,2);
 
-- stock_reservado = unidades de pedidos pendientes (pedido 1: 2×v1 y 1×v4; pedido 5: 1×v3)
INSERT INTO variantes_producto (id,talla,color,tipo_prenda,sku,precio_base,stock,stock_reservado,created_at,updated_at,producto_id) VALUES
(1,'M','Gris','super baby','CHOM-M-GRIS-SB',185.00,6,2,'2026-02-03 11:00:00','2026-02-03 11:00:00',1),
(2,'L','Gris','super baby','CHOM-L-GRIS-SB',185.00,4,0,'2026-02-03 11:01:00','2026-02-03 11:01:00',1),
(3,'M','Crema','baby','CHOM-M-CREMA-B',165.00,3,1,'2026-02-03 11:02:00','2026-02-03 11:02:00',1),
(4,'Única','Natural','baby','BUF-U-NAT-B',89.00,10,1,'2026-02-03 11:03:00','2026-02-03 11:03:00',2),
(5,'Única','Natural','','HILO-U-NAT',35.00,20,0,'2026-02-03 11:04:00','2026-02-03 11:04:00',3),
(6,'1 kg','Blanco','','FIB-1KG-BL',120.00,7,0,'2026-02-03 11:05:00','2026-02-03 11:05:00',4);
 
INSERT INTO precios_temporada (id,nombre_temporada,precio_especial,fecha_inicio,fecha_fin,activo,variante_id) VALUES
(1,'Fiestas Patrias 2026',159.00,'2026-07-15','2026-07-31',1,1),
(2,'Navidad 2026',149.00,'2026-12-01','2026-12-25',1,2);
 
INSERT INTO pedidos (id,codigo,cliente_nombre,cliente_contacto,cliente_referencia,estado,total,created_at,updated_at,motivo_comprobante) VALUES
(1,'WP-00001','María Flores','987654321','Envío a Lima, agencia Olva','pendiente',459.00,'2026-11-01 10:30:00','2026-11-01 10:35:00',''),
(2,'WP-00002','Carlos Ramos','912345678','','pagado',185.00,'2026-10-28 14:00:00','2026-10-28 15:10:00',''),
(3,'WP-00003','Lucía Paredes','998877665','Recojo en feria','entregado',120.00,'2026-10-20 09:00:00','2026-10-25 11:00:00',''),
(4,'WP-00004','Pedro Huanca','955443322','','cancelado',35.00,'2026-10-15 16:00:00','2026-10-17 16:05:00',''),
(5,'WP-00005','Ana Torres','944112233','','pendiente',165.00,'2026-10-29 08:15:00','2026-10-29 12:00:00','La captura no se ve completa');
 
INSERT INTO detalle_pedido (id,cantidad,precio_unitario,pedido_id,variante_id) VALUES
(1,2,185.00,1,1),(2,1,89.00,1,4),(3,1,185.00,2,2),(4,1,120.00,3,6),(5,1,35.00,4,5),(6,1,165.00,5,3);
 
INSERT INTO pagos (id,metodo,comprobante_imagen,estado,fecha_confirmacion,gateway_transaccion_id,observaciones_admin,created_at,confirmado_por_id,pedido_id) VALUES
(1,'yape','comprobantes/00000000000000009e3779b97f4a7c15.jpg','pendiente',NULL,'','','2026-11-01 10:35:00',NULL,1),
(2,'plin','comprobantes/00000000000000013c6ef372fe94f82a.jpg','confirmado','2026-10-28 15:10:00','','','2026-10-28 14:20:00',1,2),
(3,'yape','comprobantes/0000000000000001daa66d2c7ddf743f.jpg','confirmado','2026-10-20 10:00:00','','','2026-10-20 09:30:00',1,3),
(4,'yape','comprobantes/00000000000000031715609f7c746c69.jpg','rechazado',NULL,'','Captura ilegible','2026-10-29 08:30:00',1,5);
 
INSERT INTO animales_en_venta (id,precio,proposito,titulo,descripcion,imagen,destacado,orden,created_at,animal_id,estado) VALUES
(1,2800.00,'reproductor','Wayra — macho Suri reproductor','Macho joven con genealogía registrada y fibra medida.',NULL,1,1,'2026-03-10 10:00:00',4,'disponible'),
(2,3200.00,'reproductor','','',NULL,0,2,'2026-03-10 10:05:00',3,'no_en_venta'),
(3,1800.00,'cria','Pacha — cría hembra Huacaya','Hija de Luna y Amaru.',NULL,0,3,'2026-03-10 10:10:00',5,'reservado');
 
INSERT INTO eventos_feria (id,titulo,descripcion,fecha_evento,ubicacion,activo,destacado,direccion,enlace,fecha_fin,imagen,imagen_url) VALUES
(1,'Feria Agropecuaria de Puno 2026','Venta directa de fibra y prendas.','2026-11-20','Puno',1,1,'Av. Floral s/n','','2026-11-23',NULL,''),
(2,'Expo Alpaca Perú 2025','Participación con reproductores.','2025-10-10','Arequipa',1,0,'Centro de Convenciones','',NULL,NULL,'');
 
INSERT INTO publicaciones (id,titulo,resumen,fuente,medio,fecha,enlace,imagen,imagen_url,destacado,activo) VALUES
(1,'Wawa Pacocha, fibra con trazabilidad','Nota sobre el proyecto de trazabilidad de fibra de alpaca.','prensa','Los Andes','2026-05-12','https://ejemplo.pe/nota-1',NULL,'',1,1),
(2,'Nueva colección de temporada','Publicación en Facebook de la asociación.','facebook','Wawa Pacocha','2026-09-02','https://facebook.com/ejemplo',NULL,'',0,1);

-- Los comprobantes se guardan fuera de /media/ con nombre aleatorio; la huella
-- (SHA-256 del archivo) detecta la misma captura reenviada en otro pedido.
UPDATE pagos SET huella_comprobante = SHA2(CONCAT('captura-', pedido_id), 256);
-- La fibra se vende por kilo; las prendas, por unidad (valor por defecto).
UPDATE productos SET unidad_venta = 'kg' WHERE categoria = 'fibra';

-- ===== 4 7 Datos de prueba Seed Contenido editable =====
-- Registro único de configuración de la tienda (id = 1, como fuerza el modelo)
INSERT INTO configuracion_tienda (id,nombre_tienda,lema,hero_titulo,hero_subtitulo,hero_cta_texto,hero_cta_enlace,hero_alineacion,hero_altura,hero_oscurecer,tipo_media,imagen_url,video_url,logo_url,
  anuncio_activo,anuncio_texto,anuncio_enlace,color_primario,color_acento,color_fondo,color_superficie,color_borde,
  mostrar_cifras,mostrar_bloques,mostrar_proceso,mostrar_destacados,titulo_bloques,subtitulo_bloques,titulo_proceso,subtitulo_proceso,
  mostrar_animales,titulo_animales,subtitulo_animales,animales_destacados_max,mostrar_ferias,titulo_ferias,subtitulo_ferias,
  titulo_destacados,subtitulo_destacados,productos_destacados_max,cierre_titulo,cierre_texto,cierre_cta_texto,
  telefono_yape,telefono_plin,titular_pago,pedido_por_whatsapp,horas_reserva,aviso_whatsapp,
  whatsapp,whatsapp_mensaje,whatsapp_flotante,correo,direccion,facebook,instagram,tiktok,meta_titulo,meta_descripcion,
  traza_mostrar,traza_mostrar_animal,traza_mostrar_lote,traza_mostrar_esquila,traza_mostrar_procesos,traza_mostrar_analisis,traza_mostrar_artesano,
  mensaje_envios,actualizado)
VALUES (1,'Wawa Pacocha','Fibra andina con historia','Del altiplano de Puno a tus manos','','Ver el catálogo','/catalogo','izquierda',78,55,'imagen','','','',
  0,'','','#1E3A8A','#A0522D','#FDFBF7','#F5F2EB','#E8DFD0',
  1,1,1,1,'Por qué comprar aquí','No vendemos prendas anónimas. Vendemos fibra con nombre, origen y medición.','De la puna a la prenda','Cada paso queda registrado. Esto es lo que verás en la ficha de cualquier producto.',
  1,'Animales de nuestro hato','Reproductores y crías con genealogía registrada y fibra medida en laboratorio.',3,1,'Dónde encontrarnos','Las ferias donde vendemos en directo, y lo que se ha publicado sobre la asociación.',
  'Piezas destacadas','Lo que más sale de nuestro taller esta temporada.',3,'Compra directo al criador','Sin registrarte y sin intermediarios. Eliges tu prenda, pagas por Yape o Plin y coordinamos la entrega contigo.','Ver el catálogo',
  '987 654 321','','Wawa Pacocha S.R.L.',1,48,'Te escribimos para coordinar el pago y la entrega.',
  '992255284','Hola, vengo de la tienda y quiero consultar por un producto.',1,'','Puno, Perú','','','','','',
  1,1,1,1,1,1,1,
  'La entrega se coordina contigo por WhatsApp, sin costo calculado aquí.',NOW());
 
INSERT INTO bloques_inicio (id,titulo,descripcion,icono,orden,activo) VALUES
(1,'Trazabilidad real','Cada prenda enlaza con el animal, la esquila y el lote de fibra de origen.','trazabilidad',1,1),
(2,'Fibra medida en laboratorio','Mostramos el diámetro medio y el factor de confort de la fibra.','analisis',2,1),
(3,'Compra directa','Sin intermediarios: pagas por Yape o Plin y coordinamos la entrega.','pago',3,1);
 
INSERT INTO cifras_inicio (id,valor,etiqueta,orden,activo) VALUES
(1,'3','generaciones de genealogía registrada',1,1),(2,'100%','de la fibra con lote de origen',2,1),(3,'48 h','de reserva de tu pedido',3,1);
 
INSERT INTO diapositivas (id,tipo_media,imagen,imagen_url,video,video_url,titulo,subtitulo,etiqueta,cta_texto,cta_enlace,alineacion,oscurecer,orden,activo) VALUES
(1,'imagen',NULL,'https://ejemplo.wawapacocha.pe/img/portada-1.jpg',NULL,'','Nueva temporada de alpaca baby','Prendas tejidas por artesanas de Chucuito.','NUEVA TEMPORADA','Ver el catálogo','/catalogo','izquierda',50,1,1);
 
INSERT INTO tarjetas_categoria (id,tipo_media,imagen,imagen_url,video,video_url,titulo,descripcion,enlace,orden,activo) VALUES
(1,'imagen',NULL,'','','','Prendas artesanales','Tejidas a mano','/catalogo?categoria=artesanal',1,1),
(2,'imagen',NULL,'','','','Fibra y semi industrial','Para tejedores y talleres','/catalogo?categoria=fibra',2,1);
 
INSERT INTO secciones_pagina (id,tipo_media,imagen,imagen_url,video,video_url,titulo,etiqueta,texto,cta_texto,cta_enlace,disposicion,fondo_alterno,orden,activo) VALUES
(1,'imagen',NULL,'',NULL,'','Nuestra historia','WAWA PACOCHA','Criamos alpacas en el altiplano de Puno y registramos la genealogía de cada animal.','','','media_izq',0,1,1);
 
INSERT INTO enlaces_navegacion (id,ubicacion,grupo,texto,enlace,icono,orden,activo) VALUES
(1,'cabecera','','Catálogo','/catalogo','catalogo',1,1),
(2,'cabecera','','Ferias','/ferias','feria',2,1),
(3,'cabecera','','Mi pedido','/pedido','pedido',3,1),
(4,'pie','Tienda','Catálogo','/catalogo','',1,1),
(5,'pie','Tienda','Animales en venta','/animales','',2,1),
(6,'pie','Ayuda','Seguir mi pedido','/pedido','',1,1);
 
INSERT INTO textos_interfaz (id,clave,grupo,descripcion,valor,por_defecto,orden) VALUES
(1,'traza-titulo','trazabilidad','Título de la ficha de trazabilidad','Ficha de trazabilidad','Ficha de trazabilidad',1),
(2,'traza-animal','trazabilidad','Rótulo del animal de origen','Animal de origen','Animal de origen',2),
(3,'producto-confeccionado','producto','Rótulo del artesano','Confeccionado por','Confeccionado por',1);
 
INSERT INTO pasos_proceso (id,titulo,texto,icono,orden,activo) VALUES
(1,'El animal','Se registra su arete, raza y genealogía.','animal',1,1),
(2,'La esquila','Se anota la fecha, el peso del vellón y la longitud de mecha.','esquila',2,1),
(3,'El análisis','La fibra se mide en laboratorio.','analisis',3,1),
(4,'La prenda','El artesano confecciona la pieza y queda ligada a su lote.','artesano',4,1);

-- Página «Conócenos»
INSERT INTO convenios (id,entidad,proposito,logo,logo_url,enlace,desde,vigente,orden,activo) VALUES
(1,'Municipalidad Distrital de Cojata','Campañas de sanidad y esquila tecnificada.',NULL,'','','2024-03-01',1,1,1);
INSERT INTO equipo (id,nombre,rol,resumen,funciones,credencial,foto,foto_url,destacado,orden,activo) VALUES
(1,'Elena Choquehuanca Mamani','Médico veterinario','Sanidad del hato.','Vacunación y control sanitario del hato.','CMVP 08421',NULL,'',1,1,1),
(2,'Rosa Mamani Quispe','Maestra clasificadora','Clasificación de fibra.','Categoriza y clasifica la fibra por finura y color.','',NULL,'',0,2,1);
INSERT INTO reconocimientos (id,direccion,titulo,entidad,materia,en_colaboracion_con,descripcion,fecha,imagen,imagen_url,enlace,destacado,orden,activo) VALUES
(1,'recibido','Primer puesto en finura — Feria regional','Gobierno Regional de Puno','Fibra de alpaca','','Premio a la mejor fibra Huacaya.','2025-11-15',NULL,'','',1,1,1),
(2,'otorgado','Certificación de reproductores','Wawa Pacocha','Genética','INIA','Constancias de genealogía para criadores vecinos.','2026-02-10',NULL,'','',0,2,1);


-- ===== 6 1 Procedimiento almacenado sp resumen animales =====
DELIMITER $$
CREATE PROCEDURE sp_resumen_animales ()
BEGIN
    SELECT COUNT(*)                                       AS total_registrados,
           SUM(estado = 'VIVO')                           AS vivos,
           SUM(estado = 'VENDIDO')                        AS vendidos,
           SUM(estado = 'MUERTO')                         AS muertos,
           SUM(estado = 'VIVO' AND especie = 'alpaca')    AS alpacas_vivas,
           SUM(estado = 'VIVO' AND especie = 'llama')     AS llamas_vivas,
           SUM(estado = 'VIVO' AND especie = 'ovino')     AS ovinos_vivos
    FROM animales;
END$$
DELIMITER ;

-- ===== 6 2 Función fn animales vivos =====
DELIMITER $$
CREATE FUNCTION fn_animales_vivos () RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total FROM animales
    WHERE estado = 'VIVO';
    RETURN v_total;
END$$
DELIMITER ;

-- ===== 6 3 Triggers tg animales fecha estado ins y tg ani =====
DELIMITER $$
CREATE TRIGGER tg_animales_fecha_estado_ins
BEFORE INSERT ON animales FOR EACH ROW
BEGIN
    IF NEW.fecha_estado IS NULL THEN
        SET NEW.fecha_estado = NOW(6);
    END IF;
END$$
 
CREATE TRIGGER tg_animales_fecha_estado_upd
BEFORE UPDATE ON animales FOR EACH ROW
BEGIN
    IF NEW.estado <> OLD.estado THEN
        SET NEW.fecha_estado = NOW(6);
    END IF;
END$$
DELIMITER ;

-- ===== 6 4 Función fn precio vigente Módulo Tienda Virtua =====
DELIMITER $$
CREATE FUNCTION fn_precio_vigente (p_variante_id BIGINT) RETURNS DECIMAL(8,2)
READS SQL DATA
BEGIN
    DECLARE v_precio DECIMAL(8,2);
    SELECT MIN(precio_especial) INTO v_precio
    FROM precios_temporada
    WHERE variante_id = p_variante_id AND activo = 1
      AND CURDATE() BETWEEN fecha_inicio AND fecha_fin;
    IF v_precio IS NULL THEN
        SELECT precio_base INTO v_precio FROM variantes_producto WHERE id = p_variante_id;
    END IF;
    RETURN v_precio;
END$$
DELIMITER ;

-- ===== 6 5 Función fn stock disponible Módulo Tienda Virt =====
DELIMITER $$
CREATE FUNCTION fn_stock_disponible (p_variante_id BIGINT) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_disp INT;
    SELECT GREATEST(stock - stock_reservado, 0) INTO v_disp
    FROM variantes_producto WHERE id = p_variante_id;
    RETURN COALESCE(v_disp, 0);
END$$
DELIMITER ;

-- ===== 6 6 Trigger tg reservar stock Módulo Tienda Virtua =====
DELIMITER $$
CREATE TRIGGER tg_reservar_stock
BEFORE INSERT ON detalle_pedido FOR EACH ROW
BEGIN
    IF fn_stock_disponible(NEW.variante_id) < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock insuficiente para la variante solicitada';
    END IF;
    UPDATE variantes_producto
       SET stock_reservado = stock_reservado + NEW.cantidad
     WHERE id = NEW.variante_id;
END$$
DELIMITER ;

-- ===== 6 7 Procedimiento sp confirmar pago Módulo Tienda  =====
DELIMITER $$
CREATE PROCEDURE sp_confirmar_pago (IN p_pedido_id BIGINT, IN p_admin_id BIGINT)
BEGIN
    DECLARE v_estado_pedido VARCHAR(15);
    DECLARE v_estado_pago   VARCHAR(15);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
 
    START TRANSACTION;
    SELECT p.estado, pg.estado INTO v_estado_pedido, v_estado_pago
    FROM pedidos p JOIN pagos pg ON pg.pedido_id = p.id
    WHERE p.id = p_pedido_id
    FOR UPDATE;
 
    IF v_estado_pedido IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no existe o no tiene comprobante';
    END IF;
    IF v_estado_pedido <> 'pendiente' OR v_estado_pago <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no está pendiente de confirmación';
    END IF;
 
    -- El stock físico baja y la reserva se libera (RN11)
    UPDATE variantes_producto v
    JOIN detalle_pedido d ON d.variante_id = v.id
       SET v.stock = v.stock - d.cantidad,
           v.stock_reservado = v.stock_reservado - d.cantidad
     WHERE d.pedido_id = p_pedido_id;
 
    UPDATE pagos SET estado = 'confirmado', confirmado_por_id = p_admin_id,
                     fecha_confirmacion = NOW(6)
     WHERE pedido_id = p_pedido_id;
    UPDATE pedidos SET estado = 'pagado', updated_at = NOW(6) WHERE id = p_pedido_id;
    COMMIT;
END$$
DELIMITER ;

-- ===== 6 8 Procedimiento sp marcar entregado Módulo Tiend =====
DELIMITER $$
CREATE PROCEDURE sp_marcar_entregado (IN p_pedido_id BIGINT)
BEGIN
    UPDATE pedidos SET estado = 'entregado', updated_at = NOW(6)
     WHERE id = p_pedido_id AND estado = 'pagado';
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se puede entregar un pedido en estado pagado';
    END IF;
END$$
DELIMITER ;

-- ===== 6 9 Procedimiento sp liberar reservas vencidas Mód =====
DELIMITER $$
CREATE PROCEDURE sp_liberar_reservas_vencidas ()
BEGIN
    DECLARE v_horas INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
 
    SELECT horas_reserva INTO v_horas FROM configuracion_tienda WHERE id = 1;
 
    START TRANSACTION;
    CREATE TEMPORARY TABLE tmp_vencidos AS
        SELECT p.id FROM pedidos p
        WHERE p.estado = 'pendiente'
          AND p.created_at < NOW() - INTERVAL v_horas HOUR
          AND NOT EXISTS (SELECT 1 FROM pagos pg
                          WHERE pg.pedido_id = p.id AND pg.estado = 'pendiente');
 
    UPDATE variantes_producto v
    JOIN (SELECT d.variante_id, SUM(d.cantidad) AS cant
          FROM detalle_pedido d JOIN tmp_vencidos t ON t.id = d.pedido_id
          GROUP BY d.variante_id) x ON x.variante_id = v.id
       SET v.stock_reservado = v.stock_reservado - x.cant;
 
    UPDATE pedidos SET estado = 'cancelado', updated_at = NOW(6)
     WHERE id IN (SELECT id FROM tmp_vencidos);
    SELECT ROW_COUNT() AS pedidos_cancelados;
 
    DROP TEMPORARY TABLE tmp_vencidos;
    COMMIT;
END$$
DELIMITER ;

-- ===== 6 10 Trigger tg pago confirmado inmutable Módulo T =====
DELIMITER $$
CREATE TRIGGER tg_pago_confirmado_inmutable
BEFORE UPDATE ON pagos FOR EACH ROW
BEGIN
    IF OLD.estado = 'confirmado' AND NEW.estado <> 'confirmado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un pago confirmado no puede cambiar de estado';
    END IF;
END$$
DELIMITER ;


-- ===== auditoria =====
-- ══════════════ AUDITORÍA DE CAMBIOS (esquema separado, solo escritura por triggers) ══════════════
CREATE DATABASE IF NOT EXISTS wawapacocha_auditoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wawapacocha_auditoria.auditoria (
    id               BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tabla            VARCHAR(40)  NOT NULL,
    operacion        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    registro_id      BIGINT       NOT NULL,
    datos_anteriores JSON         NULL,
    datos_nuevos     JSON         NULL,
    usuario_bd       VARCHAR(100) NOT NULL,
    fecha            DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    INDEX idx_aud_tabla_registro (tabla, registro_id),
    INDEX idx_aud_fecha (fecha)
) ENGINE=InnoDB;

DELIMITER $$
-- animales
CREATE TRIGGER aud_animales_ins AFTER INSERT ON animales FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_nuevos, usuario_bd)
  VALUES ('animales', 'INSERT', NEW.id,
          JSON_OBJECT('arete', NEW.arete, 'especie', NEW.especie, 'estado', NEW.estado,
                      'padre_id', NEW.padre_id, 'madre_id', NEW.madre_id, 'usuario_id', NEW.usuario_id), USER())$$
CREATE TRIGGER aud_animales_upd AFTER UPDATE ON animales FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_anteriores, datos_nuevos, usuario_bd)
  VALUES ('animales', 'UPDATE', NEW.id,
          JSON_OBJECT('arete', OLD.arete, 'estado', OLD.estado, 'motivo_estado', OLD.motivo_estado,
                      'padre_id', OLD.padre_id, 'madre_id', OLD.madre_id),
          JSON_OBJECT('arete', NEW.arete, 'estado', NEW.estado, 'motivo_estado', NEW.motivo_estado,
                      'padre_id', NEW.padre_id, 'madre_id', NEW.madre_id), USER())$$
CREATE TRIGGER aud_animales_del AFTER DELETE ON animales FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_anteriores, usuario_bd)
  VALUES ('animales', 'DELETE', OLD.id, JSON_OBJECT('arete', OLD.arete, 'estado', OLD.estado), USER())$$
-- pedidos
CREATE TRIGGER aud_pedidos_ins AFTER INSERT ON pedidos FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_nuevos, usuario_bd)
  VALUES ('pedidos', 'INSERT', NEW.id, JSON_OBJECT('codigo', NEW.codigo, 'estado', NEW.estado, 'total', NEW.total), USER())$$
CREATE TRIGGER aud_pedidos_upd AFTER UPDATE ON pedidos FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_anteriores, datos_nuevos, usuario_bd)
  VALUES ('pedidos', 'UPDATE', NEW.id,
          JSON_OBJECT('estado', OLD.estado, 'total', OLD.total, 'motivo_comprobante', OLD.motivo_comprobante),
          JSON_OBJECT('estado', NEW.estado, 'total', NEW.total, 'motivo_comprobante', NEW.motivo_comprobante), USER())$$
CREATE TRIGGER aud_pedidos_del AFTER DELETE ON pedidos FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_anteriores, usuario_bd)
  VALUES ('pedidos', 'DELETE', OLD.id, JSON_OBJECT('codigo', OLD.codigo, 'estado', OLD.estado), USER())$$
-- pagos
CREATE TRIGGER aud_pagos_ins AFTER INSERT ON pagos FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_nuevos, usuario_bd)
  VALUES ('pagos', 'INSERT', NEW.id, JSON_OBJECT('pedido_id', NEW.pedido_id, 'metodo', NEW.metodo, 'estado', NEW.estado), USER())$$
CREATE TRIGGER aud_pagos_upd AFTER UPDATE ON pagos FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_anteriores, datos_nuevos, usuario_bd)
  VALUES ('pagos', 'UPDATE', NEW.id,
          JSON_OBJECT('estado', OLD.estado, 'confirmado_por_id', OLD.confirmado_por_id),
          JSON_OBJECT('estado', NEW.estado, 'confirmado_por_id', NEW.confirmado_por_id,
                      'observaciones_admin', NEW.observaciones_admin), USER())$$
CREATE TRIGGER aud_pagos_del AFTER DELETE ON pagos FOR EACH ROW
  INSERT INTO wawapacocha_auditoria.auditoria (tabla, operacion, registro_id, datos_anteriores, usuario_bd)
  VALUES ('pagos', 'DELETE', OLD.id, JSON_OBJECT('pedido_id', OLD.pedido_id, 'estado', OLD.estado), USER())$$
DELIMITER ;


-- ===== roles =====
-- ══════════════ ROLES Y USUARIOS (MySQL 8) ══════════════
CREATE ROLE IF NOT EXISTS 'rol_app', 'rol_lectura', 'rol_dba';

-- Aplicación: solo DML sobre el esquema del negocio (sin DDL ni acceso a la auditoría)
GRANT SELECT, INSERT, UPDATE, DELETE ON wawapacocha.* TO 'rol_app';
-- Lectura: reportes y analítica, incluida la consulta de la auditoría
GRANT SELECT ON wawapacocha.* TO 'rol_lectura';
GRANT SELECT ON wawapacocha_auditoria.* TO 'rol_lectura';
-- DBA: administra el esquema del negocio; la auditoría solo la puede leer
GRANT ALL PRIVILEGES ON wawapacocha.* TO 'rol_dba';
GRANT SELECT ON wawapacocha_auditoria.* TO 'rol_dba';

CREATE USER IF NOT EXISTS 'wawapacocha_app'@'localhost'      IDENTIFIED BY '<password_app>';
CREATE USER IF NOT EXISTS 'wawapacocha_readonly'@'localhost' IDENTIFIED BY '<password_lectura>';
CREATE USER IF NOT EXISTS 'wawapacocha_admin'@'localhost'    IDENTIFIED BY '<password_dba>';

GRANT 'rol_app'     TO 'wawapacocha_app'@'localhost';
GRANT 'rol_lectura' TO 'wawapacocha_readonly'@'localhost';
GRANT 'rol_dba'     TO 'wawapacocha_admin'@'localhost';
SET DEFAULT ROLE ALL TO 'wawapacocha_app'@'localhost', 'wawapacocha_readonly'@'localhost', 'wawapacocha_admin'@'localhost';
