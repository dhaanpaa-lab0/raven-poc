FROM rundeck/rundeck:5.9.0
# CLIs so Rundeck jobs can reach MariaDB, MongoDB and DuckDB.
USER root
ARG DUCKDB_VERSION=1.3.2
ARG MONGOSH_VERSION=2.5.0
RUN apt-get update \
 && apt-get install -y --no-install-recommends mariadb-client curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*
# Detect the base image's real arch (it may differ from the build host, e.g. amd64 under emulation).
RUN set -eux; \
    case "$(uname -m)" in \
      aarch64|arm64) DK=arm64; MG=arm64 ;; \
      *)             DK=amd64; MG=x64 ;; \
    esac; \
    curl -fsSL "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-${DK}.zip" -o /tmp/duckdb.zip; \
    unzip /tmp/duckdb.zip -d /usr/local/bin && chmod +x /usr/local/bin/duckdb && rm /tmp/duckdb.zip; \
    curl -fsSL "https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${MG}.tgz" | tar -xz -C /opt; \
    ln -s /opt/mongosh-${MONGOSH_VERSION}-linux-${MG}/bin/mongosh /usr/local/bin/mongosh
# Shared DuckDB data dir
RUN mkdir -p /data && chown rundeck:root /data
USER rundeck
