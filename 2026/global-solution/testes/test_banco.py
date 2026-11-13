"""Verificações locais do esquema SQLite; não substituem testes da API."""
import pathlib
import sqlite3
import unittest

SCHEMA = (pathlib.Path(__file__).resolve().parents[1] / 'banco' / 'schema.sql').read_text()

class BancoTest(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(':memory:')
        self.db.executescript(SCHEMA)
    def tearDown(self): self.db.close()
    def test_carga_inicial(self):
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM sensores').fetchone()[0], 2)
    def test_chave_estrangeira(self):
        with self.assertRaises(sqlite3.IntegrityError): self.db.execute('INSERT INTO leituras(sensor_id,valor) VALUES (999,1)')
    def test_rejeita_valor_negativo(self):
        with self.assertRaises(sqlite3.IntegrityError): self.db.execute('INSERT INTO leituras(sensor_id,valor) VALUES (1,-1)')
    def test_tipo_sensor_unico_por_local(self):
        with self.assertRaises(sqlite3.IntegrityError): self.db.execute("INSERT INTO sensores(local_id,tipo,unidade) VALUES (1,'NIVEL','m')")
    def test_alerta_unico_por_leitura(self):
        self.db.execute('INSERT INTO leituras(id,sensor_id,valor) VALUES (1,1,2.5)')
        self.db.execute("INSERT INTO alertas(leitura_id,mensagem) VALUES (1,'Alerta')")
        with self.assertRaises(sqlite3.IntegrityError): self.db.execute("INSERT INTO alertas(leitura_id,mensagem) VALUES (1,'Outro')")
    def test_rejeita_limite_zero(self):
        with self.assertRaises(sqlite3.IntegrityError): self.db.execute("INSERT INTO locais(nome,bairro,limite_nivel,limite_chuva) VALUES ('Rua','Centro',0,20)")
    def test_rejeita_perfil_desconhecido(self):
        with self.assertRaises(sqlite3.IntegrityError): self.db.execute("INSERT INTO usuarios(nome,email,senha_hash,perfil) VALUES ('Teste','a@b.c','hash','OUTRO')")
    def test_consultas_sao_validas(self):
        consultas=(pathlib.Path(__file__).resolve().parents[1]/'banco'/'consultas.sql').read_text()
        for consulta in consultas.split(';'):
            if consulta.strip(): self.db.execute(consulta).fetchall()

if __name__ == '__main__': unittest.main(verbosity=2)
