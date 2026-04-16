<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    String ctx = request.getContextPath();
    int productId = 0;
    try { productId = Integer.parseInt(request.getParameter("id")); } catch (Exception ignored) {}

    Map<String, Object> wine = null;
    List<Map<String, Object>> related = new ArrayList<>();
    String dbError = null;
    Connection conn = null;
    try {
        conn = getConnection();

        // Load main product
        PreparedStatement ps = conn.prepareStatement(
            "SELECT * FROM wines WHERE id = ?"
        );
        ps.setInt(1, productId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            wine = new HashMap<>();
            wine.put("id",          rs.getInt("id"));
            wine.put("name",        rs.getString("name"));
            wine.put("grape",       rs.getString("grape"));
            wine.put("country",     rs.getString("country"));
            wine.put("region",      rs.getString("region"));
            wine.put("type",        rs.getString("type"));
            wine.put("vintage",     rs.getInt("vintage"));
            wine.put("price",       rs.getDouble("price"));
            wine.put("alcohol",     rs.getDouble("alcohol_content"));
            wine.put("description", rs.getString("description"));
            wine.put("imageUrl",    rs.getString("image_url"));
            wine.put("featured",    rs.getBoolean("is_featured"));
        }
        rs.close(); ps.close();

        // Load related wines (same type, different id)
        if (wine != null) {
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT TOP 4 id, name, grape, country, type, price, image_url FROM wines " +
                "WHERE id <> ? AND type = ? ORDER BY NEWID()"
            );
            ps2.setInt(1, productId);
            ps2.setString(2, (String) wine.get("type"));
            ResultSet rs2 = ps2.executeQuery();
            while (rs2.next()) {
                Map<String, Object> r = new HashMap<>();
                r.put("id",       rs2.getInt("id"));
                r.put("name",     rs2.getString("name"));
                r.put("grape",    rs2.getString("grape"));
                r.put("country",  rs2.getString("country"));
                r.put("type",     rs2.getString("type"));
                r.put("price",    rs2.getDouble("price"));
                r.put("imageUrl", rs2.getString("image_url"));
                related.add(r);
            }
            rs2.close(); ps2.close();
        }
    } catch (Exception e) {
        dbError = e.getMessage();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }

    // Redirect to catalog if product not found
    if (wine == null && dbError == null) {
        response.sendRedirect(ctx + "/catalogo.jsp");
        return;
    }
%>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title><%= wine != null ? wine.get("name") : "Produto" %> — Vinheria Agnello</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Lato:wght@300;400;700&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="<%= ctx %>/css/styles.css"/>
  <style>
    .breadcrumb { padding: 16px 6%; font-size: 13px; color: #888; display: flex; gap: 8px; align-items: center; }
    .breadcrumb a { color: var(--gold); text-decoration: none; }
    .breadcrumb a:hover { text-decoration: underline; }

    .product-detail { display: grid; grid-template-columns: 1fr 1fr; gap: 48px; padding: 20px 6% 60px; max-width: 1200px; margin: 0 auto; }
    .product-main-img {
      background: var(--white); border-radius: 16px; box-shadow: var(--shadow);
      padding: 40px; display: flex; align-items: center; justify-content: center;
      font-size: 160px; aspect-ratio: 1; width: 100%; margin-bottom: 16px; overflow: hidden;
    }
    .product-main-img img { width: 100%; height: 100%; object-fit: cover; border-radius: 12px; }
    .product-badge { display: inline-block; background: rgba(197,160,89,0.15); color: var(--gold); border: 1px solid var(--gold); font-size: 12px; padding: 5px 14px; border-radius: 20px; font-weight: 700; letter-spacing: 1px; margin-bottom: 14px; text-transform: uppercase; }
    .product-info-col h1 { font-size: 38px; color: var(--bordo); margin-bottom: 8px; line-height: 1.2; }
    .product-meta { display: flex; gap: 20px; margin-bottom: 16px; flex-wrap: wrap; }
    .meta-item { font-size: 14px; color: #888; }
    .meta-item strong { color: var(--text); }
    .divider { height: 1px; background: #eee; margin: 20px 0; }
    .price-block { margin-bottom: 24px; }
    .price-main { font-size: 42px; font-weight: 700; color: var(--text); }
    .price-parcel { font-size: 14px; color: #888; margin-top: 4px; }
    .price-parcel span { color: var(--gold); font-weight: 700; }
    .qty-block { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; }
    .qty-label { font-size: 14px; font-weight: 700; }
    .qty-control { display: flex; align-items: center; border: 1.5px solid #ddd; border-radius: 8px; overflow: hidden; }
    .qty-btn { background: var(--bg); border: none; padding: 10px 16px; font-size: 18px; cursor: pointer; transition: background 0.2s; }
    .qty-btn:hover { background: #eee; }
    .qty-val { padding: 10px 20px; font-size: 16px; font-weight: 700; border-left: 1.5px solid #ddd; border-right: 1.5px solid #ddd; min-width: 50px; text-align: center; }
    .cta-buttons { display: flex; gap: 12px; margin-bottom: 24px; }
    .cta-buttons .btn-gold { flex: 2; }
    .cta-buttons .btn-bordo { flex: 1; }
    .btn-wishlist { width: 52px; height: 52px; background: var(--white); border: 1.5px solid #ddd; border-radius: var(--radius); font-size: 22px; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; }
    .btn-wishlist:hover { border-color: #e57; }
    .product-tags { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 8px; }
    .tag { background: var(--bg); border: 1px solid #ddd; border-radius: 6px; padding: 5px 12px; font-size: 13px; }

    /* Harmonização */
    .harmonization { background: var(--white); border-radius: 16px; box-shadow: var(--shadow); padding: 30px; margin: 40px 6%; max-width: 1200px; margin-left: auto; margin-right: auto; }
    .harmonization h2 { font-size: 26px; color: var(--bordo); margin-bottom: 8px; }
    .harmonization > p { color: #888; margin-bottom: 24px; font-size: 14px; }
    .harm-items { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 30px; }
    .harm-item { display: flex; flex-direction: column; align-items: center; gap: 8px; background: var(--bg); border-radius: 12px; padding: 18px 22px; font-size: 13px; font-weight: 700; border: 1.5px solid transparent; cursor: pointer; transition: all 0.2s; min-width: 90px; }
    .harm-item:hover { border-color: var(--gold); background: #fbf7ef; }
    .harm-icon { font-size: 32px; }
    .giulio-quote { display: flex; gap: 20px; align-items: flex-start; background: linear-gradient(135deg, #fbf7ef, var(--bg)); border-radius: 12px; padding: 24px; border-left: 4px solid var(--gold); }
    .giulio-avatar { width: 60px; height: 60px; border-radius: 50%; background: var(--bordo); flex-shrink: 0; display: flex; align-items: center; justify-content: center; font-size: 28px; color: white; }
    .giulio-text h4 { font-family: "Playfair Display", serif; color: var(--bordo); margin-bottom: 6px; }
    .giulio-text p { font-style: italic; color: #555; line-height: 1.7; font-size: 15px; }

    /* Ficha técnica accordion */
    .ficha-section { padding: 0 6% 60px; max-width: 1200px; margin: 0 auto; }
    .ficha-section h2 { font-size: 26px; color: var(--bordo); margin-bottom: 20px; }
    .accordion-item { background: var(--white); border-radius: var(--radius); margin-bottom: 10px; box-shadow: var(--shadow); overflow: hidden; }
    .accordion-header { display: flex; justify-content: space-between; align-items: center; padding: 18px 24px; cursor: pointer; transition: background 0.2s; font-weight: 700; font-size: 15px; }
    .accordion-header:hover { background: var(--bg); }
    .accordion-icon { font-size: 20px; transition: transform 0.3s; color: var(--gold); }
    .accordion-icon.open { transform: rotate(45deg); }
    .accordion-body { max-height: 0; overflow: hidden; transition: max-height 0.4s ease, padding 0.3s; padding: 0 24px; }
    .accordion-body.open { max-height: 300px; padding: 0 24px 20px; }
    .ficha-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; margin-top: 12px; }
    .ficha-item label { font-size: 11px; text-transform: uppercase; letter-spacing: 1px; color: #aaa; display: block; margin-bottom: 4px; }
    .ficha-item span { font-size: 15px; font-weight: 700; color: var(--text); }

    /* Related */
    .related { padding: 40px 6% 60px; }
    .related h2 { font-size: 26px; color: var(--bordo); margin-bottom: 24px; }
    .related-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
    .related-card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); padding: 20px; text-align: center; cursor: pointer; transition: transform 0.3s; }
    .related-card:hover { transform: translateY(-4px); }
    .related-card .rc-emoji { font-size: 48px; margin-bottom: 12px; }
    .related-card h4 { font-size: 15px; color: var(--bordo); margin-bottom: 4px; }
    .related-card p { font-size: 13px; color: #888; }
    .related-price { font-size: 16px; font-weight: 700; margin-top: 8px; }

    @media (max-width: 768px) {
      .product-detail { grid-template-columns: 1fr; gap: 24px; }
      .product-main-img { font-size: 120px; }
      .cta-buttons { flex-wrap: wrap; }
      .cta-buttons .btn-gold, .cta-buttons .btn-bordo { flex: auto; width: 100%; }
    }
  </style>
</head>
<body>

<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<% if (dbError != null) { %>
  <div class="alert alert-error" style="margin: 20px 6%;">⚠️ Erro ao carregar produto: <%= dbError %></div>
<% } %>

<% if (wine != null) {
     String imgUrl  = (String) wine.get("imageUrl");
     String wType   = (String) wine.get("type");
     String emoji   = wineEmoji(wType);
     double price   = (Double) wine.get("price");
     // Installments: 10x
     double installment = price / 10.0;
%>

<!-- BREADCRUMB -->
<div class="breadcrumb">
  <a href="<%= ctx %>/index.jsp">Home</a> ›
  <a href="<%= ctx %>/catalogo.jsp">Catálogo</a> ›
  <%= wine.get("name") %>
</div>

<!-- PRODUCT DETAIL -->
<div class="product-detail">
  <div class="product-visual">
    <div class="product-main-img" id="mainImg">
      <% if (imgUrl != null && !imgUrl.isEmpty()) { %>
        <img src="<%= imgUrl %>" alt="<%= wine.get("name") %>"/>
      <% } else { %><%= emoji %><% } %>
    </div>
  </div>

  <div class="product-info-col">
    <div class="product-badge">
      <%= wine.get("country") %> · <%= wType %>
    </div>
    <h1><%= wine.get("name") %></h1>

    <div class="product-meta">
      <div class="meta-item">Uva: <strong><%= wine.get("grape") %></strong></div>
      <div class="meta-item">Safra: <strong><%= wine.get("vintage") %></strong></div>
      <div class="meta-item">Região: <strong><%= wine.get("region") %></strong></div>
      <div class="meta-item">Teor: <strong><%= wine.get("alcohol") %>%</strong></div>
    </div>

    <div class="divider"></div>

    <div class="price-block">
      <div class="price-main"><%= formatPrice(price) %></div>
      <div class="price-parcel">
        ou <span>10x de <%= formatPrice(installment) %></span> sem juros
      </div>
    </div>

    <div class="qty-block">
      <span class="qty-label">Quantidade:</span>
      <div class="qty-control">
        <button class="qty-btn" onclick="changeQty(-1)">−</button>
        <div class="qty-val" id="qty">1</div>
        <button class="qty-btn" onclick="changeQty(1)">+</button>
      </div>
    </div>

    <div class="cta-buttons">
      <button class="btn-gold" onclick="addToCart(null, '<%= wine.get("name") %>', <%= price %>, '<%= emoji %>', qty, '<%= imgUrl != null ? imgUrl : "" %>')">&#x1F6D2; Adicionar ao Carrinho</button>
      <button class="btn-bordo">⚡ Comprar Agora</button>
      <button class="btn-wishlist" id="wishBtn" onclick="toggleWish()">🤍</button>
    </div>

    <div class="divider"></div>

    <div class="product-tags">
      <% if ((Boolean) wine.get("featured")) { %><span class="tag">⭐ Dica do Giulio</span><% } %>
      <span class="tag">❄️ Temp. Controlada</span>
      <span class="tag">🚚 Entrega Expressa</span>
    </div>
  </div>
</div>

<!-- HARMONIZAÇÃO -->
<div class="harmonization">
  <h2>🍽️ Harmonização Perfeita</h2>
  <p>O que comer com este vinho? Veja as recomendações do Sr. Giulio:</p>
  <div class="harm-items">
    <% if ("Tinto".equals(wType)) { %>
      <div class="harm-item"><span class="harm-icon">🥩</span>Carne Vermelha</div>
      <div class="harm-item"><span class="harm-icon">🧀</span>Queijo Curado</div>
      <div class="harm-item"><span class="harm-icon">🍝</span>Massas Italianas</div>
      <div class="harm-item"><span class="harm-icon">🍄</span>Cogumelos</div>
    <% } else if ("Branco".equals(wType)) { %>
      <div class="harm-item"><span class="harm-icon">🐟</span>Frutos do Mar</div>
      <div class="harm-item"><span class="harm-icon">🥗</span>Saladas</div>
      <div class="harm-item"><span class="harm-icon">🧀</span>Queijo Fresco</div>
      <div class="harm-item"><span class="harm-icon">🍗</span>Aves</div>
    <% } else if ("Espumante".equals(wType)) { %>
      <div class="harm-item"><span class="harm-icon">🦐</span>Camarão</div>
      <div class="harm-item"><span class="harm-icon">🍣</span>Sushi</div>
      <div class="harm-item"><span class="harm-icon">🎂</span>Sobremesas</div>
      <div class="harm-item"><span class="harm-icon">🧀</span>Brie</div>
    <% } else { %>
      <div class="harm-item"><span class="harm-icon">🥗</span>Saladas</div>
      <div class="harm-item"><span class="harm-icon">🍗</span>Aves</div>
      <div class="harm-item"><span class="harm-icon">🧀</span>Queijos</div>
      <div class="harm-item"><span class="harm-icon">🍤</span>Frutos do Mar</div>
    <% } %>
  </div>
  <div class="giulio-quote">
    <div class="giulio-avatar">👨‍🍳</div>
    <div class="giulio-text">
      <h4>Sr. Giulio Agnello recomenda:</h4>
      <p>"<%= wine.get("description") %>"</p>
    </div>
  </div>
</div>

<!-- FICHA TÉCNICA -->
<div class="ficha-section">
  <h2>📋 Ficha Técnica</h2>
  <div class="accordion-item">
    <div class="accordion-header" onclick="toggleAccordion(this)">
      🍷 Informações do Vinho <span class="accordion-icon">+</span>
    </div>
    <div class="accordion-body">
      <div class="ficha-grid">
        <div class="ficha-item"><label>Nome</label><span><%= wine.get("name") %></span></div>
        <div class="ficha-item"><label>Safra</label><span><%= wine.get("vintage") %></span></div>
        <div class="ficha-item"><label>Tipo</label><span><%= wType %></span></div>
        <div class="ficha-item"><label>Uva</label><span><%= wine.get("grape") %></span></div>
        <div class="ficha-item"><label>Teor Alcoólico</label><span><%= wine.get("alcohol") %>% vol.</span></div>
        <div class="ficha-item"><label>Volume</label><span>750 ml</span></div>
      </div>
    </div>
  </div>
  <div class="accordion-item">
    <div class="accordion-header" onclick="toggleAccordion(this)">
      🌍 Origem e Produção <span class="accordion-icon">+</span>
    </div>
    <div class="accordion-body">
      <div class="ficha-grid">
        <div class="ficha-item"><label>País</label><span><%= wine.get("country") %></span></div>
        <div class="ficha-item"><label>Região</label><span><%= wine.get("region") %></span></div>
        <div class="ficha-item"><label>Temperatura</label><span>
          <% if ("Tinto".equals(wType)) { %>16°C – 18°C<% } else { %>8°C – 12°C<% } %>
        </span></div>
      </div>
    </div>
  </div>
</div>

<!-- RELACIONADOS -->
<% if (!related.isEmpty()) { %>
<div class="related">
  <h2>Você também pode gostar</h2>
  <div class="related-grid">
    <% for (Map<String, Object> r : related) { %>
    <div class="related-card" onclick="window.location='<%= ctx %>/produto.jsp?id=<%= r.get("id") %>'">
      <% String rImg = (String) r.get("imageUrl"); %>
      <div class="rc-emoji">
        <% if (rImg != null && !rImg.isEmpty()) { %>
          <img src="<%= rImg %>" alt="<%= r.get("name") %>" style="width:80px;height:80px;object-fit:cover;border-radius:8px;"/>
        <% } else { %><%= wineEmoji((String) r.get("type")) %><% } %>
      </div>
      <h4><%= r.get("name") %></h4>
      <p><%= r.get("grape") %> · <%= r.get("country") %></p>
      <div class="related-price"><%= formatPrice((Double) r.get("price")) %></div>
    </div>
    <% } %>
  </div>
</div>
<% } %>

<% } /* end if wine != null */ %>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

<script>
  let qty = 1;
  let inWishlist = false;
  function changeQty(d) { qty = Math.max(1, qty + d); document.getElementById('qty').textContent = qty; }
  function toggleWish() { inWishlist = !inWishlist; document.getElementById('wishBtn').textContent = inWishlist ? '❤️' : '🤍'; }
  function toggleAccordion(header) {
    const body = header.nextElementSibling;
    const icon = header.querySelector('.accordion-icon');
    const isOpen = body.classList.contains('open');
    document.querySelectorAll('.accordion-body').forEach(b => b.classList.remove('open'));
    document.querySelectorAll('.accordion-icon').forEach(i => i.classList.remove('open'));
    if (!isOpen) { body.classList.add('open'); icon.classList.add('open'); }
  }
</script>
</body>
</html>
