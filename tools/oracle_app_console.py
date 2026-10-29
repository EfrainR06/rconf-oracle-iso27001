"""Local SQL*Plus session using the existing application credentials in memory.

No password is written to a SQL file, command line, terminal, or history file.
This console is for RCONF_APP only; use ordinary SQL*Plus for DBA installation.
"""
from pathlib import Path
import argparse
import shutil
import subprocess
import sys
import threading

from dotenv import dotenv_values


ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Check the session and exit.')
    args = parser.parse_args()
    config = dotenv_values(ROOT / '.env')
    user = config.get('ORACLE_USER', '')
    password = config.get('ORACLE_PASSWORD', '')
    dsn = config.get('ORACLE_DSN', '')
    if user.upper() != 'RCONF_APP' or not password or not dsn:
        print('Revisar ORACLE_USER, ORACLE_PASSWORD y ORACLE_DSN en el .env local.')
        return 1
    if any(char in value for value in (user, password, dsn) for char in '\r\n') or '"' in password:
        print('Esta configuracion requiere la entrada habitual de SQL*Plus.')
        return 1
    executable = shutil.which('sqlplus')
    if not executable:
        fallback = Path(r'C:\app\Usuario\product\21c\dbhomeXE\bin\sqlplus.exe')
        executable = str(fallback) if fallback.exists() else None
    if not executable:
        print('No se encontro SQL*Plus en este equipo.')
        return 1

    process = subprocess.Popen(
        [executable, '-S', '/nolog'], cwd=ROOT, stdin=subprocess.PIPE,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1,
        errors='replace',
    )
    ready = threading.Event()
    status = {'connected': False}
    marker = '__RCONF_APP_SESSION_READY__'

    def show_output():
        try:
            for line in process.stdout:
                if line.strip() == marker:
                    status['connected'] = True
                    ready.set()
                else:
                    sys.stdout.write(line.replace(password, '[CONTRASENA_OCULTA]'))
                    sys.stdout.flush()
        finally:
            ready.set()

    reader = threading.Thread(target=show_output, daemon=True)
    reader.start()

    def send(text):
        process.stdin.write(text + '\n')
        process.stdin.flush()

    try:
        send('SET ECHO OFF\nSET VERIFY OFF\nSET DEFINE OFF\nSET FEEDBACK OFF\nSET LINESIZE 180\nSET PAGESIZE 100')
        send('WHENEVER SQLERROR EXIT FAILURE ROLLBACK')
        send('CONNECT ' + user + '/"' + password + '"@' + dsn)
        send("BEGIN IF USER <> 'RCONF_APP' OR SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN RAISE_APPLICATION_ERROR(-20001, 'Cuenta o PDB inesperado'); END IF; END;\n/")
        send('SET HEADING OFF\nSET FEEDBACK OFF')
        send("SELECT 'CONECTADO: ' || USER || ' / ' || SYS_CONTEXT('USERENV','CON_NAME') FROM dual;")
        send('SET HEADING ON\nSET FEEDBACK ON\nWHENEVER SQLERROR CONTINUE NONE')
        send('PROMPT ' + marker)
        if not ready.wait(20) or not status['connected'] or process.poll() is not None:
            print('No se pudo abrir la sesion. No se modificaron credenciales ni permisos.')
            return 1
        if args.check:
            send('EXIT ROLLBACK')
            process.wait(timeout=10)
            reader.join(timeout=2)
            return process.returncode

        print('SQL*Plus local - cuenta RCONF_APP. Carpeta: ' + str(ROOT))
        print('Escribi SQL o @sql/05_verify_runtime.sql. EXIT para salir.')
        print('Para cambiar de cuenta o introducir contrasenas, usa SQL*Plus habitual.')
        while process.poll() is None:
            line = input('SQL> ')
            first = line.strip().split(maxsplit=1)
            if first and first[0].upper() in ('CONNECT', 'CONN', 'PASSWORD', 'ACCEPT'):
                print('Esta consola usa RCONF_APP del .env. Para otra cuenta, usa SQL*Plus habitual.')
                continue
            send(line)
            if first and first[0].upper().rstrip(';') in ('EXIT', 'QUIT'):
                process.wait(timeout=10)
                break
        reader.join(timeout=2)
        return process.returncode or 0
    except (EOFError, KeyboardInterrupt):
        print('\nCerrando la sesion local.')
        return 0
    except (BrokenPipeError, OSError, subprocess.TimeoutExpired):
        print('La sesion SQL*Plus se cerro. Volve a abrir este acceso local.')
        return 1
    finally:
        if process.poll() is None:
            try:
                send('EXIT ROLLBACK')
                process.wait(timeout=3)
            except (OSError, subprocess.TimeoutExpired):
                process.kill()
                process.wait(timeout=3)


if __name__ == '__main__':
    raise SystemExit(main())
