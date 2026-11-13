package br.com.alerta;

import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class AlertaRepository {
    private final JdbcTemplate db;
    public AlertaRepository(JdbcTemplate db) { this.db = db; }
    public List<Map<String,Object>> locais() { return db.queryForList("SELECT * FROM locais ORDER BY nome"); }
    public List<Map<String,Object>> sensores() { return db.queryForList("SELECT s.*, l.nome AS local_nome FROM sensores s JOIN locais l ON l.id=s.local_id ORDER BY s.id"); }
    public List<Map<String,Object>> alertas() { return db.queryForList("SELECT a.id, a.mensagem, a.criada_em, l.nome AS local_nome, s.tipo, r.valor, s.unidade FROM alertas a JOIN leituras r ON r.id=a.leitura_id JOIN sensores s ON s.id=r.sensor_id JOIN locais l ON l.id=s.local_id ORDER BY a.id DESC LIMIT 100"); }
    public List<Map<String,Object>> leituras() { return db.queryForList("SELECT r.*, s.tipo, s.unidade, l.nome AS local_nome FROM leituras r JOIN sensores s ON s.id=r.sensor_id JOIN locais l ON l.id=s.local_id ORDER BY r.id DESC LIMIT 100"); }
    public List<Map<String,Object>> usuario(String email) { return db.queryForList("SELECT * FROM usuarios WHERE email = ?", email); }
    public int criarAdmin(String nome,String email,String hash) { return db.update("INSERT INTO usuarios(nome,email,senha_hash,perfil) VALUES (?,?,?,'ADMIN')",nome,email,hash); }
    public int criarUsuario(String nome,String email,String hash) { return db.update("INSERT INTO usuarios(nome,email,senha_hash,perfil) VALUES (?,?,?,'CIDADAO')",nome,email,hash); }
    public int criarLocal(String nome,String bairro,double nivel,double chuva) { return db.update("INSERT INTO locais(nome,bairro,limite_nivel,limite_chuva) VALUES (?,?,?,?)",nome,bairro,nivel,chuva); }
    public int atualizarLocal(long id,String nome,String bairro,double nivel,double chuva) { return db.update("UPDATE locais SET nome=?,bairro=?,limite_nivel=?,limite_chuva=? WHERE id=?",nome,bairro,nivel,chuva,id); }
    public int excluirLocal(long id) { return db.update("DELETE FROM locais WHERE id=? AND NOT EXISTS (SELECT 1 FROM sensores WHERE local_id=?)",id,id); }
    @Transactional
    public Map<String,Object> registrar(long sensorId,double valor) {
        var lista = db.queryForList("SELECT s.tipo,s.unidade,l.nome,l.limite_nivel,l.limite_chuva FROM sensores s JOIN locais l ON l.id=s.local_id WHERE s.id=?",sensorId);
        if (lista.isEmpty()) return Map.of();
        var sensor=lista.get(0);
        db.update("INSERT INTO leituras(sensor_id,valor) VALUES (?,?)",sensorId,valor);
        long id=db.queryForObject("SELECT last_insert_rowid()",Long.class);
        double limite=((Number)sensor.get("NIVEL".equals(sensor.get("tipo")) ? "limite_nivel" : "limite_chuva")).doubleValue();
        boolean alerta=valor>=limite;
        if (alerta) db.update("INSERT INTO alertas(leitura_id,mensagem) VALUES (?,?)",id,"Limite de " + sensor.get("tipo") + " atingido em " + sensor.get("nome") + ": " + valor + " " + sensor.get("unidade"));
        return Map.of("id",id,"alerta",alerta,"limite",limite);
    }
}
