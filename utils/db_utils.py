"""
db_utils.py — Módulo utilitário para operações no PostgreSQL.

Funções para conectar ao banco, salvar DataFrames e imagens,
mantendo a rastreabilidade de todas as saídas da pipeline.

Uso nos notebooks:
    from db_utils import get_engine, salvar_dataframe, salvar_imagem, criar_tabelas

Cada execução sobrepõe os dados anteriores (TRUNCATE + INSERT).
Os dados são inseridos na mesma estrutura do DataFrame original (sem rotacionar).
"""

import os
from pathlib import Path
from io import BytesIO

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# ============================================================================
# Carregar variáveis de ambiente do .env na raiz do projeto
# ============================================================================
_PROJECT_ROOT = Path(__file__).resolve().parent
_env_candidates = [
    _PROJECT_ROOT / ".env",
    _PROJECT_ROOT.parent / ".env",
    Path(r"C:\ScriptsDatamindsPIP\4-Projeto aplicado\.env"),
    Path(r"G:\Meu Drive\1-Pos Graduação\4-Projeto aplicado\.env"),
]
for _env_path in _env_candidates:
    if _env_path.exists():
        load_dotenv(_env_path)
        break

# Configuração do banco lida do .env
DB_HOST = os.getenv("HOST_POSTGRE")
DB_PORT = os.getenv("PORTA_POSTGRE", "5432")
DB_NAME = os.getenv("BANCO_POSTGRE")
DB_USER = os.getenv("USUARIO_POSTGRE")
DB_PASS = os.getenv("SENHA_POSTGRE")
DB_SCHEMA = os.getenv("DB_SCHEMA", "otimizar_moagem_aura")

# Fonte de dados: "banco" ou "local"
DATA_SOURCE = os.getenv("DATA_SOURCE", "banco")

# Caminho do SQL de criação de tabelas
_SQL_DIR = Path(r"C:\ScriptsDatamindsPIP\4-Projeto aplicado\sql")


def get_engine():
    """
    Cria e retorna uma engine SQLAlchemy conectada ao PostgreSQL.

    Returns:
        sqlalchemy.Engine: engine de conexão
    """
    url = f"postgresql+psycopg://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    return create_engine(url, pool_pre_ping=True, pool_size=5)


def criar_tabelas(schema: str = None) -> None:
    """
    Cria o schema e todas as tabelas definidas em sql/001_criar_schema.sql.

    Idempotente: usa CREATE TABLE IF NOT EXISTS, pode ser executado várias vezes
    sem erro. Cada notebook deve chamar esta função no início para garantir que
    as tabelas existam antes de inserir dados.

    Args:
        schema: schema do banco (default: DB_SCHEMA do .env)
    """
    import psycopg

    schema = schema or DB_SCHEMA
    sql_file = _SQL_DIR / "001_criar_schema.sql"

    if not sql_file.exists():
        raise FileNotFoundError(f"Arquivo SQL não encontrado: {sql_file}")

    sql_content = sql_file.read_text(encoding="utf-8")
    engine = get_engine()

    # Executar SQL inteiro via psycopg (suporta múltiplos statements)
    conninfo = engine.url.render_as_string(hide_password=False).replace(
        "postgresql+psycopg://", "postgresql://"
    )
    with psycopg.connect(conninfo, autocommit=True) as pg_conn:
        pg_conn.execute(sql_content.encode("utf-8"))

    print(f"[db_utils] Schema '{schema}' e tabelas criados/verificados com sucesso")


def salvar_dataframe(df: pd.DataFrame, tabela: str, schema: str = None,
                     chunksize: int = 500000, modo: str = "truncate") -> int:
    """
    Salva um DataFrame no PostgreSQL, sobrepondo dados anteriores.

    Args:
        df: DataFrame a ser salvo
        tabela: nome da tabela destino (ex: 'dados_brutos')
        schema: schema do banco (default: DB_SCHEMA do .env)
        chunksize: linhas por chunk de COPY (default: 500000)
        modo: 'truncate' (default) limpa dados mantendo schema existente;
              'replace' faz DROP + CREATE, recriando a tabela com as colunas do DataFrame.
              Use 'replace' quando o DataFrame tem colunas diferentes do schema original.

    Returns:
        int: número de linhas inseridas
    """
    import psycopg

    schema = schema or DB_SCHEMA
    engine = get_engine()

    if modo == "replace":
        # DROP + CREATE: recria a tabela com schema dinâmico do DataFrame
        with engine.begin() as conn:
            conn.execute(text(f'DROP TABLE IF EXISTS {schema}."{tabela}" CASCADE'))
        df.head(0).to_sql(tabela, engine, schema=schema, if_exists="replace", index=False)
        # Agora a tabela existe com as colunas certas — prosseguir com COPY
    else:
        # TRUNCATE: limpa dados mantendo schema existente
        with engine.begin() as conn:
            conn.execute(text(f'TRUNCATE TABLE {schema}."{tabela}" RESTART IDENTITY CASCADE'))

    # Converter colunas datetime para string (sem timezone)
    df_write = df.copy()
    for col in df_write.select_dtypes(include=["datetime64[ns, UTC]", "datetime64[ns]"]).columns:
        df_write[col] = df_write[col].dt.tz_localize(None).astype(str)

    # Conexão psycopg3 direta para COPY rápido
    conninfo = engine.url.render_as_string(hide_password=False).replace("postgresql+psycopg://", "postgresql://")
    columns = ', '.join(f'"{c}"' for c in df_write.columns)
    table_ref = f'{schema}."{tabela}"'
    n_rows = len(df_write)
    total_written = 0

    with psycopg.connect(conninfo) as pg_conn:
        for start in range(0, n_rows, chunksize):
            chunk = df_write.iloc[start:start + chunksize]

            # Montar TSV em bytes na memória (sem loop Python)
            buf = BytesIO()
            chunk.to_csv(buf, index=False, header=False, sep="\t",
                         lineterminator="\n", na_rep="\\N")
            buf.seek(0)

            # COPY: envia buffer inteiro em blocos de 1 MB
            with pg_conn.cursor() as cur:
                with cur.copy(
                    f"COPY {table_ref} ({columns}) FROM STDIN WITH (FORMAT text, NULL '\\N')"
                ) as copy:
                    while block := buf.read(1048576):
                        copy.write(block)

            pg_conn.commit()
            total_written += len(chunk)

            if n_rows > chunksize:
                pct = total_written / n_rows * 100
                print(f"[db_utils] {tabela}: {total_written:,} / {n_rows:,} ({pct:.1f}%)")

    print(f"[db_utils] {total_written:,} linhas salvas em {schema}.{tabela}")
    return total_written


def salvar_imagem(stage: str, image_key: str, fig, filename: str = None,
                  mime_type: str = "image/png", dpi: int = 150) -> None:
    """
    Salva uma figura matplotlib/seaborn no banco como imagem binária.

    Se já existir uma imagem com o mesmo stage + image_key, ela é substituída.

    Args:
        stage: etapa da pipeline (ex: 'S1a', 'S1b', 'S1c', 'S2a')
        image_key: identificador único da imagem (ex: 'boxplot_geral')
        fig: objeto matplotlib Figure
        filename: nome do arquivo para referência (ex: 'boxplot_geral.png')
        mime_type: tipo MIME da imagem (default: 'image/png')
        dpi: resolução da imagem (default: 150)
    """
    schema = DB_SCHEMA
    engine = get_engine()

    # Converter figura para bytes
    buf = BytesIO()
    fig.savefig(buf, format="png", dpi=dpi, bbox_inches="tight")
    buf.seek(0)
    image_data = buf.read()
    buf.close()

    filename = filename or f"{image_key}.png"

    with engine.begin() as conn:
        # Remover imagem anterior com mesmo stage + key
        conn.execute(
            text(f"""
                DELETE FROM {schema}.stage_images
                WHERE stage = :stage AND image_key = :key
            """),
            {"stage": stage, "key": image_key}
        )
        # Inserir nova imagem
        conn.execute(
            text(f"""
                INSERT INTO {schema}.stage_images
                    (stage, image_key, filename, image_data, mime_type, created_at)
                VALUES
                    (:stage, :key, :filename, :data, :mime, NOW())
            """),
            {
                "stage": stage,
                "key": image_key,
                "filename": filename,
                "data": image_data,
                "mime": mime_type,
            }
        )

    print(f"[db_utils] Imagem '{image_key}' salva para etapa {stage}")


def carregar_dataframe(tabela: str, schema: str = None) -> pd.DataFrame:
    """
    Carrega uma tabela do PostgreSQL como DataFrame.

    Args:
        tabela: nome da tabela (ex: 'dados_limpos')
        schema: schema do banco (default: DB_SCHEMA do .env)

    Returns:
        pd.DataFrame com os dados da tabela
    """
    schema = schema or DB_SCHEMA
    engine = get_engine()
    df = pd.read_sql_table(tabela, con=engine, schema=schema)
    print(f"[db_utils] {len(df)} linhas carregadas de {schema}.{tabela}")
    return df


def carregar_sql(query: str, params: dict = None) -> pd.DataFrame:
    """
    Executa uma query SQL e retorna o resultado como DataFrame.

    Args:
        query: consulta SQL
        params: parâmetros nomeados para a query

    Returns:
        pd.DataFrame com o resultado
    """
    engine = get_engine()
    df = pd.read_sql(text(query), con=engine, params=params)
    return df


def salvar_chart_data(chart_type: str, data: dict, schema: str = None) -> None:
    """
    Salva dados pré-computados de gráfico como JSONB no banco.

    Faz UPSERT: se chart_type já existe, substitui o chart_data.

    Args:
        chart_type: identificador do gráfico (ex: 'histograms', 'boxplots')
        data: dicionário com os dados do gráfico
        schema: schema do banco (default: DB_SCHEMA do .env)
    """
    import json
    import math
    schema = schema or DB_SCHEMA
    engine = get_engine()

    def _clean(obj):
        """Replace NaN/Inf with None for valid JSON."""
        if isinstance(obj, float) and (math.isnan(obj) or math.isinf(obj)):
            return None
        if isinstance(obj, dict):
            return {k: _clean(v) for k, v in obj.items()}
        if isinstance(obj, list):
            return [_clean(v) for v in obj]
        return obj

    with engine.begin() as conn:
        conn.execute(
            text(f"""
                INSERT INTO {schema}.s1b_chart_data (chart_type, chart_data)
                VALUES (:chart_type, CAST(:chart_data AS jsonb))
                ON CONFLICT (chart_type) DO UPDATE SET chart_data = EXCLUDED.chart_data
            """),
            {"chart_type": chart_type, "chart_data": json.dumps(_clean(data))}
        )

    print(f"[db_utils] Chart data '{chart_type}' salvo em {schema}.s1b_chart_data")


def truncar_tabela(tabela: str, schema: str = None) -> None:
    """
    Limpa todos os dados de uma tabela (TRUNCATE).

    Args:
        tabela: nome da tabela
        schema: schema do banco (default: DB_SCHEMA do .env)
    """
    schema = schema or DB_SCHEMA
    engine = get_engine()
    with engine.begin() as conn:
        conn.execute(text(f'TRUNCATE TABLE {schema}."{tabela}" RESTART IDENTITY CASCADE'))
    print(f"[db_utils] Tabela {schema}.{tabela} truncada")


# ============================================================================
# Carga inteligente (banco ou disco conforme DATA_SOURCE)
# ============================================================================

# Mapeamento: tabela do banco → caminho relativo do parquet em disco
_TABELA_PARA_ARQUIVO = {
    "dados_brutos":              "data/raw/dados_unificados.parquet",
    "dados_limpos":              "data/processed/dataset_limpo.parquet",
    "s1c_v1_dados_com_clusters": "data/processed/dados_com_clusters_v1.parquet",
    "s1c_v2_dados_com_clusters": "data/processed/dados_com_clusters_v2.parquet",
    "s1c_v3_dados_com_clusters": "data/processed/dados_com_clusters_v3.parquet",
    "dados_rotulados":           "data/labeled/dataset_rotulado.parquet",
}

# Raiz do projeto (para resolver caminhos relativos)
_PROJECT_ROOT_CANDIDATES = [
    Path(r"C:\ScriptsDatamindsPIP\4-Projeto aplicado"),
    Path(r"G:\Meu Drive\1-Pos Graduação\4-Projeto aplicado"),
]
PROJECT_ROOT = next((p for p in _PROJECT_ROOT_CANDIDATES if p.exists()), _PROJECT_ROOT_CANDIDATES[0])


def carregar_dados(tabela: str, arquivo: str = None, schema: str = None) -> pd.DataFrame:
    """
    Carrega dados do banco ou do disco conforme DATA_SOURCE (.env).

    Lógica:
        - DATA_SOURCE='banco'  → lê do PostgreSQL via carregar_dataframe()
        - DATA_SOURCE='local'  → lê do parquet em disco

    Args:
        tabela: nome da tabela no banco (ex: 'dados_limpos')
        arquivo: caminho relativo do arquivo local (ex: 'data/processed/dataset_limpo.parquet').
                 Se omitido, usa o mapeamento padrão _TABELA_PARA_ARQUIVO.
        schema: schema do banco (default: DB_SCHEMA do .env)

    Returns:
        pd.DataFrame com os dados
    """
    source = DATA_SOURCE.lower()

    if source == "banco":
        df = carregar_dataframe(tabela, schema=schema)
        df = df.drop(columns=["id"], errors="ignore")
        if "Timestamp" in df.columns:
            df["Timestamp"] = pd.to_datetime(df["Timestamp"])
        return df

    elif source == "local":
        if arquivo is None:
            arquivo = _TABELA_PARA_ARQUIVO.get(tabela)
            if arquivo is None:
                raise ValueError(
                    f"Tabela '{tabela}' não tem mapeamento local definido. "
                    f"Passe o parâmetro 'arquivo' explicitamente."
                )

        caminho = PROJECT_ROOT / arquivo
        if not caminho.exists():
            raise FileNotFoundError(
                f"Arquivo local não encontrado: {caminho}\n"
                f"Execute o notebook anterior ou mude DATA_SOURCE=banco no .env"
            )

        df = pd.read_parquet(caminho)
        print(f"[db_utils] {len(df):,} linhas carregadas de {caminho}")
        if "Timestamp" in df.columns:
            df["Timestamp"] = pd.to_datetime(df["Timestamp"])
        return df

    else:
        raise ValueError(f"DATA_SOURCE inválido: '{source}'. Use 'banco' ou 'local'.")
