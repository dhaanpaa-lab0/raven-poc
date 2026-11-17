# Paste into a new Python script in the Windmill UI (or push with `wmill sync`).
# Windmill resolves these imports from PyPI automatically on first run.
# Hosts below are the compose service names; adjust if you use Windmill resources.
import json

import duckdb
import pymysql
from pymongo import MongoClient

DUCKDB_PATH = "/data/eval.duckdb"  # shared volume on the default worker


def main(
    mariadb_host: str = "mariadb",
    mariadb_user: str = "eval",
    mariadb_password: str = "eval",
    mongo_uri: str = "mongodb://eval:eval@mongodb:27017/?authSource=admin",
):
    conn = pymysql.connect(host=mariadb_host, user=mariadb_user, password=mariadb_password, database="eval")
    with conn.cursor() as cur:
        cur.execute("SELECT id, customer, CAST(amount AS DOUBLE), status, created_at FROM orders")
        orders = cur.fetchall()

    events = list(MongoClient(mongo_uri)["eval"]["events"].find({}, {"_id": 0}))

    con = duckdb.connect(DUCKDB_PATH)
    con.execute("CREATE OR REPLACE TABLE orders (id INT, customer VARCHAR, amount DOUBLE, status VARCHAR, created_at TIMESTAMP)")
    con.executemany("INSERT INTO orders VALUES (?, ?, ?, ?, ?)", orders)
    con.execute("CREATE OR REPLACE TABLE events (type VARCHAR, usr VARCHAR, ts TIMESTAMP, payload JSON)")
    con.executemany(
        "INSERT INTO events VALUES (?, ?, ?, ?)",
        [(e["type"], e["user"], e["ts"], json.dumps(e["payload"])) for e in events],
    )
    paid = con.execute(
        "SELECT customer, SUM(amount) AS total FROM orders WHERE status='paid' GROUP BY 1 ORDER BY 2 DESC"
    ).fetchall()
    con.close()
    return {"orders": len(orders), "events": len(events), "paid_by_customer": paid}
