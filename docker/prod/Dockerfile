# docker/prod/Dockerfile
FROM wordpress:6.7.1-php8.3-apache

# Set working directory
WORKDIR /var/www/html

# Copy custom WordPress configuration
# COPY config/wp-config.prod.php /var/www/html/wp-config.php

COPY ./wp-content /var/www/html/wp-content

# Enable production PHP settings
RUN echo "php_flag[display_errors] = off" >> /usr/local/etc/php/php.ini-production

# Expose port for production
EXPOSE 80
