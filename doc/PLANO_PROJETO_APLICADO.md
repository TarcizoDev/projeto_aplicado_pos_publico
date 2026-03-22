# PLANO DE DESENVOLVIMENTO - Projeto Aplicado (Pós-Graduação XP Educação)

> **Título:** Identificação de Regimes Operacionais em Moagem Industrial com Aprendizado Supervisionado e Não-Supervisionado
> **Aluno:** Tarcizo Junior
> **Data:** 2026-03-22
> **Versão:** 4.0

---

## CONTEXTO ESTRATÉGICO

Este projeto aplicado tem como objetivo desenvolver um sistema de identificação automática de regimes operacionais em um moinho de bolas industrial, utilizando técnicas de aprendizado de máquina supervisionado e não-supervisionado.

**Princípio:** Todo o trabalho técnico foi feito **do zero**, com pipeline próprio, garantindo independência e reprodutibilidade.

**O que temos como entrada:**
- Dataset bruto: ~830.000 registros, 27 variáveis, freq. 1 min, período ago/2024 - mar/2026
- Sistema de classificação de dureza em operação na planta com 6 classes (C1-C6) — utilizado como referência de comparação
- Venv dedicado para o projeto: `C:\ScriptsDatamindsVenv\pos_graduacao`

**Abordagem técnica central:**
- Não-supervisionado: Descobrir regimes operacionais no moinho de bolas via clustering
- Supervisionado: Treinar classificador usando os regimes descobertos pelo clustering como target
- Comparação: Investigar a relação entre regimes descobertos e classes de dureza (C1-C6) — se corresponderem, a dureza é o fator dominante; se não, os regimes capturam aspectos operacionais que transcendem a dureza

---

## SPRINT 1: PREPARAÇÃO DOS DADOS + EDA + CLUSTERING

> **Objetivo:** Preparar os dados do zero, explorar e descobrir regimes operacionais
> **Status:** ✅ CONCLUÍDA

### 1.1 Preparar Ambiente ✅

- [x] Atualizar venv `C:\ScriptsDatamindsVenv\pos_graduacao` com todas as libs necessárias
- [x] Gerar `requirements.txt` do venv
- [x] Criar estrutura de pastas do projeto aplicado

### 1.2 Preparação dos Dados (Pipeline do Zero) ✅

**Notebook:** `01_sprint1/a_preparacao_dados.ipynb`

- [x] Carregar dataset bruto
- [x] Inspeção inicial: shape, dtypes, nulos, duplicados
- [x] Limpeza: valores negativos, ausentes, períodos de parada/partida, mancal > 55 bar
- [x] Tratamento de outliers (Z-Score, IQR)
- [x] Documentar cada etapa: registros removidos, motivo, impacto
- [x] Salvar dataset limpo no banco de dados PostgreSQL

### 1.3 Análise Exploratória de Dados (EDA) ✅

**Notebook:** `01_sprint1/b_analise_exploratoria.ipynb`

- [x] Estatísticas descritivas de todas as variáveis
- [x] Distribuições (histogramas, boxplots)
- [x] Correlações (Pearson, Spearman) + heatmaps
- [x] Séries temporais das variáveis críticas
- [x] Calcular energia específica (potência / alimentação) como variável derivada

### 1.4 Clustering Não-Supervisionado ✅

**Notebooks:** `01_sprint1/clusters/` (v1, v2 e v3)

**Três versões do pipeline desenvolvidas e comparadas:**

| Versão | Scaler | Features | Preprocessing |
|---|---|---|---|
| v1 | StandardScaler | 26 (todas) | Nenhum |
| v2 | RobustScaler | ~16 (curadas) | Hampel + QuasiConst + Colinearidade |
| v3 | RobustScaler | ~20 (curadas + eng.) | Filtro estável + FE + Hampel + Colinearidade |

**Algoritmos testados:**
- [x] K-Means com k=2..8 (Elbow + Silhouette)
- [x] DBSCAN (sweep sistemático eps × min_samples, 44 combinações)
- [x] Gaussian Mixture Models (BIC/AIC)

**Resultado:** K-Means com k=3 selecionado (V2). Três regimes identificados:
- **R0 — Operação em carga reduzida:** 14,2% do período, alimentação e potência abaixo da média
- **R1 — Operação moderada:** 45,6% do período, carga média, regime predominante
- **R2 — Operação em alta carga:** 40,2% do período, plena capacidade

**Análise dos clusters:**
- [x] Caracterização por cluster (média, desvio, min, max)
- [x] Visualização PCA 2D
- [x] Perfil temporal dos regimes
- [x] Transições entre regimes (análise de Markov)
- [x] Validação interna: Silhouette, Davies-Bouldin, Calinski-Harabasz

### 1.5 Comparação de Versões e Análise Temporal ✅

**Notebooks:** `01_sprint1/d_comparacao_versoes.ipynb`, `01_sprint1/e_analise_temporal_regimes.ipynb`

- [x] Comparação objetiva V1 × V2 × V3 (métricas, regimes, técnicas)
- [x] Análise temporal: permanência, taxa de transição, matrizes de Markov
- [x] Seleção da V2 como versão final (melhor equilíbrio métricas + coerência temporal)
- [x] Hipótese H1 confirmada (existência de regimes distintos)

### 1.6 Rastreabilidade ✅

**Versionamento completo — cada versão salva em namespace independente:**

| Versão | Tabelas PostgreSQL | Parquet local |
|---|---|---|
| v1 | `s1c_v1_*` (5 tabelas) | `dados_com_clusters_v1.parquet` |
| v2 | `s1c_v2_*` (5 tabelas) | `dados_com_clusters_v2.parquet` |
| v3 | `s1c_v3_*` (5 tabelas) | `dados_com_clusters_v3.parquet` |

---

## SPRINT 2: COMPARAÇÃO + CLASSIFICADOR SUPERVISIONADO

> **Objetivo:** Investigar relação com dureza e treinar classificador de regimes
> **Status:** 🔲 NÃO INICIADA

### 2.1 Carimbamento e Comparação com Dureza

**Notebook:** `02_sprint2/a_carimbamento_preditor.ipynb`

**Processo:**
- [ ] Carregar dataset com regimes (versão selecionada na Sprint 1)
- [ ] Executar sistema de classificação de dureza (classes C1-C6) sobre os dados
- [ ] Gerar dataset com classes SAG + regimes do clustering

**Comparação Clusters vs Classes SAG:**
- [ ] Confusion matrix: clusters vs classes C1-C6
- [ ] Adjusted Rand Index (ARI)
- [ ] Normalized Mutual Information (NMI)

### 2.2 Preparação de Dados para Modelagem

**Notebook:** `02_sprint2/b_preparacao_modelagem.ipynb`

- [ ] Feature engineering: lags temporais, médias móveis, taxas de variação, energia específica
- [ ] Split temporal (sem shuffle): treino, validação, teste
- [ ] Verificação de balanceamento de classes
- [ ] Dados salvos no PostgreSQL

### 2.3 Treinamento de Modelos

**Notebook:** `02_sprint2/c_treinamento_modelos.ipynb`

**Modelos planejados (classificação multiclasse — 3 regimes):**

1. **Random Forest** — com GridSearchCV + TimeSeriesSplit
2. **XGBoost** — com GridSearchCV + TimeSeriesSplit
3. **LightGBM** — com GridSearchCV + TimeSeriesSplit

- [ ] Treinar os 3 modelos
- [ ] Avaliar: acurácia, precisão, recall, F1-Score por classe
- [ ] Selecionar melhor modelo

### 2.4 Seleção e Análise do Melhor Modelo

- [ ] SHAP summary plot (quais features mais importam para cada regime)
- [ ] Análise de erros: em quais regimes o modelo mais erra
- [ ] Análise temporal dos erros

---

## SPRINT 3: VALIDAÇÃO + RESULTADOS + ENTREGÁVEIS

> **Objetivo:** Validar resultados, gerar visualizações finais e preparar entregáveis
> **Status:** 🔲 NÃO INICIADA

### 3.1 Validação Cruzada dos Resultados

**Notebook:** `03_sprint3/a_validacao_cruzada.ipynb`

**Comparação Clustering vs Supervisionado:**
- [ ] Matriz de correspondência: cluster_id vs classe_predita pelo classificador
- [ ] ARI e NMI entre as duas abordagens
- [ ] Onde divergem? O que isso significa operacionalmente?

**Comparação com Dureza (validação complementar):**
- [ ] Analisar como os regimes classificados se relacionam com as classes SAG
- [ ] Formalizar resultado da hipótese H2

**Validação temporal:**
- [ ] O classificador mantém performance ao longo do tempo?
- [ ] Gráfico de accuracy rolling (janela de 1 semana)
- [ ] Detectar períodos de queda de performance (possível drift)

**Validação operacional (interpretabilidade):**
- [ ] SHAP analysis completa
- [ ] Para cada regime: perfil operacional em linguagem de operador
- [ ] Os regimes fazem sentido físico?
- [ ] Recomendações operacionais por regime

### 3.2 Visualizações Finais

**Notebook:** `03_sprint3/b_visualizacoes_finais.ipynb`

- [ ] Dashboard estático (HTML) com todos os resultados
- [ ] Gráficos para o Pitch (formato limpo, legível em vídeo)

### 3.3 Consolidação de Resultados

**Notebook:** `03_sprint3/c_resultados_finais.ipynb`

- [ ] Tabela resumo final
- [ ] Validação formal das 5 hipóteses:
  - H1: ✅ Confirmada na Sprint 1 (3 regimes distintos identificados)
  - H2: A validar (comparação regimes vs dureza)
  - H3: A validar (acurácia do classificador > 80%)
  - H4: A validar (SHAP na Sprint 3)
  - H5: A validar (análise temporal na Sprint 3)
- [ ] Lições aprendidas
- [ ] Próximos passos

---

## ENTREGÁVEIS FINAIS

### Relatório (preenchimento progressivo do template)

| Seção do Template | Quando preencher | Status |
|---|---|---|
| Análise de Contexto | Etapa 1 | ✅ Concluída |
| Personas | Etapa 1 | ✅ Concluída |
| Justificativas | Etapa 1 | ✅ Concluída |
| Hipóteses | Etapa 1 | ✅ Concluída |
| Objetivo SMART | Etapa 2 | ✅ Concluída |
| Escopo (Premissas/Restrições) | Etapa 2 | ✅ Concluída |
| Backlog de Produto | Etapa 2 | ✅ Concluída |
| Sprint 1 | Sprint 1 | ✅ Concluída |
| Sprint 2 | Sprint 2 | 🔲 Pendente |
| Sprint 3 | Sprint 3 | 🔲 Pendente |
| Considerações Finais | Etapa Final | 🔲 Pendente |

### Pitch (8-10 min, template oficial)

| Slide | Conteúdo planejado |
|---|---|
| 1 - Capa | Título, nome, curso |
| 2 - Sumário | 6 seções |
| 3 - Apresentação | Quem sou, formação, experiência em dados/mineração |
| 4 - Desafio | Moagem industrial, variabilidade, necessidade de identificar regimes |
| 5 - Solução | Abordagem ML (clustering + classificador), objetivo SMART |
| 6 - Diferencial | Dados reais, combinação supervisionado + não-supervisionado, interpretabilidade |
| 7 - Desenvolvimento | Sprint 1 (clustering), Sprint 2 (classificador), Sprint 3 (validação) |
| 8 - Resultados | Métricas, gráficos, próximos passos |
| 9 - Agradecimento | - |

---

## FERRAMENTAS E TECNOLOGIAS

| Categoria | Ferramenta |
|---|---|
| Linguagem | Python 3.12 |
| Ambiente | Venv em `C:\ScriptsDatamindsVenv\pos_graduacao` |
| Dados | pandas, numpy, pyarrow (parquet) |
| Visualização | matplotlib, seaborn, plotly |
| Clustering | scikit-learn (KMeans, DBSCAN, GMM), PCA |
| Classificação | scikit-learn, XGBoost, LightGBM |
| Interpretabilidade | SHAP |
| Métricas | scikit-learn (classification_report, confusion_matrix, roc_auc) |
| Validação interna | Silhouette, Davies-Bouldin, Calinski-Harabasz |
| Validação externa | ARI, NMI |
| Banco de dados | PostgreSQL (schema: otimizar_moagem_aura) |
| Relatório | Template .docx oficial |
| Pitch | Template .pptx oficial |

---

## RISCOS E MITIGAÇÕES

| Risco | Impacto | Mitigação | Status |
|---|---|---|---|
| Clusters não correspondem às classes SAG | Regimes capturam aspectos diferentes de dureza | Tratar como achado válido — regimes e dureza são dimensões complementares | 🔲 A verificar na Sprint 2 |
| Desbalanceamento de classes nos regimes | Modelo viesado | class_weight, métricas por classe | 🔲 A verificar na Sprint 2 |
| Classificador com accuracy baixa (<80%) | Projeto abaixo da meta | Revisar features, ajustar número de regimes | 🔲 A verificar na Sprint 2 |
| Drift temporal | Modelo degrada ao longo do tempo | Validação temporal na Sprint 3 | 🔲 A verificar |
| Tempo insuficiente para 3 sprints | Entregas incompletas | Sprint 1 e 2 são o core; Sprint 3 pode ser simplificada | 🔄 Sprint 1 concluída |
