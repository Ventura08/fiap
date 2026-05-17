"""Train supervised classifier on Vinheria Agnello sales dataset."""
from __future__ import annotations

import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)
from sklearn.model_selection import cross_val_score, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder
from sklearn.tree import DecisionTreeClassifier, plot_tree

RANDOM_SEED = 42
ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "dataset.csv"
OUT = ROOT / "outputs"

TARGET = "sucesso_venda"
NUMERIC_FEATURES = ["preco_unitario", "quantidade", "desconto_aplicado", "safra", "valor_total"]
CATEGORICAL_FEATURES = ["tipo_vinho", "canal", "regiao_cliente", "tipo_cliente", "forma_pagamento"]
DROP_FEATURES = ["id_venda", "data_venda", "produto"]


def load() -> pd.DataFrame:
    return pd.read_csv(DATA)


def build_pipeline(max_depth: int = 6) -> Pipeline:
    preprocessor = ColumnTransformer(
        transformers=[
            ("cat", OneHotEncoder(handle_unknown="ignore"), CATEGORICAL_FEATURES),
            ("num", "passthrough", NUMERIC_FEATURES),
        ]
    )
    clf = DecisionTreeClassifier(
        max_depth=max_depth,
        min_samples_leaf=10,
        criterion="gini",
        random_state=RANDOM_SEED,
    )
    return Pipeline([("prep", preprocessor), ("clf", clf)])


def plot_confusion(cm: np.ndarray, path: Path) -> None:
    fig, ax = plt.subplots(figsize=(5, 4))
    im = ax.imshow(cm, cmap="Blues")
    ax.set_xticks([0, 1])
    ax.set_yticks([0, 1])
    ax.set_xticklabels(["Insucesso", "Sucesso"])
    ax.set_yticklabels(["Insucesso", "Sucesso"])
    ax.set_xlabel("Previsto")
    ax.set_ylabel("Real")
    ax.set_title("Matriz de Confusao")
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, str(cm[i, j]), ha="center", va="center",
                    color="white" if cm[i, j] > cm.max() / 2 else "black")
    fig.colorbar(im, ax=ax)
    fig.tight_layout()
    fig.savefig(path, dpi=120)
    plt.close(fig)


def plot_feature_importance(pipeline: Pipeline, path: Path) -> pd.DataFrame:
    clf: DecisionTreeClassifier = pipeline.named_steps["clf"]
    prep: ColumnTransformer = pipeline.named_steps["prep"]
    feature_names = list(prep.get_feature_names_out())
    importances = clf.feature_importances_
    df = (
        pd.DataFrame({"feature": feature_names, "importance": importances})
        .sort_values("importance", ascending=False)
        .head(15)
    )
    fig, ax = plt.subplots(figsize=(7, 5))
    ax.barh(df["feature"][::-1], df["importance"][::-1])
    ax.set_title("Top 15 - Importancia das Variaveis")
    ax.set_xlabel("Importancia")
    fig.tight_layout()
    fig.savefig(path, dpi=120)
    plt.close(fig)
    return df


def plot_tree_diagram(pipeline: Pipeline, path: Path) -> None:
    clf: DecisionTreeClassifier = pipeline.named_steps["clf"]
    prep: ColumnTransformer = pipeline.named_steps["prep"]
    feature_names = list(prep.get_feature_names_out())
    shallow = DecisionTreeClassifier(
        max_depth=3, min_samples_leaf=20, class_weight="balanced", random_state=RANDOM_SEED
    )
    # quick refit shallow tree on transformed data for readable plot
    X_trans = prep.transform(pipeline._final_train_X) if hasattr(pipeline, "_final_train_X") else None
    if X_trans is None:
        return
    shallow.fit(X_trans, pipeline._final_train_y)
    fig, ax = plt.subplots(figsize=(16, 8))
    plot_tree(
        shallow,
        feature_names=feature_names,
        class_names=["Insucesso", "Sucesso"],
        filled=True,
        rounded=True,
        ax=ax,
        fontsize=8,
    )
    fig.tight_layout()
    fig.savefig(path, dpi=120)
    plt.close(fig)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    df = load()

    X = df.drop(columns=DROP_FEATURES + [TARGET])
    y = df[TARGET]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=RANDOM_SEED, stratify=y
    )

    pipeline = build_pipeline()
    pipeline.fit(X_train, y_train)
    pipeline._final_train_X = X_train
    pipeline._final_train_y = y_train

    y_pred = pipeline.predict(X_test)

    metrics = {
        "n_train": int(len(X_train)),
        "n_test": int(len(X_test)),
        "accuracy": float(accuracy_score(y_test, y_pred)),
        "precision": float(precision_score(y_test, y_pred)),
        "recall": float(recall_score(y_test, y_pred)),
        "f1": float(f1_score(y_test, y_pred)),
    }

    cv_scores = cross_val_score(pipeline, X, y, cv=5, scoring="accuracy")
    metrics["cv_accuracy_mean"] = float(cv_scores.mean())
    metrics["cv_accuracy_std"] = float(cv_scores.std())

    cm = confusion_matrix(y_test, y_pred)
    metrics["confusion_matrix"] = cm.tolist()
    metrics["classification_report"] = classification_report(y_test, y_pred, output_dict=True)

    (OUT / "metrics.json").write_text(json.dumps(metrics, indent=2, ensure_ascii=False))
    plot_confusion(cm, OUT / "confusion_matrix.png")
    importance_df = plot_feature_importance(pipeline, OUT / "feature_importance.png")
    importance_df.to_csv(OUT / "feature_importance.csv", index=False)
    plot_tree_diagram(pipeline, OUT / "decision_tree.png")

    print("=== Metrics ===")
    for k in ("accuracy", "precision", "recall", "f1", "cv_accuracy_mean", "cv_accuracy_std"):
        print(f"{k}: {metrics[k]:.4f}")
    print("\nConfusion matrix:")
    print(cm)
    print("\nTop features:")
    print(importance_df.head(10).to_string(index=False))


if __name__ == "__main__":
    main()
