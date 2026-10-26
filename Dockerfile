FROM php:8.2-apache

# Cài đặt các thư viện hệ thống cần thiết cho PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    sqlite3 \
    libsqlite3-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql pdo_sqlite zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Kích hoạt module rewrite của Apache
RUN a2enmod rewrite

# Cấu hình Apache AllowOverride cho /var/www/html và ServerName
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Thiết lập thư mục làm việc
WORKDIR /var/www/html

# Sao chép toàn bộ mã nguồn vào thư mục web server
COPY . /var/www/html/

# Phân quyền cho uploads và SQLite database
RUN chown -R www-data:www-data /var/www/html \
    && chmod 775 /var/www/html \
    && chmod -R 775 /var/www/html/uploads \
    && chmod 664 /var/www/html/wedding.sqlite || true

EXPOSE 80

CMD ["apache2-foreground"]
