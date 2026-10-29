-- Objetivo 1. Solo lectura; ejecutar como RCONF_APP en XEPDB1.
-- El conteo refleja registros de Oracle, no los ejemplos del navegador.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET ECHO ON
SET LINESIZE 180
SET PAGESIZE 100
BEGIN
 IF USER <> 'RCONF_APP' OR SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20043,'Se requiere RCONF_APP en XEPDB1');
 END IF;
END;
/
SELECT SYSTIMESTAMP AS fecha, USER AS cuenta,
       SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;
PROMPT === Objetivo 1: cantidad de riesgos registrados ===
SELECT COUNT(*) AS riesgos_registrados FROM rconf_owner.risk_view;
PROMPT === Valores inherentes registrados: probabilidad x impacto ===
WITH datos AS (
 SELECT id,
        JSON_VALUE(payload, '$.probability' RETURNING NUMBER NULL ON ERROR) AS probabilidad,
        JSON_VALUE(payload, '$.impact' RETURNING NUMBER NULL ON ERROR) AS impacto
 FROM rconf_owner.risk_view
)
SELECT id, probabilidad, impacto, probabilidad*impacto AS puntaje,
 CASE WHEN probabilidad NOT BETWEEN 1 AND 5 OR impacto NOT BETWEEN 1 AND 5
           OR probabilidad IS NULL OR impacto IS NULL THEN 'REVISAR'
      WHEN probabilidad*impacto <= 4 THEN 'BAJO'
      WHEN probabilidad*impacto <= 9 THEN 'MEDIO'
      WHEN probabilidad*impacto <= 16 THEN 'ALTO'
      ELSE 'CRITICO' END AS nivel
FROM datos ORDER BY id;
PROMPT Comparar cada registro con su activo, tratamiento y control en la pagina.
PROMPT Cinco filas no prueban por si solas la calidad de la evaluacion.
