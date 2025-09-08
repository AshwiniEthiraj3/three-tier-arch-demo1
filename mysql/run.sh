#!/usr/bin/env bash
set -euo pipefail

# --- required env ---
: "${MYSQL_HOST:?set MYSQL_HOST}"
: "${MYSQL_USER:?set MYSQL_USER}"
: "${MYSQL_PASSWORD:?set MYSQL_PASSWORD}"

RATINGS_SQL="/root/20-ratings.sql"   # already in your image
CITIES_CSV="/root/cities.csv"        # already in your image (if you’re seeding)
CONVERT_SH="/root/convert.sh"        # already in your image

mysql_cmd() {
  mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$@"
}

echo "[run.sh] starting"

# --- wait for MySQL ---
echo "[run.sh] waiting for MySQL at ${MYSQL_HOST}:3306"
for i in {1..60}; do
  if mysql_cmd -e "SELECT 1" >/dev/null 2>&1; then
    echo "[run.sh] MySQL is reachable"
    break
  fi
  sleep 2
  if [[ $i -eq 60 ]]; then
    echo "[run.sh] ERROR: MySQL not reachable after wait"; exit 1
  fi
done

# --- ratings schema (idempotent) ---
if [[ -f "$RATINGS_SQL" ]]; then
  echo "--------------"
  echo "[run.sh] importing ratings schema"
  # Make the SQL idempotent (CREATE DATABASE/TABLE IF NOT EXISTS) if your file isn’t already.
  mysql_cmd < "$RATINGS_SQL" || true
  echo "--------------"
else
  echo "[run.sh] $RATINGS_SQL not found, skipping ratings schema"
fi

# OPTIONAL: ensure app user exists for ratings (adjust/remove as you like)
# mysql_cmd -e "CREATE USER IF NOT EXISTS 'ratings'@'%' IDENTIFIED BY 'iloveit'; GRANT ALL ON ratings.* TO 'ratings'@'%'; FLUSH PRIVILEGES;" || true

# --- ensure cities schema exists ---
echo "[run.sh] ensuring cities schema exists"
mysql_cmd -e "
CREATE DATABASE IF NOT EXISTS cities CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS cities.cities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  country_code CHAR(2) NOT NULL,
  city         VARCHAR(64)  NOT NULL,
  name         VARCHAR(128) NOT NULL,
  region       VARCHAR(64),
  latitude     DECIMAL(9,6),
  longitude    DECIMAL(9,6),
  KEY idx_city (city)
);
"

# --- seed cities only if empty ---
if [[ -f "$CITIES_CSV" && -f "$CONVERT_SH" ]]; then
  rows=$(mysql_cmd -N -s -D cities -e "SELECT COUNT(*) FROM cities;" || echo 0)
  if [[ "${rows}" == "0" ]]; then
    echo "[run.sh] seeding cities from CSV -> SQL"
    bash "$CONVERT_SH" "$CITIES_CSV" | mysql_cmd -D cities
    echo "[run.sh] cities seed complete"
  else
    echo "[run.sh] cities already has ${rows} rows, skipping seed"
  fi
else
  echo "[run.sh] ${CITIES_CSV} or ${CONVERT_SH} missing, skipping cities seed"
fi

echo "[run.sh] all done"
