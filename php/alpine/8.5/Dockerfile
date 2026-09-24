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
        php85 \
        php85-bcmath \
        php85-ctype \
        php85-curl \
        php85-dom \
        php85-exif \
        php85-fileinfo \
        php85-fpm \
        php85-gd \
        php85-iconv \
        php85-intl \
        php85-mbstring \
        php85-mysqli \
        php85-openssl \
        php85-pcntl \
        php85-pdo \
        php85-pdo_mysql \
        php85-pdo_sqlite \
        php85-pecl-imagick \
        php85-pecl-mongodb \
        php85-pecl-pcov \
        php85-pecl-redis \
        php85-pecl-xdebug \
        php85-phar \
        php85-posix \
        php85-session \
        php85-simplexml \
        php85-soap \
        php85-sodium \
        php85-tokenizer \
        php85-xsl \
        php85-xml \
        php85-xmlreader \
        php85-xmlwriter \
        php85-zip

RUN ln -sf /usr/bin/php85 /usr/bin/php

COPY php.ini /etc/php85/conf.d/custom.ini

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
