import hmac
import logging
import math
import os
from functools import wraps
from pathlib import Path
from flask import Flask, jsonify, request, send_from_directory, send_file, Response, g
from dotenv import load_dotenv
from .domain import validate
from .script_catalog import SCRIPT_CATALOG, SCRIPT_NAMES
from .audit_exports import capture_template, build_txt_bundle

load_dotenv()

def create_app(store=None):
    app = Flask(__name__, static_folder='static')
    app.config['MAX_CONTENT_LENGTH'] = 65536
    mode = os.getenv('APP_MODE', 'demo')
    if mode not in ('demo', 'oracle'):
        raise RuntimeError('APP_MODE debe ser demo u oracle.')
    tokens = {r: os.getenv('API_TOKEN_' + r.upper(), '') for r in ('analista', 'gestor', 'auditor')}
    if mode == 'oracle':
        if any(len(t) < 32 for t in tokens.values()) or len(set(tokens.values())) != 3:
            raise RuntimeError('Configure tres tokens distintos de al menos 32 caracteres.')
        if not all(os.getenv(k) for k in ('ORACLE_USER', 'ORACLE_PASSWORD', 'ORACLE_DSN')) and store is None:
            raise RuntimeError('Falta la configuración de Oracle.')
        if store is None:
            from .store import OracleStore
            store = OracleStore()

    def auth(write=False):
        def decorate(fn):
            @wraps(fn)
            def wrapped(*args, **kwargs):
                if mode != 'oracle':
                    return jsonify(error='La demostración se guarda solo en este navegador.'), 409
                header = request.headers.get('Authorization', '')
                supplied = header[7:] if header.startswith('Bearer ') else ''
                g.role = next((r for r,t in tokens.items() if hmac.compare_digest(supplied, t)), None)
                if g.role is None:
                    return jsonify(error='Credencial no válida.'), 401
                if write and g.role == 'auditor':
                    return jsonify(error='El auditor tiene acceso de lectura.'), 403
                return fn(*args, **kwargs)
            return wrapped
        return decorate

    @app.after_request
    def headers(response):
        response.headers.update({
            'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'",
            'X-Content-Type-Options': 'nosniff', 'Referrer-Policy': 'no-referrer',
            'X-Frame-Options': 'DENY', 'Permissions-Policy': 'camera=(), microphone=(), geolocation=()'})
        if request.path.startswith('/api/'):
            response.headers['Cache-Control'] = 'no-store'
        if os.getenv('WEBSITE_HOSTNAME'):
            response.headers['Strict-Transport-Security'] = 'max-age=31536000'
        return response

    @app.get('/')
    def index():
        return send_from_directory(app.static_folder, 'index.html')

    @app.get('/documents/<string:name>')
    def document(name):
        published = {
            '01_informe_academico.pdf', '02_manual_tecnico.pdf', '03_azure.pdf',
            '04_uso_ia.pdf', '07_evidencia_oracle_2026-10-26.pdf',
            '08_guion_demostracion.pdf',
            '10_pruebas_y_video.pdf', '11_caso_antes_despues.md', '12_objetivos_paso_a_paso.md',
        }
        if name not in published:
            return jsonify(error='Documento no disponible.'), 404
        return send_from_directory(Path(app.root_path).parent / 'docs', name)

    @app.get('/api/scripts')
    def scripts():
        return jsonify(SCRIPT_CATALOG)

    @app.get('/api/scripts/<string:name>')
    def script_source(name):
        if name not in SCRIPT_NAMES:
            return jsonify(error='Script no disponible.'), 404
        content = (Path(app.root_path).parent / 'sql' / name).read_text(encoding='utf-8')
        return jsonify(name=name, content=content)

    @app.get('/sql/<string:name>')
    def auditor_sql(name):
        if name not in SCRIPT_NAMES:
            return jsonify(error='Script no disponible.'), 404
        return send_from_directory(Path(app.root_path).parent / 'sql', name, as_attachment=True)

    @app.get('/txt/<string:name>')
    def script_txt(name):
        sql_name = name[:-4]+'.sql' if name.endswith('.txt') else ''
        if sql_name not in SCRIPT_NAMES:
            return jsonify(error='Script no disponible.'), 404
        source = (Path(app.root_path).parent/'sql'/sql_name).read_text(encoding='utf-8')
        return Response(source, mimetype='text/plain', headers={'Content-Disposition':f'attachment; filename="{name}"'})

    @app.get('/capture-template/<string:stage>/<string:name>')
    def script_template(stage, name):
        script = next((s for s in SCRIPT_CATALOG if s['name']==name), None)
        if stage not in ('before','after') or script is None:
            return jsonify(error='Plantilla no disponible.'), 404
        return Response(capture_template(script, stage), mimetype='text/plain',
                        headers={'Content-Disposition':f'attachment; filename="{stage}_{name[:-4]}.txt"'})

    @app.get('/downloads/auditoria-txt.zip')
    def audit_bundle():
        return send_file(build_txt_bundle(Path(app.root_path).parent), mimetype='application/zip',
                         download_name='rconf-auditoria-txt.zip', as_attachment=True)

    @app.get('/api/database')
    @auth()
    def database():
        return jsonify(store.database_snapshot())

    @app.get('/api/case-local')
    @auth()
    def case_local():
        if request.remote_addr not in ('127.0.0.1', '::1') or os.getenv('WEBSITE_HOSTNAME'):
            return jsonify(error='El expediente del caso solo está disponible en el servidor local.'), 403
        documents = store.project_documents()
        captures = {stage: documents[key]['data'] for stage, key in (('before', 'CASE_BEFORE'), ('after', 'CASE_AFTER')) if key in documents}
        extra = {key: doc['data'] for key, doc in documents.items()
                 if key not in ('CATALOG', 'MATURITY', 'CASE_BEFORE', 'CASE_AFTER')}
        snapshot = store.database_snapshot()
        return jsonify(account=snapshot['account'], pdb=snapshot['pdb'], observed_at=snapshot.get('observed_at'), captures=captures, extra=extra)

    @app.get('/health')
    def health():
        return jsonify(status='ok', mode=mode, database='no comprobada')

    @app.get('/api/config')
    def config():
        return jsonify(mode=mode)

    @app.get('/api/session')
    @auth()
    def session():
        return jsonify(role=g.role)

    @app.get('/api/risks')
    @auth()
    def risks():
        return jsonify(store.list())

    @app.get('/api/dba-tasks')
    @auth()
    def dba_tasks():
        return jsonify(store.list_dba_tasks())

    @app.get('/api/project')
    @auth()
    def project():
        docs = store.project_documents()
        if 'CATALOG' not in docs or 'MATURITY' not in docs:
            return jsonify(error='El expediente Oracle está incompleto.'), 503
        return jsonify(catalog=docs['CATALOG']['data'], maturity=docs['MATURITY']['data'],
                       version=docs['MATURITY']['version'])

    @app.put('/api/maturity')
    @auth(write=True)
    def save_maturity():
        raw = request.get_json(silent=True)
        if not isinstance(raw, dict) or type(raw.get('version')) is not int or raw['version'] < 1:
            return jsonify(error='Versión de matriz no válida.'), 400
        target, rows = raw.get('target'), raw.get('rows')
        if type(target) not in (int, float) or not math.isfinite(target) or not 0 <= target <= 4 or not isinstance(rows, dict):
            return jsonify(error='Matriz o meta no válida.'), 400
        docs = store.project_documents()
        allowed = {item['id'] for item in docs['CATALOG']['data']['controls']}
        blocks = {'R01','R02','R03','R04','R05','TDE','RMAN','Red'}
        statuses = {'','Cumple','Parcial','No cumple'}
        cleaned = {}
        for key, row in rows.items():
            if key not in allowed or not isinstance(row, dict):
                return jsonify(error='Control no reconocido.'), 400
            if any(row.get(k) is not None and (type(row[k]) is not int or not 0 <= row[k] <= 4) for k in ('before','after')):
                return jsonify(error='Nivel fuera de 0–4.'), 400
            if any(not isinstance(row.get(k), str) or len(row[k]) > 300 for k in ('beforeRef','afterRef')):
                return jsonify(error='Referencia no válida.'), 400
            if not isinstance(row.get('block'), str) or row['block'] not in blocks or type(row.get('reviewed')) is not bool:
                return jsonify(error='Bloque o revisión no válidos.'), 400
            if any(not isinstance(row.get(k, ''), str) or row.get(k, '') not in statuses for k in ('beforeStatus','afterStatus')):
                return jsonify(error='Estado de control no válido.'), 400
            cleaned[key] = {k: row.get(k) for k in ('before','after','beforeRef','afterRef','block','reviewed')}
            cleaned[key].update({k: row.get(k, '') for k in ('beforeStatus','afterStatus')})
        try:
            version = store.save_maturity({'target': target, 'rows': cleaned}, raw['version'], g.role)
        except Exception as exc:
            if getattr(exc.args[0], 'code', None) == 20064:
                return jsonify(error='La matriz cambió en otra sesión; recargá antes de guardar.'), 409
            raise
        return jsonify(version=version)

    @app.get('/api/events')
    @auth()
    def events():
        return jsonify(store.events())

    @app.post('/api/checks/runtime')
    @auth()
    def check_runtime():
        if request.remote_addr not in ('127.0.0.1', '::1') or os.getenv('WEBSITE_HOSTNAME'):
            return jsonify(error='Las comprobaciones solo están disponibles en el servidor local.'), 403
        return jsonify(store.check_runtime(g.role))

    @app.route('/api/risks', methods=['POST'])
    @app.route('/api/risks/<int:risk_id>', methods=['PUT'])
    @auth(write=True)
    def save(risk_id=None):
        raw = request.get_json(silent=True)
        previous = next((r for r in store.list() if r['id'] == risk_id), None) if risk_id else None
        if risk_id and previous is None:
            return jsonify(error='Riesgo inexistente.'), 404
        try:
            clean = validate(raw, previous, g.role)
        except PermissionError as exc:
            return jsonify(error=str(exc)), 403
        except ValueError as exc:
            return jsonify(error=str(exc)), 400
        result = store.save(clean, risk_id, previous['version'] if previous else None, g.role)
        return jsonify(id=result), 200 if risk_id else 201

    @app.errorhandler(Exception)
    def unexpected(exc):
        from werkzeug.exceptions import HTTPException
        if isinstance(exc, HTTPException):
            return jsonify(error=exc.name), exc.code
        # No SQL text, credentials or request bodies in logs or responses.
        logging.error('R-CONF operation failed: %s', type(exc).__name__)
        if 'ORA-20001' in str(exc):
            return jsonify(error='El registro cambió. Actualice e intente de nuevo.'), 409
        return jsonify(error='No se pudo completar la operación. Revise conexión y configuración del servidor.'), 503

    return app

app = create_app()
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8000, debug=False)
