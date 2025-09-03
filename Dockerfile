# 使用官方 PHP 7.3 + Apache Buster 镜像，依赖版本稳定
FROM php:7.3-apache-buster

# 安装必要的 PHP 扩展和工具
RUN apt-get update \
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
