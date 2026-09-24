Jenkins Agents
==============

[![Continuous Integration](https://github.com/core23/jenkins-docker-agents/actions/workflows/continuous-integration.yml/badge.svg)](https://github.com/core23/jenkins-docker-agents/actions/workflows/continuous-integration.yml)

PHP Agents
----------

Jenkins inbound agents with PHP, Composer, Node.js (npm, yarn, pnpm), phive and the Symfony CLI.
The images are published to [DockerHub](https://hub.docker.com/r/core23/jenkins-php-agent) and
[GitHub Container Registry](https://github.com/core23/jenkins-docker-agents/pkgs/container/jenkins-php-agent).

### Tags

| Tag                  | Description                                    |
|----------------------|------------------------------------------------|
| `latest`             | Newest PHP version (Alpine)                    |
| `8.5`, `8.4`, `8.3`, `8.2` | PHP version on Alpine                    |
| `8.5-alpine`, `8.4-alpine`, `8.3-alpine`, `8.2-alpine` | PHP version on Alpine |
| `8.5-debian`, `8.4-debian`, `8.3-debian`, `8.2-debian` | PHP version on Debian |

The images are rebuilt every night to pick up security updates.

### Usage

If you have a jenkins server running (on serverhost:8080), you can connect the agent via the following command.

```bash
docker run -d --restart always -v ~/.composer:/home/jenkins/.composer ghcr.io/core23/jenkins-php-agent:latest -url http://serverhost:8080 SECRET AGENT_NAME
```

Use a specific tag like `8.4` or `8.4-debian` to pin the PHP version and the base image.

Please have a look at the [official docs](https://hub.docker.com/r/jenkins/inbound-agent) for more information.

### PHP configuration

Xdebug is installed but disabled by default. Enable it on demand, for example for code coverage:

```bash
XDEBUG_MODE=coverage vendor/bin/phpunit
```

### Building locally

The PHP version is passed as a build argument:

```bash
docker build php/alpine --build-arg PHP_VERSION=8.4 -t jenkins-php-agent:8.4-alpine
docker build php/debian --build-arg PHP_VERSION=8.4 -t jenkins-php-agent:8.4-debian
```
