---

`Ref: /Users/estevaoboaventura/dev/fiap/fiap/2026/1-semestre/fase-2/atividade-fase-2`

# 🍷 PLANEJAMENTO FASE 3: VINHERIA AGNELLO

## 🎯 1. OBJETIVO

- Aplicar **Ciência de Dados** e **Aprendizado Supervisionado**.
- Construir modelo preditivo simples (sucesso de venda).
- Gerar dashboard com **Power BI** ou **Tableau**.
- Refletir sobre insights e decisões estratégicas.

---

## 📦 2. ENTREGÁVEIS (ZIP único)

Nome: `NomeSobrenome_RMxxxxxx_fase3_PBL.zip`

| # | Arquivo | Conteúdo |
|---|---------|----------|
| 1 | `.xlsx` ou `.csv` | Base simulada, ≥8 colunas, inclui rótulo de sucesso |
| 2 | `.pdf` | Justificativa modelagem + prints dashboard + reflexão final |
| 3 | `.pbix` ou `.twbx` | Arquivo dashboard Power BI/Tableau |

PDF deve cobrir:
- Algoritmo escolhido + justificativa
- Variáveis de entrada
- Split treino/teste
- Métricas (acurácia, precisão etc.)
- Screenshots das 3+ visualizações
- Respostas reflexão final

---

## 🛠️ 3. TECNOLOGIA (FOCO ZERO CUSTO)

1. **Geração dados:** Python (`pandas`, `numpy`, `Faker`) ou planilha manual.
2. **Modelagem:** Python + `scikit-learn` (Árvore de Decisão ou KNN).
3. **Dashboard:** **Power BI Desktop** (grátis no Windows) — fallback **Tableau Public**.
4. **Documento:** Google Docs/Word → exportar PDF.

---

## 📅 4. ETAPAS

### ETAPA 1: BASE DE DADOS (2,5 pts)

- Definir ≥8 colunas relevantes para venda da Vinheria.
- Sugestão de colunas:
  - `id_venda`, `data_venda`, `produto` (rótulo do vinho), `tipo_vinho` (tinto/branco/rosé), `safra`, `preco_unitario`, `quantidade`, `canal` (loja/online/distribuidor), `regiao_cliente`, `tipo_cliente` (PF/PJ), `desconto_aplicado`, `forma_pagamento`, **`sucesso_venda` (0/1 — rótulo)**.
- Definir regra de "sucesso" (ex.: venda concluída sem cancelamento E margem ≥ X%).
- Gerar ~500–1000 linhas simuladas via script Python.
- Salvar em `dataset.csv`.

### ETAPA 2: MODELAGEM SUPERVISIONADA (2,5 pts)

- Escolher algoritmo: **Árvore de Decisão** (interpretável, bom para apresentação).
- Pré-processar: encoding categórico, normalização se KNN.
- Split: `train_test_split` 80/20, `random_state=42`, `stratify=y`.
- Treinar `DecisionTreeClassifier`.
- Métricas: acurácia, precisão, recall, F1, matriz de confusão.
- Script `modelo.py` ou notebook `modelo.ipynb`.
- Documentar resultados no PDF.

### ETAPA 3: DASHBOARD (2,5 pts)

- Importar `dataset.csv` no Power BI.
- Mínimo 3 visualizações:
  1. Vendas por período (linha temporal)
  2. Vendas por produto/tipo de vinho (barra)
  3. Mapa/regiões ou taxa de sucesso por canal
- Filtros obrigatórios: **período, produto, região**.
- Destacar padrões/exceções (top N, conditional formatting).
- Salvar `dashboard.pbix` + screenshots.

### ETAPA 4: REFLEXÃO FINAL (2,5 pts)

Responder no PDF:
1. Quais insights foram descobertos?
2. Como a Vinheria pode usar para decisões estratégicas?
3. Modelo teve bom desempenho? Melhorias possíveis?

Foco: profundidade analítica, conexão dado → decisão de negócio.

### ETAPA 5: EMPACOTAR & ENTREGAR

- Conferir todos arquivos no ZIP.
- Validar nome do arquivo conforme padrão.
- Subir na plataforma com antecedência (NÃO deixar para últimos minutos).

---

## ⚠️ 5. PONTOS DE ATENÇÃO

- Equipe obrigatória 3–5 alunos.
- Não compartilhar respostas em WhatsApp/Discord/Teams (plágio = zero coletivo).
- Revisão de nota: até 15 dias após publicação.
- Upload correto — não dá para trocar arquivo depois do prazo.

---

`Ref: /Users/estevaoboaventura/dev/fiap/fiap/2026/1-semestre/fase-2/atividade-fase-2`
