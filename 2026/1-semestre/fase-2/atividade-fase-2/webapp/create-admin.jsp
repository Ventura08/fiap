<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%--
  ⚠️ SETUP PAGE — Delete this file after creating your admin user!
  This page registers a new user in the Azure SQL database.
  URL: http://localhost:8080/agnello/create-admin.jsp
--%>
<%
    String ctx = request.getContextPath();
    String successMsg = null;
    String errorMsg   = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String email    = request.getParameter("email");
        String password = request.getParameter("password");
        String confirm  = request.getParameter("confirm");

        if (username == null || username.trim().isEmpty()
            || email == null || email.trim().isEmpty()
            || password == null || password.isEmpty()) {
            errorMsg = "Preencha todos os campos.";
        } else if (!password.equals(confirm)) {
            errorMsg = "As senhas não coincidem.";
        } else if (password.length() < 6) {
            errorMsg = "A senha deve ter pelo menos 6 caracteres.";
        } else {
            String hash = sha256(password);
            Connection conn = null;
            try {
                conn = getConnection();
                // Check if username already exists
                PreparedStatement check = conn.prepareStatement("SELECT id FROM users WHERE username = ?");
                check.setString(1, username.trim());
                ResultSet rs = check.executeQuery();
                if (rs.next()) {
                    errorMsg = "Usuário '" + username + "' já existe.";
                } else {
                    PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)"
                    );
                    ps.setString(1, username.trim());
                    ps.setString(2, email.trim());
                    ps.setString(3, hash);
                    ps.executeUpdate();
                    ps.close();
                    successMsg = "Usuário '" + username + "' criado com sucesso! Delete este arquivo (create-admin.jsp) agora.";
                }
                rs.close(); check.close();
            } catch (Exception e) {
                errorMsg = "Erro ao criar usuário: " + e.getMessage();
            } finally {
                if (conn != null) try { conn.close(); } catch (Exception ignored) {}
            }
        }
    }
%>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Criar Usuário — Setup</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Lato:wght@300;400;700&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="<%= ctx %>/css/styles.css"/>
  <style>
    body { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: var(--bg); padding: 40px 20px; }
    .setup-card { background: var(--white); border-radius: 20px; box-shadow: var(--shadow); padding: 48px 40px; width: 100%; max-width: 440px; }
    .setup-card h1 { font-size: 24px; color: var(--bordo); margin-bottom: 8px; }
    .setup-card .warning { background: #fff8e1; border: 1px solid #ffd54f; border-radius: 8px; padding: 12px 16px; font-size: 13px; color: #7a5c00; margin-bottom: 24px; line-height: 1.5; }
    .form-group { margin-bottom: 18px; }
    .form-group label { display: block; font-size: 13px; font-weight: 700; margin-bottom: 6px; }
    .form-group input { width: 100%; padding: 12px 16px; border: 1.5px solid #ddd; border-radius: var(--radius); font-family: "Lato", sans-serif; font-size: 15px; outline: none; transition: border-color 0.2s; }
    .form-group input:focus { border-color: var(--bordo); }
    .btn-submit { width: 100%; padding: 14px; background: var(--bordo); color: white; border: none; border-radius: var(--radius); font-size: 15px; font-weight: 700; cursor: pointer; font-family: "Lato", sans-serif; }
    .btn-submit:hover { background: #3a0612; }
  </style>
</head>
<body>
<div class="setup-card">
  <h1>⚙️ Criar Primeiro Usuário</h1>
  <div class="warning">
    ⚠️ <strong>Página de setup.</strong> Delete o arquivo <code>create-admin.jsp</code> após criar seu usuário. Deixar esta página acessível é um risco de segurança.
  </div>

  <% if (successMsg != null) { %>
    <div class="alert alert-success"><%= successMsg %></div>
    <a href="<%= ctx %>/login.jsp" class="btn-gold" style="display:block;text-align:center;text-decoration:none;">Ir para o Login →</a>
  <% } else { %>
    <% if (errorMsg != null) { %>
      <div class="alert alert-error"><%= errorMsg %></div>
    <% } %>
    <form method="post">
      <div class="form-group">
        <label>Usuário</label>
        <input type="text" name="username" placeholder="ex: giulio" required/>
      </div>
      <div class="form-group">
        <label>E-mail</label>
        <input type="email" name="email" placeholder="ex: giulio@vinheria.com" required/>
      </div>
      <div class="form-group">
        <label>Senha (mín. 6 caracteres)</label>
        <input type="password" name="password" required/>
      </div>
      <div class="form-group">
        <label>Confirmar Senha</label>
        <input type="password" name="confirm" required/>
      </div>
      <button type="submit" class="btn-submit">Criar Usuário</button>
    </form>
  <% } %>
</div>
</body>
</html>
