# 1. Nâng cấp lên PHP 8.4-fpm để khớp với composer.json
FROM php:8.4-fpm

# 2. Cài đặt thêm libzip-dev để hỗ trợ extension zip
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    nginx

# 3. Cài đặt pdo_mysql và quan trọng là ZIP (cần cho Excel)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# 4. Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# 5. Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# 6. Chạy cài đặt thư viện
RUN composer install --no-dev --optimize-autoloader

# 7. Phân quyền
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000