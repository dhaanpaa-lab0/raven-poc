### RAVEN

Your friendly local Runbook Automation and Verification ENvironment

Docker Compose sandboxes for evaluating workflow/runbook tools against **MongoDB**, **MariaDB** and **DuckDB**.

| Stack | Dir | UI | Mongo / MariaDB host ports | Login |
|---|---|---|---|---|
| Apache Airflow 3 (LocalExecutor) | `airflow/` | http://localhost:8080 | 27117 / 3307 | none (all-admins, eval only) |
| Windmill CE | `windmill/` | http://localhost:8000 | 27217 / 3308 | `admin@windmill.dev` / `changeme` |
| Rundeck OSS 5.9 (MariaDB-backed) | `rundeck-oss/` | http://localhost:4440 | 27317 / 3309 | `admin` / `admin` |

Each stack uses distinct ports, so they can run side by side. Copy a stack's `.env.example` to `.env` to override ports.
All credentials are throwaway, evaluation-only values.

## Prerequisites

Docker with Compose v2 and, optionally, [Task](https://taskfile.dev).

## Usage

```sh
task airflow:up      # or: cd airflow && docker compose up --build -d
task windmill:up
task rundeck:up
task <stack>:down    # stop, keep data
task <stack>:purge   # stop and delete volumes
```

## Sample data and the ETL example

`common/seed/` is mounted into every stack's databases on first start:

- MariaDB `eval.orders` (6 rows) and, for Rundeck's own store, a `rundeck` database
- MongoDB `eval.events` (5 documents)

Each stack has the same example: load both sources into DuckDB (`/opt/airflow/data` or `/data`, a named volume) and run a query.

| Stack | Example | How to run |
|---|---|---|
| Airflow | `airflow/dags/eval_etl.py` | Trigger DAG `eval_etl` |
| Windmill | `windmill/scripts/eval_etl.py` | Paste into a new Python script in the UI and run |
| Rundeck | `rundeck-oss/scripts/eval_etl.sh`, `rundeck-oss/jobs/eval_etl.yaml` | Upload the job definition and run it |

## Notes for the evaluation

- DuckDB is an embedded, single-writer file database, so orchestrated tasks must load it sequentially (the Airflow DAG does).
- Airflow and Rundeck use custom images (`pymongo`/`pymysql`/`duckdb`, and the `mariadb`/`mongosh`/`duckdb` CLIs respectively). Windmill resolves Python dependencies from PyPI on first run.
- Airflow login is disabled for convenience; do not expose it beyond localhost.
