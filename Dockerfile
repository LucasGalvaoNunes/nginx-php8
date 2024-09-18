FROM alpine:latest
LABEL Maintainer="Lucas Galvão Nunes <contato@lucasgnunes.dev>" \
      Description="Container limpo com Nginx 1.18 e PHP-FPM 8 baseado no Alpine Linux."

# Install packages and remove default server definition
RUN apk --no-cache add php82-fpm php82-common php82-opcache php82-mysqli php82-json \
    php82-openssl php82-pdo php82-pdo_mysql php82-curl php82-soap php82-zlib php82-xml php82-phar php82-intl php82-dom php82-xmlreader php82-ctype php82-session php82-simplexml \
    php82-mbstring php82-gd nginx supervisor curl php82-exif php82-zip php82-tokenizer php82-fileinfo php82-iconv php82-soap tzdata htop mysql-client \
    php82-pecl-imagick php82-pecl-redis php82-pecl-xdebug && \
    rm /etc/nginx/conf.d/default.conf

# Symling php8 => php
RUN ln -s /usr/bin/php82 /usr/bin/php

# Install PHP tools
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php82/php-fpm.d/www.conf
COPY config/php.ini /etc/php82/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody


# Add application
WORKDIR /var/www

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]



