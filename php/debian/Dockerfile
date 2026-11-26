ARG PHP_VERSION=8.5
ARG NODE_VERSION=24

# Source of the agent launcher script and remoting jar
FROM jenkins/inbound-agent:latest-jdk21 AS agent

# Source of the Node.js binaries, so Alpine and Debian images share the same major version
FROM node:${NODE_VERSION}-trixie-slim AS node

FROM php:${PHP_VERSION}-cli-trixie

ARG PHP_VERSION

LABEL org.opencontainers.image.authors="mail@core23.de"

# Extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libxslt-dev \
    libmagickwand-dev \
    unzip \
    gnupg2 \
    curl \
    git \
    ant \
    openssh-client \
    openjdk-21-jre-headless \
    sendmail \
    wget \
    && exts="bcmath exif gd intl mysqli pcntl pdo_mysql soap xsl zip" \
    # opcache is built into PHP 8.5+ and only needs to be installed on older versions
    && { php -m | grep -qi 'opcache' || exts="$exts opcache"; } \
    # mbstring is no longer built into the PHP 8.6 image
    && { php -m | grep -qi 'mbstring' || exts="$exts mbstring"; } \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" $exts \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# NPM, PNPM, YARN
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && npm install -g yarn pnpm

# PIE
COPY --from=ghcr.io/php/pie:bin /pie /usr/bin/pie

# pcov has no release for PHP 8.6 yet, build the fix from krakjoe/pcov#134 until it is released
RUN if [ "$(echo "${PHP_VERSION}" | tr -d .)" -ge 86 ]; then \
        git init /tmp/pcov \
        && git -C /tmp/pcov fetch --depth 1 https://github.com/krakjoe/pcov.git f04029fa86ae58c6dfff8049de8433669dbf1394 \
        && git -C /tmp/pcov checkout FETCH_HEAD \
        && cd /tmp/pcov && phpize && ./configure && make -j"$(nproc)" && make install \
        && docker-php-ext-enable pcov \
        && rm -rf /tmp/pcov; \
    else \
        pie install pecl/pcov; \
    fi

# imagick has no release for PHP 8.6 yet (Imagick/imagick#768 removes the zval_dtor() alias), patch master until it is released
RUN if [ "$(echo "${PHP_VERSION}" | tr -d .)" -ge 86 ]; then \
        git init /tmp/imagick \
        && git -C /tmp/imagick fetch --depth 1 https://github.com/Imagick/imagick.git 55ed2e9fda264395636a2e27e51f31673f5566ab \
        && git -C /tmp/imagick checkout FETCH_HEAD \
        && cd /tmp/imagick \
        && sed -i 's/zval_dtor(/zval_ptr_dtor_nogc(/' imagick.c \
        && phpize && ./configure && make -j"$(nproc)" && make install \
        && docker-php-ext-enable imagick \
        && rm -rf /tmp/imagick; \
    else \
        pie install imagick/imagick; \
    fi

# phpredis has no release with PHP 8.6 support yet, build develop until it is released
RUN if [ "$(echo "${PHP_VERSION}" | tr -d .)" -ge 86 ]; then \
        git init /tmp/phpredis \
        && git -C /tmp/phpredis fetch --depth 1 https://github.com/phpredis/phpredis.git adf5196a9f1e601c4976a41a3657f533da7d69a4 \
        && git -C /tmp/phpredis checkout FETCH_HEAD \
        && cd /tmp/phpredis \
        && phpize && ./configure && make -j"$(nproc)" && make install \
        && docker-php-ext-enable redis \
        && rm -rf /tmp/phpredis; \
    else \
        pie install phpredis/phpredis; \
    fi

# xdebug 3.5 excludes PHP 8.6, build master until a release supports it
RUN if [ "$(echo "${PHP_VERSION}" | tr -d .)" -ge 86 ]; then \
        git init /tmp/xdebug \
        && git -C /tmp/xdebug fetch --depth 1 https://github.com/xdebug/xdebug.git 5e19866c1766e38c527f9f94faa170370dc4209f \
        && git -C /tmp/xdebug checkout FETCH_HEAD \
        && cd /tmp/xdebug \
        && phpize && ./configure --enable-xdebug && make -j"$(nproc)" && make install \
        && docker-php-ext-enable xdebug \
        && rm -rf /tmp/xdebug; \
    else \
        pie install xdebug/xdebug; \
    fi

# Authenticated GitHub access avoids anonymous rate limits when PIE downloads the package
RUN --mount=type=secret,id=github_token \
    if [ -s /run/secrets/github_token ]; then \
        export COMPOSER_AUTH="{\"github-oauth\":{\"github.com\":\"$(cat /run/secrets/github_token)\"}}"; \
    fi; \
    pie install mongodb/mongodb-extension

# PHPStan Turbo requires PHP 8.3 or newer
RUN if [ "$(echo "${PHP_VERSION}" | tr -d .)" -ge 83 ]; then pie install phpstan/turbo; fi

# Composer
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

# Jenkins agent, taken from the official inbound-agent image
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent

ENV AGENT_WORKDIR=${AGENT_WORKDIR}

COPY --from=agent /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar
COPY --from=agent /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent

RUN groupadd -g ${gid} ${group} \
    && useradd -m -d /home/${user} -u ${uid} -g ${gid} -s /bin/bash ${user} \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave \
    && mkdir -p /home/${user}/.jenkins "${AGENT_WORKDIR}" \
    && chown -R ${uid}:${gid} /home/${user}

USER ${user}
WORKDIR /home/${user}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
