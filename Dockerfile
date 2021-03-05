# common base - php prod image
FROM php:8.0-cli AS php-prod

ARG GROUP_ID=1000
ARG USER_ID=1000

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    mkdir -p /app \
    && groupadd -g "${GROUP_ID}" app \
    && adduser --no-create-home --disabled-password --gecos "" --uid "${USER_ID}" --gid "${GROUP_ID}" app \
    && chown -R app:app /app \
    && sync \
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
        /usr/local/bin/install-php-extensions

COPY ./config/prod/php.ini /usr/local/etc/php/php.ini
COPY ./config/prod/conf.d/* /usr/local/etc/php/conf.d/

VOLUME ["/app"]

WORKDIR /app

CMD ["-"]
ENTRYPOINT ["/usr/local/bin/php"]

# php dev image - includes xdebug and dev config for php + opcache
FROM php-prod AS php-dev

COPY ./config/dev/conf.d/* /usr/local/etc/php/conf.d/

USER app
