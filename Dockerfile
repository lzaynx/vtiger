# 使用官方 PHP 7.3 + Apache 镜像
FROM php:7.3-apache

# 防止 Debian 仓库过期问题（Buster 版本）
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until \
 && echo 'deb http://archive.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list \
 && echo 'deb http://archive.debian.org/debian buster-updates main contrib non-free' >> /etc/apt/sources.list

# 安装必要 PHP 扩展和工具
RUN apt-get update -o Acquire::Check-Valid-Until=false \
 && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    zip \
    unzip \
    git \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql zip intl opcache \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 启用 Apache 重写模块
RUN a2enmod rewrite

# 复制 vtiger 项目到 Apache 的根目录
COPY . /var/www/html/

# 设置工作目录
WORKDIR /var/www/html
