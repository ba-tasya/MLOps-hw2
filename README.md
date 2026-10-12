# MLOps-hw2

## Шаг 0
Создать в корне папку ```data``` и положить туда ```train.csv``` (не загружается на гх из-за размера).

## Шаг 1: докер и venv
```bash
docker compose up -d
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Шаг 2: самое задание
### 1. Загрузка данных в Kafka
Читаем `data/train.csv` и отправляем каждую строку в топик `transactions` как JSON-фалй
```bash
python producer.py
```
### 2. Таблицы в ClickHouse
Создаем таблицы:
* `transactions_queue` - таблица для чтения топика
* `transactions` - таблица MergeTree, где хранятся данные
* `transactions_mv` - материализованное представление, перекладываем данные из `transactions_queue` в `transactions` и конвертим время в `DateTime`
```bash
docker exec -i clickhouse clickhouse-client --multiquery < scripts/ddl.sql
```
### 3. Запрос категории
```bash
docker exec -i clickhouse clickhouse-client --format CSVWithNames < scripts/category_by_state.sql > result.csv
```
### 4. Оптимизируем хранение
Что поменялось в сравнении с п.2:
* **LowCardinality(String)**: в каждом текстовом столбце достаточно мало уникальных значений, поэтому храним словарь значений и их номеров вместо повторений
* **Более компактные типы**: `Float32` вместо `Float64` для координат, `UInt32` / `UInt8` вместо `Int64`, `Decimal32(2)` для суммы транзакции
* **ORDER BY (us_state, cat_id, transaction_time)**: сортируем данные по тому штату, по которому идет группировка
```bash
docker exec -i clickhouse clickhouse-client --multiquery < scripts/ddl_optimized.sql
```

### 5. Сравнение
```bash
docker exec -i clickhouse clickhouse-client --multiquery --format PrettyCompact < scripts/check.sql
```
В скрипте запрос выполняется по 5 раз для каждой таблицы для усреднения времени

Результаты локально:

| table | rows | size_on_disk | size_uncompressed | avg_query_ms | read_per_query |
|---|---|---|---|---|---|
| `transactions` | 786431 | 54.36 MiB | 126.76 MiB | 4.6 мс | 28.89 MiB |
| `transactions_optimized` | 786431 | 26.41 MiB | 34.13 MiB | 1.4 мс | 4.50 MiB |
* **table** - название таблицы
* **rows** - число строк для проверки корректности
* **size_on_disk** - сколько места таблица реально занимает на диске (сжатая в ClickHouse)
* **size_uncompressed** - сколько места занимает не сжатая таблица (как в памяти при запросе)
* **avg_query_ms** - среднее время выполнения запроса по 5 запускам
* **read_per_query** - сколько прочиталось в среднем за 1 запрос
