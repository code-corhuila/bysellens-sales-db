#!/bin/sh
set -eu
: "${DB_PASSWORD:?DB_PASSWORD is required}"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  -v app_password="$DB_PASSWORD" <<'SQL'
CREATE ROLE sales_app LOGIN PASSWORD :'app_password';
CREATE SCHEMA sales AUTHORIZATION sales_app;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT CONNECT ON DATABASE bysellens_db TO sales_app;
SQL
