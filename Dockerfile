FROM php:8.3-apache

# Instalar dependencias del sistema y extensiones comunes de PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        gd \
        intl \
        mbstring \
        bcmath \
        opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Habilitar mod_rewrite de Apache (necesario para rutas amigables / .htaccess)
RUN a2enmod rewrite

# Instalar Composer por si tu proyecto tiene composer.json
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Aumentar límites de PHP para scripts complejos (memoria, subida y tiempo de ejecución)
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/custom.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html

# Copiar los archivos del proyecto
COPY . /var/www/html/

# Instalar dependencias si existe composer.json
RUN if [ -f "composer.json" ]; then composer install --no-dev --optimize-autoloader; fi

# Ajustar permisos
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
