-- ===== dml transaccion =====
-- DML en transacción: actualización y borrado con verificación y reversión
START TRANSACTION;
UPDATE variantes_producto SET precio_base = precio_base * 1.05 WHERE producto_id = 1;
SELECT id, sku, precio_base FROM variantes_producto WHERE producto_id = 1;
DELETE FROM imagenes_producto WHERE producto_id = 1 AND orden > 1;
SELECT ROW_COUNT() AS imagenes_borradas;
ROLLBACK;
-- Tras el ROLLBACK los precios vuelven a su valor original
SELECT id, sku, precio_base FROM variantes_producto WHERE producto_id = 1;

-- Baja lógica de un animal (RN05): no se borra, se cambia el estado con motivo
UPDATE animales SET estado = 'VENDIDO', motivo_estado = 'Vendido en feria de Juliaca'
 WHERE arete = '1006';
SELECT arete, nombre, estado, motivo_estado, fecha_estado FROM animales WHERE arete = '1006';
