FROM wordpress:6.7-php8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSLo /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY build-setup.sh /tmp/build-setup.sh
RUN chmod +x /tmp/build-setup.sh && /tmp/build-setup.sh && rm /tmp/build-setup.sh

COPY supervisord.conf /etc/supervisor/conf.d/wp.conf

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/wp.conf"]