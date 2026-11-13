-- Locais e sensores instalados
SELECT l.nome, l.bairro, s.tipo, s.unidade FROM locais l JOIN sensores s ON s.local_id=l.id ORDER BY l.nome,s.tipo;
-- Histórico das leituras com contexto
SELECT l.nome, s.tipo, r.valor, s.unidade, r.registrada_em FROM leituras r JOIN sensores s ON s.id=r.sensor_id JOIN locais l ON l.id=s.local_id ORDER BY r.registrada_em DESC;
-- Quantidade e valor médio por sensor
SELECT l.nome, s.tipo, COUNT(r.id) AS total, ROUND(AVG(r.valor),2) AS media FROM sensores s JOIN locais l ON l.id=s.local_id LEFT JOIN leituras r ON r.sensor_id=s.id GROUP BY s.id;
-- Alertas por bairro
SELECT l.bairro, COUNT(a.id) AS total FROM locais l JOIN sensores s ON s.local_id=l.id JOIN leituras r ON r.sensor_id=s.id JOIN alertas a ON a.leitura_id=r.id GROUP BY l.bairro;
-- Alertas detalhados
SELECT a.id, l.nome, s.tipo, r.valor, s.unidade, a.mensagem, a.criada_em FROM alertas a JOIN leituras r ON r.id=a.leitura_id JOIN sensores s ON s.id=r.sensor_id JOIN locais l ON l.id=s.local_id ORDER BY a.id DESC;
