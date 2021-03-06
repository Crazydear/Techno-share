#!/bin/bash
# (c) Carsten Rieger IT-Services (Ubuntu 18.04) 14.03.2020
# Typecho 1.1
# PHP 7.4
#########################################################
# Donatations are really appreciated
#########################################################

###global function to update and cleanup the environment
function update_and_clean() {
apt update
apt upgrade -y
apt autoclean -y
apt autoremove -y
}

###global function to restart all cloud services
function restart_all_services() {
/usr/sbin/service nginx restart
/usr/sbin/service mysql restart
/usr/sbin/service redis-server restart
/usr/sbin/service php7.4-fpm restart
}

### START ###
apt install gnupg gnupg2 lsb-release wget curl -y

###prepare the server environment
cd /etc/apt/sources.list.d
echo "deb [arch=amd64,arm64] http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -cs) main" | tee php.list
echo "deb [arch=amd64,arm64] http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" | tee nginx.list
echo "deb [arch=amd64,arm64] http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.4/ubuntu $(lsb_release -cs) main" | tee mariadb.list
###
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com:443 4F4EA0AAE5267A6C
apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com:443 0xF1656F24C74CD1D8
update_and_clean
apt install software-properties-common zip unzip screen git wget ffmpeg libfile-fcntllock-perl locate ghostscript tree htop -y
apt remove nginx nginx-common nginx-full -y --allow-change-held-packages

###instal NGINX using TLSv1.3, OpenSSL 1.1.1
update_and_clean
apt install nginx -y

###enable NGINX autostart
systemctl enable nginx.service

### prepare the NGINX
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && touch /etc/nginx/nginx.conf
cat <<EOF >/etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /var/run/nginx.pid;
events {
worker_connections 1024;
multi_accept on;
use epoll;
}
http {
server_names_hash_bucket_size 64;
upstream php-handler {
server unix:/run/php/php7.4-fpm.sock;
}
set_real_ip_from 127.0.0.1;
# set_real_ip_from 192.168.2.0/24;
real_ip_header X-Forwarded-For;
real_ip_recursive on;
include /etc/nginx/mime.types;
#include /etc/nginx/proxy.conf;
#include /etc/nginx/ssl.conf;
#include /etc/nginx/header.conf;
#include /etc/nginx/optimization.conf;
default_type application/octet-stream;
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log warn;
sendfile on;
send_timeout 3600;
tcp_nopush on;
tcp_nodelay on;
open_file_cache max=500 inactive=10m;
open_file_cache_errors on;
keepalive_timeout 65;
reset_timedout_connection on;
server_tokens off;
resolver 127.0.0.53 valid=30s;
resolver_timeout 5s;
include /etc/nginx/conf.d/*.conf;
}
EOF

###restart NGINX
/usr/sbin/service nginx restart

###create folders
mkdir -p /var/www/letsencrypt /etc/letsencrypt/rsa-certs /etc/letsencrypt/ecc-certs

###apply permissions
chown -R www-data:www-data /var/www

###install PHP - Backup default files
apt install php7.4-fpm php7.4-gd php7.4-mysql php7.4-curl php7.4-xml php7.4-zip php7.4-intl php7.4-mbstring php7.4-json php7.4-bz2 php7.4-ldap php-apcu imagemagick php-imagick -y
cp /etc/php/7.4/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf.bak
cp /etc/php/7.4/cli/php.ini /etc/php/7.4/cli/php.ini.bak
cp /etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini.bak
cp /etc/php/7.4/fpm/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf.bak
cp /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.bak

###PHP Mods: www.conf
sed -i "s/;env\[HOSTNAME\] = /env[HOSTNAME] = /" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;env\[TMP\] = /env[TMP] = /" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;env\[TMPDIR\] = /env[TMPDIR] = /" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;env\[TEMP\] = /env[TEMP] = /" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;env\[PATH\] = /env[PATH] = /" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm.max_children =.*/pm.max_children = 120/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm.start_servers =.*/pm.start_servers = 12/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm.min_spare_servers =.*/pm.min_spare_servers = 6/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/pm.max_spare_servers =.*/pm.max_spare_servers = 18/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;pm.max_requests =.*/pm.max_requests = 1000/" /etc/php/7.4/fpm/pool.d/www.conf

###PHP Mods: cli/php.ini
sed -i "s/output_buffering =.*/output_buffering = 'Off'/" /etc/php/7.4/cli/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/7.4/cli/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/7.4/cli/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10240M/" /etc/php/7.4/cli/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10240M/" /etc/php/7.4/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = Asia\/\Shanghai/" /etc/php/7.4/cli/php.ini

###PHP Mods: fpm/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
sed -i "s/output_buffering =.*/output_buffering = 'Off'/" /etc/php/7.4/fpm/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/7.4/fpm/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/7.4/fpm/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10240M/" /etc/php/7.4/fpm/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10240M/" /etc/php/7.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = Asia\/\Shanghai/" /etc/php/7.4/fpm/php.ini
sed -i "s/;session.cookie_secure.*/session.cookie_secure = True/" /etc/php/7.4/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/7.4/fpm/php.ini
sed -i "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" /etc/php/7.4/fpm/php.ini
sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/7.4/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/7.4/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/" /etc/php/7.4/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=1/" /etc/php/7.4/fpm/php.ini
sed -i "s/;opcache.save_comments=.*/opcache.save_comments=1/" /etc/php/7.4/fpm/php.ini
sed -i "$aapc.enable_cli=1" /etc/php/7.4/mods-available/apcu.ini

### Solution for ImageMagick errors
sed -i "s/rights=\"none\" pattern=\"PS\"/rights=\"read|write\" pattern=\"PS\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"EPI\"/rights=\"read|write\" pattern=\"EPI\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"PDF\"/rights=\"read|write\" pattern=\"PDF\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"XPS\"/rights=\"read|write\" pattern=\"XPS\"/" /etc/ImageMagick-6/policy.xml
ln -s /usr/local/bin/gs /usr/bin/gs

###restart PHP and NGINX
/usr/sbin/service php7.4-fpm restart
/usr/sbin/service nginx restart

###install MariaDB
apt update && apt install mariadb-server -y
/usr/sbin/service mysql stop

###configure MariaDB
mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
cat <<EOF >/etc/mysql/my.cnf
[client]
default-character-set = utf8mb4
port = 3306
[mysqld_safe]
log_error=/var/log/mysql/mysql_error.log
nice = 0
socket = /var/run/mysqld/mysqld.sock
[mysqld]
basedir = /usr
bind-address = 127.0.0.1
binlog_format = ROW
bulk_insert_buffer_size = 16M
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
concurrent_insert = 2
connect_timeout = 5
datadir = /var/lib/mysql
default_storage_engine = InnoDB
expire_logs_days = 10
general_log_file = /var/log/mysql/mysql.log
general_log = 0
innodb_buffer_pool_size = 1024M
innodb_buffer_pool_instances = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 32M
innodb_max_dirty_pages_pct = 90
innodb_file_per_table = 1
innodb_open_files = 400
innodb_io_capacity = 4000
innodb_flush_method = O_DIRECT
key_buffer_size = 128M
lc_messages_dir = /usr/share/mysql
lc_messages = en_US
log_bin = /var/log/mysql/mariadb-bin
log_bin_index = /var/log/mysql/mariadb-bin.index
log_error = /var/log/mysql/mysql_error.log
log_slow_verbosity = query_plan
log_warnings = 2
long_query_time = 1
max_allowed_packet = 16M
max_binlog_size = 100M
max_connections = 200
max_heap_table_size = 64M
myisam_recover_options = BACKUP
myisam_sort_buffer_size = 512M
port = 3306
pid-file = /var/run/mysqld/mysqld.pid
query_cache_limit = 2M
query_cache_size = 64M
query_cache_type = 1
query_cache_min_res_unit = 2k
read_buffer_size = 2M
read_rnd_buffer_size = 1M
skip-external-locking
skip-name-resolve
slow_query_log_file = /var/log/mysql/mariadb-slow.log
slow-query-log = 1
socket = /var/run/mysqld/mysqld.sock
sort_buffer_size = 4M
table_open_cache = 400
thread_cache_size = 128
tmp_table_size = 64M
tmpdir = /tmp
transaction_isolation = READ-COMMITTED
user = mysql
wait_timeout = 600
[mysqldump]
max_allowed_packet = 16M
quick
quote-names
[isamchk]
key_buffer = 16M
EOF
/usr/sbin/service mysql restart

###restart MariaDB server and connect to MariaDB to create the database
/usr/sbin/service mysql restart && mysql -uroot <<EOF
CREATE DATABASE typecho CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER typecho@localhost identified by 'typecho';
GRANT ALL PRIVILEGES on typecho.* to typecho@localhost;
FLUSH privileges;
EOF
clear
echo ""
echo " Your database server will now be hardened - just follow the instructions."
echo " Keep in mind: your MariaDB root password is still NOT set!"
echo ""

###harden your MariDB server
mysql_secure_installation
update_and_clean

###install Redis-Server
apt install redis-server php-redis -y
cp /etc/redis/redis.conf /etc/redis/redis.conf.bak
sed -i "s/port 6379/port 0/" /etc/redis/redis.conf
sed -i s/\#\ unixsocket/\unixsocket/g /etc/redis/redis.conf
sed -i "s/unixsocketperm 700/unixsocketperm 770/" /etc/redis/redis.conf
sed -i "s/# maxclients 10000/maxclients 512/" /etc/redis/redis.conf
usermod -a -G redis www-data
cp /etc/sysctl.conf /etc/sysctl.conf.bak && sed -i '$avm.overcommit_memory = 1' /etc/sysctl.conf

###install self signed certificates
apt install ssl-cert -y

###prepare NGINX for Typecho and SSL
[ -f /etc/nginx/conf.d/default.conf ] && mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
touch /etc/nginx/conf.d/default.conf
cat <<EOF >/etc/nginx/conf.d/typecho.conf
server {
server_name YOUR.DEDYN.IO;
listen 80 default_server;
listen [::]:80 default_server;
location / {
root   /var/www/typecho;
index  index.html index.htm index.php;
}
location ~ .*\.php(\/.*)*$  {
root   /var/www/typecho/;
fastcgi_pass   unix:/run/php/php7.4-fpm.sock;
fastcgi_index  index.php;
fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
include        fastcgi_params;
}
}
EOF

###create a Let's Encrypt vhost file
touch /etc/nginx/conf.d/letsencrypt.conf
cat <<EOF >/etc/nginx/conf.d/letsencrypt.conf
server
{
server_name 127.0.0.1;
listen 127.0.0.1:81 default_server;
charset utf-8;
location ^~ /.well-known/acme-challenge
{
default_type text/plain;
root /var/www/letsencrypt;
}
}
EOF

###create a ssl configuration file
touch /etc/nginx/ssl.conf
cat <<EOF >/etc/nginx/ssl.conf
ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
ssl_trusted_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
#ssl_certificate /etc/letsencrypt/rsa-certs/fullchain.pem;
#ssl_certificate_key /etc/letsencrypt/rsa-certs/privkey.pem;
#ssl_certificate /etc/letsencrypt/ecc-certs/fullchain.pem;
#ssl_certificate_key /etc/letsencrypt/ecc-certs/privkey.pem;
#ssl_trusted_certificate /etc/letsencrypt/ecc-certs/chain.pem;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
ssl_session_timeout 1d; ssl_session_cache shared:SSL:50m;
ssl_session_tickets off; ssl_protocols TLSv1.3 TLSv1.2;
ssl_ciphers 'TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384';
ssl_ecdh_curve X448:secp521r1:secp384r1:prime256v1;
ssl_prefer_server_ciphers on;
ssl_stapling on;
ssl_stapling_verify on;
EOF

###add a default dhparam.pem file // https://wiki.mozilla.org/Security/Server_Side_TLS#ffdhe4096
touch /etc/ssl/certs/dhparam.pem
cat <<EOF >/etc/ssl/certs/dhparam.pem
-----BEGIN DH PARAMETERS-----
MIICCAKCAgEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
ssbzSibBsu/6iGtCOGEfz9zeNVs7ZRkDW7w09N75nAI4YbRvydbmyQd62R0mkff3
7lmMsPrBhtkcrv4TCYUTknC0EwyTvEN5RPT9RFLi103TZPLiHnH1S/9croKrnJ32
nuhtK8UiNjoNq8Uhl5sN6todv5pC1cRITgq80Gv6U93vPBsg7j/VnXwl5B0rZp4e
8W5vUsMWTfT7eTDp5OWIV7asfV9C1p9tGHdjzx1VA0AEh/VbpX4xzHpxNciG77Qx
iu1qHgEtnmgyqQdgCpGBMMRtx3j5ca0AOAkpmaMzy4t6Gh25PXFAADwqTs6p+Y0K
zAqCkc3OyX3Pjsm1Wn+IpGtNtahR9EGC4caKAH5eZV9q//////////8CAQI=
-----END DH PARAMETERS-----
EOF

###create a proxy configuration file
touch /etc/nginx/proxy.conf
cat <<EOF >/etc/nginx/proxy.conf
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-Host \$host;
proxy_set_header X-Forwarded-Protocol \$scheme;
proxy_set_header X-Forwarded-For \$remote_addr;
proxy_set_header X-Forwarded-Port \$server_port;
proxy_set_header X-Forwarded-Server \$host;
proxy_connect_timeout 3600;
proxy_send_timeout 3600;
proxy_read_timeout 3600;
proxy_redirect off;
EOF

###create a header configuration file
touch /etc/nginx/header.conf
cat <<EOF >/etc/nginx/header.conf
add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";
add_header X-Robots-Tag none always;
add_header X-Download-Options noopen always;
add_header X-Permitted-Cross-Domain-Policies none always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer" always;
add_header X-Frame-Options "SAMEORIGIN" always;
EOF

###create a nginx optimization file
touch /etc/nginx/optimization.conf
cat <<EOF >/etc/nginx/optimization.conf
fastcgi_hide_header X-Powered-By;
fastcgi_read_timeout 3600;
fastcgi_send_timeout 3600;
fastcgi_connect_timeout 3600;
fastcgi_buffers 64 64K;
fastcgi_buffer_size 256k;
fastcgi_busy_buffers_size 3840K;
fastcgi_cache_key \$http_cookie\$request_method\$host\$request_uri;
fastcgi_cache_use_stale error timeout invalid_header http_500;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
gzip on;
gzip_vary on;
gzip_comp_level 4;
gzip_min_length 256;
gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
gzip_disable "MSIE [1-6]\.";
EOF

###create a nginx php optimization file
touch /etc/nginx/php_optimization.conf
cat <<EOF >/etc/nginx/php_optimization.conf
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
fastcgi_param PATH_INFO \$path_info;
fastcgi_param modHeadersAvailable true;
fastcgi_param front_controller_active true;
fastcgi_pass php-handler;
fastcgi_param HTTPS on;
fastcgi_intercept_errors on;
fastcgi_request_buffering off;
fastcgi_cache_valid 404 1m;
fastcgi_cache_valid any 1h;
fastcgi_cache_methods GET HEAD;
EOF

###enable all nginx configuration files
sed -i s/\#\include/\include/g /etc/nginx/nginx.conf
sed -i "s/server_name YOUR.DEDYN.IO;/server_name $(hostname);/" /etc/nginx/conf.d/typecho.conf

###create Typecho cronjob
(crontab -u www-data -l ; echo "*/5 * * * * php -f /var/www/typecho/cron.php > /dev/null 2>&1") | crontab -u www-data -

###restart NGINX
/usr/sbin/service nginx restart

###Download Typecho 1.1 release and extract it
wget https://github.com/typecho/typecho/releases/download/v1.1-17.10.30-release/1.1.17.10.30.-release.tar.gz
tar -xjf 1.1.17.10.30.-release.tar.gz -C /var/www
mv /var/www/build /var/www/typecho

###apply permissions
chown -R www-data:www-data /var/www/
chmod 777 /var/www/typecho -R

###remove the Typecho sources
rm -f 1.1.17.10.30.-release.tar.gz

###update and restart all sources and services
update_and_clean
restart_all_services
clear

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "Your TYPECHO will now be installed - please open ip in your brower ..."
echo ""
### CleanUp
cat /dev/null > ~/.bash_history && history -c && history -w
exit 0
