-- Silver views
CREATE OR ALTER VIEW silver_fact_orders AS
SELECT *
FROM OPENROWSET(
    BULK 'silver/fact_orders/*.parquet',
    DATA_SOURCE = 'LakeData',
    FORMAT = 'PARQUET'
) WITH (
    order_id               INT,
    user_id                INT,
    eval_set               VARCHAR(20),
    order_number           INT,
    order_dow              INT,
    order_hour_of_day      INT,
    days_since_prior_order FLOAT
) AS rows;

CREATE OR ALTER VIEW silver_fact_order_products AS
SELECT *
FROM OPENROWSET(
    BULK 'silver/fact_order_products/*.parquet',
    DATA_SOURCE = 'LakeData',
    FORMAT = 'PARQUET'
) AS rows;

CREATE OR ALTER VIEW silver_dim_products AS
SELECT *
FROM OPENROWSET(
    BULK 'silver/dim_products/*.parquet',
    DATA_SOURCE = 'LakeData',
    FORMAT = 'PARQUET'
) AS rows;

CREATE OR ALTER VIEW silver_dim_users AS
SELECT *
FROM OPENROWSET(
    BULK 'silver/dim_users/*.parquet',
    DATA_SOURCE = 'LakeData',
    FORMAT = 'PARQUET'
) AS rows;

-- Quick sanity checks (run a few SELECTs)
SELECT TOP 10 * FROM silver_fact_orders;
SELECT TOP 10 * FROM silver_dim_products;
SELECT TOP 10 * FROM silver_dim_users;
SELECT TOP 10 * FROM silver_fact_order_products;