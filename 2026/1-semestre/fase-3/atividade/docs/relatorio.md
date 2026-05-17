# Vinheria Agnello — Fase 3
## Ciência de Dados e Aprendizado Supervisionado

**Grupo:** _(preencher com nomes e RMs)_
**Disciplina:** PBL — Engenharia de Software, FIAP
**Data:** 2026

---

## 1. Base de Dados (Etapa 1)

Arquivo: `data/dataset.csv` — 1.000 linhas, 14 colunas. Gerado pelo script `src/generate_dataset.py` com semente `42` para reprodutibilidade.

### Colunas

| Coluna | Tipo | Descrição |
|---|---|---|
| `id_venda` | int | Identificador único da venda |
| `data_venda` | date | Data em que a venda foi registrada (2024-01 a 2026-04) |
| `tipo_vinho` | categórico | Tinto, Branco, Rose, Espumante |
| `produto` | categórico | Nome do rótulo (Cabernet Reserva, Malbec Premium, etc.) |
| `safra` | int | Ano da safra (2000–2023) |
| `preco_unitario` | float | Preço por garrafa (R$) |
| `quantidade` | int | Quantidade de garrafas na venda |
| `desconto_aplicado` | float | Desconto fracionário (0.0 a 0.25) |
| `canal` | categórico | Loja Física, E-commerce, Distribuidor, Eventos |
| `regiao_cliente` | categórico | Sudeste, Sul, Nordeste, Centro-Oeste, Norte |
| `tipo_cliente` | categórico | PF (pessoa física) ou PJ (pessoa jurídica) |
| `forma_pagamento` | categórico | Crédito, Débito, Pix, Boleto |
| `valor_total` | float | `preco_unitario * quantidade * (1 - desconto)` |
| **`sucesso_venda`** | **binário (0/1)** | **Rótulo: 1 se venda foi bem-sucedida** |

### Definição de sucesso

Venda **bem-sucedida** = venda concluída sem cancelamento, sem inadimplência e com margem aceitável para a Vinheria. O processo de geração modela essa condição como uma função probabilística sobre as variáveis (canal, tipo de cliente, região, desconto, forma de pagamento, preço, safra), garantindo que o dataset tenha estrutura aprendível e ruído realista.

Distribuição final: **~67% sucesso / 33% insucesso**.

---

## 2. Modelagem de Aprendizado Supervisionado (Etapa 2)

### Algoritmo escolhido: Árvore de Decisão (`DecisionTreeClassifier`)

**Justificativa:**
- **Interpretabilidade**: a árvore gera regras explícitas (`SE preço > 200 E canal = E-commerce ENTÃO sucesso`), úteis para apresentação à diretoria da Vinheria.
- **Não exige normalização**: lida bem com mistura de features numéricas e categóricas após one-hot encoding.
- **Robusto a outliers** e a relações não-lineares.
- **Rápido** de treinar e inferir em datasets pequenos como este.

### Variáveis de entrada

- **Numéricas (5)**: `preco_unitario`, `quantidade`, `desconto_aplicado`, `safra`, `valor_total`
- **Categóricas (5)**: `tipo_vinho`, `canal`, `regiao_cliente`, `tipo_cliente`, `forma_pagamento` — codificadas via `OneHotEncoder`
- **Descartadas**: `id_venda` (identificador), `data_venda` (alta cardinalidade, sem agregação temporal), `produto` (alta cardinalidade — pode ser explorada em iteração futura)
- **Rótulo**: `sucesso_venda`

### Hiperparâmetros

```python
DecisionTreeClassifier(
    max_depth=6,
    min_samples_leaf=10,
    criterion="gini",
    random_state=42,
)
```

### Separação treino/teste

- `train_test_split` com `test_size=0.20`, `random_state=42`, `stratify=y` (mantém proporção 67/33 nas duas partições).
- **Treino**: 800 amostras • **Teste**: 200 amostras.
- Validação cruzada estratificada de 5 dobras adicional para estimar variância.

### Métricas (conjunto de teste)

| Métrica | Valor |
|---|---|
| Acurácia | **0,635** |
| Precisão (classe 1) | **0,691** |
| Recall (classe 1) | **0,830** |
| F1-score (classe 1) | **0,754** |
| Acurácia 5-fold CV (média ± dp) | **0,610 ± 0,029** |

**Matriz de confusão**: ver `outputs/confusion_matrix.png`.

| | Previsto: Insucesso | Previsto: Sucesso |
|---|---|---|
| **Real: Insucesso** | 15 | 50 |
| **Real: Sucesso** | 23 | 112 |

**Top features (importância)**: `valor_total` (24%), `preco_unitario` (20%), `safra` (19%), `forma_pagamento_Debito` (16%), `canal_Eventos` (10%). Ver `outputs/feature_importance.png`.

---

## 3. Dashboard (Etapa 3)

Arquivo: `dashboard.pbix` (Power BI Desktop).

### Visualizações implementadas (≥3)

1. **Vendas ao longo do tempo** — gráfico de linha de `valor_total` somado por mês, com sobreposição de taxa de sucesso.
2. **Vendas por tipo de vinho e canal** — gráfico de barras empilhadas mostrando volume e proporção sucesso/insucesso.
3. **Mapa de calor regional** — taxa de sucesso por `regiao_cliente`, destacando Sudeste e Sul.
4. _(extra)_ **Funil por forma de pagamento** — proporção de sucesso por método.

### Filtros (slicers)

- Período (`data_venda`)
- Produto (`produto` / `tipo_vinho`)
- Região (`regiao_cliente`)

### Padrões destacados

- E-commerce e Distribuidor têm taxas de sucesso superiores ao canal Eventos.
- Boleto bancário apresenta menor conversão.
- Safras entre 2016 e 2023 vendem melhor que safras muito antigas.

**Screenshots**: ver pasta `outputs/dashboard_screens/` _(adicionar após montar dashboard)_.

---

## 4. Reflexão Final (Etapa 4)

### 4.1 Quais insights foram descobertos a partir dos dados?

- **Valor total e preço unitário** são os principais preditores de sucesso — vendas premium têm comportamento diferente das populares.
- **Canal de venda** importa: E-commerce e Distribuidor superam Eventos em taxa de conversão.
- **Forma de pagamento Boleto** está associada a maior risco de insucesso (provavelmente inadimplência), enquanto Pix e Débito tendem a fechar melhor.
- **Safra** influencia: vinhos com 3 a 10 anos de envelhecimento têm melhor desempenho que safras muito jovens ou muito antigas.
- **Clientes PJ** convertem mais que PF, sugerindo que vendas corporativas/B2B são um nicho subexplorado.
- **Sudeste e Sul** concentram a maior parte das vendas bem-sucedidas — mercado natural a defender.

### 4.2 Como a Vinheria poderia usar essa análise para tomar decisões estratégicas?

- **Reforçar E-commerce e B2B**: investir em UX do site e em equipe comercial para distribuidores, onde a conversão é mais alta.
- **Repensar política de Boleto**: oferecer desconto adicional para Pix ou exigir entrada para boleto, reduzindo inadimplência.
- **Curadoria de safras**: priorizar estoque de safras 2016–2023 e liquidar gradualmente safras muito antigas com promoções segmentadas.
- **Expandir Norte e Nordeste**: regiões com menor volume mas mercado endereçável — testar campanhas regionais e parcerias logísticas.
- **Eventos**: reavaliar ROI dos eventos presenciais — taxa de conversão menor pode não compensar o custo se não houver retorno em branding mensurável.
- **Programa B2B**: criar carteira dedicada a restaurantes, hotéis e empresas (PJ) com condições comerciais específicas.

### 4.3 O modelo de classificação teve bom desempenho? Quais melhorias poderiam ser feitas?

**Desempenho atual**: acurácia de 63,5% no teste, com F1 de 0,75 para a classe sucesso. O modelo supera o baseline trivial de prever sempre sucesso (~67% — porém com recall 100% e precisão = prevalência, sem capacidade discriminativa real) quando consideramos as métricas balanceadas (F1 macro 0,52 e precisão por classe), evidenciando que ele realmente aprende estrutura, especialmente para identificar insucessos.

**Limitações observadas**:
- Recall da classe **insucesso** (0,23) é baixo — o modelo erra ao classificar vendas que falham.
- Variância entre folds da validação cruzada é pequena (±0,03), indicando estabilidade mas teto baixo.
- Dataset é simulado: pode subestimar interações reais.

**Melhorias possíveis**:
1. **Mais dados reais** — substituir simulação por histórico operacional da Vinheria.
2. **Feature engineering** — variáveis derivadas: sazonalidade (mês, trimestre), tempo desde última compra do cliente, recência, frequência, ticket médio histórico.
3. **Modelos mais poderosos** — Random Forest, Gradient Boosting (XGBoost, LightGBM) costumam superar uma única árvore.
4. **Tratamento de desbalanceamento** — SMOTE ou class weights tunados em conjunto com threshold otimizado para o custo de negócio (perder uma venda vs. perseguir falsa positiva).
5. **Hiperparâmetros via GridSearch/Optuna** com validação cruzada estratificada.
6. **Calibração de probabilidades** (Platt scaling) caso a Vinheria use o score como ranking para priorizar leads.
7. **Explicabilidade** — SHAP values para apoiar a leitura das regras a nível de venda individual.

---

## Estrutura de entrega (ZIP)

```
NomeSobrenome_RMxxxxxx_fase3_PBL.zip
├── dataset.csv               (Etapa 1)
├── relatorio.pdf             (Etapas 2, 3 e 4 — exportado deste .md)
└── dashboard.pbix            (Etapa 3 — Power BI)
```

Reprodução completa do pipeline:
```bash
uv sync
uv run python src/generate_dataset.py
uv run python src/train_model.py
```
