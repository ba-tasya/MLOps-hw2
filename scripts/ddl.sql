CREATE TABLE transactions_queue
(
    transaction_time String,
    merch String,
    cat_id String,
    amount Float64,
    name_1 String,
    name_2 String,
    gender String,
    street String,
    one_city String,
    us_state String,
    post_code  Int64,
    lat Float64,
    lon Float64,
    population_city Int64,
    jobs String,
    merchant_lat Float64,
    merchant_lon Float64,
    target Int64
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:29092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'clickhouse_transactions',
    kafka_format = 'JSONEachRow';

CREATE TABLE transactions
(
    transaction_time DateTime,
    merch String,
    cat_id String,
    amount Float64,
    name_1 String,
    name_2 String,
    gender String,
    street String,
    one_city String,
    us_state String,
    post_code Int64,
    lat Float64,
    lon Float64,
    population_city Int64,
    jobs String,
    merchant_lat Float64,
    merchant_lon Float64,
    target Int64
)
ENGINE = MergeTree
ORDER BY transaction_time;

CREATE MATERIALIZED VIEW transactions_mv TO transactions AS
SELECT
    parseDateTimeBestEffort(transaction_time) AS transaction_time,
    merch, cat_id, amount, name_1, name_2, gender, street, one_city, us_state,
    post_code, lat, lon, population_city, jobs, merchant_lat, merchant_lon, target
FROM transactions_queue;
