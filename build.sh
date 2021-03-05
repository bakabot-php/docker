#!/usr/bin/env bash

set -eux;

GROUP_ID="$(id -g)"
USER_ID="$(id -u)"

if [[ "${JOB_NAME:-nil}" != "nil" || "$OSTYPE" == darwin* ]]; then
    GROUP_ID=1000
    USER_ID=1000
fi

docker build \
    --pull \
    --target php-prod \
    -t "bakabot/php:latest" \
    ./

docker build \
    --target php-dev \
    --build-arg GROUP_ID="$GROUP_ID" \
    --build-arg USER_ID="$USER_ID" \
    -t "bakabot/php-dev:latest" \
    ./
