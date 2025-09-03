FROM php:7.3-apache

# 使用 Debian Buster archive 源
RUN rm -rf /etc/apt/sources.list.d/* \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until \
    && echo 'deb http://archive.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list \
    && echo 'deb http://archive.debian.org/debian buster-updates main contrib non-free' >> /etc/apt/sources.list \
    && echo 'deb http://archive.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list

# 更新 & 安装依赖（不要指定版本）
RUN apt-get update -o Acquire::Check-Valid-Until=false \
    && apt-get install -y --no-install-recommends \
       libpng-dev \
       libjpeg-dev \
       libfreetype6-dev \
       libzip-dev \
       libxml2-dev \
       libicu-dev \
       libcurl4-openssl-dev \
       libonig-dev \
       libldap2-dev \
       libxslt1-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
       gd mysqli pdo_mysql mbstring curl zip xml intl ldap xsl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 启用 Apache Rewrite 模块
RUN a2enmod rewrite

WORKDIR /var/www/html
COPY . .