FROM php:8.3-apache

# Moodle 5.2 Systemabhaengigkeiten + PHP-Extensions
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

# Ab Moodle 5.0 liegt der oeffentliche Webroot unter public/ statt im
# Repo-Wurzelverzeichnis (Symfony/Laravel-artige Umstrukturierung) --
# Apache muss deshalb auf public/ zeigen, nicht auf /var/www/html direkt.
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

EXPOSE 80

# Kein "git clone" hier drin -- der Moodle-Core wird per setup.sh
# auf dem Host geklont und per Bind-Mount reingereicht, damit
# direktes Arbeiten im Quellcode moeglich ist (kein Rebuild noetig).
