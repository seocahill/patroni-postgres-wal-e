# patroni-postgres-wal-e
Docker image for creating containers with postgres 12, patroni and wal-e installed.

Includes a separate healthcheck container which posts patroni cluster health updates to an instance of [healthchecks](https://github.com/healthchecks/healthchecks).
