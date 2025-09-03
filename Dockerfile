# syntax=docker/dockerfile:1.4
FROM php:7.3-apache

# 使用 BuildKit 缓存挂载，并确保可以写入配置
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    mkdir -p /etc/apt/apt.conf.d && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until && \
    echo 'deb http://archive.debian.org/debian bullseye main contrib non-free' > /etc/apt/sources.list && \
    echo 'deb http://archive.debian.org/debian bullseye-updates main contrib non-free' >> /etc/apt/sources.list && \
    apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libzip-dev \
        libxml2-dev \
        libicu-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libldap2-dev \
        libxslt1-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql mbstring curl zip xml intl ldap xsl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 开启 Apache Rewrite 模块（vtiger 常用）
RUN a2enmod rewrite

# 设置工作目录
WORKDIR /var/www/html

# 复制项目代码
COPY . .