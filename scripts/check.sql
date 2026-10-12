SELECT us_state, argMax(cat_id, amount) FROM transactions GROUP BY us_state SETTINGS log_comment = 'compare_transactions' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions GROUP BY us_state SETTINGS log_comment = 'compare_transactions' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions GROUP BY us_state SETTINGS log_comment = 'compare_transactions' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions GROUP BY us_state SETTINGS log_comment = 'compare_transactions' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions GROUP BY us_state SETTINGS log_comment = 'compare_transactions' FORMAT Null;

SELECT us_state, argMax(cat_id, amount) FROM transactions_optimized GROUP BY us_state SETTINGS log_comment = 'compare_transactions_optimized' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions_optimized GROUP BY us_state SETTINGS log_comment = 'compare_transactions_optimized' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions_optimized GROUP BY us_state SETTINGS log_comment = 'compare_transactions_optimized' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions_optimized GROUP BY us_state SETTINGS log_comment = 'compare_transactions_optimized' FORMAT Null;
SELECT us_state, argMax(cat_id, amount) FROM transactions_optimized GROUP BY us_state SETTINGS log_comment = 'compare_transactions_optimized' FORMAT Null;

SYSTEM FLUSH LOGS;

SELECT
    p.table AS table,
    p.rows AS rows,
    p.size_on_disk AS size_on_disk,
    p.size_uncompressed AS size_uncompressed,
    q.avg_query_ms AS avg_query_ms,
    q.avg_read AS read_per_query
FROM
(
    SELECT
        table,
        sum(rows) AS rows,
        formatReadableSize(sum(data_compressed_bytes)) AS size_on_disk,
        formatReadableSize(sum(data_uncompressed_bytes)) AS size_uncompressed
    FROM system.parts
    WHERE active AND table IN ('transactions', 'transactions_optimized')
    GROUP BY table
) AS p
LEFT JOIN
(
    SELECT
        replaceOne(log_comment, 'compare_', '') AS table,
        round(avg(query_duration_ms), 1) AS avg_query_ms,
        formatReadableSize(avg(read_bytes)) AS avg_read
    FROM system.query_log
    WHERE type = 'QueryFinish' AND log_comment LIKE 'compare_%'
    GROUP BY table
) AS q ON p.table = q.table
ORDER BY p.table;