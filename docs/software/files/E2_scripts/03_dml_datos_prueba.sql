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
