-- ===== datos sinteticos =====
-- ══════════════ DATOS SINTÉTICOS PARA LAS PRUEBAS DE RENDIMIENTO (solo entorno de pruebas) ══════════════
SET SESSION cte_max_recursion_depth = 30000;

-- 20 000 animales: 85 % vivos; solo ~40 modificados en el último día
INSERT INTO animales (uid, arete, especie, sexo, fecha_nacimiento, nombre, raza, foto, observaciones, sync_status,
                      created_at, updated_at, usuario_id, fecha_estado, motivo_estado, peso_nacimiento_kg, estado,
                      madre_id, padre_id, longitud_mecha_nacimiento_cm)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM n WHERE i < 20000)
SELECT MD5(CONCAT('sint-', i)), CONCAT('S', LPAD(i, 6, '0')),
       ELT(1 + i % 3, 'alpaca', 'llama', 'ovino'), IF(i % 2 = 0, 'hembra', 'macho'),
       DATE_SUB('2026-01-01', INTERVAL (i % 3000) DAY), CONCAT('Sintetico ', i),
       ELT(1 + i % 3, 'Huacaya', 'K''ara', 'Corriedale'), NULL, '', 'sincronizado',
       NOW(6) - INTERVAL 700 DAY, IF(i % 500 = 0, NOW(6) - INTERVAL (i % 20) HOUR, NOW(6) - INTERVAL (2 + i % 700) DAY),
       2 + (i % 2), NULL, '', 7.50, IF(i % 20 = 0, 'MUERTO', IF(i % 10 = 0, 'VENDIDO', 'VIVO')),
       NULL, NULL, 3.5
FROM n;

-- 5 000 pedidos históricos: casi todos entregados; 15 pendientes
INSERT INTO pedidos (codigo, cliente_nombre, cliente_contacto, cliente_referencia, estado, total, created_at, updated_at,
                     motivo_comprobante)
WITH RECURSIVE n AS (SELECT 1 AS i UNION ALL SELECT i + 1 FROM n WHERE i < 5000)
SELECT CONCAT('WP-S', LPAD(i, 5, '0')), CONCAT('Cliente ', i), CONCAT('9', LPAD(i, 8, '0')), '',
       IF(i % 333 = 0, 'pendiente', IF(i % 10 = 0, 'cancelado', 'entregado')),
       100 + (i % 400), NOW(6) - INTERVAL (i % 900) DAY, NOW(6) - INTERVAL (i % 900) DAY, ''
FROM n;

ANALYZE TABLE animales, pedidos;
SELECT (SELECT COUNT(*) FROM animales) AS animales, (SELECT COUNT(*) FROM pedidos) AS pedidos;
