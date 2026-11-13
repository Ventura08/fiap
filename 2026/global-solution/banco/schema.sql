PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS usuarios (
 id INTEGER PRIMARY KEY, nome TEXT NOT NULL CHECK(length(trim(nome)) BETWEEN 2 AND 100),
 email TEXT NOT NULL UNIQUE, senha_hash TEXT NOT NULL, perfil TEXT NOT NULL CHECK(perfil IN ('ADMIN','CIDADAO'))
);
CREATE TABLE IF NOT EXISTS locais (
 id INTEGER PRIMARY KEY, nome TEXT NOT NULL CHECK(length(trim(nome)) BETWEEN 2 AND 100),
 bairro TEXT NOT NULL CHECK(length(trim(bairro)) BETWEEN 2 AND 100),
 limite_nivel REAL NOT NULL CHECK(limite_nivel > 0), limite_chuva REAL NOT NULL CHECK(limite_chuva > 0)
);
CREATE TABLE IF NOT EXISTS sensores (
 id INTEGER PRIMARY KEY, local_id INTEGER NOT NULL REFERENCES locais(id),
 tipo TEXT NOT NULL CHECK(tipo IN ('NIVEL','CHUVA')), unidade TEXT NOT NULL,
 UNIQUE(local_id,tipo)
);
CREATE TABLE IF NOT EXISTS leituras (
 id INTEGER PRIMARY KEY, sensor_id INTEGER NOT NULL REFERENCES sensores(id),
 valor REAL NOT NULL CHECK(valor >= 0), registrada_em TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE TABLE IF NOT EXISTS alertas (
 id INTEGER PRIMARY KEY, leitura_id INTEGER NOT NULL UNIQUE REFERENCES leituras(id),
 mensagem TEXT NOT NULL, criada_em TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
INSERT OR IGNORE INTO locais(id,nome,bairro,limite_nivel,limite_chuva) VALUES (1,'Córrego Esperança','Vila Esperança',2.0,30.0);
INSERT OR IGNORE INTO sensores(id,local_id,tipo,unidade) VALUES (1,1,'NIVEL','m'),(2,1,'CHUVA','mm/h');
