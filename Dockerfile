FROM php:8.1.0-apache

COPY --from=composer /usr/bin/composer /usr/bin/composer
# WORKDIR /var/www/html
# RUN apt-get update && apt-get install -y \
# 		libfreetype-dev \
# 		libjpeg62-turbo-dev \
# 		libpng-dev \
# 	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
# 	&& docker-php-ext-install -j$(nproc) gd \
RUN apt-get update && apt-get install -y \
    vim \
    zlib1g-dev \
    libzip-dev \
    libwebp-dev libjpeg62-turbo-dev libpng-dev \
    libfreetype6-dev \
    libxml2-dev \
    unzip && \
    a2enmod rewrite headers && \
    #sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    #sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install bcmath pdo_mysql zip opcache gd exif && \
    pecl install xdebug-3.1.6 && \
    docker-php-ext-enable xdebug
# ARG uid
# RUN useradd -G www-data,root -u $uid -d /home/devuser devuser && \
#     mkdir -p /home/devuser/.composer && \
#     chown -R devuser:devuser /home/devuser

# OpenSSLのセキュリティレベルを変更(`cURL error 35: error:1414D172:SSL routines:tls12_check_peer_sigalg:wrong signature type (see https://curl.haxx.se/libcurl/c/libcurl-errors.html) for https://stbfep.sps-system.com/api/xmlapi.do`対策)
# RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/' /etc/ssl/openssl.cnf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80