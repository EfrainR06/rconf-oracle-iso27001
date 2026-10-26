import hmac
import logging
import os
from functools import wraps
from flask import Flask, jsonify, request, send_from_directory, g
from dotenv import load_dotenv
from .domain import validate

load_dotenv()

def create_app(store=None):
    app = Flask(__name__, static_folder='static')
    app.config['MAX_CONTENT_LENGTH'] = 16384
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

    @app.get('/api/events')
    @auth()
    def events():
        return jsonify(store.events())

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
