package br.com.alerta;

import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api")
public class AlertaController {
    private final AlertaRepository repo; private final AlertaService service;
    public AlertaController(AlertaRepository repo,AlertaService service) { this.repo=repo; this.service=service; }
    record Credenciais(String email,String senha) {} record Cadastro(String nome,String email,String senha) {}
    record Local(String nome,String bairro,Double limiteNivel,Double limiteChuva) {} record Leitura(Long sensorId,Double valor) {}
    @PostMapping("/cadastro") @ResponseStatus(HttpStatus.CREATED) public Map<String,String> cadastro(@RequestBody Cadastro c) { service.cadastrar(c.nome(),c.email(),c.senha()); return Map.of("mensagem","Cadastro criado"); }
    @PostMapping("/login") public Map<String,Object> login(@RequestBody Credenciais c) { return service.login(c.email(),c.senha()); }
    @PostMapping("/logout") @ResponseStatus(HttpStatus.NO_CONTENT) public void logout(@RequestHeader(value="Authorization",required=false) String auth) { service.autorizar(auth,false); service.sair(auth); }
    @GetMapping("/locais") public Object locais(@RequestHeader(value="Authorization",required=false) String auth) { service.autorizar(auth,false); return repo.locais(); }
    @GetMapping("/sensores") public Object sensores(@RequestHeader(value="Authorization",required=false) String auth) { service.autorizar(auth,false); return repo.sensores(); }
    @GetMapping("/leituras") public Object leituras(@RequestHeader(value="Authorization",required=false) String auth) { service.autorizar(auth,false); return repo.leituras(); }
    @GetMapping("/alertas") public Object alertas(@RequestHeader(value="Authorization",required=false) String auth) { service.autorizar(auth,false); return repo.alertas(); }
    @PostMapping("/locais") @ResponseStatus(HttpStatus.CREATED) public Map<String,String> criar(@RequestHeader(value="Authorization",required=false) String auth,@RequestBody Local l) { service.autorizar(auth,true); repo.criarLocal(service.texto(l.nome(),2,100),service.texto(l.bairro(),2,100),service.positivo(l.limiteNivel()),service.positivo(l.limiteChuva())); return Map.of("mensagem","Local criado"); }
    @PutMapping("/locais/{id}") public Map<String,String> atualizar(@RequestHeader(value="Authorization",required=false) String auth,@PathVariable long id,@RequestBody Local l) { service.autorizar(auth,true); if(repo.atualizarLocal(id,service.texto(l.nome(),2,100),service.texto(l.bairro(),2,100),service.positivo(l.limiteNivel()),service.positivo(l.limiteChuva()))==0) throw new ResponseStatusException(HttpStatus.NOT_FOUND,"Local não encontrado"); return Map.of("mensagem","Local atualizado"); }
    @DeleteMapping("/locais/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void excluir(@RequestHeader(value="Authorization",required=false) String auth,@PathVariable long id) { service.autorizar(auth,true); if(repo.excluirLocal(id)==0) throw new ResponseStatusException(HttpStatus.CONFLICT,"Local inexistente ou possui sensores"); }
    @PostMapping("/leituras") @ResponseStatus(HttpStatus.CREATED) public Object leitura(@RequestHeader(value="Authorization",required=false) String auth,@RequestBody Leitura l) { service.autorizar(auth,true); if(l.sensorId()==null || l.sensorId()<=0) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Sensor inválido"); var resultado=repo.registrar(l.sensorId(),service.naoNegativo(l.valor())); if(resultado.isEmpty()) throw new ResponseStatusException(HttpStatus.NOT_FOUND,"Sensor não encontrado"); return resultado; }
}
