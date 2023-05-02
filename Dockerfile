ARG PHP_VERSION=""
FROM php:${PHP_VERSION}-apache-stretch

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844
 
ARG DEBIAN_FRONTEND=noninteractive

# Update
RUN apt-get -y update --fix-missing && \
    apt-get upgrade -y && \
    apt-get --no-install-recommends install -y apt-utils && \
    rm -rf /var/lib/apt/lists/*


# Install useful tools and install important libaries
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install nano wget dialog libsqlite3-dev libsqlite3-0 && \
    apt-get -y --no-install-recommends install mysql-client zlib1g-dev libzip-dev libicu-dev && \
    apt-get -y --no-install-recommends install --fix-missing apt-utils build-essential git curl && \ 
    apt-get -y --no-install-recommends install --fix-missing libcurl3 libcurl3-dev zip unzip openssl && \
    rm -rf /var/lib/apt/lists/*

# Install xdebug
RUN pecl install xdebug-2.7.2 && \
    docker-php-ext-enable xdebug

# Install redis. Uncomment only if needed
# RUN pecl install redis-5.0.2 && \
#     docker-php-ext-enable redis

# Other PHP7 Extensions

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install curl && \
    docker-php-ext-install tokenizer && \
    docker-php-ext-install json && \
    docker-php-ext-install zip && \
    docker-php-ext-install -j$(nproc) intl && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install opcache && \
    docker-php-ext-install gettext

# Install Freetype 
RUN apt-get -y update && \
    apt-get --no-install-recommends install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libwebp6 webp libmagickwand-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-webp-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd

# Enable apache modules
RUN a2enmod rewrite headers

# Cleanup
RUN rm -rf /usr/src/*

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install Drush
COPY --from=drush/drush:8 /usr/local/bin/drush /usr/local/bin/drush

# Install Drupalconsole. Uncomment only for Drupal project
# COPY --from=mparker17/drupalconsole /usr/local/bin/drupal /usr/local/bin/drupal

ENV WP_CLI_VERSION 2.4.0

## Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp-cli.phar && \
    echo '#!/bin/sh' >> /usr/local/bin/wp && \
    echo 'wp-cli.phar "$@" --allow-root' >> /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp && \
    wp cli version
