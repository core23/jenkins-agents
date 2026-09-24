FROM php:8.2

LABEL org.opencontainers.image.authors="mail@core23.de"

# Extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    apt-utils sendmail \
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
    wget \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        bcmath \
        gd \
        intl \
        mysqli \
        soap \
        zip \
        xsl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# NPM, PNPM, YARN
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g --unsafe-perm yarn pnpm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PIE
COPY --from=ghcr.io/php/pie:bin /pie /usr/bin/pie

RUN pie install pecl/pcov \
    && pie install mongodb/mongodb-extension \
    && pie install imagick/imagick \
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
RUN curl -sS https://get.symfony.com/cli/installer | bash -s -- --install-dir /usr/local/bin

# Define the Jenkins agent home directory
ENV JENKINS_AGENT_HOME=/home/jenkins/agent

# Install Java and curl
RUN apt-get update && apt-get install -y \
    openjdk-21-jre-headless \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the Jenkins user
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins
USER jenkins
WORKDIR $JENKINS_AGENT_HOME

# Download the JNLP agent launcher (JAR file)
ARG JENKINS_REMOTING_VERSION=3309.v27b_9314fd1a_4

RUN curl -Lo agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_REMOTING_VERSION}/remoting-${JENKINS_REMOTING_VERSION}.jar

# Run the agent when the container starts
ENTRYPOINT ["java", "-jar", "agent.jar"]
