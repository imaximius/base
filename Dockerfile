FROM php:7.4-fpm

MAINTAINER Maksym Churkyn <imaximius@gmail.com>

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libssl-dev \
    cron \
    systemd \
    supervisor \
    librabbitmq-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libonig-dev

# Install AMPQ ext
RUN pecl install amqp \
    && docker-php-ext-enable amqp

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-install pdo pdo_mysql bcmath sockets dom mbstring simplexml xml

# Install PHP extensions which depend on external libraries
RUN docker-php-ext-configure curl --with-curl \
    && docker-php-ext-install -j$(nproc) curl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer \
    && composer --version

# Install Opcache
RUN docker-php-ext-install opcache \
    && echo 'opcache.enable=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo 'opcache.fast_shutdown=0' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo 'opcache.memory_consumption=512' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo 'opcache.interned_strings_buffer=64' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo 'opcache.max_accelerated_files=32531' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && echo 'opcache.save_comments=1' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

RUN if ! $DEBUG; then echo 'opcache.validate_timestamps=0' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini; fi