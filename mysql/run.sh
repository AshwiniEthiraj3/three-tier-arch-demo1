#!/usr/bin/env bash
set -euo pipefail

echo "[run.sh] starting"

MYSQL_HOST="${MYSQL_HOST:?missing}"
MYSQL_USER="${MYSQL_USER:?missing}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:?missing}"

# optional: wait for DB
echo "[run.sh] waiting for MySQL at $MYSQL_HOST:3306"
for i in {1..30}; do
  if mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "[run.sh] MySQL is reachable"
    break
  fi
  echo "[run.sh] retry $i/30..."
  sleep 2
done

echo "[run.sh] importing ratings schema"
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < /docker-entrypoint-initdb.d/20-ratings.sql

echo "[run.sh] seeding cities from CSV -> SQL"
bash /root/convert.sh /root/cities.csv | mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" cities

echo "[run.sh] finished imports"
sleep 600   # keep alive for debugging
