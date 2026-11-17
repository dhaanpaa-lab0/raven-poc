#!/usr/bin/env bash
# MariaDB + MongoDB -> DuckDB, using the CLIs baked into the image.
set -euo pipefail
: "${EVAL_DUCKDB_PATH:=/data/eval.duckdb}"
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT

mariadb -h "$EVAL_MARIADB_HOST" -u "$EVAL_MARIADB_USER" -p"$EVAL_MARIADB_PASSWORD" "$EVAL_MARIADB_DB" \
  --batch --raw -e "SELECT id, customer, amount, status, created_at FROM orders" \
  | tr '\t' ',' > "$work/orders.csv"

mongosh "$EVAL_MONGO_URI" --quiet --eval '
  db.getSiblingDB("eval").events.find({}, {_id: 0}).forEach(d => print(JSON.stringify(d)))
' > "$work/events.jsonl"

duckdb "$EVAL_DUCKDB_PATH" <<SQL
CREATE OR REPLACE TABLE orders AS SELECT * FROM read_csv('$work/orders.csv', header=true);
CREATE OR REPLACE TABLE events AS SELECT * FROM read_json('$work/events.jsonl', format='newline_delimited');
SELECT customer, SUM(amount) AS total FROM orders WHERE status='paid' GROUP BY 1 ORDER BY 2 DESC;
SQL
