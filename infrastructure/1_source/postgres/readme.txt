run command to res  tore database: ( after pgsql created)

docker exec postgres_source /bin/bash /docker-entrypoint-initdb.d/20-restore-dump.sh

