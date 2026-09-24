ARG PHP_VERSION=8.5

# Source of the agent launcher script and remoting jar
FROM jenkins/inbound-agent:latest-jdk21 AS agent

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
    # opcache is built into PHP 8.5 and only needs to be installed on older versions
    && { php -m | grep -qi 'opcache' || exts="$exts opcache"; } \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" $exts \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# NPM, PNPM, YARN
RUN curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    && rm nodesource_setup.sh \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g --unsafe-perm yarn pnpm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PIE
COPY --from=ghcr.io/php/pie:bin /pie /usr/bin/pie

RUN pie install pecl/pcov \
    && pie install mongodb/mongodb-extension \
    && pie install imagick/imagick \
    && pie install phpredis/phpredis \
    && pie install xdebug/xdebug

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
