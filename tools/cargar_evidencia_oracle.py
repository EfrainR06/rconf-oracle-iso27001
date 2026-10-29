"""R-CONF | Copia salidas originales (TXT) al expediente Oracle RCONF_OWNER.RCONF_PROJECT_DATA.

Uso (como usuario del grupo ORA_DBA del servidor local, sin contrasenas):
    .venv\\Scripts\\python tools\\cargar_evidencia_oracle.py            # muestra el plan
    .venv\\Scripts\\python tools\\cargar_evidencia_oracle.py --aplicar  # inserta en XEPDB1

- Solo inserta claves nuevas: nunca sobrescribe una evidencia ya guardada.
- El contenido se guarda tal cual (sin editar) junto con nombre, tamano y SHA-256 del archivo.
- La lista de archivos es fija; revisar SQL_TEXT y rutas antes de cargar o compartir.
"""
import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EVID = ROOT / 'local-evidence' / 'pruebas_dba_2026-10-29'

# doc_key -> archivo (patron); se elige el ultimo por nombre si hay varios.
DOCUMENTS = {
    'DBA_VERIFY_20261029': '04_verify_dba_*.txt',
    'AUDITOR_CONTROLS_20261029': '08_auditor_controls_*.txt',
    'AUDIT_CORRELATION_20261029': '19_audit_correlation_*.txt',
    'T11_CORRELATION_20261029': '24_correlacion_t11_*.txt',
    'OBS_INVESTIGATION_PDB': '23_investigacion_observaciones_2*.txt',
    'OBS_INVESTIGATION_CDB': '23_investigacion_observaciones_CDBROOT_*.txt',
    'BACKUP_ACL_20261029': 'acl_respaldos_*.txt',
}


def decode(raw: bytes) -> str:
    if raw.startswith(b'\xef\xbb\xbf'):
        return raw[3:].decode('utf-8')
    try:
        return raw.decode('utf-8')
    except UnicodeDecodeError:
        return raw.decode('cp1252', errors='replace')


def literal_chunks(text: str, size: int = 1800):
    for i in range(0, len(text), size):
        chunk = text[i:i + size]
        for d in ('~', '#', '!', '^', '|'):
            if d + "'" not in chunk and not chunk.endswith(d):
                yield f"q'{d}{chunk}{d}'"
                break
        else:
            raise ValueError('No hay delimitador seguro para un fragmento.')


def build_sql(key: str, path: Path) -> str:
    raw = path.read_bytes()
    payload = json.dumps({'name': path.name, 'content': decode(raw), 'size': len(raw),
                          'sha256': hashlib.sha256(raw).hexdigest(),
                          'source': 'local-evidence/' + path.parent.name + '/' + path.name},
                         ensure_ascii=True)
    appends = '\n'.join(f' s := {c};\n DBMS_LOB.WRITEAPPEND(v, LENGTH(s), s);' for c in literal_chunks(payload))
    return f"""DECLARE v CLOB; n NUMBER; s VARCHAR2(4000); BEGIN
 SELECT COUNT(*) INTO n FROM rconf_owner.rconf_project_data WHERE doc_key='{key}';
 IF n > 0 THEN DBMS_OUTPUT.PUT_LINE('OMITIDO (ya existe): {key}'); RETURN; END IF;
 DBMS_LOB.CREATETEMPORARY(v, TRUE);
{appends}
 INSERT INTO rconf_owner.rconf_project_data(doc_key, payload) VALUES ('{key}', v);
 DBMS_OUTPUT.PUT_LINE('INSERTADO: {key} ({len(raw)} bytes)');
END;
/
"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--aplicar', action='store_true')
    args = parser.parse_args()
    blocks = []
    for key, pattern in DOCUMENTS.items():
        files = sorted(EVID.glob(pattern))
        if not files:
            print(f'FALTA: {key} ({pattern})')
            continue
        print(f'{key:28} <- {files[-1].name}')
        blocks.append(build_sql(key, files[-1]))
    if not args.aplicar:
        print('Plan solamente. Repetir con --aplicar para insertar.')
        return
    script = ('WHENEVER SQLERROR EXIT FAILURE ROLLBACK\nSET DEFINE OFF\nSET SERVEROUTPUT ON\nSET FEEDBACK OFF\n'
              "ALTER SESSION SET CONTAINER=XEPDB1;\n" + '\n'.join(blocks) + 'COMMIT;\nEXIT\n')
    result = subprocess.run(['sqlplus', '-S', '-L', '/ as sysdba'], input=script, text=True,
                            capture_output=True, encoding='ascii')
    print(result.stdout.strip())
    if result.returncode:
        print(result.stderr, file=sys.stderr)
        sys.exit(result.returncode)


if __name__ == '__main__':
    main()
