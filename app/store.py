import json
import os
import threading
from datetime import datetime, timezone
import oracledb

class OracleStore:
    def __init__(self):
        self._pool = None
        self._lock = threading.Lock()

    def pool(self):
        with self._lock:
            if self._pool is None:
                options = dict(user=os.environ['ORACLE_USER'], password=os.environ['ORACLE_PASSWORD'],
                               dsn=os.environ['ORACLE_DSN'], min=0, max=4, increment=1,
                               tcp_connect_timeout=5)
                if os.getenv('ORACLE_WALLET_DIR'):
                    options.update(config_dir=os.environ['ORACLE_WALLET_DIR'],
                                   wallet_location=os.environ['ORACLE_WALLET_DIR'],
                                   wallet_password=os.getenv('ORACLE_WALLET_PASSWORD'),
                                   ssl_server_dn_match=True)
                self._pool = oracledb.create_pool(**options)
            return self._pool

    def list(self):
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            with conn.cursor() as cur:
                cur.execute('SELECT id, payload, version FROM rconf_owner.risk_view ORDER BY id')
                return [dict(json.loads(p.read() if hasattr(p, 'read') else p), id=i, version=v)
                        for i, p, v in cur]

    def list_dba_tasks(self):
        """Read the task catalog through a view, without access to its base table."""
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            with conn.cursor() as cur:
                cur.execute('SELECT task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status FROM rconf_owner.v_dba_tasks ORDER BY task_id')
                return [dict(id=i, task=title, action=action, frequency=frequency,
                             controls=controls, evidence=evidence, script=script, status=status)
                        for i, title, action, frequency, controls, evidence, script, status in cur]

    def project_documents(self):
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            with conn.cursor() as cur:
                cur.execute("""SELECT doc_key,payload,version FROM rconf_owner.v_project_data
                    WHERE doc_key IN ('CATALOG','MATURITY','CASE_BEFORE','CASE_AFTER',
                    'CASE_DBA_BEFORE','CASE_DBA_AFTER','CURRENT_DIAGNOSTIC',
                    'RUNTIME_20261029','RISK_INVENTORY_CURRENT',
                    'DBA_VERIFY_20261029','AUDITOR_CONTROLS_20261029','AUDIT_CORRELATION_20261029',
                    'T11_CORRELATION_20261029','OBS_INVESTIGATION_PDB','OBS_INVESTIGATION_CDB',
                    'BACKUP_ACL_20261029')""")
                return {key: {'data': json.loads(payload.read() if hasattr(payload, 'read') else payload), 'version': version}
                        for key, payload, version in cur}

    def save_maturity(self, data, version, role):
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            with conn.cursor() as cur:
                payload = cur.var(oracledb.DB_TYPE_CLOB)
                payload.setvalue(0, json.dumps(data, ensure_ascii=False))
                new_version = cur.var(int)
                cur.callproc('rconf_owner.project_api.save_maturity', [payload, version, role, new_version])
                conn.commit()
                return new_version.getvalue()

    def database_snapshot(self):
        """Observe metadata visible to the configured account, without DBA grants."""
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            with conn.cursor() as cur:
                cur.execute("SELECT SYS_CONTEXT('USERENV','SESSION_USER'), SYS_CONTEXT('USERENV','CON_NAME'), SYS_CONTEXT('USERENV','DB_NAME'), SYS_CONTEXT('USERENV','SERVICE_NAME') FROM dual")
                account, pdb, db_name, service = cur.fetchone()
                cur.execute("SELECT object_name, object_type, status FROM all_objects WHERE owner='RCONF_OWNER' AND object_type IN ('VIEW','PACKAGE','TABLE') ORDER BY object_type,object_name")
                objects = [dict(name=n, type=t, status=s) for n,t,s in cur]
                cur.execute('SELECT privilege FROM session_privs ORDER BY privilege')
                privileges = [row[0] for row in cur]
                cur.execute('SELECT role FROM session_roles ORDER BY role')
                roles = [row[0] for row in cur]
                cur.execute('SELECT COUNT(*) FROM rconf_owner.risk_view')
                risk_count = cur.fetchone()[0]
                cur.execute('SELECT COUNT(*) FROM rconf_owner.event_view')
                event_count = cur.fetchone()[0]
        return dict(account=account, pdb=pdb, database=db_name, service=service,
                    objects=objects, privileges=privileges, roles=roles,
                    risk_count=risk_count, event_count=event_count,
                    observed_at=datetime.now(timezone.utc).isoformat(),
                    scope='Metadatos visibles para la cuenta técnica. No es un inventario DBA completo ni prueba de auditoría unificada.')

    def save(self, payload, risk_id, version, role):
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            conn.client_identifier = 'rconf:' + role
            with conn.cursor() as cur:
                out = cur.var(int)
                cur.callproc('rconf_owner.risk_api.save_risk',
                             [risk_id, json.dumps(payload, ensure_ascii=False), version, role, out])
                conn.commit()
                return out.getvalue()

    def events(self):
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            with conn.cursor() as cur:
                cur.execute('SELECT event_id, risk_id, actor_role, action, created_at FROM rconf_owner.event_view ORDER BY event_id DESC FETCH FIRST 200 ROWS ONLY')
                return [dict(id=i, risk_id=r, actor=a, action=x, at=t.isoformat()) for i,r,a,x,t in cur]

    def check_runtime(self, role):
        """Run fixed, read-only probes as RCONF_APP; never return row contents."""
        probes = (
            ('T07-VISTA', 'Vista limitada', 'SELECT email FROM rconf_owner.masked_personal WHERE ROWNUM = 1', 'masked'),
            ('T07-TABLA', 'Tabla personal directa', 'SELECT 1 FROM rconf_owner.demo_personal WHERE 1 = 0', 'denied'),
            ('T08-VISTA', 'Vista de riesgos', 'SELECT id FROM rconf_owner.risk_view WHERE 1 = 0', 'allowed'),
            ('T08-TABLA', 'Tabla de riesgos directa', 'SELECT 1 FROM rconf_owner.risks WHERE 1 = 0', 'denied'),
        )
        results = []
        with self.pool().acquire() as conn:
            conn.call_timeout = 10000
            conn.client_identifier = 'rconf:check:' + role
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT SYS_CONTEXT('USERENV','SESSION_USER'), SYS_CONTEXT('USERENV','CON_NAME') FROM dual")
                    account, pdb = cur.fetchone()
                    if account != 'RCONF_APP':
                        raise RuntimeError('La verificación requiere la cuenta limitada RCONF_APP.')
                    for probe_id, title, sql, expected in probes:
                        try:
                            cur.execute(sql)
                            row = cur.fetchone()
                            if expected == 'denied':
                                status, observed = 'fallo', 'La lectura directa fue permitida.'
                            elif expected == 'masked':
                                status = 'conforme' if row and row[0] == '[oculto]' else 'revisar'
                                observed = 'La vista devolvió el valor enmascarado esperado.' if status == 'conforme' else 'No se confirmó el valor enmascarado esperado.'
                            else:
                                status, observed = 'conforme', 'La vista fue accesible.'
                        except oracledb.DatabaseError as exc:
                            error_code = getattr(exc.args[0], 'code', None)
                            if expected == 'denied' and error_code in (942, 1031):
                                status, observed = 'conforme', f'Acceso denegado por Oracle (ORA-{error_code:05d}).'
                            else:
                                status, observed = 'revisar', f'Oracle devolvió ORA-{error_code:05d}.' if isinstance(error_code, int) else 'La consulta no pudo completarse.'
                        results.append(dict(id=probe_id, title=title, expected=expected, status=status, observed=observed))
            finally:
                conn.rollback()
                conn.client_identifier = None
        return dict(account=account, pdb=pdb, checked_at=datetime.now(timezone.utc).isoformat(), results=results)
