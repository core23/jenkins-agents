FROM jenkins/inbound-agent:alpine

LABEL org.opencontainers.image.authors="Christian Gripp <mail@core23.de>"

# Switch to install mode
USER root

# cmd tools
RUN apk update && apk upgrade && apk add --update alpine-sdk && \
    apk add --no-cache make cmake gpg gpg-agent bash curl

# NPM
RUN apk add --no-cache nodejs npm \
    && npm install -g --unsafe-perm yarn pnpm

# PHP
RUN apk add --no-cache \
        -X https://dl-cdn.alpinelinux.org/alpine/edge/main \
        -X https://dl-cdn.alpinelinux.org/alpine/edge/community \
        -X https://dl-cdn.alpinelinux.org/alpine/edge/testing \
        php84 \
        php84-bcmath \
        php84-cli \
        php84-ctype \
        php84-curl \
        php84-dom \
        php84-exif \
        php84-fileinfo \
        php84-fpm \
        php84-gd \
        php84-iconv \
        php84-intl \
        php84-mbstring \
        php84-mysqli \
        php84-opcache \
        php84-openssl \
        php84-pcntl \
        php84-pdo \
        php84-pdo_mysql \
        php84-pdo_sqlite \
        php84-pecl-imagick \
        php84-pecl-mongodb \
        php84-pecl-pcov \
        php84-pecl-redis \
        php84-phar \
        php84-posix \
        php84-redis \
        php84-session \
        php84-simplexml \
        php84-soap \
        php84-sodium \
        php84-tokenizer \
        php84-xdebug \
        php84-xsl \
        php84-xml \
        php84-xmlreader \
        php84-xmlwriter \
        php84-zip \
        php84-zlib

RUN ln -sf /usr/bin/php84 /usr/bin/php

COPY php.ini /etc/php84/conf.d/custom.ini

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

ENTRYPOINT ["jenkins-slave"]
