"""Example DAG: writes to and reads from a DuckDB file in the shared ./data folder."""

from datetime import datetime

from airflow.sdk import dag, task

DB_PATH = "/data/airflow.duckdb"


@dag(schedule=None, start_date=datetime(2026, 1, 1), catchup=False, tags=["duckdb", "example"])
def duckdb_example():
    @task
    def create_table():
        import duckdb

        with duckdb.connect(DB_PATH) as con:
            con.execute(
                "CREATE OR REPLACE TABLE hello AS SELECT 42 AS answer, now() AS created_at"
            )

    @task
    def read_table():
        import duckdb

        with duckdb.connect(DB_PATH, read_only=True) as con:
            rows = con.execute("SELECT * FROM hello").fetchall()
        print(rows)
        return str(rows)

    create_table() >> read_table()


duckdb_example()
