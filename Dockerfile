FROM php:7.3-apache

# 使用 Buster archive 源（防止源过期）
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until \
 && sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list \
 && sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list

# 安装 PHP 扩展，并缓存 APT 下载的包
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update -o Acquire::Check-Valid-Until=false \
 && apt-get install -y \
      libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libxml2-dev libicu-dev \
      libcurl4-openssl-dev libonig-dev libldap2-dev libxslt1-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql mbstring curl zip xml intl ldap xsl \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# 启用 Apache Rewrite
RUN a2enmod rewrite

# 设置工作目录
WORKDIR /var/www/html

# 复制 vtiger 项目
COPY . .

# 给缓存设置权限（可选，保证 Apache 用户能访问）
RUN chown -R www-data:www-data /var/www/html
