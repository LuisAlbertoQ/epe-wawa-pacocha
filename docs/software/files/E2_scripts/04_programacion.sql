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
