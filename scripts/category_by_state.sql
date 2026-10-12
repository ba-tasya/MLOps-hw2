SELECT us_state, argMax(cat_id, amount) AS category
FROM transactions
GROUP BY us_state;