"""Exercita a API em execução. Use um banco de teste novo e as credenciais do README."""
import json
import os
import unittest
from urllib.request import Request, urlopen
from urllib.error import HTTPError

BASE = os.environ.get('ALERTA_TEST_URL', 'http://localhost:8080')

def request(path, method='GET', data=None, token=None):
    body = json.dumps(data).encode() if data is not None else None
    headers = {'Content-Type': 'application/json'}
    if token: headers['Authorization'] = 'Bearer ' + token
    try:
        with urlopen(Request(BASE + '/api' + path, data=body, headers=headers, method=method), timeout=10) as response:
            raw=response.read()
            return response.status, json.loads(raw) if raw else None
    except HTTPError as error:
        raw=error.read()
        return error.code, json.loads(raw) if raw else None

class ApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        status, admin = request('/login','POST',{'email':'admin@example.test','senha':'EscolhaUmaSenhaForte123'})
        if status != 200: raise RuntimeError('Login administrador falhou: '+str(status))
        cls.admin=admin['token']
        import uuid
        cls.email=uuid.uuid4().hex+'@example.test'
        status,_=request('/cadastro','POST',{'nome':'Cidadão Teste','email':cls.email,'senha':'SenhaSegura123'})
        if status != 201: raise RuntimeError('Cadastro de teste falhou: '+str(status))
        status, cidadao=request('/login','POST',{'email':cls.email,'senha':'SenhaSegura123'})
        if status != 200: raise RuntimeError('Login de teste falhou: '+str(status))
        cls.cidadao=cidadao['token']
    def test_01_login_invalido(self):
        self.assertEqual(request('/login','POST',{'email':self.email,'senha':'errada'})[0],401)
    def test_02_acesso_sem_token(self):
        self.assertEqual(request('/locais')[0],401)
    def test_03_cidadao_nao_registra_medicao(self):
        self.assertEqual(request('/leituras','POST',{'sensorId':1,'valor':3},self.cidadao)[0],403)
    def test_04_leitura_abaixo_limite(self):
        code,data=request('/leituras','POST',{'sensorId':1,'valor':1},self.admin)
        self.assertEqual(code,201); self.assertFalse(data['alerta'])
    def test_05_leitura_no_limite_e_alerta(self):
        code,data=request('/leituras','POST',{'sensorId':1,'valor':2},self.admin)
        self.assertEqual(code,201); self.assertTrue(data['alerta'])
        code,alertas=request('/alertas',token=self.cidadao)
        self.assertEqual(code,200); self.assertTrue(any(a['tipo']=='NIVEL' and a['valor']==2 for a in alertas))
    def test_06_chuva_acima_limite(self):
        code,data=request('/leituras','POST',{'sensorId':2,'valor':35},self.admin)
        self.assertEqual(code,201); self.assertTrue(data['alerta'])
    def test_07_leitura_negativa(self):
        self.assertEqual(request('/leituras','POST',{'sensorId':1,'valor':-1},self.admin)[0],400)
    def test_08_sensor_inexistente(self):
        self.assertEqual(request('/leituras','POST',{'sensorId':999,'valor':1},self.admin)[0],404)
    def test_09_criar_atualizar_excluir_local(self):
        local={'nome':'Ponte teste','bairro':'Centro','limiteNivel':2,'limiteChuva':30}
        self.assertEqual(request('/locais','POST',local,self.admin)[0],201)
        code,lista=request('/locais',token=self.admin)
        identifier=next(x['id'] for x in lista if x['nome']=='Ponte teste')
        local['nome']='Ponte atualizada'
        self.assertEqual(request('/locais/'+str(identifier),'PUT',local,self.admin)[0],200)
        self.assertEqual(request('/locais/'+str(identifier),'DELETE',token=self.admin)[0],204)
    def test_10_estrutura_do_painel(self):
        for path in ('/sensores','/locais','/leituras','/alertas'):
            with self.subTest(path=path): self.assertEqual(request(path,token=self.cidadao)[0],200)
    def test_11_credencial_duplicada(self):
        self.assertEqual(request('/cadastro','POST',{'nome':'Pessoa Teste','email':self.email,'senha':'SenhaSegura123'})[0],409)

if __name__ == '__main__': unittest.main(verbosity=2)
