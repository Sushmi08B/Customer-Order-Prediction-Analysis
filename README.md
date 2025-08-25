# Customer-Order-Prediction-Analysis
An end-to-end data engineering + machine learning project built on Azure Synapse, ADLS Gen2, Azure ML, and Tableau using the Instacart Online Grocery dataset.

1. **Ingest**
   - Upload CSVs (orders, order_products_prior/train, products, aisles, departments) to `ADLS Gen2` at `data/raw/online_retail_ii/landing_date=YYYY-MM-DD/`.
   - Optionally automate with a Python script or Azure Function.

2. **Bronze (Synapse Spark)**
   - Read all raw CSVs with headers + schema inference.
   - Standardize column names, add `ingest_ts`, `ingest_date`.
   - Write **Parquet** to `data/bronze/online_retail_ii/`.

3. **Silver (Synapse Spark)**
   - Create curated tables:
     - `silver.dim_products` (join products ↔ aisles ↔ departments)
     - `silver.dim_orders` (typed, validated)
     - `silver.fact_order_products` (union prior + train with `split_source`)
   - Partition by appropriate keys (often not necessary here; Parquet is enough).

4. **Gold (Synapse Spark + Azure ML)**
   - Compute features: user, product, user×product.
   - Train a classifier (reorder prediction) in Azure ML; write batch inferences to `gold/predictions/`.
   - Optionally compute top‑K product recommendations per user.

5. **Serve**
   - Create Synapse **Serverless SQL views** over `silver/` and `gold/`.
   - Connect Tableau Desktop (trial) to Synapse, or export CSV extracts for Tableau Public.

 ### Architecture Overview
 
```mermaid
flowchart LR
 subgraph Sources["External / First‑party Sources"]
        A1["CSV / ZIP\n(Instacart-style files)"]
        A2["Future APIs / Webhooks"]
  end
 subgraph Ingest["Ingestion Options"]
        I1["Manual Upload\nSynapse Studio"]
        I2["Python Script\nrequests + ADLS SDK"]
        I3["Azure Function (HTTP)\nManaged Identity → ADLS"]
  end
 subgraph Lake["ADLS Gen2 (Data Lake)"]
        R["raw/\nlanding_date=YYYY‑MM‑DD"]
        B["bronze/\nParquet + ingest_date"]
        S["silver/\nCurated Parquet (dims/facts)"]
        G["gold/\nFeatures + Predictions"]
  end
 subgraph Synapse["Azure Synapse"]
        SP[("Spark Pool\nNotebooks / ETL")]
        SQL[("Serverless SQL\nExternal Views")]
        PIPE["Synapse Pipelines\n(Orchestration)"]
  end
 subgraph AzureML["Azure Machine Learning"]
        FE["Feature Prep"]
        TR["Train & Register Model"]
        INF["Batch Inference\n→ gold/predictions"]
  end
 subgraph BI["Analytics / Serving"]
        TB["Tableau Desktop/Public\n(Extracts or CSV)"]
        ENDPOINT[("Optional: Synapse SQL endpoint")]
  end
    A1 --> I1
    A1 -. automation .-> I2
    A2 --> I3
    I1 --> R
    I2 --> R
    I3 --> R
    R --> SP
    SP --> B & S & G
    B --> SP
    S --> SP & FE
    G --> SQL & TB
    FE --> TR
    TR --> INF
    INF --> G
    SQL --> TB
    PIPE -. orchestrate .- SP & TR & INF

```
### Medallion Architecture

``` mermaid
flowchart LR
    RAW["Raw CSVs\norders, order_products_prior/train,\nproducts, aisles, departments"]
    BRONZE["Bronze Parquet\n(clean headers, ingest_ts/date)"]
    SILVER["Silver Curated\n• dim_products\n• dim_orders\n• fact_order_products"]
    GOLD["Gold Features & Predictions\n• user_features\n• product_features\n• user_product_features\n• predictions"]

    RAW --> BRONZE --> SILVER --> GOLD
```
**Raw**: direct landing zone for CSV/ZIP as-is.

**Bronze**: standardize column names, add ingest metadata, store as Parquet.

**Silver**: dimensional model (orders, products, order_products, aisles, departments).

**Gold**: aggregated features + ML predictions.

### Machine Learning
Features prepared in Synapse Spark → saved to gold/features/.

Model training in Azure ML (e.g., XGBoost, Logistic Regression).

Batch inference → results stored in gold/predictions/.

### Data Model (ERD)
``` mermaid
erDiagram
    ORDERS {
      int order_id PK
      int user_id
      string eval_set
      int order_number
      int order_dow
      int order_hour_of_day
      int days_since_prior_order
    }

    ORDER_PRODUCTS {
      int order_id FK
      int product_id FK
      int add_to_cart_order
      int reordered
      string split_source  "prior|train"
    }

    PRODUCTS {
      int product_id PK
      string product_name
      int aisle_id FK
      int department_id FK
    }

    AISLES {
      int aisle_id PK
      string aisle
    }

    DEPARTMENTS {
      int department_id PK
      string department
    }

    ORDERS ||--o{ ORDER_PRODUCTS : contains
    PRODUCTS ||--o{ ORDER_PRODUCTS : appears_in
    PRODUCTS }o--|| AISLES : in
    PRODUCTS }o--|| DEPARTMENTS : in
```
