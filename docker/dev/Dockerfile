# docker/dev/Dockerfile
FROM wordpress:php8.3-apache

# Set working directory
WORKDIR /var/www/html

# Enable error display for PHP (development)
RUN echo "php_flag[display_errors] = on" >> /usr/local/etc/php/php.ini-development

# Copy custom WordPress configuration
# COPY config/wp-config.dev.php /var/www/html/wp-config.php

# Expose port for development
EXPOSE 80
