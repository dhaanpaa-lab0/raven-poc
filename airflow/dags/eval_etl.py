"""Eval DAG: MariaDB + MongoDB -> DuckDB, then a DuckDB analytical query."""
from datetime import datetime
import os

from airflow.sdk import dag, task


@dag(schedule=None, start_date=datetime(2026, 1, 1), catchup=False, tags=["eval"])
def eval_etl():
    @task
    def orders_to_duckdb() -> int:
        import duckdb, pymysql

        conn = pymysql.connect(
            host=os.environ["EVAL_MARIADB_HOST"], user=os.environ["EVAL_MARIADB_USER"],
            password=os.environ["EVAL_MARIADB_PASSWORD"], database=os.environ["EVAL_MARIADB_DB"],
        )
        with conn.cursor() as cur:
            cur.execute("SELECT id, customer, CAST(amount AS DOUBLE), status, created_at FROM orders")
            rows = cur.fetchall()
        con = duckdb.connect(os.environ["EVAL_DUCKDB_PATH"])
        con.execute("CREATE OR REPLACE TABLE orders (id INT, customer VARCHAR, amount DOUBLE, status VARCHAR, created_at TIMESTAMP)")
        con.executemany("INSERT INTO orders VALUES (?, ?, ?, ?, ?)", rows)
        con.close()
        return len(rows)

    @task
    def events_to_duckdb() -> int:
        import duckdb, json
        from pymongo import MongoClient

        docs = list(MongoClient(os.environ["EVAL_MONGO_URI"])["eval"]["events"].find({}, {"_id": 0}))
        con = duckdb.connect(os.environ["EVAL_DUCKDB_PATH"])
        con.execute("CREATE OR REPLACE TABLE events (type VARCHAR, usr VARCHAR, ts TIMESTAMP, payload JSON)")
        con.executemany(
            "INSERT INTO events VALUES (?, ?, ?, ?)",
            [(d["type"], d["user"], d["ts"], json.dumps(d["payload"])) for d in docs],
        )
        con.close()
        return len(docs)

    @task
    def report(n_orders: int, n_events: int):
        import duckdb

        con = duckdb.connect(os.environ["EVAL_DUCKDB_PATH"], read_only=True)
        print(f"loaded {n_orders} orders, {n_events} events")
        print(con.execute(
            "SELECT customer, SUM(amount) total FROM orders WHERE status='paid' GROUP BY 1 ORDER BY 2 DESC"
        ).fetchall())

    # DuckDB allows one writer at a time, so load sequentially.
    o = orders_to_duckdb()
    e = events_to_duckdb()
    o >> e
    report(o, e)


eval_etl()
