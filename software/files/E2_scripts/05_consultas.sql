-- ===== 5 2 Consultas básicas Módulo Ganadería =====
SELECT id, uid, arete, nombre, especie, sexo, raza, fecha_nacimiento
FROM animales
WHERE estado = 'VIVO'
ORDER BY created_at DESC
LIMIT 20;
SELECT id, arete, nombre, especie, sexo, estado
FROM animales
WHERE arete LIKE '%100%' OR nombre LIKE '%Lu%'
ORDER BY arete;
SELECT a.arete, a.nombre, a.raza, a.estado,
       p.arete AS padre_arete, p.nombre AS padre_nombre,
       m.arete AS madre_arete, m.nombre AS madre_nombre
FROM animales a
LEFT JOIN animales p ON p.id = a.padre_id
LEFT JOIN animales m ON m.id = a.madre_id
WHERE a.id = 5;
SELECT especie, sexo, estado,
       COUNT(*)                         AS total,
       ROUND(AVG(peso_nacimiento_kg),2) AS peso_nac_promedio_kg
FROM animales
GROUP BY especie, sexo, estado
ORDER BY especie, sexo, estado;

-- ===== 5 3 Consultas avanzadas Módulo Ganadería CTE venta =====
WITH RECURSIVE ancestros AS (
    SELECT id, arete, nombre, padre_id, madre_id, 0 AS generacion
    FROM animales WHERE id = 5
    UNION ALL
    SELECT a.id, a.arete, a.nombre, a.padre_id, a.madre_id, x.generacion + 1
    FROM animales a
    JOIN ancestros x ON a.id = x.padre_id OR a.id = x.madre_id
    WHERE x.generacion < 3
)
SELECT generacion, arete, nombre FROM ancestros ORDER BY generacion, arete;
SELECT 'animales' AS tabla, id, uid, updated_at FROM animales WHERE sync_status = 'pendiente'
UNION ALL
SELECT 'producciones', id, uid, updated_at FROM producciones WHERE sync_status = 'pendiente';
SELECT id, uid, arete, nombre, estado, updated_at
FROM animales
WHERE updated_at > '2026-02-01 00:00:00'
ORDER BY updated_at;
SELECT especie, raza, COUNT(*) AS total,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS porcentaje
FROM animales
WHERE estado = 'VIVO'
GROUP BY especie, raza
ORDER BY total DESC;
SELECT p.numero_esquila, p.fecha_esquila, p.peso_vellon_lb, p.longitud_mecha_cm,
       f.dmf, f.cv, f.factor_confort, f.indice_curvatura
FROM producciones p
LEFT JOIN analisis_fibra f ON f.produccion_id = p.id
WHERE p.animal_id = 1
ORDER BY p.numero_esquila;
SELECT a.especie, a.raza,
       COUNT(f.id)                    AS analisis,
       ROUND(AVG(f.dmf),2)            AS dmf_promedio_um,
       ROUND(AVG(f.factor_confort),1) AS confort_promedio
FROM analisis_fibra f
JOIN producciones p ON p.id = f.produccion_id
JOIN animales a     ON a.id = p.animal_id
GROUP BY a.especie, a.raza
HAVING COUNT(f.id) >= 1
ORDER BY dmf_promedio_um;
SELECT a.especie, a.arete, a.nombre,
       ROUND(AVG(f.dmf),2) AS dmf_promedio,
       RANK() OVER (PARTITION BY a.especie ORDER BY AVG(f.dmf)) AS puesto
FROM animales a
JOIN producciones p ON p.animal_id = a.id
JOIN analisis_fibra f ON f.produccion_id = p.id
GROUP BY a.id, a.especie, a.arete, a.nombre
ORDER BY a.especie, puesto;
 
-- ══════════════ MÓDULO TIENDA VIRTUAL ══════════════

-- ===== 5 4 Consultas Módulo Tienda Virtual RF21 RF40  =====
SELECT v.id, v.sku, v.precio_base,
       COALESCE((SELECT MIN(t.precio_especial) FROM precios_temporada t
                 WHERE t.variante_id = v.id AND t.activo = 1
                   AND CURDATE() BETWEEN t.fecha_inicio AND t.fecha_fin), v.precio_base) AS precio_vigente
FROM variantes_producto v
ORDER BY v.id;
SELECT talla, color, tipo_prenda, stock, stock_reservado,
       GREATEST(stock - stock_reservado, 0) AS disponible
FROM variantes_producto
WHERE producto_id = 1
ORDER BY talla, color;
SELECT pr.nombre AS producto, ar.nombre AS artesano, l.codigo_lote, l.tipo_fibra,
       an.arete, an.nombre AS animal, an.raza,
       pd.numero_esquila, pd.fecha_esquila, f.dmf, f.factor_confort,
       (SELECT GROUP_CONCAT(pl.etapa ORDER BY pl.orden_secuencia SEPARATOR ' → ')
        FROM procesos_lote pl WHERE pl.lote_id = l.id) AS procesos
FROM productos pr
LEFT JOIN artesanos ar       ON ar.id = pr.artesano_id
LEFT JOIN lotes l            ON l.id = pr.lote_id
LEFT JOIN animales an        ON an.id = l.animal_id
LEFT JOIN producciones pd    ON pd.id = l.produccion_id
LEFT JOIN analisis_fibra f   ON f.produccion_id = pd.id
WHERE pr.slug = 'chompa-de-alpaca-baby';
SELECT p.codigo, p.cliente_nombre, p.cliente_contacto, p.total, pg.metodo, pg.created_at AS comprobante_subido
FROM pedidos p
JOIN pagos pg ON pg.pedido_id = p.id
WHERE p.estado = 'pendiente' AND pg.estado = 'pendiente'
ORDER BY pg.created_at;
SELECT v.sku, pr.nombre, SUM(d.cantidad) AS unidades, SUM(d.cantidad * d.precio_unitario) AS ingresos
FROM detalle_pedido d
JOIN pedidos p             ON p.id = d.pedido_id AND p.estado IN ('pagado','entregado')
JOIN variantes_producto v  ON v.id = d.variante_id
JOIN productos pr          ON pr.id = v.producto_id
GROUP BY v.id, v.sku, pr.nombre
ORDER BY unidades DESC, ingresos DESC;
SELECT p.codigo, p.cliente_nombre, p.created_at,
       p.created_at + INTERVAL c.horas_reserva HOUR AS reserva_vence
FROM pedidos p
CROSS JOIN configuracion_tienda c
WHERE c.id = 1 AND p.estado = 'pendiente'
  AND p.created_at + INTERVAL c.horas_reserva HOUR <= NOW();
SELECT av.id, COALESCE(NULLIF(av.titulo,''), an.nombre, an.arete) AS nombre_publico,
       av.proposito, av.precio, av.estado,
       an.raza, pa.arete AS padre, ma.arete AS madre,
       ROUND(AVG(f.dmf),2) AS dmf_promedio
FROM animales_en_venta av
JOIN animales an          ON an.id = av.animal_id
LEFT JOIN animales pa     ON pa.id = an.padre_id
LEFT JOIN animales ma     ON ma.id = an.madre_id
LEFT JOIN producciones pd ON pd.animal_id = an.id
LEFT JOIN analisis_fibra f ON f.produccion_id = pd.id
WHERE av.estado IN ('disponible','reservado','vendido')
GROUP BY av.id, av.titulo, an.nombre, an.arete, av.proposito, av.precio, av.estado, an.raza, pa.arete, ma.arete
ORDER BY av.orden;
SELECT DATE_FORMAT(created_at, '%Y-%m') AS mes, COUNT(*) AS pedidos, SUM(total) AS ingresos
FROM pedidos
WHERE estado IN ('pagado','entregado')
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY mes;
SELECT CASE e.ubicacion WHEN 'cabecera' THEN 'Navbar' ELSE 'Footer' END AS menu,
       e.grupo, e.texto, e.enlace
FROM enlaces_navegacion e
WHERE e.activo = 1
ORDER BY e.ubicacion, e.grupo, e.orden;
