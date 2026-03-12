FROM php:8.4-fpm

# 1. Cài đặt các thư viện hệ thống cần thiết
# Bổ sung các thư viện hỗ trợ xử lý ảnh (GD) và nén (Zip)
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
# Cần configure gd trước khi cài để Maatwebsite Excel không bị lỗi font/ảnh
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
# Thêm --ignore-platform-reqs để bỏ qua việc kiểm tra ext-gd hay PHP 8.4 ở tầng build của Railway
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-interaction --ignore-platform-reqs

# 7. Phân quyền cho Laravel (Quan trọng để không bị lỗi 500 Permission denied)
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

EXPOSE 8000

# Khuyên dùng: Dùng artisan serve cho môi trường test/dev trên Railway
CMD php artisan serve --host=0.0.0.0 --port=8000