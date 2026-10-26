import json
import os
import threading
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
