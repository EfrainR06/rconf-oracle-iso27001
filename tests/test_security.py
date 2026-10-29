import copy
import os
import pytest
from app.domain import validate
from app.server import create_app

@pytest.fixture
def record():
 return dict(title='Acceso indebido',asset='Clientes',owner='DBA',treatment='Restringir permisos',
  evidence='',controls='8.2',decision='',probability=4,impact=5,residual_probability=1,
  residual_impact=4,due='2026-11-12',phase='Planificar',status='Abierto')

class FakeStore:
 def __init__(self,record): self.rows=[dict(record,id=1,version=1)]; self.calls=[]
 def list(self): return copy.deepcopy(self.rows)
 def events(self): return []
 def list_dba_tasks(self): return [dict(id='T01',task='Usuarios',status='PENDIENTE')]
 def project_documents(self): return {'CATALOG':{'data':{'controls':[{'id':'5.12'}]}},'MATURITY':{'data':{'target':3.1,'rows':{}},'version':1}}
 def save_maturity(self,data,version,role): self.calls.append(('maturity',data,version,role)); return version+1
 def save(self,data,id,version,role): self.calls.append((data,id,version,role)); return id or 2
 def check_runtime(self,role): self.calls.append(('check',role)); return dict(account='RCONF_APP',pdb='XEPDB1',results=[])
 def database_snapshot(self): self.calls.append(('snapshot',)); return dict(account='RCONF_APP',pdb='XEPDB1',objects=[],privileges=['CREATE SESSION'],roles=['RCONF_RUNTIME'],risk_count=1,event_count=0)

@pytest.fixture
def oracle(monkeypatch,record):
 monkeypatch.setenv('APP_MODE','oracle')
 for r in ('ANALISTA','GESTOR','AUDITOR'): monkeypatch.setenv('API_TOKEN_'+r,r.lower().ljust(40,'x'))
 store=FakeStore(record)
 return create_app(store).test_client(),store

def auth(role): return {'Authorization':'Bearer '+role.ljust(40,'x')}

def test_no_auth_no_data(oracle):
 client,store=oracle
 assert client.get('/api/risks').status_code==401
 assert client.get('/api/events').status_code==401
 assert client.post('/api/checks/runtime').status_code==401
 assert client.get('/api/database').status_code==401
 assert client.get('/api/dba-tasks').status_code==401
 assert not store.calls

def test_database_snapshot_is_authenticated_and_read_only(oracle):
 client,store=oracle
 response=client.get('/api/database',headers=auth('auditor'))
 assert response.status_code==200
 assert response.json['account']=='RCONF_APP'
 assert store.calls==[('snapshot',)]
 assert client.post('/api/database',headers=auth('gestor')).status_code==405

def test_case_local_requires_session_and_loopback(oracle, monkeypatch):
 client,store=oracle
 assert client.get('/api/case-local').status_code==401
 assert client.get('/api/case-local',headers=auth('auditor'),environ_base={'REMOTE_ADDR':'203.0.113.8'}).status_code==403
 monkeypatch.setenv('WEBSITE_HOSTNAME','example.azurewebsites.net')
 assert client.get('/api/case-local',headers=auth('auditor')).status_code==403
 assert not store.calls

def test_case_local_only_exposes_allowlisted_evidence(oracle, monkeypatch):
 client,store=oracle
 monkeypatch.setattr(store,'project_documents',lambda: {
  'CASE_DBA_BEFORE': {'data': {'name':'antes.txt','content':'salida'}},
  'CURRENT_DIAGNOSTIC': {'data': {'name':'actual.txt','content':'estado'}},
  'PRIVATE_DOCUMENT': {'data': {'name':'privado.txt','content':'secreto'}}})
 result=client.get('/api/case-local',headers=auth('analista'))
 assert result.status_code==200
 assert set(result.json['extra'])=={'CASE_DBA_BEFORE','CURRENT_DIAGNOSTIC'}
 assert 'PRIVATE_DOCUMENT' not in result.get_data(as_text=True)

def test_dba_task_catalog_requires_auth_and_is_read_only(oracle):
 client,store=oracle
 result=client.get('/api/dba-tasks',headers=auth('auditor'))
 assert result.status_code==200
 assert result.json[0]['id']=='T01'
 assert client.post('/api/dba-tasks',headers=auth('auditor')).status_code==405

def test_maturity_persistence_enforces_roles_and_validates_input(oracle):
 client,store=oracle
 assert client.get('/api/project').status_code==401
 assert client.get('/api/project',headers=auth('auditor')).status_code==200
 payload={'version':1,'target':3.1,'rows':{'5.12':{'before':1,'after':2,'beforeRef':'EV1','afterRef':'EV2','block':'R01','reviewed':False,'beforeStatus':'No cumple','afterStatus':'Parcial'}}}
 assert client.put('/api/maturity',headers=auth('auditor'),json=payload).status_code==403
 assert client.put('/api/maturity',headers=auth('analista'),json=payload).json['version']==2
 payload['rows']['5.12']['before']=8
 assert client.put('/api/maturity',headers=auth('analista'),json=payload).status_code==400
 payload['rows']['5.12']['before']=1
 payload['rows']['5.12']['block']=[]
 assert client.put('/api/maturity',headers=auth('analista'),json=payload).status_code==400

def test_script_library_allows_only_published_sql(monkeypatch):
 monkeypatch.setenv('APP_MODE','demo')
 client=create_app().test_client()
 catalog=client.get('/api/scripts').json
 assert len(catalog)==24
 for script in catalog:
  source=client.get('/api/scripts/'+script['name'])
  assert source.status_code==200 and source.json['content']
  assert client.get('/sql/'+script['name']).status_code==200
 for path in ['/api/scripts/.env','/sql/.env','/api/scripts/%2e%2e%2f.env','/sql/%2e%2e%2f.env']:
  assert client.get(path).status_code==404
 assert client.get('/api/database').status_code==409

def test_txt_exports_and_pending_bundle(monkeypatch):
 from io import BytesIO
 from zipfile import ZipFile
 monkeypatch.setenv('APP_MODE','demo')
 client=create_app().test_client()
 for script in client.get('/api/scripts').json:
  stem=script['name'][:-4]
  txt=client.get('/txt/'+stem+'.txt')
  assert txt.status_code==200
  assert txt.get_data(as_text=True)==client.get('/api/scripts/'+script['name']).json['content']
  for stage in ('before','after'):
   result=client.get('/capture-template/'+stage+'/'+script['name'])
   assert result.status_code==200 and b'PENDIENTE - NO EJECUTADO' in result.data
 assert client.get('/txt/.env').status_code==404
 assert client.get('/capture-template/unknown/05_verify_runtime.sql').status_code==404
 bundle=client.get('/downloads/auditoria-txt.zip')
 assert bundle.status_code==200
 with ZipFile(BytesIO(bundle.data)) as archive:
  assert len([n for n in archive.namelist() if n.startswith('txt/scripts/')])==24
  assert b'PENDIENTE - NO EJECUTADO' in archive.read('txt/antes/14_case_before.txt')
  assert not any('.env' in n or n.startswith('local-evidence/') for n in archive.namelist())

def test_local_checks_are_fixed_and_local_only(oracle,monkeypatch):
 client,store=oracle
 assert client.post('/api/checks/runtime',headers=auth('auditor'),environ_base={'REMOTE_ADDR':'203.0.113.8'}).status_code==403
 assert not store.calls
 response=client.post('/api/checks/runtime',headers=auth('auditor'),json={'sql':'DROP TABLE risks'})
 assert response.status_code==200
 assert response.json['account']=='RCONF_APP'
 assert store.calls==[('check','auditor')]
 monkeypatch.setenv('WEBSITE_HOSTNAME','example.azurewebsites.net')
 assert client.post('/api/checks/runtime',headers=auth('auditor')).status_code==403

def test_auditor_cannot_write(oracle,record):
 client,store=oracle
 assert client.get('/api/risks',headers=auth('auditor')).status_code==200
 assert client.post('/api/risks',headers=auth('auditor'),json=record).status_code==403
 assert not store.calls

def test_analyst_cannot_accept(oracle,record):
 client,store=oracle
 record.update(version=1,phase='Hacer',evidence='EV-01',status='Aceptado',decision='Acepto')
 assert client.put('/api/risks/1',headers=auth('analista'),json=record).status_code==403
 assert not store.calls

def test_stale_version_rejected(oracle,record):
 client,store=oracle
 record['version']=0
 assert client.put('/api/risks/1',headers=auth('analista'),json=record).status_code==400
 assert not store.calls

def test_phase_requires_evidence(oracle,record):
 client,store=oracle
 record.update(version=1,phase='Hacer')
 assert client.put('/api/risks/1',headers=auth('analista'),json=record).status_code==400
 assert not store.calls

def test_sql_injection_remains_data(oracle,record):
 client,store=oracle
 record['title']="x'); DROP TABLE risks; --"
 assert client.post('/api/risks',headers=auth('analista'),json=record).status_code==201
 assert store.calls[0][0]['title']==record['title']

def test_invalid_probability_rejected(record):
 record['probability']=True
 with pytest.raises(ValueError): validate(record)

def test_no_phase_skip(record):
 old=dict(record,version=1)
 record.update(version=1,phase='Actuar',evidence='EV-01')
 with pytest.raises(ValueError): validate(record,old)

def test_manager_can_approve_only_with_evidence(record):
 old=dict(record,version=1,phase='Verificar')
 record.update(version=1,phase='Actuar',status='Mitigado',evidence='EV-01',decision='Prueba revisada')
 assert validate(record,old,'gestor')['status']=='Mitigado'
 record['decision']=''
 with pytest.raises(ValueError): validate(record,old,'gestor')

def test_demo_server_never_writes(monkeypatch):
 monkeypatch.setenv('APP_MODE','demo')
 client=create_app().test_client()
 assert client.post('/api/risks',json={}).status_code==409
 assert client.get('/').status_code==200
 assert "script-src 'self'" in client.get('/').headers['Content-Security-Policy']

def test_tokens_must_be_distinct(monkeypatch):
 monkeypatch.setenv('APP_MODE','oracle')
 for r in ('ANALISTA','GESTOR','AUDITOR'): monkeypatch.setenv('API_TOKEN_'+r,'x'*40)
 with pytest.raises(RuntimeError): create_app(FakeStore({}))

def test_error_does_not_leak_credentials(oracle,monkeypatch):
 client,store=oracle
 def fail(): raise RuntimeError('password=secret; SELECT * FROM private')
 monkeypatch.setattr(store,'list',fail)
 response=client.get('/api/risks',headers=auth('gestor'))
 assert response.status_code==503
 assert b'secret' not in response.data and b'SELECT' not in response.data
