from io import BytesIO
from zipfile import ZipFile, ZIP_DEFLATED
from .script_catalog import SCRIPT_CATALOG

def capture_template(script, stage):
    label = {'before':'ANTES', 'after':'DESPUES'}[stage]
    return (f'PENDIENTE - NO EJECUTADO\nETAPA: {label}\nSCRIPT: {script["name"]}\n'
            f'CUENTA / PDB: {script["account"]}\nEFECTO: {script["kind"]}\n'
            f'ESPERADO: {script["expected"]}\n\nFECHA REAL: ______________\n'
            'EJECUTOR: ______________\nREVISOR: ______________\n'
            'SALIDA ORIGINAL: cargar el TXT generado por SQLPlus, sin editar resultados.\n'
            'Esta plantilla no es evidencia ni una ejecucion de Oracle.\n'
            'No capturar contrasenas; no repetir instalacion para producir una comparacion.\n')

def build_txt_bundle(root):
    output = BytesIO()
    with ZipFile(output, 'w', ZIP_DEFLATED) as bundle:
        for script in SCRIPT_CATALOG:
            name = script['name']
            source = (root/'sql'/name).read_text(encoding='utf-8')
            bundle.writestr('sql/'+name, source)
            bundle.writestr('txt/scripts/'+name[:-4]+'.txt', source)
            for stage,folder in [('before','antes'),('after','despues')]:
                bundle.writestr('txt/'+folder+'/'+name[:-4]+'.txt',capture_template(script,stage))
        bundle.writestr('LEEME_PRUEBA_REAL.txt',(root/'docs'/'11_caso_antes_despues.md').read_text(encoding='utf-8'))
        bundle.writestr('GUIA_OBJETIVOS.txt',(root/'docs'/'12_objetivos_paso_a_paso.md').read_text(encoding='utf-8'))
    output.seek(0)
    return output
