# 📂 Data Folder

This folder is the landing zone for the **Instacart Online Grocery Dataset** (used in this project).  
The raw files are too large to upload to GitHub, but you can download them yourself from Kaggle or other sources.

---

## 📊 Dataset Used

**Instacart Online Grocery Shopping Dataset (2017, Kaggle)**  
- Orders: `orders.csv`
- Aisles: `aisles.csv`
- Departments: `departments.csv`
- Order details (prior): `order_products__prior.csv`
- Order details (train): `order_products__train.csv`
- Products: `products.csv`

📥 Download from Kaggle:  
👉 https://www.kaggle.com/datasets/yasserh/instacart-online-grocery-basket-analysis-dataset?select=orders.csv

---

## 📂 Folder Structure (Medallion)

After download, place files under the following paths in your **Azure Data Lake (ADLS Gen2)** or local project structure:

---
```text
data/
├── raw/
│   └── online_retail_ii/
│       └── landing_date=YYYY-MM-DD/
│           ├── orders.csv
│           ├── aisles.csv
│           ├── departments.csv
│           ├── order_products__prior.csv
│           ├── order_products__train.csv
│           └── products.csv
├── bronze/ <- created by Synapse Spark (Parquet)
├── silver/ <- curated fact/dim tables
└── gold/ <- ML features + predictions
```
---
- **raw/** → Original CSVs (as downloaded).  
- **bronze/** → Standardized Parquet with metadata (`ingest_ts`, `ingest_date`).  
- **silver/** → Clean curated tables (dim_products, dim_orders, fact_order_products).  
- **gold/** → Features and ML prediction outputs.  

---

## ⚡ How to Ingest into Azure

1. Upload raw CSVs to your ADLS Gen2 `data` container in the path above.  
   - Example:  
     `abfss://data@<your_storage>.dfs.core.windows.net/raw/online_retail_ii/landing_date=2025-08-24/orders.csv`

2. Run the **Bronze ETL notebook** → writes to `bronze/`.  
3. Run the **Silver ETL notebook** → writes to `silver/`.  
4. Run the **Gold ETL notebook** → writes to `gold/`.  

---

## 📝 Notes

- Files are **not checked into GitHub** due to size limits.  
- Please download them separately and place them under `data/raw/...` before running notebooks.  
- Kaggle account required to download the dataset.  
