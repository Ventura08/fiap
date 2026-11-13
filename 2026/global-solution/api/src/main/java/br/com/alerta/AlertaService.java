package br.com.alerta;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import jakarta.annotation.PostConstruct;

@Service
public class AlertaService {
    private final AlertaRepository repo;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
    private final SecureRandom random = new SecureRandom();
    private final Map<String,Session> sessions = new ConcurrentHashMap<>();
    private record Session(String perfil, Instant expira) {}
    @Value("${ALERTA_ADMIN_EMAIL:admin@example.test}") private String adminEmail;
    @Value("${ALERTA_ADMIN_PASSWORD:}") private String adminPassword;
    public AlertaService(AlertaRepository repo) { this.repo=repo; }
    @PostConstruct public void inicializar() {
        if (!adminPassword.isBlank() && repo.usuario(adminEmail.toLowerCase(Locale.ROOT)).isEmpty()) {
            if (adminPassword.length()<10 || adminPassword.length()>72) throw new IllegalStateException("ALERTA_ADMIN_PASSWORD precisa ter entre 10 e 72 caracteres");
            repo.criarAdmin("Administrador",adminEmail.toLowerCase(Locale.ROOT),encoder.encode(adminPassword));
        }
    }
    public void cadastrar(String nome,String email,String senha) {
        nome=texto(nome,2,100); email=email(email);
        if (senha==null || senha.length()<10 || senha.length()>72) erro("Senha deve ter entre 10 e 72 caracteres");
        if (!repo.usuario(email).isEmpty()) throw new ResponseStatusException(HttpStatus.CONFLICT,"E-mail já cadastrado");
        repo.criarUsuario(nome,email,encoder.encode(senha));
    }
    public Map<String,Object> login(String email,String senha) {
        var usuarios=repo.usuario(email(email));
        if (senha==null || usuarios.isEmpty() || !encoder.matches(senha,(String)usuarios.get(0).get("senha_hash"))) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,"Credenciais inválidas");
        byte[] bytes=new byte[32]; random.nextBytes(bytes); String token=Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        String perfil=(String)usuarios.get(0).get("perfil"); sessions.put(token,new Session(perfil,Instant.now().plusSeconds(28800)));
        return Map.of("token",token,"perfil",perfil,"nome",usuarios.get(0).get("nome"));
    }
    public void autorizar(String header, boolean admin) {
        String token=header!=null && header.startsWith("Bearer ") ? header.substring(7) : "";
        Session s=sessions.get(token);
        if (s==null || s.expira().isBefore(Instant.now())) { sessions.remove(token); throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,"Sessão ausente ou expirada"); }
        if (admin && !s.perfil().equals("ADMIN")) throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Acesso restrito ao administrador");
    }
    public void sair(String header) { if (header!=null && header.startsWith("Bearer ")) sessions.remove(header.substring(7)); }
    public String texto(String valor,int min,int max) { if (valor==null || valor.trim().length()<min || valor.trim().length()>max) { erro("Texto inválido"); } return valor.trim(); }
    public double positivo(Double valor) { if (valor==null || !Double.isFinite(valor) || valor<=0 || valor>100000) erro("Valor deve ser positivo e finito"); return valor; }
    public double naoNegativo(Double valor) { if (valor==null || !Double.isFinite(valor) || valor<0 || valor>100000) erro("Valor deve ser não negativo e finito"); return valor; }
    private String email(String valor) { valor=texto(valor,3,120).toLowerCase(Locale.ROOT); if (!Pattern.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$",valor)) erro("E-mail inválido"); return valor; }
    private void erro(String mensagem) { throw new ResponseStatusException(HttpStatus.BAD_REQUEST,mensagem); }
}
