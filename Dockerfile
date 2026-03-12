FROM php:8.4-fpm

# 1. Cài đặt các thư viện hệ thống cần thiết
# Bổ sung libfreetype6-dev và libjpeg62-turbo-dev để hỗ trợ extension GD (phục vụ Maatwebsite Excel)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    nginx

# 2. Cấu hình và cài đặt PHP extensions
# Phải có docker-php-ext-configure gd thì extension GD mới nhận đủ định dạng ảnh
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# 3. Cài đặt và kích hoạt Redis
RUN pecl install redis && docker-php-ext-enable redis

# 4. Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Thiết lập thư mục làm việc
WORKDIR /var/www
COPY . .

# 6. Cài đặt các thư viện PHP
# QUAN TRỌNG: Thêm --ignore-platform-reqs để tránh lỗi lệch phiên bản PHP 8.2/8.4 khi build
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction --ignore-platform-reqs

# 7. Phân quyền
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000