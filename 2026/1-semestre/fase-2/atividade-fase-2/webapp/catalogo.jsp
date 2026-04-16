<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map" %>
<%@ include file="/WEB-INF/jspf/db.jspf" %>
<%
    // Read filter parameters from GET request
    String filterType = request.getParameter("tipo");   // Tinto | Branco | Rosé | Espumante | null
    String filterMaxStr = request.getParameter("max");  // max price
    String searchQuery  = request.getParameter("q");    // text search

    if (filterType == null || filterType.isEmpty()) filterType = null;
    if (searchQuery  == null) searchQuery = "";

    double filterMax = 500.0;
    try { filterMax = Double.parseDouble(filterMaxStr); } catch (Exception ignored) {}

    // Build dynamic query
    StringBuilder sql = new StringBuilder(
        "SELECT id, name, grape, country, type, price, image_url, is_featured FROM wines WHERE price <= ?"
    );
    if (filterType != null) sql.append(" AND type = ?");
    if (!searchQuery.isEmpty()) sql.append(" AND (name LIKE ? OR grape LIKE ? OR country LIKE ?)");
    sql.append(" ORDER BY is_featured DESC, name ASC");

    List<Map<String, Object>> wines = new ArrayList<>();
    String dbError = null;
    Connection conn = null;
    try {
        conn = getConnection();
        PreparedStatement ps = conn.prepareStatement(sql.toString());
        int idx = 1;
        ps.setDouble(idx++, filterMax);
        if (filterType != null) ps.setString(idx++, filterType);
        if (!searchQuery.isEmpty()) {
            String like = "%" + searchQuery + "%";
            ps.setString(idx++, like);
            ps.setString(idx++, like);
            ps.setString(idx++, like);
        }
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> w = new HashMap<>();
            w.put("id",       rs.getInt("id"));
            w.put("name",     rs.getString("name"));
            w.put("grape",    rs.getString("grape"));
            w.put("country",  rs.getString("country"));
            w.put("type",     rs.getString("type"));
            w.put("price",    rs.getDouble("price"));
            w.put("imageUrl", rs.getString("image_url"));
            w.put("featured", rs.getBoolean("is_featured"));
            wines.add(w);
        }
        rs.close(); ps.close();
    } catch (Exception e) {
        dbError = e.getMessage();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }

    String ctx = request.getContextPath();
%>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Catálogo — Vinheria Agnello</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Lato:wght@300;400;700&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="<%= ctx %>/css/styles.css"/>
  <style>
    .page-hero {
      background: linear-gradient(135deg, var(--bordo), #8b1a30);
      color: var(--white); text-align: center; padding: 50px 6%;
    }
    .page-hero h1 { font-size: 38px; margin-bottom: 10px; }
    .page-hero p  { color: rgba(255,255,255,0.75); font-size: 16px; }

    .catalog-layout {
      display: grid; grid-template-columns: 260px 1fr;
      gap: 30px; padding: 40px 6%; max-width: 1400px; margin: 0 auto;
    }
    .sidebar {
      background: var(--white); border-radius: var(--radius);
      box-shadow: var(--shadow); padding: 28px;
      height: fit-content; position: sticky; top: 80px;
    }
    .sidebar h3 { font-size: 18px; color: var(--bordo); margin-bottom: 20px; }
    .filter-group { margin-bottom: 28px; }
    .filter-group label { font-size: 12px; text-transform: uppercase; letter-spacing: 1.5px; color: #888; font-weight: 700; display: block; margin-bottom: 12px; }
    .filter-chips { display: flex; flex-wrap: wrap; gap: 8px; }
    .chip {
      border: 1.5px solid #ddd; border-radius: 25px; padding: 7px 15px;
      font-size: 13px; cursor: pointer; background: var(--bg);
      font-family: "Lato", sans-serif; transition: all 0.2s; text-decoration: none;
      display: inline-block;
    }
    .chip.active { border-color: var(--bordo); background: var(--bordo); color: var(--white); }
    .chip:hover:not(.active) { border-color: var(--gold); color: var(--gold); }
    .price-range { width: 100%; accent-color: var(--bordo); cursor: pointer; }
    .price-display { display: flex; justify-content: space-between; font-size: 13px; color: #888; margin-top: 8px; }
    .btn-bordo-full { width: 100%; padding: 12px; background: var(--bordo); color: var(--white); border: none; border-radius: var(--radius); font-size: 14px; font-weight: 700; cursor: pointer; font-family: "Lato", sans-serif; transition: background 0.3s; }
    .btn-bordo-full:hover { background: #3a0612; }
    .catalog-toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
    .catalog-toolbar p { color: #888; font-size: 14px; }
    .no-results { text-align: center; padding: 60px; color: #888; grid-column: 1/-1; }
    .no-results div { font-size: 48px; margin-bottom: 16px; }
    /* Narrower card grid in catalog */
    .products-grid { grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 22px; }
    @media (max-width: 900px) { .catalog-layout { grid-template-columns: 1fr; } .sidebar { position: static; } }
  </style>
</head>
<body>

<%@ include file="/WEB-INF/jspf/navbar.jspf" %>

<div class="page-hero">
  <h1>🍷 Nosso Catálogo</h1>
  <p>Explore nossa seleção curada pessoalmente pelo Sr. Giulio</p>
</div>

<div class="catalog-layout">
  <!-- SIDEBAR FILTERS (submitted as GET params) -->
  <aside class="sidebar">
    <h3>🔍 Filtros</h3>
    <form method="get" action="catalogo.jsp" id="filterForm">
      <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
        <input type="hidden" name="q" value="<%= searchQuery %>"/>
      <% } %>

      <div class="filter-group">
        <label>Tipo de Vinho</label>
        <div class="filter-chips">
          <a href="catalogo.jsp<%= searchQuery.isEmpty() ? "" : "?q=" + searchQuery %>" class="chip <%= filterType == null ? "active" : "" %>">Todos</a>
          <% String[] types = {"Tinto","Branco","Rosé","Espumante"};
             String[] emojis = {"🍷","🥂","🌸","✨"};
             for (int i = 0; i < types.length; i++) {
               boolean active = types[i].equals(filterType); %>
          <a href="catalogo.jsp?tipo=<%= types[i] %><%= searchQuery.isEmpty() ? "" : "&q=" + searchQuery %>"
             class="chip <%= active ? "active" : "" %>"><%= emojis[i] %> <%= types[i] %></a>
          <% } %>
        </div>
      </div>

      <div class="filter-group">
        <label>Preço máximo (R$ <span id="priceLabel"><%= (int) filterMax %></span>)</label>
        <input type="range" class="price-range" name="max" id="priceRange"
               min="50" max="500" value="<%= (int) filterMax %>"
               oninput="document.getElementById('priceLabel').textContent=this.value; this.form.submit()"/>
        <div class="price-display"><span>R$ 50</span><span>R$ 500</span></div>
      </div>

      <% if (filterType != null) { %>
        <input type="hidden" name="tipo" value="<%= filterType %>"/>
      <% } %>
    </form>

    <a href="catalogo.jsp" class="btn-bordo-full" style="display:block;text-align:center;text-decoration:none;margin-top:8px;">Limpar Filtros</a>
  </aside>

  <!-- PRODUCT GRID -->
  <main>
    <% if (dbError != null) { %>
      <div class="alert alert-error">⚠️ Erro ao conectar ao banco: <%= dbError %></div>
    <% } %>

    <div class="catalog-toolbar">
      <p>Mostrando <strong><%= wines.size() %></strong> vinho<%= wines.size() != 1 ? "s" : "" %></p>
    </div>

    <div class="products-grid">
      <% if (wines.isEmpty()) { %>
        <div class="no-results">
          <div>🍷</div>
          <p>Nenhum vinho encontrado com esses filtros.</p>
        </div>
      <% } %>
      <% for (Map<String, Object> w : wines) {
           String imgUrl  = (String) w.get("imageUrl");
           String wType   = (String) w.get("type");
           boolean feat   = (Boolean) w.get("featured");
      %>
      <div class="product-card" onclick="window.location='<%= ctx %>/produto.jsp?id=<%= w.get("id") %>'">
        <% if (feat) { %><div class="tag-dica">⭐ Dica do Giulio</div><% } %>
        <div class="product-img">
          <% if (imgUrl != null && !imgUrl.isEmpty()) { %>
            <img src="<%= imgUrl %>" alt="<%= w.get("name") %>"/>
          <% } else { %><%= wineEmoji(wType) %><% } %>
        </div>
        <div class="product-info">
          <div class="product-type"><%= wType %> · <%= w.get("country") %></div>
          <h3><%= w.get("name") %></h3>
          <p class="product-uva">Uva: <%= w.get("grape") %></p>
          <div class="product-footer">
            <span class="product-price"><%= formatPrice((Double) w.get("price")) %></span>
            <button class="btn-add" onclick="addToCart(event, '<%= w.get("name") %>', <%= w.get("price") %>, '<%= wineEmoji(wType) %>', 1, '<%= imgUrl != null ? imgUrl : "" %>')">+</button>
          </div>
        </div>
      </div>
      <% } %>
    </div>
  </main>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
</body>
</html>
