#!/bin/bash 
set -e

echo "DOCKER_SERVICE:$DOCKER_SERVICE"

cd {{ project_path }}/releases 
OLD=$(ls -1 | tail -2)
LINE_COUNT=$(echo "$OLD" | wc -l)
echo "OLD:$OLD"
echo "LINE_COUNT:$LINE_COUNT"

if [[ $LINE_COUNT > 1 ]]; then 
    cd {{ project_path }}/releases/$(echo "$OLD" | head -1)
    docker-compose stop 
    docker-compose down
fi

cd {{ release_path }}
docker-compose up --no-start
echo -e "\n"

if [ $DOCKER_RUN_COMPOSER -ne 0 ]; then 
    docker-compose up -d
    ID=$(docker-compose ps -q $DOCKER_SERVICE)
    echo "ID:$ID"
    docker exec -i  $ID sh <<TEST
    pwd
    composer install --no-interaction --optimize-autoloader \
      --prefer-dist  --no-ansi --working-dir $DOCKER_APP_DIR
TEST
else
    echo "DOCKER_RUN_COMPOSER is set to $DOCKER_RUN_COMPOSER. Skipping Composer Dependencies."
fi
