# ---------- Stage 0: Base PHP 7.3 on Debian Buster ----------
  FROM php:7.3-apache AS vtiger

  # 使用 Buster archive 源，防止过期 & 清理可能残留源
  RUN rm -rf /etc/apt/sources.list.d/* \
      && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99disable-check-valid-until \
      && echo 'deb http://archive.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list \
      && echo 'deb http://archive.debian.org/debian buster-updates main contrib non-free' >> /etc/apt/sources.list \
      && echo 'deb http://archive.debian.org/debian-security buster/updates main contrib non-free' >> /etc/apt/sources.list

  # 更新 & 安装依赖，锁定 Buster 版本，清理缓存
  RUN apt-get update -o Acquire::Check-Valid-Until=false \
      && apt-get install -y --no-install-recommends \
         libpng-dev=1:1.6.36-6+deb10u3 \
         libjpeg-dev=1:1.5.2-2+deb10u1 \
         libfreetype6-dev=2.9.1-3+deb10u2 \
         libzip-dev=1.5.1-3.1+deb10u1 \
         libxml2-dev=2.9.4+dfsg1-7+deb10u6 \
         libicu-dev=63.1-6+deb10u1 \
         libcurl4-openssl-dev=7.64.0-4+deb10u9 \
         libonig-dev=6.9.4-1 \
         libldap2-dev=2.4.47+dfsg-3+deb10u7 \
         libxslt1-dev=1.1.32-2.2~deb10u1 \
      && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
      && docker-php-ext-install -j$(nproc) \
         gd mysqli pdo_mysql mbstring curl zip xml intl ldap xsl \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

  # 开启 Apache Rewrite 模块（vtiger 常用）
  RUN a2enmod rewrite

  # 设置工作目录
  WORKDIR /var/www/html

  # 复制项目代码
  COPY . .