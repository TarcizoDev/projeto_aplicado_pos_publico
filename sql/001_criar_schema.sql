-- ==============================================================================
-- 001_criar_schema.sql
-- Schema: otimizar_moagem_aura
-- Estrutura alinhada ao PLANO_PROJETO_APLICADO.md
-- ==============================================================================
-- Notebooks do plano:
--   Sprint 1: a_preparacao_dados | b_analise_exploratoria | clusters/ (v1, v2, v3)
--   Sprint 2: a_carimbamento     | b_preparacao_modelagem | c_treinamento | d_selecao
--   Sprint 3: a_validacao        | b_visualizacoes        | c_resultados
-- ==============================================================================
-- Cada execução sobrepõe dados anteriores (TRUNCATE + INSERT, sem run_id)
-- Dados inseridos na mesma estrutura do DataFrame (sem rotacionar)
-- ==============================================================================

CREATE SCHEMA IF NOT EXISTS otimizar_moagem_aura;

-- ==============================================================================
-- TABELAS DE DADOS (preservam estrutura original do DataFrame)
-- 27 variáveis de processo + Timestamp (fonte: dados_unificados.parquet)
-- ==============================================================================

-- Dados brutos carregados do parquet (Sprint 1a - inspeção)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.dados_brutos (
    id                  BIGSERIAL PRIMARY KEY,
    "Timestamp"         TIMESTAMP NOT NULL,
    "1010_BRITAGEM _ SL01 _ NÍVEL_pipoint"                  DOUBLE PRECISION,
    "1025_RETOMADA_SL01_NIVEL_pipoint"                       DOUBLE PRECISION,
    "1025_RETOMADA _ AL01 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL02 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL03 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ BALANÇA_pipoint"                 DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ CORRENTE_pipoint"                DOUBLE PRECISION,
    "1030_MOAGEM _ CX01 _ NÍVEL_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ DENSIDADE_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ VAZÃO_pipoint"            DOUBLE PRECISION,
    "1030_MOAGEM _ HC _ PRESSÃO_pipoint"                     DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALENTRADA _ PRESSÃO_pipoint"      DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALSAÍDA _ PRESSÃO_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ MO01ÁGUADESCARGAMOINHO _ VAZÃO_pipoint"   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01_VAZAO_pipoint"                       DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ CORRENTE_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ OUVIDOELETRÔNICO_pipoint"          DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ POTÊNCIA_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ ROTAÇÃO_pipoint"                   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ TORQUE_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ TR01 _ TRANSMISSORDEPESO_pipoint"         DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01ALIMENTAÇÃOCIL _ VAZÃO_pipoint" DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PH_pipoint"                  DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PRESSÃOSAÍDA_pipoint"        DOUBLE PRECISION,
    "1065_DETOX _ CX01 _ NÍVEL_pipoint"                     DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ01 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ02 _ NÍVEL_pipoint"              DOUBLE PRECISION
);

-- Dados limpos após preparação (Sprint 1a - saída final)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.dados_limpos (
    id                  BIGSERIAL PRIMARY KEY,
    "Timestamp"         TIMESTAMP NOT NULL,
    "1010_BRITAGEM _ SL01 _ NÍVEL_pipoint"                  DOUBLE PRECISION,
    "1025_RETOMADA_SL01_NIVEL_pipoint"                       DOUBLE PRECISION,
    "1025_RETOMADA _ AL01 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL02 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL03 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ BALANÇA_pipoint"                 DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ CORRENTE_pipoint"                DOUBLE PRECISION,
    "1030_MOAGEM _ CX01 _ NÍVEL_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ DENSIDADE_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ VAZÃO_pipoint"            DOUBLE PRECISION,
    "1030_MOAGEM _ HC _ PRESSÃO_pipoint"                     DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALENTRADA _ PRESSÃO_pipoint"      DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALSAÍDA _ PRESSÃO_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ MO01ÁGUADESCARGAMOINHO _ VAZÃO_pipoint"   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01_VAZAO_pipoint"                       DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ CORRENTE_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ OUVIDOELETRÔNICO_pipoint"          DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ POTÊNCIA_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ ROTAÇÃO_pipoint"                   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ TORQUE_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ TR01 _ TRANSMISSORDEPESO_pipoint"         DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01ALIMENTAÇÃOCIL _ VAZÃO_pipoint" DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PH_pipoint"                  DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PRESSÃOSAÍDA_pipoint"        DOUBLE PRECISION,
    "1065_DETOX _ CX01 _ NÍVEL_pipoint"                     DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ01 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ02 _ NÍVEL_pipoint"              DOUBLE PRECISION
);

-- Dados com cluster/regime atribuído (Sprint 1c - saída)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v3_dados_com_clusters (
    id                  BIGSERIAL PRIMARY KEY,
    "Timestamp"         TIMESTAMP NOT NULL,
    "1010_BRITAGEM _ SL01 _ NÍVEL_pipoint"                  DOUBLE PRECISION,
    "1025_RETOMADA_SL01_NIVEL_pipoint"                       DOUBLE PRECISION,
    "1025_RETOMADA _ AL01 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL02 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL03 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ BALANÇA_pipoint"                 DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ CORRENTE_pipoint"                DOUBLE PRECISION,
    "1030_MOAGEM _ CX01 _ NÍVEL_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ DENSIDADE_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ VAZÃO_pipoint"            DOUBLE PRECISION,
    "1030_MOAGEM _ HC _ PRESSÃO_pipoint"                     DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALENTRADA _ PRESSÃO_pipoint"      DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALSAÍDA _ PRESSÃO_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ MO01ÁGUADESCARGAMOINHO _ VAZÃO_pipoint"   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01_VAZAO_pipoint"                       DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ CORRENTE_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ OUVIDOELETRÔNICO_pipoint"          DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ POTÊNCIA_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ ROTAÇÃO_pipoint"                   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ TORQUE_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ TR01 _ TRANSMISSORDEPESO_pipoint"         DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01ALIMENTAÇÃOCIL _ VAZÃO_pipoint" DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PH_pipoint"                  DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PRESSÃOSAÍDA_pipoint"        DOUBLE PRECISION,
    "1065_DETOX _ CX01 _ NÍVEL_pipoint"                     DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ01 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ02 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    regime              INTEGER
);

-- Dados rotulados com classe SAG (Sprint 2a - saída)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.dados_rotulados (
    id                  BIGSERIAL PRIMARY KEY,
    "Timestamp"         TIMESTAMP NOT NULL,
    "1010_BRITAGEM _ SL01 _ NÍVEL_pipoint"                  DOUBLE PRECISION,
    "1025_RETOMADA_SL01_NIVEL_pipoint"                       DOUBLE PRECISION,
    "1025_RETOMADA _ AL01 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL02 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL03 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ BALANÇA_pipoint"                 DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ CORRENTE_pipoint"                DOUBLE PRECISION,
    "1030_MOAGEM _ CX01 _ NÍVEL_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ DENSIDADE_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ VAZÃO_pipoint"            DOUBLE PRECISION,
    "1030_MOAGEM _ HC _ PRESSÃO_pipoint"                     DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALENTRADA _ PRESSÃO_pipoint"      DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALSAÍDA _ PRESSÃO_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ MO01ÁGUADESCARGAMOINHO _ VAZÃO_pipoint"   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01_VAZAO_pipoint"                       DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ CORRENTE_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ OUVIDOELETRÔNICO_pipoint"          DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ POTÊNCIA_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ ROTAÇÃO_pipoint"                   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ TORQUE_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ TR01 _ TRANSMISSORDEPESO_pipoint"         DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01ALIMENTAÇÃOCIL _ VAZÃO_pipoint" DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PH_pipoint"                  DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PRESSÃOSAÍDA_pipoint"        DOUBLE PRECISION,
    "1065_DETOX _ CX01 _ NÍVEL_pipoint"                     DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ01 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ02 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    regime              INTEGER,
    classe_sag          INTEGER,
    energia_especifica  DOUBLE PRECISION,
    is_stable           BOOLEAN
);

-- ==============================================================================
-- SPRINT 1a — PREPARAÇÃO DOS DADOS (a_preparacao_dados.ipynb)
-- ==============================================================================

-- Resumo geral da extração
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_resumo_extracao (
    id              SERIAL PRIMARY KEY,
    total_rows      INTEGER,
    total_vars      INTEGER,
    periodo_inicio  TIMESTAMP,
    periodo_fim     TIMESTAMP,
    arquivo_origem  VARCHAR(255)
);

-- Contagem de valores negativos por variável
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_resumo_negativos (
    id                  SERIAL PRIMARY KEY,
    variavel            VARCHAR(255),
    contagem_negativos  INTEGER,
    percentual          DOUBLE PRECISION
);

-- Contagem de valores ausentes por variável
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_resumo_ausentes (
    id              SERIAL PRIMARY KEY,
    variavel        VARCHAR(255),
    total_registros INTEGER,
    ausentes        INTEGER,
    percentual      DOUBLE PRECISION
);

-- Gaps contínuos de dados ausentes
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_gaps_ausentes (
    id              SERIAL PRIMARY KEY,
    variavel        VARCHAR(255),
    gap_inicio      TIMESTAMP,
    gap_fim         TIMESTAMP,
    duracao_minutos INTEGER
);

-- Resumo de registros removidos por etapa de limpeza
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_resumo_limpeza (
    id              SERIAL PRIMARY KEY,
    etapa           VARCHAR(100),
    descricao       TEXT,
    rows_antes      INTEGER,
    rows_depois     INTEGER,
    rows_removidas  INTEGER,
    percentual      DOUBLE PRECISION
);

-- Exclusões temporais aplicadas (paradas, partidas, eventos)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_exclusoes_temporais (
    id              SERIAL PRIMARY KEY,
    inicio          TIMESTAMP,
    fim             TIMESTAMP,
    motivo          VARCHAR(255),
    rows_removidas  INTEGER
);

-- Comparação estatística antes/depois da limpeza
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_comparacao_estatisticas (
    id              SERIAL PRIMARY KEY,
    variavel        VARCHAR(255),
    estatistica     VARCHAR(50),
    valor_antes     DOUBLE PRECISION,
    valor_depois    DOUBLE PRECISION
);

-- Log de detecção e remoção de outliers
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1a_log_outliers (
    id                  SERIAL PRIMARY KEY,
    variavel            VARCHAR(255),
    tecnica             VARCHAR(50),
    limite_inferior     DOUBLE PRECISION,
    limite_superior     DOUBLE PRECISION,
    outliers_detectados INTEGER,
    percentual_removido DOUBLE PRECISION
);

-- ==============================================================================
-- SPRINT 1b — ANÁLISE EXPLORATÓRIA (b_analise_exploratoria.ipynb)
-- ==============================================================================

-- Estatísticas descritivas por variável
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1b_estatisticas_descritivas (
    id          SERIAL PRIMARY KEY,
    variavel    VARCHAR(255),
    estatistica VARCHAR(50),
    valor       DOUBLE PRECISION
);

-- Matriz de correlação
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1b_matriz_correlacao (
    id      SERIAL PRIMARY KEY,
    var_x   VARCHAR(255),
    var_y   VARCHAR(255),
    valor   DOUBLE PRECISION,
    metodo  VARCHAR(20)
);

-- Dados pré-computados para gráficos nativos (JSONB)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1b_chart_data (
    id          SERIAL PRIMARY KEY,
    chart_type  VARCHAR(50) UNIQUE NOT NULL,
    chart_data  JSONB NOT NULL
);

-- ==============================================================================
-- SPRINT 1c — CLUSTERING (clusters/c_clustering_regimes_v3.ipynb)
-- ==============================================================================

-- Métricas de validação dos algoritmos de clustering
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v3_metricas_clustering (
    id              SERIAL PRIMARY KEY,
    algoritmo       VARCHAR(50),
    n_clusters      INTEGER,
    silhouette      DOUBLE PRECISION,
    davies_bouldin  DOUBLE PRECISION,
    calinski_harabasz DOUBLE PRECISION,
    inertia         DOUBLE PRECISION,
    bic             DOUBLE PRECISION,
    selecionado     BOOLEAN DEFAULT FALSE
);

-- Caracterização dos regimes/clusters identificados
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v3_regimes (
    id          SERIAL PRIMARY KEY,
    regime      INTEGER,
    n_samples   INTEGER,
    percentual  DOUBLE PRECISION,
    tph_medio   DOUBLE PRECISION,
    tph_std     DOUBLE PRECISION
);

-- Centróides dos regimes por variável
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v3_regime_centroides (
    id              SERIAL PRIMARY KEY,
    regime          INTEGER,
    variavel        VARCHAR(255),
    valor_centroide DOUBLE PRECISION
);

-- ==============================================================================
-- SPRINT 1c — CLUSTERING v1 e v2 (notebooks/01_sprint1/clusters/)
-- ==============================================================================

-- v1: Métricas de validação
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v1_metricas_clustering (
    id              SERIAL PRIMARY KEY,
    algoritmo       VARCHAR(50),
    n_clusters      INTEGER,
    silhouette      DOUBLE PRECISION,
    davies_bouldin  DOUBLE PRECISION,
    calinski_harabasz DOUBLE PRECISION,
    inertia         DOUBLE PRECISION,
    bic             DOUBLE PRECISION,
    selecionado     BOOLEAN DEFAULT FALSE
);

-- v1: Caracterização dos regimes
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v1_regimes (
    id          SERIAL PRIMARY KEY,
    regime      INTEGER,
    n_samples   INTEGER,
    percentual  DOUBLE PRECISION,
    tph_medio   DOUBLE PRECISION,
    tph_std     DOUBLE PRECISION
);

-- v1: Centróides por variável
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v1_regime_centroides (
    id              SERIAL PRIMARY KEY,
    regime          INTEGER,
    variavel        VARCHAR(255),
    valor_centroide DOUBLE PRECISION
);

-- v2: Métricas de validação
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v2_metricas_clustering (
    id              SERIAL PRIMARY KEY,
    algoritmo       VARCHAR(50),
    n_clusters      INTEGER,
    silhouette      DOUBLE PRECISION,
    davies_bouldin  DOUBLE PRECISION,
    calinski_harabasz DOUBLE PRECISION,
    inertia         DOUBLE PRECISION,
    bic             DOUBLE PRECISION,
    selecionado     BOOLEAN DEFAULT FALSE
);

-- v2: Caracterização dos regimes
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v2_regimes (
    id          SERIAL PRIMARY KEY,
    regime      INTEGER,
    n_samples   INTEGER,
    percentual  DOUBLE PRECISION,
    tph_medio   DOUBLE PRECISION,
    tph_std     DOUBLE PRECISION
);

-- v2: Centróides por variável
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v2_regime_centroides (
    id              SERIAL PRIMARY KEY,
    regime          INTEGER,
    variavel        VARCHAR(255),
    valor_centroide DOUBLE PRECISION
);

-- v1: Dataset completo com clusters (26 pipoint + regime)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v1_dados_com_clusters (
    id                  BIGSERIAL PRIMARY KEY,
    "Timestamp"         TIMESTAMP NOT NULL,
    "1010_BRITAGEM _ SL01 _ NÍVEL_pipoint"                  DOUBLE PRECISION,
    "1025_RETOMADA _ AL01 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL02 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL03 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ BALANÇA_pipoint"                 DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ CORRENTE_pipoint"                DOUBLE PRECISION,
    "1030_MOAGEM _ CX01 _ NÍVEL_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ DENSIDADE_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ VAZÃO_pipoint"            DOUBLE PRECISION,
    "1030_MOAGEM _ HC _ PRESSÃO_pipoint"                     DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALENTRADA _ PRESSÃO_pipoint"      DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALSAÍDA _ PRESSÃO_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ MO01ÁGUADESCARGAMOINHO _ VAZÃO_pipoint"   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01_VAZAO_pipoint"                       DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ CORRENTE_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ OUVIDOELETRÔNICO_pipoint"          DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ POTÊNCIA_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ ROTAÇÃO_pipoint"                   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ TORQUE_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ TR01 _ TRANSMISSORDEPESO_pipoint"         DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01ALIMENTAÇÃOCIL _ VAZÃO_pipoint" DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PH_pipoint"                  DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PRESSÃOSAÍDA_pipoint"        DOUBLE PRECISION,
    "1065_DETOX _ CX01 _ NÍVEL_pipoint"                     DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ01 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ02 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    regime              INTEGER
);

-- v2: Dataset completo com clusters (pipoint curados + regime)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1c_v2_dados_com_clusters (
    id                  BIGSERIAL PRIMARY KEY,
    "Timestamp"         TIMESTAMP NOT NULL,
    "1010_BRITAGEM _ SL01 _ NÍVEL_pipoint"                  DOUBLE PRECISION,
    "1025_RETOMADA _ AL01 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL02 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ AL03 _ SETPOINT_pipoint"               DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ BALANÇA_pipoint"                 DOUBLE PRECISION,
    "1025_RETOMADA _ TR02 _ CORRENTE_pipoint"                DOUBLE PRECISION,
    "1030_MOAGEM _ CX01 _ NÍVEL_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ DENSIDADE_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ HCALIMENTAÇÃO _ VAZÃO_pipoint"            DOUBLE PRECISION,
    "1030_MOAGEM _ HC _ PRESSÃO_pipoint"                     DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALENTRADA _ PRESSÃO_pipoint"      DOUBLE PRECISION,
    "1030_MOAGEM _ MO01MANCALSAÍDA _ PRESSÃO_pipoint"        DOUBLE PRECISION,
    "1030_MOAGEM _ MO01ÁGUADESCARGAMOINHO _ VAZÃO_pipoint"   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01_VAZAO_pipoint"                       DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ CORRENTE_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ OUVIDOELETRÔNICO_pipoint"          DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ POTÊNCIA_pipoint"                  DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ ROTAÇÃO_pipoint"                   DOUBLE PRECISION,
    "1030_MOAGEM _ MO01 _ TORQUE_pipoint"                    DOUBLE PRECISION,
    "1030_MOAGEM _ TR01 _ TRANSMISSORDEPESO_pipoint"         DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01ALIMENTAÇÃOCIL _ VAZÃO_pipoint" DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PH_pipoint"                  DOUBLE PRECISION,
    "1035_ESPESSAMENTO _ EP01 _ PRESSÃOSAÍDA_pipoint"        DOUBLE PRECISION,
    "1065_DETOX _ CX01 _ NÍVEL_pipoint"                     DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ01 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    "2020_SISTEMADEÁGUA _ TQ02 _ NÍVEL_pipoint"              DOUBLE PRECISION,
    regime              INTEGER
);

-- ==============================================================================
-- SPRINT 1e — ANÁLISE TEMPORAL (e_analise_temporal_regimes.ipynb)
-- ==============================================================================

-- Estatísticas de permanência por regime (duração dos blocos)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1e_permanencia_regimes (
    id                      SERIAL PRIMARY KEY,
    regime                  INTEGER,
    nome                    VARCHAR(50),
    n_blocos                INTEGER,
    duracao_min_min         DOUBLE PRECISION,
    duracao_mediana_min     DOUBLE PRECISION,
    duracao_media_min       DOUBLE PRECISION,
    duracao_max_min         DOUBLE PRECISION,
    duracao_media_h         DOUBLE PRECISION,
    duracao_max_h           DOUBLE PRECISION,
    pct_blocos_curtos_5min  DOUBLE PRECISION,
    pct_blocos_longos_1h    DOUBLE PRECISION
);

-- Matriz de transição (probabilidade de mudança entre regimes)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1e_matriz_transicao (
    id          SERIAL PRIMARY KEY,
    regime_de   VARCHAR(50),
    regime_para VARCHAR(50),
    probabilidade DOUBLE PRECISION
);

-- Proporção mensal de cada regime
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1e_distribuicao_mensal (
    id          SERIAL PRIMARY KEY,
    mes         VARCHAR(10),
    regime      INTEGER,
    percentual  DOUBLE PRECISION
);

-- Taxa de transição mensal (transições por hora)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1e_taxa_transicao (
    id              SERIAL PRIMARY KEY,
    mes             VARCHAR(10),
    transicoes_hora DOUBLE PRECISION
);

-- Blocos contíguos de regime (runs)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s1e_blocos_regime (
    id              SERIAL PRIMARY KEY,
    bloco_id        INTEGER,
    regime          INTEGER,
    inicio          TIMESTAMP,
    fim             TIMESTAMP,
    duracao_min     INTEGER,
    duracao_h       DOUBLE PRECISION
);

-- ==============================================================================
-- SPRINT 2a — CARIMBAMENTO (a_carimbamento_preditor.ipynb)
-- ==============================================================================

-- Resumo do carimbamento (distribuição de classes, estabilidade)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s2a_resumo_carimbamento (
    id                  SERIAL PRIMARY KEY,
    classe_sag          INTEGER,
    n_registros         INTEGER,
    percentual          DOUBLE PRECISION,
    n_estaveis          INTEGER,
    pct_estaveis        DOUBLE PRECISION
);

-- Comparação clusters vs classes SAG
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s2a_comparacao_clusters_classes (
    id              SERIAL PRIMARY KEY,
    metrica         VARCHAR(50),
    valor           DOUBLE PRECISION
);

-- ==============================================================================
-- SPRINT 2b — PREPARAÇÃO PARA MODELAGEM (b_preparacao_modelagem.ipynb)
-- ==============================================================================

-- Lista de features engenheiradas
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s2b_features (
    id          SERIAL PRIMARY KEY,
    feature     VARCHAR(255),
    ranking     INTEGER
);

-- Metadados do split temporal
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s2b_split_metadata (
    id              SERIAL PRIMARY KEY,
    conjunto        VARCHAR(20),
    n_registros     INTEGER,
    periodo_inicio  TIMESTAMP,
    periodo_fim     TIMESTAMP,
    pct_total       DOUBLE PRECISION
);

-- ==============================================================================
-- SPRINT 2c/d — TREINAMENTO E SELEÇÃO DE MODELOS
-- ==============================================================================

-- Resultados comparativos dos modelos treinados
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s2_resultados_modelos (
    id          SERIAL PRIMARY KEY,
    modelo      VARCHAR(50),
    conjunto    VARCHAR(20),
    metrica     VARCHAR(50),
    valor       DOUBLE PRECISION
);

-- Importância de features por modelo (SHAP / feature_importance)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s2_importancia_features (
    id          SERIAL PRIMARY KEY,
    modelo      VARCHAR(50),
    feature     VARCHAR(255),
    importancia DOUBLE PRECISION,
    ranking     INTEGER
);

-- ==============================================================================
-- SPRINT 3 — VALIDAÇÃO E RESULTADOS
-- ==============================================================================

-- Validação temporal (accuracy rolling por semana)
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s3_validacao_temporal (
    id              SERIAL PRIMARY KEY,
    periodo_inicio  TIMESTAMP,
    periodo_fim     TIMESTAMP,
    accuracy        DOUBLE PRECISION,
    f1_macro        DOUBLE PRECISION,
    n_registros     INTEGER
);

-- Resultados finais consolidados
CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.s3_resultados_finais (
    id      SERIAL PRIMARY KEY,
    aspecto VARCHAR(100),
    valor   VARCHAR(255)
);

-- ==============================================================================
-- TABELA COMPARTILHADA — IMAGENS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS otimizar_moagem_aura.stage_images (
    id          SERIAL PRIMARY KEY,
    stage       VARCHAR(10),
    image_key   VARCHAR(100),
    filename    VARCHAR(255),
    image_data  BYTEA,
    mime_type   VARCHAR(50),
    created_at  TIMESTAMP DEFAULT NOW()
);

-- ==============================================================================
-- ÍNDICES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_brutos_ts ON otimizar_moagem_aura.dados_brutos ("Timestamp");
CREATE INDEX IF NOT EXISTS idx_limpos_ts ON otimizar_moagem_aura.dados_limpos ("Timestamp");
CREATE INDEX IF NOT EXISTS idx_clusters_ts ON otimizar_moagem_aura.s1c_v3_dados_com_clusters ("Timestamp");
CREATE INDEX IF NOT EXISTS idx_clusters_regime ON otimizar_moagem_aura.s1c_v3_dados_com_clusters (regime);
CREATE INDEX IF NOT EXISTS idx_rotulados_ts ON otimizar_moagem_aura.dados_rotulados ("Timestamp");
CREATE INDEX IF NOT EXISTS idx_rotulados_classe ON otimizar_moagem_aura.dados_rotulados (classe_sag);
CREATE INDEX IF NOT EXISTS idx_images_stage_key ON otimizar_moagem_aura.stage_images (stage, image_key);
