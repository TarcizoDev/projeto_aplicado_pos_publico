"""
Exporta todos os notebooks do projeto para HTML (sem código, com outputs).

Uso:
    python exportar_html.py              # exporta todos (pipeline + clusters)
    python exportar_html.py s1a          # exporta só o S1a
    python exportar_html.py s1c s2a      # exporta S1c e S2a
    python exportar_html.py v1 v2 v3    # exporta só os de clusters
    python exportar_html.py --pipeline   # exporta só os da pipeline (sem clusters)
"""
import sys
from pathlib import Path
from nbconvert import HTMLExporter
import nbformat

PROJECT_ROOT = Path(r"C:\ScriptsDatamindsPIP\4-Projeto aplicado")
HTML_DIR = PROJECT_ROOT / "html"
HTML_DIR.mkdir(parents=True, exist_ok=True)

# Notebooks da pipeline ativa
NOTEBOOKS = {
    "s1a": PROJECT_ROOT / "notebooks" / "01_sprint1" / "a_preparacao_dados.ipynb",
    "s1b": PROJECT_ROOT / "notebooks" / "01_sprint1" / "b_analise_exploratoria.ipynb",
    "s1c": PROJECT_ROOT / "notebooks" / "01_sprint1" / "clusters" / "c_clustering_regimes_v3.ipynb",
    "s1d": PROJECT_ROOT / "notebooks" / "01_sprint1" / "d_comparacao_versoes.ipynb",
    "s1e": PROJECT_ROOT / "notebooks" / "01_sprint1" / "e_analise_temporal_regimes.ipynb",
    "s2a": PROJECT_ROOT / "notebooks" / "02_sprint2" / "a_carimbamento_preditor.ipynb",
    "s2b": PROJECT_ROOT / "notebooks" / "02_sprint2" / "b_preparacao_modelagem.ipynb",
    "s2c": PROJECT_ROOT / "notebooks" / "02_sprint2" / "c_treinamento_modelos.ipynb",
}

# Notebooks de clusters (versões de experimentação)
NOTEBOOKS_CLUSTERS = {
    "v1": PROJECT_ROOT / "notebooks" / "01_sprint1" / "clusters" / "c_clustering_regimes_v1.ipynb",
    "v2": PROJECT_ROOT / "notebooks" / "01_sprint1" / "clusters" / "c_clustering_regimes_v2.ipynb",
    "v3": PROJECT_ROOT / "notebooks" / "01_sprint1" / "clusters" / "c_clustering_regimes_v3.ipynb",
}


def exportar(tag: str, nb_path: Path, prefix: str = ""):
    """Exporta um notebook para HTML, espelhando a estrutura de diretórios."""
    if not nb_path.exists():
        print(f"  [{tag}] SKIP — arquivo não encontrado: {nb_path}")
        return

    with open(nb_path, encoding="utf-8") as f:
        nb_node = nbformat.read(f, as_version=4)

    exporter = HTMLExporter()
    exporter.exclude_input = True  # Ocultar código, manter outputs

    html_body, _ = exporter.from_notebook_node(nb_node)

    # Espelhar subpasta do notebook (ex: notebooks/01_sprint1 → html/01_sprint1)
    nb_dir = nb_path.parent
    notebooks_root = PROJECT_ROOT / "notebooks"
    try:
        sub_dir = nb_dir.relative_to(notebooks_root)
    except ValueError:
        sub_dir = Path()

    out_dir = HTML_DIR / sub_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    out_name = f"{prefix}{nb_path.stem}.html"
    out_path = out_dir / out_name
    out_path.write_text(html_body, encoding="utf-8")
    print(f"  [{tag}] {sub_dir / out_name} ({out_path.stat().st_size / 1e6:.1f} MB)")


def main():
    filtros = [a.lower() for a in sys.argv[1:]]
    only_pipeline = "--pipeline" in filtros
    filtros = [f for f in filtros if f != "--pipeline"]

    if filtros:
        nbs = {k: v for k, v in NOTEBOOKS.items() if k in filtros}
        nbs_clusters = {k: v for k, v in NOTEBOOKS_CLUSTERS.items() if k in filtros}
        if not nbs and not nbs_clusters:
            todas = list(NOTEBOOKS.keys()) + list(NOTEBOOKS_CLUSTERS.keys())
            print(f"Tags válidas: {', '.join(todas)}")
            sys.exit(1)
    else:
        nbs = NOTEBOOKS
        nbs_clusters = {} if only_pipeline else NOTEBOOKS_CLUSTERS

    total = len(nbs) + len(nbs_clusters)
    print(f"Exportando {total} notebook(s) para {HTML_DIR}\n")

    if nbs:
        print("Pipeline:")
        for tag, path in nbs.items():
            exportar(tag, path)

    if nbs_clusters:
        print("\nClusters:")
        for tag, path in nbs_clusters.items():
            exportar(tag, path, prefix="CLUSTER_")

    print(f"\nConcluído. HTMLs em: {HTML_DIR}")


if __name__ == "__main__":
    main()
