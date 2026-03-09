FROM php:8.4-fpm

# Cài đặt các thư viện hệ thống cần thiết (thêm libzip-dev để hỗ trợ zip)
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Cài đặt và kích hoạt Redis extension (C-extension)
RUN pecl install redis && docker-php-ext-enable redis

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# Cài đặt các thư viện PHP
RUN composer install --optimize-autoloader

# Phân quyền
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000