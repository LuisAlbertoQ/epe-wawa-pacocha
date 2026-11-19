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
