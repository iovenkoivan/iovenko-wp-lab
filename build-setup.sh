#!/bin/bash
set -e

mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld
mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

mariadbd --user=mysql --datadir=/var/lib/mysql \
         --socket=/var/run/mysqld/mysqld.sock &
MYSQL_PID=$!
for i in {1..30}; do mariadb -e "SELECT 1" &>/dev/null && break; sleep 1; done

mariadb -e "CREATE DATABASE wordpress;
            CREATE USER 'wp'@'localhost' IDENTIFIED BY 'wppass';
            GRANT ALL ON wordpress.* TO 'wp'@'localhost';
            FLUSH PRIVILEGES;"

cp -a /usr/src/wordpress/. /var/www/html/
cd /var/www/html

wp config create --allow-root \
  --dbname=wordpress --dbuser=wp --dbpass=wppass --dbhost=127.0.0.1

wp core install --allow-root \
  --url=http://localhost:8080 \
  --title="WordPress Lab" \
  --admin_user=admin \
  --admin_password=admin \
  --admin_email=admin@example.com \
  --skip-email

wp plugin install --allow-root --activate --force \
  elementor --version=3.6.2

wp plugin install --allow-root --activate --force \
  contact-form-7 --version=5.3.1

wp plugin install --allow-root --activate --force \
  wp-super-cache --version=1.7.1

wp plugin install --allow-root --activate --force \
  duplicator --version=1.3.26

wp plugin install --allow-root --activate --force \
  all-in-one-seo-pack --version=4.1.5.2

chown -R www-data:www-data /var/www/html

mariadb-admin shutdown
wait $MYSQL_PID 2>/dev/null || true