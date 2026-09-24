#!/bin/sh
# Runs inside the built image: docker run --rm -i --entrypoint sh IMAGE -s < smoke-test.sh
set -eu

extensions="bcmath ctype curl dom exif fileinfo gd iconv imagick intl mbstring mongodb mysqli \
openssl pcntl pcov PDO pdo_mysql pdo_sqlite Phar posix redis session SimpleXML soap sodium \
tokenizer xdebug xml xmlreader xmlwriter xsl zip zlib"

missing=0
for ext in $extensions "Zend OPcache"; do
    if ! php -r "exit(extension_loaded('$ext') ? 0 : 1);"; then
        echo "Missing PHP extension: $ext"
        missing=1
    fi
done
[ "$missing" -eq 0 ]

php -r 'exit(ini_get("xdebug.mode") === "off" ? 0 : 1);' || { echo "xdebug.mode is not off"; exit 1; }
php -r 'exit(ini_get("opcache.enable_cli") ? 0 : 1);' || { echo "opcache.enable_cli is not enabled"; exit 1; }

php --version
composer --version
phive --version
symfony version --no-interaction
node --version
npm --version
yarn --version
pnpm --version
git --version
