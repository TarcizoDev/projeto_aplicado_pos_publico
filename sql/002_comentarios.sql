-- ==============================================================================
-- 002_comentarios.sql
-- Comentários descritivos para schema, tabelas e colunas
-- Objetivo: documentação no pgAdmin para rastreabilidade e auditoria
-- ==============================================================================

-- ── SCHEMA ──
COMMENT ON SCHEMA otimizar_moagem_aura IS
'Projeto Aplicado — Identificação de Regimes Operacionais em Moagem Industrial.
Pipeline: Design Thinking + ML (clustering + classificação supervisionada).
Dados: 27 variáveis de processo, intervalo 1min, ago/2024 a mar/2026.
Cada execução sobrepõe dados anteriores (TRUNCATE + INSERT, sem run_id).';

-- ==============================================================================
-- TABELAS DE DADOS PRINCIPAIS
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.dados_brutos IS
'Dados brutos extraídos do PI System (parquet). 27 variáveis de processo + Timestamp.
Origem: data/raw/Dados_brutos_1m.parquet (~830k linhas, intervalo 1min).
Notebook: 01_sprint1/a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.dados_limpos IS
'Dados após pipeline de limpeza (S1a): remoção de negativos, NaN, outliers, paradas.
26 variáveis (removida 1025_RETOMADA_SL01_NIVEL por 59%% NaN). 632.985 registros.
Origem: notebook a_preparacao_dados.ipynb → dataset_limpo.parquet';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v3_dados_com_clusters IS
'Dataset COMPLETO usado no clustering v3, incluindo features derivadas (FEAT_) e regime atribuído.
Colunas: variáveis de processo (_pipoint) + FEAT_energia_especifica, FEAT_razao_torque_potencia,
FEAT_tph_mm5, FEAT_tph_std5, FEAT_pot_mm5 + regime (0=Moderado, 1=Alta Carga, 2=Instável).
Tabela canônica consumida pelo notebook d_analise_temporal e pelo dashboard.
Origem: notebook clusters/c_clustering_regimes_v3.ipynb. Schema dinâmico (modo replace).';

COMMENT ON TABLE otimizar_moagem_aura.dados_rotulados IS
'Dataset com regime do clustering + classe SAG (dureza) + energia específica + flag estabilidade.
Usado como entrada para a modelagem supervisionada (Sprint 2).
Colunas extras: regime (int), classe_sag (int, 1-6), energia_especifica (float), is_stable (bool).
Origem: notebook a_carimbamento_preditor.ipynb (S2a) → dataset_rotulado.parquet';

-- ==============================================================================
-- S1a — PREPARAÇÃO DOS DADOS
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s1a_resumo_extracao IS
'Resumo geral da extração dos dados brutos: total de linhas, variáveis, período e arquivo de origem.
Origem: a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.s1a_resumo_negativos IS
'Contagem de valores negativos por variável de processo (antes da limpeza).
Origem: a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.s1a_resumo_ausentes IS
'Contagem e percentual de valores ausentes (NaN) por variável.
Origem: a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.s1a_gaps_ausentes IS
'Gaps contínuos de dados ausentes: início, fim e duração em minutos por variável.
Origem: a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.s1a_exclusoes_temporais IS
'Períodos excluídos da análise (paradas programadas, partidas, eventos anômalos).
Campos: início, fim, motivo, rows removidas.
Origem: a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.s1a_resumo_limpeza IS
'Funil de limpeza: cada etapa do pipeline com rows antes, depois e removidas.
Permite auditar a perda de dados em cada passo.
Origem: a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.s1a_log_outliers IS
'Log de detecção de outliers: variável, técnica usada, limites inferior/superior,
quantidade detectada e percentual removido.
Origem: a_preparacao_dados.ipynb (S1a)';

COMMENT ON TABLE otimizar_moagem_aura.s1a_comparacao_estatisticas IS
'Comparação estatística (mean, std, min, max, etc.) antes e depois da limpeza por variável.
Permite verificar se a limpeza introduziu viés nos dados.
Origem: a_preparacao_dados.ipynb (S1a)';

-- ==============================================================================
-- S1b — ANÁLISE EXPLORATÓRIA
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s1b_estatisticas_descritivas IS
'Estatísticas descritivas das 26 variáveis de processo em formato long (variavel, estatistica, valor).
Inclui: count, mean, std, min, 25%%, 50%%, 75%%, max.
Origem: b_analise_exploratoria.ipynb (S1b)';

COMMENT ON TABLE otimizar_moagem_aura.s1b_matriz_correlacao IS
'Matriz de correlação entre variáveis em formato long (var_x, var_y, valor, metodo).
Métodos: Pearson e Spearman. Usada para identificar colinearidade.
Origem: b_analise_exploratoria.ipynb (S1b)';

COMMENT ON TABLE otimizar_moagem_aura.s1b_chart_data IS
'Dados pré-computados para gráficos do dashboard React (formato JSONB).
Chaves: histograms, boxplots, corr_pearson, corr_spearman, timeseries, energia_especifica, scatter_tph_potencia.
Origem: b_analise_exploratoria.ipynb (S1b)';

-- ==============================================================================
-- S1c — CLUSTERING DE REGIMES (v3 — versão atual)
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s1c_v3_metricas_clustering IS
'Métricas de validação dos algoritmos de clustering v3: KMeans (k=2..8), GMM (k=2..8), DBSCAN (sweep eps×min_samples).
Campos: algoritmo, n_clusters, silhouette, davies_bouldin, calinski_harabasz, inertia, bic, selecionado.
Origem: clusters/c_clustering_regimes_v3.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v3_todos_testes IS
'Log completo de TODOS os testes de clustering v3: cada KMeans k, cada GMM k e DBSCAN.
Campos: algoritmo, n_clusters, silhouette, davies_bouldin, calinski_harabasz, inertia, bic, selecionado.
Truncado e recriado a cada execução. Origem: clusters/c_clustering_regimes_v3.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v3_regimes IS
'Caracterização dos 3 regimes identificados: 0=Moderado, 1=Alta Carga, 2=Instável.
Campos: regime, n_samples, percentual, tph_medio, tph_std.
Origem: clusters/c_clustering_regimes_v3.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v3_regime_centroides IS
'Centróides dos regimes por variável de processo (formato long: regime, variavel, valor_centroide).
Permite reconstruir o perfil de cada regime.
Origem: clusters/c_clustering_regimes_v3.ipynb';

-- ==============================================================================
-- S1c — CLUSTERING VERSÕES ANTERIORES (v1 e v2 — rastreabilidade)
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s1c_v1_metricas_clustering IS
'Métricas de clustering v1 (baseline): StandardScaler, 26 variáveis, sem filtro de operação estável.
DBSCAN com sweep eps×min_samples. Mesmo grid de algoritmos que v2/v3 para comparação justa.
Origem: 01_sprint1/clusters/c_clustering_regimes_v1.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v1_todos_testes IS
'Log completo de TODOS os testes de clustering v1: cada KMeans k, cada GMM k e todas as 44 combinações DBSCAN (eps×min_samples).
Campos: algoritmo, n_clusters, silhouette, davies_bouldin, calinski_harabasz, inertia, bic, eps, min_samples, pct_noise, selecionado.
Truncado e recriado a cada execução. Origem: 01_sprint1/clusters/c_clustering_regimes_v1.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v1_regimes IS
'Regimes identificados na v1 (baseline). Origem: 01_sprint1/clusters/c_clustering_regimes_v1.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v1_regime_centroides IS
'Centróides dos regimes v1 por variável. Origem: 01_sprint1/clusters/c_clustering_regimes_v1.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v1_dados_com_clusters IS
'Dataset completo v1 com clusters atribuídos (27 variáveis pipoint + Timestamp + regime). 632.985 linhas.
Baseline: StandardScaler, sem filtro de operação estável.
Origem: 01_sprint1/clusters/c_clustering_regimes_v1.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v2_metricas_clustering IS
'Métricas de clustering v2: RobustScaler, ~16 variáveis curadas, Hampel filter, remoção de colinearidade.
DBSCAN com sweep eps×min_samples. Origem: 01_sprint1/clusters/c_clustering_regimes_v2.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v2_todos_testes IS
'Log completo de TODOS os testes de clustering v2: cada KMeans k, cada GMM k e todas as 44 combinações DBSCAN (eps×min_samples).
Campos: algoritmo, n_clusters, silhouette, davies_bouldin, calinski_harabasz, inertia, bic, eps, min_samples, pct_noise, selecionado.
Truncado e recriado a cada execução. Origem: 01_sprint1/clusters/c_clustering_regimes_v2.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v2_regimes IS
'Regimes identificados na v2. Origem: 01_sprint1/clusters/c_clustering_regimes_v2.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v2_regime_centroides IS
'Centróides dos regimes v2 por variável. Origem: 01_sprint1/clusters/c_clustering_regimes_v2.ipynb';

COMMENT ON TABLE otimizar_moagem_aura.s1c_v2_dados_com_clusters IS
'Dataset completo v2 com clusters atribuídos (27 variáveis pipoint + Timestamp + regime). 632.985 linhas.
RobustScaler, ~16 variáveis curadas, Hampel filter, remoção de colinearidade.
Origem: 01_sprint1/clusters/c_clustering_regimes_v2.ipynb';

-- ==============================================================================
-- S1e — ANÁLISE TEMPORAL DOS REGIMES
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s1e_permanencia_regimes IS
'Estatísticas de permanência por regime: duração min/mediana/média/max dos blocos contíguos,
percentual de blocos curtos (<=5min) e longos (>=1h).
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_matriz_transicao IS
'Matriz de transição de Markov entre regimes (minuto a minuto).
Campos: regime_de, regime_para, probabilidade, contagem.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_distribuicao_mensal IS
'Proporção mensal de cada regime (formato long: mes, regime, percentual).
Permite identificar drift operacional ao longo do tempo.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_taxa_transicao IS
'Taxa de transição entre regimes por mês (transições/hora).
Indicador de estabilidade operacional mensal.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_blocos_regime IS
'Blocos contíguos de regime (run-length encoding): cada linha é uma sequência ininterrupta
de minutos no mesmo regime, com início, fim e duração.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

-- ==============================================================================
-- S1e — ANÁLISE TEMPORAL VERSIONADA (v1, v2, v3)
-- ==============================================================================
-- Cada versão de clustering gera 5 tabelas de análise temporal.
-- Mesma estrutura das tabelas s1e_* (sem prefixo de versão), que armazenam
-- apenas a versão selecionada (V2). Estas preservam as 3 versões para comparação.

COMMENT ON TABLE otimizar_moagem_aura.s1e_v1_blocos_regime IS
'Blocos contíguos de regime v1 (run-length encoding). 7.773 blocos.
Campos: bloco_id, regime, inicio, fim, duracao_min, duracao_h, versao.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v1_distribuicao_mensal IS
'Proporção mensal de cada regime v1 (formato long: mes, regime, percentual, versao).
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v1_matriz_transicao IS
'Matriz de transição de Markov v1 (minuto a minuto). 2 regimes → 4 transições.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v1_permanencia_regimes IS
'Estatísticas de permanência por regime v1: durações min/mediana/média/max, pct blocos curtos/longos.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v1_taxa_transicao IS
'Taxa de transição entre regimes v1 por mês (transições/hora).
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v2_blocos_regime IS
'Blocos contíguos de regime v2 (run-length encoding). 15.915 blocos.
Campos: bloco_id, regime, inicio, fim, duracao_min, duracao_h, versao.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v2_distribuicao_mensal IS
'Proporção mensal de cada regime v2 (formato long: mes, regime, percentual, versao).
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v2_matriz_transicao IS
'Matriz de transição de Markov v2 (minuto a minuto). 3 regimes → 9 transições.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v2_permanencia_regimes IS
'Estatísticas de permanência por regime v2: durações min/mediana/média/max, pct blocos curtos/longos.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v2_taxa_transicao IS
'Taxa de transição entre regimes v2 por mês (transições/hora).
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v3_blocos_regime IS
'Blocos contíguos de regime v3 (run-length encoding). 28.855 blocos.
Campos: bloco_id, regime, inicio, fim, duracao_min, duracao_h, versao.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v3_distribuicao_mensal IS
'Proporção mensal de cada regime v3 (formato long: mes, regime, percentual, versao).
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v3_matriz_transicao IS
'Matriz de transição de Markov v3 (minuto a minuto). 3 regimes → 9 transições.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v3_permanencia_regimes IS
'Estatísticas de permanência por regime v3: durações min/mediana/média/max, pct blocos curtos/longos.
Origem: e_analise_temporal_regimes.ipynb (S1e)';

COMMENT ON TABLE otimizar_moagem_aura.s1e_v3_taxa_transicao IS
'Taxa de transição entre regimes v3 por mês (transições/hora).
Origem: e_analise_temporal_regimes.ipynb (S1e)';

-- ==============================================================================
-- S2a — CARIMBAMENTO (DUREZA SAG)
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s2a_resumo_carimbamento IS
'Distribuição das 6 classes SAG (C1-C6 baseadas em energia específica).
Campos: classe_sag, n_registros, percentual, n_estaveis, pct_estaveis.
Origem: a_carimbamento_preditor.ipynb (S2a)';

COMMENT ON TABLE otimizar_moagem_aura.s2a_comparacao_clusters_classes IS
'Métricas de concordância entre regimes (clustering) e classes SAG (dureza): ARI e NMI.
Valores baixos indicam que regimes e dureza capturam dimensões diferentes do processo.
Origem: a_carimbamento_preditor.ipynb (S2a)';

COMMENT ON TABLE otimizar_moagem_aura.s2a_exp_metricas_v1 IS
'Métricas de concordância regimes vs dureza para clustering V1.
Campos: versao_clustering, n_regimes, n_registros, ari, nmi, cramers_v, chi2, p_value.
Tabela exploratória para comparação entre versões. Origem: a_carimbamento_preditor.ipynb (S2a)';

COMMENT ON TABLE otimizar_moagem_aura.s2a_exp_metricas_v2 IS
'Métricas de concordância regimes vs dureza para clustering V2 (versão selecionada).
Campos: versao_clustering, n_regimes, n_registros, ari, nmi, cramers_v, chi2, p_value.
Origem: a_carimbamento_preditor.ipynb (S2a)';

COMMENT ON TABLE otimizar_moagem_aura.s2a_exp_metricas_v3 IS
'Métricas de concordância regimes vs dureza para clustering V3.
Campos: versao_clustering, n_regimes, n_registros, ari, nmi, cramers_v, chi2, p_value.
Tabela exploratória para comparação entre versões. Origem: a_carimbamento_preditor.ipynb (S2a)';

-- ==============================================================================
-- S2b — PREPARAÇÃO PARA MODELAGEM
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s2b_features IS
'Lista das 105 features usadas na modelagem supervisionada, com ranking.
Composição: 27 originais + 24 lags + 24 médias móveis + 16 desvio padrão + 8 derivadas + 6 engenheiradas.
Origem: b_preparacao_modelagem.ipynb (S2b)';

COMMENT ON TABLE otimizar_moagem_aura.s2b_split_metadata IS
'Metadados do split temporal: conjunto (train/val/test), n_registros, período, percentual.
Split cronológico (sem shuffle): treino<set/2025, validação set-dez/2025, teste>=dez/2025.
Origem: b_preparacao_modelagem.ipynb (S2b)';

COMMENT ON TABLE otimizar_moagem_aura.s2b_v2_features IS
'Lista de features de versão anterior da preparação (exploratória). 105 features com ranking.
Campos: feature, ranking. Origem: b_preparacao_modelagem.ipynb (S2b, execução anterior)';

COMMENT ON TABLE otimizar_moagem_aura.s2b_v2_split_metadata IS
'Metadados do split temporal de versão anterior (exploratória).
Campos: conjunto, n_registros, periodo_inicio, periodo_fim, pct_total.
Origem: b_preparacao_modelagem.ipynb (S2b, execução anterior)';

COMMENT ON TABLE otimizar_moagem_aura.s2b_dataset_train IS
'Dataset de treino com 105 features + regime (443.089 linhas, ago/2024–set/2025).
27 variáveis originais + 78 engenheiradas (lags, médias móveis, desvios, derivadas).
Normalizado com RobustScaler ajustado neste conjunto. Origem: b_preparacao_modelagem.ipynb (S2b)';

COMMENT ON TABLE otimizar_moagem_aura.s2b_dataset_val IS
'Dataset de validação com 105 features + regime (94.947 linhas, set–dez/2025).
Usado para seleção de hiperparâmetros e comparação entre modelos.
Origem: b_preparacao_modelagem.ipynb (S2b)';

COMMENT ON TABLE otimizar_moagem_aura.s2b_dataset_test IS
'Dataset de teste com 105 features + regime (94.949 linhas, dez/2025–mar/2026).
Dados inéditos para avaliação final do modelo selecionado.
Origem: b_preparacao_modelagem.ipynb (S2b)';

-- ==============================================================================
-- S2c — TREINAMENTO E RESULTADOS DOS MODELOS
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s2_resultados_modelos IS
'Métricas comparativas dos 3 classificadores (Random Forest, XGBoost, LightGBM)
nos conjuntos de validação e teste. Formato long: modelo, conjunto, metrica, valor.
Métricas: Accuracy, F1-macro, F1-weighted, Precision-macro, Recall-macro, AUC-weighted.
Origem: c_treinamento_modelos.ipynb (S2c)';

COMMENT ON TABLE otimizar_moagem_aura.s2_importancia_features IS
'Ranking de importância das 105 features do melhor modelo (LightGBM).
Campos: modelo, feature, importancia, ranking.
Baseado em feature_importances_ nativa (gain).
Origem: c_treinamento_modelos.ipynb (S2c)';

COMMENT ON TABLE otimizar_moagem_aura.s2c_predicoes_teste IS
'Predições do melhor modelo (LightGBM) no conjunto de teste (94.949 linhas).
Campos: Timestamp, regime_real, regime_pred, proba_R0, proba_R1, proba_R2.
Consumido pelo dashboard para visualização de predições vs real.
Origem: c_treinamento_modelos.ipynb (S2c)';

COMMENT ON TABLE otimizar_moagem_aura.s2_comparacao_oficial_v2 IS
'Comparação oficial entre abordagens de classificação (versão anterior, exploratória).
Campos: Abordagem, Accuracy, F1-macro, F1-weighted, Precision/Recall por regime.
Origem: c_treinamento_modelos.ipynb (S2c, execução anterior)';

COMMENT ON TABLE otimizar_moagem_aura.s2c_v2_modelos_val IS
'Métricas dos 3 modelos no conjunto de validação (versão anterior, exploratória).
Campos: Modelo, Accuracy, F1-macro, F1-weighted, Precision-macro, Recall-macro, AUC-weighted, Tempo.
Origem: c_treinamento_modelos.ipynb (S2c, execução anterior)';

COMMENT ON TABLE otimizar_moagem_aura.s2c_v2_modelos_teste IS
'Métricas dos 3 modelos no conjunto de teste (versão anterior, exploratória).
Campos: Modelo, Accuracy, F1-macro, F1-weighted, Precision/Recall por regime, AUC-weighted.
Origem: c_treinamento_modelos.ipynb (S2c, execução anterior)';

COMMENT ON TABLE otimizar_moagem_aura.s2c_v2_predicoes_teste IS
'Predições do teste com pós-processamento (versão anterior, exploratória).
Campos: Timestamp, regime_real, pred_base, pred_smooth, pred_threshold, pred_combined, proba_R0/R1/R2.
Origem: c_treinamento_modelos.ipynb (S2c, execução anterior)';

COMMENT ON TABLE otimizar_moagem_aura.s2c_v2_resultados IS
'Resultados consolidados por abordagem de pós-processamento (versão anterior, exploratória).
Campos: Abordagem, Accuracy, F1-macro, F1-weighted, Precision/Recall por regime.
Origem: c_treinamento_modelos.ipynb (S2c, execução anterior)';

-- ==============================================================================
-- S3 — VALIDAÇÃO E RESULTADOS FINAIS
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.s3_validacao_temporal IS
'Validação temporal do modelo: accuracy e F1-macro em janelas semanais rolling. 13 períodos.
Campos: periodo_inicio, periodo_fim, accuracy, f1_macro, n_registros.
Verifica degradação do modelo ao longo do tempo.
Origem: Sprint 3';

COMMENT ON TABLE otimizar_moagem_aura.s3_resultados_finais IS
'Resultados finais consolidados do projeto em formato chave-valor (aspecto, valor). 12 entradas.
Origem: Sprint 3';

-- ==============================================================================
-- TABELA DE IMAGENS
-- ==============================================================================

COMMENT ON TABLE otimizar_moagem_aura.stage_images IS
'Figuras geradas por cada etapa da pipeline, armazenadas como binário PNG.
Campos: stage (S1a, S1b, S1c, S1d, S2a, ...), image_key (identificador único),
filename, image_data (BYTEA), mime_type.
Consumidas pelo dashboard React para exibição sem dependência de disco.';

-- ==============================================================================
-- VIEW — IMAGENS EM BASE64
-- ==============================================================================

COMMENT ON VIEW otimizar_moagem_aura.vw_images_base64 IS
'View que expõe as imagens de stage_images como data URIs base64 (image_url).
Campos: id, stage, image_key, filename, mime_type, created_at, tamanho_bytes, tamanho_kb, image_url.
Consumida pelo dashboard para renderização direta no frontend sem endpoint binário.';
