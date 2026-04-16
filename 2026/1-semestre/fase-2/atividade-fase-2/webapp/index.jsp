<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    // Load featured wines from Azure SQL
    List<Map<String, Object>> featuredWines = new ArrayList<>();
    String dbError = null;
    Connection conn = null;
    try {
        conn = getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT TOP 4 id, name, grape, country, type, price, image_url, is_featured " +
            "FROM wines ORDER BY is_featured DESC, id ASC"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> w = new HashMap<>();
            w.put("id",         rs.getInt("id"));
            w.put("name",       rs.getString("name"));
            w.put("grape",      rs.getString("grape"));
            w.put("country",    rs.getString("country"));
            w.put("type",       rs.getString("type"));
            w.put("price",      rs.getDouble("price"));
            w.put("imageUrl",   rs.getString("image_url"));
            w.put("featured",   rs.getBoolean("is_featured"));
            featuredWines.add(w);
        }
        rs.close(); ps.close();
    } catch (Exception e) {
        dbError = e.getMessage();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Vinheria Agnello</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Lato:wght@300;400;700&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css"/>
  <style>
    /* ===== HERO ===== */
    .hero {
      min-height: 90vh;
      background: linear-gradient(135deg, var(--bordo) 0%, #8b1a30 50%, #3a0612 100%);
      display: flex; align-items: center; justify-content: center;
      text-align: center; padding: 60px 6%; position: relative; overflow: hidden;
    }
    .hero::before {
      content: ""; position: absolute; inset: 0;
      background: url("https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=1600&q=80") center/cover;
      opacity: 0.15;
    }
    .hero-content { position: relative; z-index: 1; max-width: 700px; }
    .hero-badge {
      display: inline-block; background: rgba(197,160,89,0.2);
      border: 1px solid var(--gold); color: var(--gold);
      padding: 6px 18px; border-radius: 25px; font-size: 13px;
      letter-spacing: 2px; text-transform: uppercase; margin-bottom: 24px;
    }
    .hero h1 { font-size: clamp(32px, 5vw, 54px); color: var(--white); line-height: 1.25; margin-bottom: 20px; }
    .hero h1 span { color: var(--gold); }
    .hero p { font-size: 18px; color: rgba(255,255,255,0.8); margin-bottom: 36px; line-height: 1.7; }
    .hero-btns { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }
    .hero-scroll {
      position: absolute; bottom: 30px; left: 50%; transform: translateX(-50%);
      color: rgba(255,255,255,0.5); font-size: 12px;
      display: flex; flex-direction: column; align-items: center; gap: 6px;
      animation: bounce 2s infinite;
    }
    @keyframes bounce {
      0%, 100% { transform: translateX(-50%) translateY(0); }
      50%       { transform: translateX(-50%) translateY(8px); }
    }

    /* ===== SOMMELIER ===== */
    .sommelier-wrapper { padding: 60px 6%; display: flex; justify-content: center; }
    .sommelier-card {
      background: var(--white); border-radius: 16px; box-shadow: var(--shadow);
      padding: 48px 40px; max-width: 900px; width: 100%;
      display: flex; gap: 40px; align-items: center; border-left: 5px solid var(--gold);
    }
    .sommelier-icon { font-size: 64px; flex-shrink: 0; }
    .sommelier-text h2 { font-size: 28px; color: var(--bordo); margin-bottom: 12px; }
    .sommelier-text p { font-size: 16px; color: #666; margin-bottom: 24px; line-height: 1.7; }
    .quiz-steps { display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; }
    .quiz-step { background: var(--bg); border: 1px solid #e0d8cc; border-radius: 25px; padding: 8px 16px; font-size: 13px; }

    /* ===== COMPROMISE ===== */
    .compromise { background: var(--text); color: var(--white); padding: 60px 6%; }
    .compromise h2 { text-align: center; font-size: 28px; margin-bottom: 40px; color: var(--gold); }
    .compromise-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 30px; text-align: center; }
    .compromise-item { padding: 20px; }
    .compromise-icon { font-size: 40px; margin-bottom: 16px; }
    .compromise-item h3 { font-size: 17px; color: var(--gold); margin-bottom: 8px; }
    .compromise-item p { font-size: 14px; color: rgba(255,255,255,0.65); line-height: 1.7; }

    @media (max-width: 768px) {
      .sommelier-card { flex-direction: column; gap: 20px; padding: 28px 24px; }
    }
  </style>
</head>
<body>

<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<!-- HERO -->
<section class="hero">
  <div class="hero-content">
    <div class="hero-badge">🍷 Curadoria Familiar Desde 1985</div>
    <h1>A tradição do <span>Sr. Giulio</span>,<br/>agora na sua casa.</h1>
    <p>Vinhos selecionados com amor, entregues com segurança.<br/>
       Descubra a experiência de uma vinheria familiar no mundo digital.</p>
    <div class="hero-btns">
      <a href="<%= request.getContextPath() %>/catalogo.jsp" class="btn-gold">Conhecer Vinhos</a>
      <a href="#sommelier" class="btn-outline">Pedir indicação →</a>
    </div>
  </div>
  <div class="hero-scroll">▼ Rolar</div>
</section>

<!-- SOMMELIER VIRTUAL -->
<section class="sommelier-wrapper" id="sommelier">
  <div class="sommelier-card">
    <div class="sommelier-icon">🧑‍🍳</div>
    <div class="sommelier-text">
      <h2>Não sabe qual vinho escolher? O Sr. Giulio te ajuda!</h2>
      <p>Responda 3 perguntas rápidas sobre a sua ocasião e receba uma recomendação
         personalizada — como se você estivesse aqui na vinheria.</p>
      <div class="quiz-steps">
        <div class="quiz-step">🍽️ Qual a ocasião?</div>
        <div class="quiz-step">👅 Seu paladar?</div>
        <div class="quiz-step">💰 Faixa de preço?</div>
      </div>
      <button class="btn-gold" onclick="abrirQuiz()">Fazer o Quiz de Paladar</button>
    </div>
  </div>
</section>

<!-- SELEÇÃO DA FAMÍLIA -->
<section class="section">
  <div class="section-header">
    <h2>Seleção da Família Agnello</h2>
    <a href="<%= request.getContextPath() %>/catalogo.jsp">Ver todos →</a>
  </div>

  <% if (dbError != null) { %>
    <div class="alert alert-error">⚠️ Erro ao carregar vinhos: <%= dbError %></div>
  <% } %>

  <div class="products-grid">
    <% for (Map<String, Object> w : featuredWines) {
         String imgUrl   = (String) w.get("imageUrl");
         String type     = (String) w.get("type");
         String emoji    = wineEmoji(type);
         boolean featured = (Boolean) w.get("featured");
    %>
    <div class="product-card" onclick="window.location='<%= request.getContextPath() %>/produto.jsp?id=<%= w.get("id") %>'">
      <% if (featured) { %><div class="tag-dica">⭐ Dica do Giulio</div><% } %>
      <div class="product-img">
        <% if (imgUrl != null && !imgUrl.isEmpty()) { %>
          <img src="<%= imgUrl %>" alt="<%= w.get("name") %>"/>
        <% } else { %>
          <%= emoji %>
        <% } %>
      </div>
      <div class="product-info">
        <div class="product-type"><%= type %></div>
        <h3><%= w.get("name") %></h3>
        <p class="product-uva"><%= w.get("grape") %> · <%= w.get("country") %></p>
        <div class="product-footer">
          <span class="product-price"><%= formatPrice((Double) w.get("price")) %></span>
          <button class="btn-add" onclick="addToCart(event, '<%= w.get("name") %>', <%= w.get("price") %>, '<%= emoji %>', 1, '<%= imgUrl != null ? imgUrl : "" %>')">+</button>
        </div>
      </div>
    </div>
    <% } %>
  </div>
</section>

<!-- COMPROMISSO -->
<section class="compromise">
  <h2>O Compromisso Agnello</h2>
  <div class="compromise-grid">
    <div class="compromise-item">
      <div class="compromise-icon">❄️</div>
      <h3>Climatização Garantida</h3>
      <p>Monitoramento constante de temperatura e luminosidade em todo o estoque.</p>
    </div>
    <div class="compromise-item">
      <div class="compromise-icon">🚚</div>
      <h3>Transporte Seguro</h3>
      <p>Embalagens anti-impacto e rastreamento em tempo real até sua porta.</p>
    </div>
    <div class="compromise-item">
      <div class="compromise-icon">🍷</div>
      <h3>Curadoria Especializada</h3>
      <p>Cada garrafa foi aprovada pessoalmente pelo Sr. Giulio e pela Bianca.</p>
    </div>
    <div class="compromise-item">
      <div class="compromise-icon">⭐</div>
      <h3>Satisfação Garantida</h3>
      <p>Não gostou? Troca ou devolução sem burocracia em até 7 dias.</p>
    </div>
  </div>
</section>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

<!-- MODAL QUIZ -->
<div id="quizModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.6);z-index:200;align-items:center;justify-content:center;">
  <div style="background:var(--white);border-radius:16px;padding:40px;max-width:500px;width:90%;position:relative;">
    <button onclick="fecharQuiz()" style="position:absolute;top:16px;right:16px;background:none;border:none;font-size:22px;cursor:pointer;color:#999;">✕</button>
    <h2 style="font-family:'Playfair Display',serif;color:var(--bordo);margin-bottom:20px;">🍷 Quiz de Paladar</h2>
    <div id="quizStep1">
      <p style="margin-bottom:16px;font-weight:700">1. Qual a ocasião?</p>
      <div style="display:flex;flex-direction:column;gap:10px">
        <button class="quiz-opt" onclick="nextStep(1)">🍽️ Jantar romântico</button>
        <button class="quiz-opt" onclick="nextStep(1)">🎉 Festa com amigos</button>
        <button class="quiz-opt" onclick="nextStep(1)">🎁 Presente especial</button>
        <button class="quiz-opt" onclick="nextStep(1)">🛋️ Momento relaxante</button>
      </div>
    </div>
    <div id="quizStep2" style="display:none">
      <p style="margin-bottom:16px;font-weight:700">2. Você prefere vinhos...?</p>
      <div style="display:flex;flex-direction:column;gap:10px">
        <button class="quiz-opt" onclick="nextStep(2)">🍒 Encorpados e intensos</button>
        <button class="quiz-opt" onclick="nextStep(2)">🌸 Suaves e frutados</button>
        <button class="quiz-opt" onclick="nextStep(2)">🍋 Frescos e secos</button>
        <button class="quiz-opt" onclick="nextStep(2)">✨ Espumantes e borbulhantes</button>
      </div>
    </div>
    <div id="quizStep3" style="display:none;text-align:center">
      <div style="font-size:48px;margin-bottom:16px">🎯</div>
      <h3 style="font-family:'Playfair Display',serif;color:var(--bordo);margin-bottom:12px;">A recomendação do Sr. Giulio:</h3>
      <div style="background:var(--bg);border-radius:10px;padding:20px;margin-bottom:20px">
        <p style="font-size:18px;font-weight:700;color:var(--text)">Barolo Riserva 2019</p>
        <p style="color:#888;font-size:14px">Nebbiolo · Itália · R$ 290,00</p>
        <p style="margin-top:12px;font-style:italic;color:#555">"Para a sua ocasião, este Barolo é perfeito. Encorpado, elegante e memorável."</p>
      </div>
      <a href="<%= request.getContextPath() %>/produto.jsp?id=1" class="btn-gold" style="display:block">Ver este vinho →</a>
    </div>
  </div>
</div>

<script>
  function abrirQuiz() {
    const m = document.getElementById('quizModal');
    m.style.display = 'flex';
    document.getElementById('quizStep1').style.display = 'block';
    document.getElementById('quizStep2').style.display = 'none';
    document.getElementById('quizStep3').style.display = 'none';
  }
  function fecharQuiz() { document.getElementById('quizModal').style.display = 'none'; }
  function nextStep(step) {
    if (step === 1) {
      document.getElementById('quizStep1').style.display = 'none';
      document.getElementById('quizStep2').style.display = 'block';
    } else {
      document.getElementById('quizStep2').style.display = 'none';
      document.getElementById('quizStep3').style.display = 'block';
    }
  }
  document.querySelectorAll('.quiz-opt').forEach(btn => {
    btn.style.cssText = "background:var(--bg);border:1px solid #ddd;border-radius:8px;padding:12px 16px;cursor:pointer;font-family:'Lato',sans-serif;font-size:14px;text-align:left;transition:all 0.2s;";
    btn.addEventListener('mouseenter', () => { btn.style.borderColor = 'var(--gold)'; btn.style.background = '#FBF7EF'; });
    btn.addEventListener('mouseleave', () => { btn.style.borderColor = '#ddd'; btn.style.background = 'var(--bg)'; });
  });
</script>
</body>
</html>
