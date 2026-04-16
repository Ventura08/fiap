<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    String ctx = request.getContextPath();

    // If already logged in, redirect to home
    if (session.getAttribute("loggedUser") != null) {
        response.sendRedirect(ctx + "/index.jsp");
        return;
    }

    String errorMsg  = null;
    String username  = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        username         = request.getParameter("username");
        String password  = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            errorMsg = "Preencha todos os campos.";
        } else {
            String passHash = sha256(password);
            Connection conn = null;
            try {
                conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, username FROM users WHERE username = ? AND password_hash = ?"
                );
                ps.setString(1, username.trim());
                ps.setString(2, passHash);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    session.setAttribute("loggedUser", rs.getString("username"));
                    session.setAttribute("userId",     rs.getInt("id"));
                    rs.close(); ps.close();
                    // Redirect to originally requested page or home
                    String redirect = request.getParameter("redirect");
                    if (redirect != null && !redirect.isEmpty()) {
                        response.sendRedirect(redirect);
                    } else {
                        response.sendRedirect(ctx + "/index.jsp");
                    }
                    return;
                } else {
                    errorMsg = "Usuário ou senha incorretos.";
                }
                rs.close(); ps.close();
            } catch (Exception e) {
                errorMsg = "Erro ao conectar ao banco: " + e.getMessage();
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
  <title>Login — Vinheria Agnello</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Lato:wght@300;400;700&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="<%= ctx %>/css/styles.css"/>
  <style>
    body { min-height: 100vh; display: flex; flex-direction: column; }
    .login-wrapper {
      flex: 1; display: flex; align-items: center; justify-content: center;
      padding: 40px 20px;
      background: linear-gradient(135deg, var(--bordo) 0%, #8b1a30 50%, #3a0612 100%);
      position: relative; overflow: hidden;
    }
    .login-wrapper::before {
      content: ""; position: absolute; inset: 0;
      background: url("https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=1600&q=80") center/cover;
      opacity: 0.1;
    }
    .login-card {
      background: var(--white); border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      padding: 48px 40px; width: 100%; max-width: 420px; position: relative; z-index: 1;
    }
    .login-logo { text-align: center; margin-bottom: 32px; }
    .login-logo .logo-text { font-size: 28px; }
    .login-logo p { font-size: 14px; color: #888; margin-top: 8px; }
    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; font-size: 13px; font-weight: 700; color: var(--text); margin-bottom: 8px; }
    .form-group input {
      width: 100%; padding: 12px 16px; border: 1.5px solid #ddd; border-radius: var(--radius);
      font-family: "Lato", sans-serif; font-size: 15px; color: var(--text); background: var(--bg);
      transition: border-color 0.2s; outline: none;
    }
    .form-group input:focus { border-color: var(--bordo); }
    .btn-login {
      width: 100%; padding: 14px; background: var(--bordo); color: var(--white);
      border: none; border-radius: var(--radius); font-size: 16px; font-weight: 700;
      cursor: pointer; font-family: "Lato", sans-serif; transition: background 0.3s;
      margin-top: 8px;
    }
    .btn-login:hover { background: #3a0612; }
    .login-divider { text-align: center; margin: 24px 0 20px; color: #aaa; font-size: 13px; position: relative; }
    .login-divider::before, .login-divider::after { content: ""; position: absolute; top: 50%; width: 42%; height: 1px; background: #eee; }
    .login-divider::before { left: 0; }
    .login-divider::after  { right: 0; }
    .register-link { text-align: center; font-size: 14px; color: #888; }
    .register-link a { color: var(--bordo); font-weight: 700; text-decoration: none; }
    .register-link a:hover { text-decoration: underline; }
  </style>
</head>
<body>

<nav>
  <a href="<%= ctx %>/index.jsp" class="logo-text">Vinheria <span>Agnello</span></a>
  <div></div>
  <a href="<%= ctx %>/catalogo.jsp" class="nav-icon" style="font-size:14px;text-decoration:none;color:var(--text);">← Voltar ao Catálogo</a>
</nav>

<div class="login-wrapper">
  <div class="login-card">
    <div class="login-logo">
      <div class="logo-text">Vinheria <span>Agnello</span></div>
      <p>Entre na sua conta para continuar</p>
    </div>

    <% if (errorMsg != null) { %>
      <div class="alert alert-error"><%= errorMsg %></div>
    <% } %>

    <form method="post" action="login.jsp<%= request.getParameter("redirect") != null ? "?redirect=" + request.getParameter("redirect") : "" %>">
      <div class="form-group">
        <label for="username">Usuário</label>
        <input type="text" id="username" name="username" placeholder="Seu nome de usuário"
               value="<%= username %>" autocomplete="username" required/>
      </div>
      <div class="form-group">
        <label for="password">Senha</label>
        <input type="password" id="password" name="password" placeholder="Sua senha"
               autocomplete="current-password" required/>
      </div>
      <button type="submit" class="btn-login">Entrar</button>
    </form>

    <div class="login-divider">ou</div>
    <div class="register-link">
      Não tem conta? <a href="<%= ctx %>/create-admin.jsp">Criar conta</a>
    </div>
  </div>
</div>

<footer>
  <p>© 2026 <strong>Vinheria Agnello</strong> — FIAP</p>
</footer>
</body>
</html>
