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
