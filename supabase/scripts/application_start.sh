#!/bin/bash

echo "STARTING THE APPLICATION"

DOCKER_BASE_DIRECTORY=/clone-me-project/supabase/docker
CLONE_ME_BASE_DIRECTORY=/clone-me-project/tmp

cd $DOCKER_BASE_DIRECTORY
python3 $CLONE_ME_BASE_DIRECTORY/scripts/add-migration-metadata.py
mkdir -p $DOCKER_BASE_DIRECTORY/db/migrations
cp -R $CLONE_ME_BASE_DIRECTORY/migrations $DOCKER_BASE_DIRECTORY/db
cp -R $CLONE_ME_BASE_DIRECTORY/functions $DOCKER_BASE_DIRECTORY/volumes
python3 $CLONE_ME_BASE_DIRECTORY/scripts/env-update.py

cp $CLONE_ME_BASE_DIRECTORY/env-config/.env.dev .env

echo "REFRESH DOCKER CONTAINER"
# docker-compose down -v
# rm -rf volumes/db/data/
docker-compose down
docker-compose up -d

echo "STARTING THE DB MIGRATION"
npx dbmate --url "postgres://postgres:C!onEme@127.0.0.1:54322/cloneme?sslmode=disable" up