# Identificação de Regimes Operacionais em Moagem Industrial

**Projeto Aplicado** — Pós-Graduação em Ciência de Dados e Machine Learning (XP Educação)

**Aluno:** Tarcizo Junior
**Orientador:** Prof. Marcos Prochnow
**Data:** Março/2026

---

## Objetivo

Desenvolver um sistema de identificação automática de regimes operacionais em um moinho de bolas industrial, utilizando técnicas de aprendizado de máquina supervisionado e não-supervisionado.

## Dados

- **Fonte:** Sistema de automação (PI System) de planta de mineração de ouro
- **Volume:** ~830.000 registros, 27 variáveis de processo, frequência de 1 minuto
- **Período:** Agosto/2024 a Março/2026 (577 dias)
- **Observação:** Os dados brutos não estão incluídos neste repositório por questões de confidencialidade e tamanho

## Metodologia

O projeto segue a metodologia **Design Thinking** aplicada a Machine Learning, organizado em 3 sprints semanais:

| Sprint | Objetivo | Status |
|--------|----------|--------|
| Sprint 1 | Preparação dos dados + EDA + Clustering | ✅ Concluída |
| Sprint 2 | Comparação com dureza + Classificador supervisionado | 🔲 Pendente |
| Sprint 3 | Validação cruzada + Resultados finais | 🔲 Pendente |

## Sprint 1 — Resultados

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

## Estrutura do Repositório

```
├── doc/                          # Documentação do projeto
│   └── PLANO_PROJETO_APLICADO.md # Plano de desenvolvimento (versão 4.0)
│
├── Relatorio_Projeto/            # Relatório acadêmico (versões progressivas)
│   ├── Canvas do Projeto Aplicado - Preenchido.pptx
│   ├── Cronograma_Acoes_Planejadas.xlsx
│   ├── Relatorio_Projeto_Aplicado_v1.docx
│   ├── Relatorio_Projeto_Aplicado_v2.docx
│   └── Relatorio_Projeto_Aplicado_v3.docx
│
├── notebooks/
│   └── 01_sprint1/
│       ├── a_preparacao_dados.ipynb       # Limpeza, tratamento, outliers
│       ├── b_analise_exploratoria.ipynb   # Estatísticas, distribuições, correlações
│       ├── d_comparacao_versoes.ipynb     # Comparação V1 × V2 × V3
│       ├── e_analise_temporal_regimes.ipynb # Markov, permanência, padrões
│       └── clusters/
│           ├── c_clustering_regimes_v1.ipynb  # Pipeline V1 (baseline)
│           ├── c_clustering_regimes_v2.ipynb  # Pipeline V2 (selecionada)
│           └── c_clustering_regimes_v3.ipynb  # Pipeline V3 (experimental)
│
├── figures/
│   └── 01_sprint1/               # Gráficos gerados (150 dpi)
│       ├── S1a_*.png             # Preparação de dados
│       ├── S1b_*.png             # Análise exploratória
│       ├── S1d_*.png             # Comparação de versões
│       ├── S1e_*.png             # Análise temporal
│       ├── clustering_v1/        # Figuras do clustering V1
│       ├── clustering_v2/        # Figuras do clustering V2
│       └── clustering_v3/        # Figuras do clustering V3
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

3. Executar notebooks na ordem: `a_preparacao_dados` → `b_analise_exploratoria` → `clusters/` → `d_comparacao_versoes` → `e_analise_temporal_regimes`
