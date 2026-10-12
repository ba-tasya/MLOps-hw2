CREATE TABLE transactions_queue_optimized
(
    transaction_time String,
    merch LowCardinality(String),
    cat_id LowCardinality(String),
    amount Decimal32(2),
    name_1 LowCardinality(String),
    name_2 LowCardinality(String),
    gender LowCardinality(String),
    street LowCardinality(String),
    one_city LowCardinality(String),
    us_state LowCardinality(String),
    post_code UInt32,
    lat Float32,
    lon Float32,
    population_city UInt32,
    jobs LowCardinality(String),
    merchant_lat Float32,
    merchant_lon Float32,
    target UInt8
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:29092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'clickhouse_transactions_optimized',
    kafka_format = 'JSONEachRow';

CREATE TABLE transactions_optimized
(
    transaction_time DateTime,
    merch LowCardinality(String),
    cat_id LowCardinality(String),
    amount Decimal32(2),
    name_1 LowCardinality(String),
    name_2 LowCardinality(String),
    gender LowCardinality(String),
    street LowCardinality(String),
    one_city LowCardinality(String),
    us_state LowCardinality(String),
    post_code UInt32,
    lat Float32,
    lon Float32,
    population_city UInt32,
    jobs LowCardinality(String),
    merchant_lat Float32,
    merchant_lon Float32,
    target UInt8
)
ENGINE = MergeTree
ORDER BY (us_state, cat_id, transaction_time);

CREATE MATERIALIZED VIEW transactions_optimized_mv TO transactions_optimized AS
SELECT
    parseDateTimeBestEffort(transaction_time) AS transaction_time,
    merch, cat_id, amount, name_1, name_2, gender, street, one_city, us_state,
    post_code, lat, lon, population_city, jobs, merchant_lat, merchant_lon, target
FROM transactions_queue_optimized;