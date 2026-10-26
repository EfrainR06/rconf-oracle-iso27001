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
 def save(self,data,id,version,role): self.calls.append((data,id,version,role)); return id or 2

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
 assert not store.calls

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
