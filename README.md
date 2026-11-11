# bysellens-sales-db

> sales bounded context: database (schema, seeds, migrations)

Part of the **LMS Library** distributed system — team `lms-library`, Grupo 2.
Governance and documentation live in [`library-docs`](https://github.com/code-corhuila/library-docs).

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `library-docs`.

## Sales PostgreSQL setup

Requirements: Docker Engine and Docker Compose v2.

1. Copy `.env.example` to `.env` and replace both password examples with
   distinct, strong local values. Keep `.env` private.
2. Run `docker compose up -d --wait` from this directory.
3. Run `docker compose ps` to check PostgreSQL health.
4. Stop with `docker compose down`; the named `postgres_data` volume persists.
   Do not use `down -v` on an existing environment.

Only PostgreSQL 17 is started. The database is `bysellens_db`; initialization
creates the login `sales_app` and the schema `sales`, owned by `sales_app`.
The administrator password comes from `POSTGRES_PASSWORD`; the application
password comes from `DB_PASSWORD`. SQL values are passed through psql quoting.
The host port defaults to 5432 and binds only to localhost. Set `POSTGRES_PORT`
if another database already uses that port.

The initialization script runs only when PostgreSQL initializes an empty data
volume. Changing `.env` does not change passwords or schemas in existing
volumes. Existing installations require an administrator to apply changes;
never delete an existing volume just to rerun initialization.

### Connect the Sales API

Configure the separately deployed Sales API with:

```dotenv
DB_URL=jdbc:postgresql://localhost:5432/bysellens_db
DB_USER=sales_app
DB_PASSWORD=replace-with-your-local-sales-password
```

Use the same `DB_PASSWORD` as PostgreSQL initialization. Adjust the host and
port for the API runtime: `localhost` applies to an API running on the Docker
host, while a container needs a reachable database hostname and network.
The API appends `?currentSchema=sales` to `DB_URL`; provide the base JDBC URL
without query parameters. Its Flyway configuration uses the `sales` schema.

Table creation belongs to the Sales API migration
`src/main/resources/db/migration/V1__initial.sql`, which creates `ventas` and
`detalles`. This repository does not duplicate that migration or ship APIs,
other service databases, or the complete backend Compose stack.
