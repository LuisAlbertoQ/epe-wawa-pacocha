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
