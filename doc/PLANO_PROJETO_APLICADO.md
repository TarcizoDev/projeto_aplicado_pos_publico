# PLANO DE DESENVOLVIMENTO - Projeto Aplicado (Pos-Graduacao XP Educacao)

> **Titulo:** Identificacao de Regimes Operacionais em Moagem Industrial com Aprendizado Supervisionado e Nao-Supervisionado
> **Aluno:** Tarcizo Junior
> **Data:** 2026-03-22
> **Versao:** 4.0

---

## CONTEXTO ESTRATEGICO

Este projeto aplicado tem como objetivo desenvolver um sistema de identificacao automatica de regimes operacionais em um moinho de bolas industrial, utilizando tecnicas de aprendizado de maquina supervisionado e nao-supervisionado.

**Principio:** Todo o trabalho tecnico foi feito **do zero**, com pipeline proprio, garantindo independencia e reprodutibilidade.

**O que temos como entrada:**
- Dataset bruto: ~830.000 registros, 27 variaveis, freq. 1 min, periodo ago/2024 - mar/2026
- Sistema de classificacao de dureza em operacao na planta com 6 classes (C1-C6) — utilizado como referencia de comparacao
- Venv dedicado para o projeto: `C:\ScriptsDatamindsVenv\pos_graduacao`

**Abordagem tecnica central:**
- Nao-supervisionado: Descobrir regimes operacionais no moinho de bolas via clustering
- Supervisionado: Treinar classificador usando os regimes descobertos pelo clustering como target
- Comparacao: Investigar a relacao entre regimes descobertos e classes de dureza (C1-C6) — se corresponderem, a dureza e o fator dominante; se nao, os regimes capturam aspectos operacionais que transcendem a dureza

---

## MAPEAMENTO: ENTREGAS ACADEMICAS vs TECNICAS

| Etapa Academica | O que entregar | Trabalho tecnico real |
|---|---|---|
| IDT (quiz) | Perguntas multipla escolha | Responder na plataforma |
| Onboarding (quiz) | Perguntas sobre PA | Responder na plataforma |
| Etapa 1 - Desafio | Relatorio: contexto, personas, justificativas, hipoteses | Documentar o problema de otimizacao de moagem |
| Etapa 2 - Solucao | Relatorio: SMART, escopo, cronograma | Definir abordagem ML + backlog de sprints |
| Sprint 1 | Relatorio parcial + evidencias | Preparacao dos dados + EDA + Clustering |
| Sprint 2 | Relatorio parcial + evidencias | Carimbamento + Comparacao + Classificador supervisionado |
| Sprint 3 | Relatorio parcial + evidencias | Validacao + Visualizacao + Resultados |
| Etapa Final | Relatorio completo + Pitch (8-10 min) | Consolidar tudo + gravar video |

---

## SPRINT 1: PREPARACAO DOS DADOS + EDA + CLUSTERING

> **Objetivo:** Preparar os dados do zero, explorar e descobrir regimes operacionais
> **Status:** ✅ CONCLUIDA

### 1.1 Preparar Ambiente ✅

- [x] Atualizar venv `C:\ScriptsDatamindsVenv\pos_graduacao` com todas as libs necessarias
- [x] Gerar `requirements.txt` do venv
- [x] Criar estrutura de pastas do projeto aplicado

### 1.2 Preparacao dos Dados (Pipeline do Zero) ✅

**Notebook:** `01_sprint1/a_preparacao_dados.ipynb`

- [x] Carregar dataset bruto
- [x] Inspecao inicial: shape, dtypes, nulos, duplicados
- [x] Limpeza: valores negativos, ausentes, periodos de parada/partida, mancal > 55 bar
- [x] Tratamento de outliers (Z-Score, IQR)
- [x] Documentar cada etapa: registros removidos, motivo, impacto
- [x] Salvar dataset limpo no banco de dados PostgreSQL

### 1.3 Analise Exploratoria de Dados (EDA) ✅

**Notebook:** `01_sprint1/b_analise_exploratoria.ipynb`

- [x] Estatisticas descritivas de todas as variaveis
- [x] Distribuicoes (histogramas, boxplots)
- [x] Correlacoes (Pearson, Spearman) + heatmaps
- [x] Series temporais das variaveis criticas
- [x] Calcular energia especifica (potencia / alimentacao) como variavel derivada

### 1.4 Clustering Nao-Supervisionado ✅

**Notebooks:** `01_sprint1/clusters/` (v1, v2 e v3)

**Tres versoes do pipeline desenvolvidas e comparadas:**

| Versao | Scaler | Features | Preprocessing |
|---|---|---|---|
| v1 | StandardScaler | 26 (todas) | Nenhum |
| v2 | RobustScaler | ~16 (curadas) | Hampel + QuasiConst + Colinearidade |
| v3 | RobustScaler | ~20 (curadas + eng.) | Filtro estavel + FE + Hampel + Colinearidade |

**Algoritmos testados:**
- [x] K-Means com k=2..8 (Elbow + Silhouette)
- [x] DBSCAN (sweep sistematico eps × min_samples, 44 combinacoes)
- [x] Gaussian Mixture Models (BIC/AIC)

**Resultado:** K-Means com k=3 selecionado (V2). Tres regimes identificados:
- **R0 — Operacao em carga reduzida:** 14,2% do periodo, alimentacao e potencia abaixo da media
- **R1 — Operacao moderada:** 45,6% do periodo, carga media, regime predominante
- **R2 — Operacao em alta carga:** 40,2% do periodo, plena capacidade

**Analise dos clusters:**
- [x] Caracterizacao por cluster (media, desvio, min, max)
- [x] Visualizacao PCA 2D
- [x] Perfil temporal dos regimes
- [x] Transicoes entre regimes (analise de Markov)
- [x] Validacao interna: Silhouette, Davies-Bouldin, Calinski-Harabasz

### 1.5 Comparacao de Versoes e Analise Temporal ✅

**Notebooks:** `01_sprint1/d_comparacao_versoes.ipynb`, `01_sprint1/e_analise_temporal_regimes.ipynb`

- [x] Comparacao objetiva V1 × V2 × V3 (metricas, regimes, tecnicas)
- [x] Analise temporal: permanencia, taxa de transicao, matrizes de Markov
- [x] Selecao da V2 como versao final (melhor equilibrio metricas + coerencia temporal)
- [x] Hipotese H1 confirmada (existencia de regimes distintos)

### 1.6 Rastreabilidade ✅

**Versionamento completo — cada versao salva em namespace independente:**

| Versao | Tabelas PostgreSQL | Parquet local |
|---|---|---|
| v1 | `s1c_v1_*` (5 tabelas) | `dados_com_clusters_v1.parquet` |
| v2 | `s1c_v2_*` (5 tabelas) | `dados_com_clusters_v2.parquet` |
| v3 | `s1c_v3_*` (5 tabelas) | `dados_com_clusters_v3.parquet` |

---

## SPRINT 2: COMPARACAO + CLASSIFICADOR SUPERVISIONADO

> **Objetivo:** Investigar relacao com dureza e treinar classificador de regimes
> **Status:** 🔲 NAO INICIADA

### 2.1 Carimbamento e Comparacao com Dureza

**Notebook:** `02_sprint2/a_carimbamento_preditor.ipynb`

**Processo:**
- [ ] Carregar dataset com regimes (versao selecionada na Sprint 1)
- [ ] Executar sistema de classificacao de dureza (classes C1-C6) sobre os dados
- [ ] Gerar dataset com classes SAG + regimes do clustering

**Comparacao Clusters vs Classes SAG:**
- [ ] Confusion matrix: clusters vs classes C1-C6
- [ ] Adjusted Rand Index (ARI)
- [ ] Normalized Mutual Information (NMI)

### 2.2 Preparacao de Dados para Modelagem

**Notebook:** `02_sprint2/b_preparacao_modelagem.ipynb`

- [ ] Feature engineering: lags temporais, medias moveis, taxas de variacao, energia especifica
- [ ] Split temporal (sem shuffle): treino, validacao, teste
- [ ] Verificacao de balanceamento de classes
- [ ] Dados salvos no PostgreSQL

### 2.3 Treinamento de Modelos

**Notebook:** `02_sprint2/c_treinamento_modelos.ipynb`

**Modelos planejados (classificacao multiclasse — 3 regimes):**

1. **Random Forest** — com GridSearchCV + TimeSeriesSplit
2. **XGBoost** — com GridSearchCV + TimeSeriesSplit
3. **LightGBM** — com GridSearchCV + TimeSeriesSplit

- [ ] Treinar os 3 modelos
- [ ] Avaliar: acuracia, precisao, recall, F1-Score por classe
- [ ] Selecionar melhor modelo

### 2.4 Selecao e Analise do Melhor Modelo

- [ ] SHAP summary plot (quais features mais importam para cada regime)
- [ ] Analise de erros: em quais regimes o modelo mais erra
- [ ] Analise temporal dos erros

---

## SPRINT 3: VALIDACAO + RESULTADOS + ENTREGAVEIS

> **Objetivo:** Validar resultados, gerar visualizacoes finais e preparar entregaveis
> **Status:** 🔲 NAO INICIADA

### 3.1 Validacao Cruzada dos Resultados

**Notebook:** `03_sprint3/a_validacao_cruzada.ipynb`

**Comparacao Clustering vs Supervisionado:**
- [ ] Matriz de correspondencia: cluster_id vs classe_predita pelo classificador
- [ ] ARI e NMI entre as duas abordagens
- [ ] Onde divergem? O que isso significa operacionalmente?

**Comparacao com Dureza (validacao complementar):**
- [ ] Analisar como os regimes classificados se relacionam com as classes SAG
- [ ] Formalizar resultado da hipotese H2

**Validacao temporal:**
- [ ] O classificador mantem performance ao longo do tempo?
- [ ] Grafico de accuracy rolling (janela de 1 semana)
- [ ] Detectar periodos de queda de performance (possivel drift)

**Validacao operacional (interpretabilidade):**
- [ ] SHAP analysis completa
- [ ] Para cada regime: perfil operacional em linguagem de operador
- [ ] Os regimes fazem sentido fisico?
- [ ] Recomendacoes operacionais por regime

### 3.2 Visualizacoes Finais

**Notebook:** `03_sprint3/b_visualizacoes_finais.ipynb`

- [ ] Dashboard estatico (HTML) com todos os resultados
- [ ] Graficos para o Pitch (formato limpo, legivel em video)

### 3.3 Consolidacao de Resultados

**Notebook:** `03_sprint3/c_resultados_finais.ipynb`

- [ ] Tabela resumo final
- [ ] Validacao formal das 5 hipoteses:
  - H1: ✅ Confirmada na Sprint 1 (3 regimes distintos identificados)
  - H2: A validar (comparacao regimes vs dureza)
  - H3: A validar (acuracia do classificador > 80%)
  - H4: A validar (SHAP na Sprint 3)
  - H5: A validar (analise temporal na Sprint 3)
- [ ] Licoes aprendidas
- [ ] Proximos passos

---

## ENTREGAVEIS FINAIS

### Relatorio (preenchimento progressivo do template)

| Secao do Template | Quando preencher | Status |
|---|---|---|
| Analise de Contexto | Etapa 1 | ✅ Concluida |
| Personas | Etapa 1 | ✅ Concluida |
| Justificativas | Etapa 1 | ✅ Concluida |
| Hipoteses | Etapa 1 | ✅ Concluida |
| Objetivo SMART | Etapa 2 | ✅ Concluida |
| Escopo (Premissas/Restricoes) | Etapa 2 | ✅ Concluida |
| Backlog de Produto | Etapa 2 | ✅ Concluida |
| Sprint 1 | Sprint 1 | ✅ Concluida |
| Sprint 2 | Sprint 2 | 🔲 Pendente |
| Sprint 3 | Sprint 3 | 🔲 Pendente |
| Consideracoes Finais | Etapa Final | 🔲 Pendente |

### Pitch (8-10 min, template oficial)

| Slide | Conteudo planejado |
|---|---|
| 1 - Capa | Titulo, nome, curso |
| 2 - Sumario | 6 secoes |
| 3 - Apresentacao | Quem sou, formacao, experiencia em dados/mineracao |
| 4 - Desafio | Moagem industrial, variabilidade, necessidade de identificar regimes |
| 5 - Solucao | Abordagem ML (clustering + classificador), objetivo SMART |
| 6 - Diferencial | Dados reais, combinacao supervisionado + nao-supervisionado, interpretabilidade |
| 7 - Desenvolvimento | Sprint 1 (clustering), Sprint 2 (classificador), Sprint 3 (validacao) |
| 8 - Resultados | Metricas, graficos, proximos passos |
| 9 - Agradecimento | - |

---

## FERRAMENTAS E TECNOLOGIAS

| Categoria | Ferramenta |
|---|---|
| Linguagem | Python 3.12 |
| Ambiente | Venv em `C:\ScriptsDatamindsVenv\pos_graduacao` |
| Dados | pandas, numpy, pyarrow (parquet) |
| Visualizacao | matplotlib, seaborn, plotly |
| Clustering | scikit-learn (KMeans, DBSCAN, GMM), PCA |
| Classificacao | scikit-learn, XGBoost, LightGBM |
| Interpretabilidade | SHAP |
| Metricas | scikit-learn (classification_report, confusion_matrix, roc_auc) |
| Validacao interna | Silhouette, Davies-Bouldin, Calinski-Harabasz |
| Validacao externa | ARI, NMI |
| Banco de dados | PostgreSQL (schema: otimizar_moagem_aura) |
| Relatorio | Template .docx oficial |
| Pitch | Template .pptx oficial |

---

## RISCOS E MITIGACOES

| Risco | Impacto | Mitigacao | Status |
|---|---|---|---|
| Clusters nao correspondem as classes SAG | Regimes capturam aspectos diferentes de dureza | Tratar como achado valido — regimes e dureza sao dimensoes complementares | 🔲 A verificar na Sprint 2 |
| Desbalanceamento de classes nos regimes | Modelo viesado | class_weight, metricas por classe | 🔲 A verificar na Sprint 2 |
| Classificador com accuracy baixa (<80%) | Projeto abaixo da meta | Revisar features, ajustar numero de regimes | 🔲 A verificar na Sprint 2 |
| Drift temporal | Modelo degrada ao longo do tempo | Validacao temporal na Sprint 3 | 🔲 A verificar |
| Tempo insuficiente para 3 sprints | Entregas incompletas | Sprint 1 e 2 sao o core; Sprint 3 pode ser simplificada | 🔄 Sprint 1 concluida |
