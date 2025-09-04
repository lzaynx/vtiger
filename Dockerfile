FROM php:7.4-apache-buster

# 修改源到 archive.debian.org
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until \
 && sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list \
 && sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list

# 安装 PHP 扩展和工具
RUN apt-get update -o Acquire::Check-Valid-Until=false \
 && apt-get install -y --no-install-recommends \
      libpng-dev libjpeg-dev libfreetype6-dev \
      libzip-dev libxml2-dev libicu-dev \
      zip unzip git \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql zip intl opcache \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 启用 Apache rewrite
RUN a2enmod rewrite

# 复制 vtiger 项目
COPY . /var/www/html/

WORKDIR /var/www/html

# 调整权限给 Apache 用户
RUN chown -R www-data:www-data /var/www/html