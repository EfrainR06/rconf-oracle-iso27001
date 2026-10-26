from datetime import date

PHASES = ('Planificar', 'Hacer', 'Verificar', 'Actuar')
STATUSES = ('Abierto', 'En tratamiento', 'Mitigado', 'Aceptado')

def validate(data, previous=None, role='analista'):
    if not isinstance(data, dict):
        raise ValueError('Se requiere un objeto JSON.')
    result = {}
    for key, limit in {'title': 160, 'asset': 120, 'owner': 100, 'treatment': 2000,
                       'evidence': 2000, 'controls': 240, 'decision': 1000}.items():
        value = data.get(key, '')
        if not isinstance(value, str) or len(value) > limit:
            raise ValueError(f'{key}: texto de hasta {limit} caracteres.')
        result[key] = value.strip()
    if not all(result[k] for k in ('title', 'asset', 'owner', 'treatment', 'controls')):
        raise ValueError('Complete título, activo, responsable, tratamiento y controles.')
    for key in ('probability', 'impact', 'residual_probability', 'residual_impact'):
        value = data.get(key)
        if type(value) is not int or not 1 <= value <= 5:
            raise ValueError('Las valoraciones deben ser enteros entre 1 y 5.')
        result[key] = value
    for key, options in (('phase', PHASES), ('status', STATUSES)):
        if data.get(key) not in options:
            raise ValueError(f'{key} no reconocido.')
        result[key] = data[key]
    try:
        result['due'] = date.fromisoformat(data.get('due', '')).isoformat()
    except (TypeError, ValueError):
        raise ValueError('Indique una fecha válida.')
    if previous:
        if data.get('version') != previous['version']:
            raise ValueError('El registro cambió. Actualice antes de guardar.')
        before, after = PHASES.index(previous['phase']), PHASES.index(result['phase'])
        if after > before + 1:
            raise ValueError('Avance una fase PHVA a la vez.')
    elif result['phase'] != 'Planificar' or result['status'] != 'Abierto':
        raise ValueError('Un riesgo nuevo inicia Abierto en Planificar.')
    if result['phase'] != 'Planificar' and not result['evidence']:
        raise ValueError('Agregue la referencia de evidencia para avanzar.')
    if result['status'] in ('Mitigado', 'Aceptado'):
        if role != 'gestor':
            raise PermissionError('Solo el gestor puede aprobar el riesgo residual.')
        if result['phase'] != 'Actuar' or not result['evidence'] or not result['decision']:
            raise ValueError('El cierre requiere Actuar, evidencia y decisión documentada.')
        if result['status'] == 'Mitigado' and result['residual_probability'] * result['residual_impact'] > 4:
            raise ValueError('Residual superior a 4: continúe el tratamiento o acepte justificadamente.')
    return result
