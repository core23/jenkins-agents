ARG PHP_VERSION=8.5
ARG NODE_VERSION=24

FROM jenkins/inbound-agent:alpine

ARG PHP_VERSION
ARG NODE_VERSION

LABEL org.opencontainers.image.authors="Christian Gripp <mail@core23.de>"

# Switch to install mode
USER root

# cmd tools
RUN apk update && apk upgrade && apk add --update alpine-sdk && \
    apk add --no-cache make cmake gpg gpg-agent bash curl

# NPM
RUN apk add --no-cache "nodejs~=${NODE_VERSION}" npm \
    && npm install -g yarn pnpm

# PHP
COPY php.ini /tmp/php.ini

RUN set -eux; \
    v="$(echo "${PHP_VERSION}" | tr -d .)"; \
    set -- "php${v}"; \
    for ext in \
        bcmath ctype curl dom exif fileinfo fpm gd iconv intl mbstring mysqli openssl pcntl \
        pdo pdo_mysql pdo_sqlite pecl-imagick pecl-mongodb pecl-pcov pecl-redis phar posix \
        session simplexml soap sodium tokenizer xsl xml xmlreader xmlwriter zip; \
    do \
        set -- "$@" "php${v}-${ext}"; \
    done; \
    # PHP 8.5 ships cli, opcache and zlib in the core package and names xdebug differently
    if [ "${v}" = "85" ]; then \
        set -- "$@" "php${v}-pecl-xdebug"; \
    else \
        set -- "$@" "php${v}-cli" "php${v}-opcache" "php${v}-xdebug" "php${v}-zlib"; \
    fi; \
    apk add --no-cache \
        -X https://dl-cdn.alpinelinux.org/alpine/edge/main \
        -X https://dl-cdn.alpinelinux.org/alpine/edge/community \
        -X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
        "$@"; \
    ln -sf "/usr/bin/php${v}" /usr/bin/php; \
    mv /tmp/php.ini "/etc/php${v}/conf.d/custom.ini"

# Get Composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# Get phive
RUN wget -O phive.phar "https://phar.io/releases/phive.phar" && \
    wget -O phive.phar.asc "https://phar.io/releases/phive.phar.asc" && \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x6AF725270AB81E04D79442549D8A98B29B2D5D79 && \
    gpg --verify phive.phar.asc phive.phar && \
    rm phive.phar.asc && \
    chmod +x phive.phar && \
    mv phive.phar /usr/local/bin/phive

# Symfony CLI
RUN curl -fsSL https://get.symfony.com/cli/installer -o symfony_installer.sh \
    && bash symfony_installer.sh --install-dir /usr/local/bin \
    && rm symfony_installer.sh

USER jenkins

ENTRYPOINT ["jenkins-agent"]
