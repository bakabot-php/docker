# common base - php prod image
FROM php:8.0-cli AS php-prod

ARG GROUP_ID=1000
ARG USER_ID=1000
ARG WAIT_VERSION=2.7.3

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/${WAIT_VERSION}/wait /usr/local/bin/wait

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    chmod a+x /usr/local/bin/wait \
    && mkdir -p /app \
    && groupadd -g "${GROUP_ID}" app \
    && adduser --no-create-home --disabled-password --gecos "" --uid "${USER_ID}" --gid "${GROUP_ID}" app \
    && chown -R app:app /app \
    && sync \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && install-php-extensions \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        redis \
        sockets \
        xdebug \
    && rm /usr/local/etc/php/php.ini-* \
    && rm /usr/local/etc/php/conf.d/*.ini \
    && rm -rf \
        /tmp/* \
        /usr/local/bin/install-php-extensions \
        /var/cache/apt/*

COPY ./docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY ./config/prod/php.ini /usr/local/etc/php/php.ini
COPY ./config/prod/setlocale.php /usr/local/etc/php/setlocale.php
COPY ./config/prod/conf.d/* /usr/local/etc/php/conf.d/

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    HOME="/tmp" \
    TZ="UTC"

VOLUME ["/app"]

WORKDIR /app

CMD ["-"]
ENTRYPOINT ["/usr/local/bin/docker-php-entrypoint"]

# php dev image - includes xdebug and dev config for php + opcache
FROM php-prod AS php-dev

RUN apt update \
    && apt install -y --no-install-recommends \
        git \
    && rm -rf /var/cache/apt/*

COPY ./config/dev/conf.d/* /usr/local/etc/php/conf.d/

USER app
