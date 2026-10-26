-- FIRST INSTALL ONLY. Run as RCONF_OWNER in the lab PDB. Stops on first error.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
CREATE TABLE risks (
 id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 payload CLOB NOT NULL CHECK (payload IS JSON STRICT),
 version NUMBER DEFAULT 1 NOT NULL,
 updated_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
);
CREATE TABLE risk_events (
 event_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 risk_id NUMBER NOT NULL REFERENCES risks(id),
 actor_role VARCHAR2(20) NOT NULL,
 action VARCHAR2(30) NOT NULL,
 created_at TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
 previous_payload CLOB,
 new_payload CLOB NOT NULL
);
CREATE VIEW risk_view AS SELECT id,payload,version FROM risks;
CREATE VIEW event_view AS
 SELECT event_id,risk_id,actor_role,action,created_at FROM risk_events;
CREATE OR REPLACE PACKAGE risk_api AUTHID DEFINER AS
 PROCEDURE save_risk(p_id NUMBER,p_payload CLOB,p_version NUMBER,p_role VARCHAR2,p_out OUT NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY risk_api AS
 PROCEDURE save_risk(p_id NUMBER,p_payload CLOB,p_version NUMBER,p_role VARCHAR2,p_out OUT NUMBER) IS
  v_before CLOB;
  v_version NUMBER;
  v_doc JSON_OBJECT_T;
 BEGIN
  IF p_role IS NULL OR p_role NOT IN ('analista','gestor') THEN
   RAISE_APPLICATION_ERROR(-20002,'Write role required');
  END IF;
  -- The service is the trusted policy enforcement point; callers have no DML grants.
  v_doc := JSON_OBJECT_T.parse(p_payload);
  IF v_doc.get_string('status') IN ('Mitigado','Aceptado') AND p_role <> 'gestor' THEN
   RAISE_APPLICATION_ERROR(-20002,'Manager approval required');
  END IF;
  IF p_id IS NULL THEN
   INSERT INTO risks(payload) VALUES(p_payload) RETURNING id INTO p_out;
   INSERT INTO risk_events(risk_id,actor_role,action,new_payload)
    VALUES(p_out,p_role,'Creacion',p_payload);
  ELSE
   SELECT payload,version INTO v_before,v_version FROM risks WHERE id=p_id FOR UPDATE;
   IF p_version IS NULL OR v_version<>p_version THEN
    RAISE_APPLICATION_ERROR(-20001,'Concurrent modification');
   END IF;
   UPDATE risks SET payload=p_payload,version=version+1,updated_at=SYSTIMESTAMP WHERE id=p_id;
   INSERT INTO risk_events(risk_id,actor_role,action,previous_payload,new_payload)
    VALUES(p_id,p_role,'Actualizacion',v_before,p_payload);
   p_out := p_id;
  END IF;
  -- The caller commits record and event in a single transaction.
 END;
END;
/
SHOW ERRORS PACKAGE BODY risk_api
BEGIN
 FOR obj IN (SELECT object_name FROM user_objects WHERE status='INVALID') LOOP
  RAISE_APPLICATION_ERROR(-20003,'Invalid object: '||obj.object_name);
 END LOOP;
END;
/
-- Synthetic sensitive data, never real people.
CREATE TABLE demo_personal (
 id NUMBER PRIMARY KEY, full_name VARCHAR2(80), email VARCHAR2(100)
);
INSERT INTO demo_personal VALUES(1,'Persona Sintetica Uno','persona1@example.invalid');
CREATE VIEW masked_personal AS
 SELECT id,'Persona '||TO_CHAR(id) AS display_name,'[oculto]' AS email FROM demo_personal;
GRANT SELECT ON risk_view TO rconf_runtime, rconf_readonly;
GRANT SELECT ON event_view TO rconf_runtime, rconf_readonly;
GRANT SELECT ON masked_personal TO rconf_runtime, rconf_readonly;
GRANT EXECUTE ON risk_api TO rconf_runtime;
COMMIT;
PROMPT Objects ready. No grants exist for base tables or ANY privileges.
