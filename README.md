# Identificação de Regimes Operacionais em Moagem Industrial

**Projeto Aplicado** — Pós-Graduação em Ciência de Dados e Machine Learning (XP Educação)

**Aluno:** Tarcizo Junior
**Orientador:** Prof. Marcos Prochnow
**Data:** Abril/2026

---

## Objetivo

Desenvolver um sistema de identificação automática de regimes operacionais em um moinho de bolas industrial, utilizando técnicas de aprendizado de máquina supervisionado e não-supervisionado.

## Dados

- **Fonte:** Sistema de automação (PI System) de planta de mineração de ouro
- **Volume:** ~830.000 registros, 27 variáveis de processo, frequência de 1 minuto
- **Período:** Agosto/2024 a Março/2026 (577 dias)
- **Dataset limpo:** 632.985 registros, 26 variáveis
- **Observação:** Os dados brutos não estão incluídos neste repositório por questões de confidencialidade e tamanho

## Metodologia

O projeto segue a metodologia **Design Thinking** aplicada a Machine Learning, organizado em 3 sprints semanais:

| Sprint | Objetivo | Status |
|--------|----------|--------|
| Sprint 1 | Preparação dos dados + EDA + Clustering | ✅ Concluída |
| Sprint 2 | Comparação com dureza + Classificador supervisionado | ✅ Concluída |
| Sprint 3 | Validação cruzada + Resultados finais | ✅ Concluída |

## Resultados Principais

| Indicador | Valor |
|-----------|-------|
| Registros analisados | 632.985 |
| Variáveis de processo | 26 originais + 78 engenheiradas = 105 |
| Regimes identificados | 3 (R0: 14,2% · R1: 45,6% · R2: 40,2%) |
| Melhor modelo | LightGBM |
| Accuracy (teste) | 98,5% |
| F1-macro (teste) | 0,870 |
| Estabilidade temporal | 98,5% ± 1,0% ao longo de 12 semanas |
| Hipóteses confirmadas | 5 de 5 |

## Sprint 1 — Preparação, EDA e Clustering

### Pipeline de Dados
- 27 variáveis brutas → 26 após limpeza (1 removida por 59% de valores ausentes)
- Tratamento: valores negativos, períodos de falha, alimentação zero, moinho desligado, NaN (regras híbridas), outliers (Z-Score 3σ)
- Dataset limpo: **632.985 registros**

### Clustering — 3 Regimes Identificados
Três versões do pipeline foram desenvolvidas e comparadas (V1, V2, V3). A **V2** foi selecionada como versão final.

**Algoritmos testados:** K-Means, DBSCAN (44 combinações), Gaussian Mixture Models
**Selecionado:** K-Means com k=3

| Regime | Descrição | Proporção |
|--------|-----------|-----------|
| R0 | Operação em carga reduzida | 14,2% |
| R1 | Operação moderada | 45,6% |
| R2 | Operação em alta carga | 40,2% |

### Análise Temporal
- Matrizes de transição de Markov entre regimes
- Análise de permanência e padrões cíclicos (hora do dia, turno)
- Impacto energético por regime

## Sprint 2 — Classificação Supervisionada

### Comparação com Dureza (H2)
- ARI=0,048 e NMI=0,047 entre regimes e classes SAG (C1-C6)
- Regimes capturam dimensões operacionais que transcendem a dureza do minério

### Feature Engineering
- 27 variáveis originais → 105 features (lags, médias móveis, desvios, derivadas)
- Split temporal 70/15/15 (treino/validação/teste) sem embaralhamento

### Treinamento e Avaliação

| Modelo | Accuracy | F1-macro | F1-weighted |
|--------|----------|----------|-------------|
| Random Forest | 88,2% | 0,517 | 0,904 |
| XGBoost | 96,9% | 0,817 | 0,970 |
| **LightGBM** | **97,0%** | **0,826** | **0,970** |

LightGBM selecionado como modelo final. No conjunto de teste: **accuracy 98,5%**, F1-macro 0,870.

## Sprint 3 — Validação e Resultados

### Validação Cruzada (H1)
- ARI=0,738 e NMI=0,598 entre clustering e classificador
- Classificador reproduz fielmente os regimes do clustering

### Estabilidade Temporal (H5)
- 12 semanas de teste sem degradação
- Accuracy: 98,5% ± 1,0% (min 96,8%, max 99,5%)
- Nenhuma semana abaixo do limiar de 85%

### Interpretabilidade SHAP (H4)
Variáveis determinantes por regime (top 3):

| Regime | 1a variável | 2a variável | 3a variável |
|--------|-------------|-------------|-------------|
| R0 — Carga Reduzida | Corrente do moinho (2,01) | Ouvido eletrônico (1,66) | Vazão alim. espessador (1,56) |
| R1 — Moderado | Nível detox (3,03) | Ouvido eletrônico (2,48) | Nível caixa moinho (1,74) |
| R2 — Alta Carga | Balança retomada (1,95) | Vazão alim. espessador (1,85) | Pressão saída espessador (1,81) |

### Hipóteses — Todas Confirmadas

| Hipótese | Resultado |
|----------|-----------|
| H1 — Existência de regimes distintos | ✅ K-Means (k=3) com perfis operacionais coerentes |
| H2 — Regimes ≠ dureza do minério | ✅ ARI=0,048, NMI=0,047 (independentes) |
| H3 — Acurácia > 80% | ✅ LightGBM: 98,5% accuracy |
| H4 — Variáveis determinantes via SHAP | ✅ Features distintas e fisicamente interpretáveis |
| H5 — Estabilidade temporal | ✅ 98,5% ± 1,0% em 12 semanas |

## Estrutura do Repositório

```
├── doc/                          # Documentação do projeto
│   └── PLANO_PROJETO_APLICADO.md # Plano de desenvolvimento (versão 4.0)
│
├── Relatorio_Projeto/            # Relatório acadêmico (versões progressivas)
│   ├── Canvas do Projeto Aplicado - Preenchido.pptx
│   ├── Cronograma_Acoes_Planejadas.xlsx
│   └── Relatorio_Projeto_Aplicado_v1..v5.docx
│
├── notebooks/
│   ├── 01_sprint1/
│   │   ├── a_preparacao_dados.ipynb       # Limpeza, tratamento, outliers
│   │   ├── b_analise_exploratoria.ipynb   # Estatísticas, distribuições, correlações
│   │   ├── d_comparacao_versoes.ipynb     # Comparação V1 × V2 × V3
│   │   ├── e_analise_temporal_regimes.ipynb # Markov, permanência, padrões
│   │   └── clusters/
│   │       ├── c_clustering_regimes_v1.ipynb  # Pipeline V1 (baseline)
│   │       ├── c_clustering_regimes_v2.ipynb  # Pipeline V2 (selecionada)
│   │       └── c_clustering_regimes_v3.ipynb  # Pipeline V3 (experimental)
│   │
│   ├── 02_sprint2/
│   │   ├── a_carimbamento_preditor.ipynb  # Comparação regimes vs dureza (H2)
│   │   ├── b_preparacao_modelagem.ipynb   # Feature engineering + split temporal
│   │   └── c_treinamento_modelos.ipynb    # RF, XGBoost, LightGBM + SHAP
│   │
│   └── 03_sprint3/
│       ├── a_validacao_cruzada.ipynb      # Validação cruzada, SHAP, temporal (H1,H4,H5)
│       ├── b_visualizacoes_finais.ipynb   # Gráficos consolidados para relatório
│       └── c_resultados_finais.ipynb      # Consolidação, hipóteses, resumo final
│
├── figures/
│   ├── 01_sprint1/               # Gráficos Sprint 1 (S1a, S1b, S1d, S1e)
│   ├── 02_sprint2/               # Gráficos Sprint 2 (S2a, S2b, S2c)
│   └── 03_sprint3/               # Gráficos Sprint 3 (S3a, S3b, S3c)
│
├── sql/
│   ├── 001_criar_schema.sql      # DDL do banco PostgreSQL
│   └── 002_comentarios.sql       # Comentários nas tabelas
│
├── utils/
│   ├── db_utils.py               # Módulo de acesso ao banco de dados
│   └── exportar_html.py          # Exportação de notebooks para HTML
│
└── requirements.txt              # Dependências Python
```

## Tecnologias

| Categoria | Ferramenta |
|-----------|------------|
| Linguagem | Python 3.12 |
| Dados | pandas, numpy, pyarrow |
| Visualização | matplotlib, seaborn |
| Clustering | scikit-learn (KMeans, DBSCAN, GMM), PCA |
| Classificação | LightGBM, XGBoost, Random Forest |
| Interpretabilidade | SHAP (TreeExplainer) |
| Banco de dados | PostgreSQL |
| Versionamento | Git + GitHub |

## Como Reproduzir

> **Nota:** Os dados brutos não estão incluídos. Os notebooks documentam cada etapa com outputs visíveis (gráficos e tabelas).

1. Criar ambiente virtual e instalar dependências:
   ```bash
   python -m venv venv
   pip install -r requirements.txt
   ```

2. Configurar banco PostgreSQL (opcional — necessário para salvar resultados):
   - Criar banco `otimizacao`
   - Executar `sql/001_criar_schema.sql`
   - Criar arquivo `.env` com a connection string

3. Executar notebooks na ordem:
   - **Sprint 1:** `a_preparacao_dados` → `b_analise_exploratoria` → `clusters/` → `d_comparacao_versoes` → `e_analise_temporal_regimes`
   - **Sprint 2:** `a_carimbamento_preditor` → `b_preparacao_modelagem` → `c_treinamento_modelos`
   - **Sprint 3:** `a_validacao_cruzada` → `b_visualizacoes_finais` → `c_resultados_finais`
