FROM php:8.3-apache

# Moodle 4.5 LTS Systemabhaengigkeiten + PHP-Extensions
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip intl mysqli opcache xsl soap \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80

# Kein "git clone" hier drin -- der Moodle-Core wird per setup.sh
# auf dem Host geklont und per Bind-Mount reingereicht, damit
# direktes Arbeiten im Quellcode moeglich ist (kein Rebuild noetig).
