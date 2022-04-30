FROM php:8.0.1-fpm

MAINTAINER mfrancaleal@gmail.com
# Use the default development php.ini configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
ENV HOME /var/www/html
WORKDIR /var/www/html

COPY . /var/www/html
#COPY crontab /etc/crontabs/root
ADD schedule/crontab /etc/cron.d/cron

RUN chmod 0644 /etc/cron.d/cron
RUN touch /var/log/cron.log

# Setup bare-minimum extra extensions for Laravel & others
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
	&& apt-get install -y --no-install-recommends \
        cron \
        sudo \
	    curl \
		libmemcached-dev  \
		libfreetype6-dev \
		libxml2-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		zlib1g-dev \
		libzip-dev \
		libz-dev \
		libpq-dev  \
		libsqlite3-dev  \
		libicu-dev \
		g++ \
		git \
		zip \
		libmcrypt-dev \
		libvpx-dev \
		libjpeg-dev \
		libpng-dev \
		bzip2 \
		wget \
		libexpat1-dev \
		libbz2-dev \
		libgmp3-dev \
		libldap2-dev \
		unixodbc-dev \
		libsnmp-dev \
		libpcre3-dev \
		libtidy-dev \
		libaspell-dev \
		tar \
		less \
		nano \
		libcurl4-gnutls-dev \
		apt-utils \
		libxrender1 \
		unzip \
		libonig-dev \
		libldap2-dev \
		libxslt-dev \
		libwebp-dev \
		libc-client-dev \
		libkrb5-dev \
		libpspell-dev \
		librabbitmq-dev \
		librabbitmq4 \
        nodejs \
        npm \
        mariadb-client \
    && phpModules=" \
                bcmath \
                bz2 \
                calendar \
                exif \
                gd \
                gettext \
                gmp \
                imap \
                intl \
                ldap \
                mysqli \
                opcache \
                pcntl \
                pdo_mysql \
                pdo_pgsql \
                pgsql \
                pspell \
                shmop \
                snmp \
                soap \
                sockets \
                sysvmsg \
                sysvsem \
                sysvshm \
                tidy \
                xsl \
                zip \
            " \
	&& docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
	&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
	&& docker-php-ext-install -j$(nproc) $phpModules \
	&& pecl install xdebug-3.0.0 \
	&& pecl install memcached-3.1.5 \
	&& pecl install apcu-5.1.19 \
	&& pecl install igbinary-3.1.6 \
	&& pecl install mongodb-1.9.0 \
	&& docker-php-ext-enable xdebug memcached apcu igbinary mongodb \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install composer and update path
ENV COMPOSER_HOME /composer
ENV PATH /composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install code quality tools
RUN composer global require "squizlabs/php_codesniffer=*"
RUN composer global require "pheromone/phpcs-security-audit=*"
RUN composer global require "phpcompatibility/php-compatibility=*"
RUN composer global require "dealerdirect/phpcodesniffer-composer-installer=*"
RUN composer global require "friendsofphp/php-cs-fixer=*"
RUN composer global require "phpmd/phpmd=*"
RUN composer global require "phpstan/phpstan=*"
RUN composer global require "vimeo/psalm=*"
RUN composer global require "sensiolabs/security-checker=*"
RUN composer global require "phpunit/phpunit=*"

# Copy custom config to PHP config dir.
COPY docker/php/custom.ini "$PHP_INI_DIR/conf.d/"
ENV PHP_IDE_CONFIG 'serverName=Michael'


RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

#setup npm
RUN npm install n -g
RUN n stable
RUN n latest
#RUN npm run dev

# Copy existing application directory contents
COPY . $HOME

# Copy existing application directory permissions
COPY --chown=www:www . $HOME

# Copy Nginx
COPY docker/config/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/conf.d/site.conf /etc/nginx/conf.d/site.conf

# Change current user to www
USER root

RUN echo "* * * * * root php /var/www/html/artisan schedule:run >> /var/log/cron.log 2>&1" >> /etc/crontab

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

CMD cron && docker-php-entrypoint php-fpm
