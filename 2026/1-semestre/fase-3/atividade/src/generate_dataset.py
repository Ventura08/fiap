"""Generate simulated sales dataset for Vinheria Agnello."""
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
from faker import Faker

RANDOM_SEED = 42
N_ROWS = 1000
OUTPUT = Path(__file__).resolve().parents[1] / "data" / "dataset.csv"

rng = np.random.default_rng(RANDOM_SEED)
fake = Faker("pt_BR")
Faker.seed(RANDOM_SEED)

WINE_TYPES = ["Tinto", "Branco", "Rose", "Espumante"]
WINE_TYPE_WEIGHTS = [0.55, 0.25, 0.10, 0.10]

PRODUCTS = {
    "Tinto": ["Cabernet Reserva", "Malbec Premium", "Merlot Classico", "Tannat Especial"],
    "Branco": ["Chardonnay Safra", "Sauvignon Blanc", "Riesling Doce"],
    "Rose": ["Rose Provence", "Rose Brasileiro"],
    "Espumante": ["Brut Tradicional", "Moscatel Doce"],
}

CHANNELS = ["Loja Fisica", "E-commerce", "Distribuidor", "Eventos"]
CHANNEL_WEIGHTS = [0.40, 0.35, 0.15, 0.10]

REGIONS = ["Sudeste", "Sul", "Nordeste", "Centro-Oeste", "Norte"]
REGION_WEIGHTS = [0.50, 0.25, 0.13, 0.08, 0.04]

CUSTOMER_TYPES = ["PF", "PJ"]
PAYMENTS = ["Credito", "Debito", "Pix", "Boleto"]


def _base_price(wine_type: str) -> float:
    ranges = {
        "Tinto": (80, 350),
        "Branco": (60, 250),
        "Rose": (70, 200),
        "Espumante": (90, 400),
    }
    lo, hi = ranges[wine_type]
    return float(rng.uniform(lo, hi))


def _success_probability(row: dict) -> float:
    """Compute probability of sale being successful given features.

    Success defined as: not cancelled AND margin acceptable AND customer satisfied.
    We model it as a logistic function on engineered signals so the dataset has
    real learnable structure (not pure noise) while keeping non-trivial overlap.
    """
    p = 0.55

    if row["canal"] == "E-commerce":
        p += 0.08
    elif row["canal"] == "Distribuidor":
        p += 0.05
    elif row["canal"] == "Eventos":
        p -= 0.05

    if row["tipo_cliente"] == "PJ":
        p += 0.10

    if row["regiao_cliente"] in ("Sudeste", "Sul"):
        p += 0.05

    if row["desconto_aplicado"] > 0.20:
        p -= 0.15
    elif row["desconto_aplicado"] > 0.10:
        p += 0.05

    if row["forma_pagamento"] == "Boleto":
        p -= 0.10
    elif row["forma_pagamento"] == "Pix":
        p += 0.05

    if row["quantidade"] >= 6:
        p += 0.05

    if row["preco_unitario"] > 300:
        p -= 0.08

    # safra age effect
    age = 2026 - row["safra"]
    if 3 <= age <= 10:
        p += 0.05
    elif age > 20:
        p -= 0.05

    return float(np.clip(p, 0.05, 0.95))


def generate() -> pd.DataFrame:
    rows = []
    dates = pd.date_range("2024-01-01", "2026-04-30", freq="D")

    for i in range(N_ROWS):
        wine_type = rng.choice(WINE_TYPES, p=WINE_TYPE_WEIGHTS)
        product = rng.choice(PRODUCTS[wine_type])
        channel = rng.choice(CHANNELS, p=CHANNEL_WEIGHTS)
        region = rng.choice(REGIONS, p=REGION_WEIGHTS)
        customer_type = rng.choice(CUSTOMER_TYPES, p=[0.78, 0.22])
        payment = rng.choice(PAYMENTS, p=[0.45, 0.20, 0.25, 0.10])
        sale_date = rng.choice(dates)

        qty = int(rng.integers(1, 12)) if customer_type == "PF" else int(rng.integers(3, 40))
        unit_price = round(_base_price(wine_type), 2)
        discount = float(rng.choice([0.0, 0.05, 0.10, 0.15, 0.20, 0.25], p=[0.40, 0.20, 0.15, 0.10, 0.10, 0.05]))
        safra = int(rng.integers(2000, 2024))

        row = {
            "id_venda": i + 1,
            "data_venda": pd.Timestamp(sale_date).date(),
            "tipo_vinho": wine_type,
            "produto": product,
            "safra": safra,
            "preco_unitario": unit_price,
            "quantidade": qty,
            "desconto_aplicado": discount,
            "canal": channel,
            "regiao_cliente": region,
            "tipo_cliente": customer_type,
            "forma_pagamento": payment,
            "valor_total": round(unit_price * qty * (1 - discount), 2),
        }
        prob = _success_probability(row)
        row["sucesso_venda"] = int(rng.random() < prob)
        rows.append(row)

    df = pd.DataFrame(rows)
    return df


def main() -> None:
    df = generate()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT, index=False, encoding="utf-8")
    print(f"Wrote {len(df)} rows to {OUTPUT}")
    print(f"Success rate: {df['sucesso_venda'].mean():.3f}")
    print(df.head())


if __name__ == "__main__":
    main()
