FROM kamerk22/laravel-alpine:7.4-mysql-nginx

RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} libxml2-dev libressl-dev pkgconfig libevent-dev libzip-dev && apk del pcre-dev ${PHPIZE_DEPS}
RUN docker-php-ext-install zip exif soap

COPY composer.json composer.json
#COPY composer.lock composer.lock
RUN composer global require hirak/prestissimo

RUN composer install --prefer-dist --no-scripts --no-autoloader && rm -rf /root/.composer

RUN apk update && \
    apk add libxml2-dev

ADD conf/nginx/default.conf /etc/nginx/conf.d/

ADD . .

RUN cp .env.example .env
RUN cp conf/supervisor/services.ini /etc/supervisor.d/

RUN chown -R www-data:www-data \
        /var/www/storage \
        /var/www/bootstrap/cache

RUN composer dump-autoload --no-scripts --optimize
RUN ln -s /var/www/storage/app/ /var/www/public/storage
RUN chmod 777 -R storage bootstrap/cache
ENTRYPOINT [ "/usr/bin/supervisord" ]