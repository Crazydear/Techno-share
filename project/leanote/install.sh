#!/bin/bash
# (c) Carsten Rieger IT-Services (Ubuntu 18.04) 14.03.2020
# Nextcloud 18

function Down_leanote_mongodb(){
wget -O /usr/local/mongodb.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.1.tgz
echo ""
echo "leanote下载很慢的，你可以选择自行下载再上传到/var/www并且把本脚本的Down_leanote_mongodb注释掉,下面提供两个下载地址"
echo "https://github.com/Crazydear/Techno-share/raw/master/project/leanote/leanote-linux-amd64-v2.6.1.bin.tar.gz"
echo "https://sourceforge.net/projects/leanote-bin/files/2.6.1/leanote-linux-amd64-v2.6.1.bin.tar.gz"
echo ""
wget -O /var/www/leanote.bin.tar.gz https://sourceforge.net/projects/leanote-bin/files/2.6.1/leanote-linux-amd64-v2.6.1.bin.tar.gz
}
Down_leanote_mongodb
cd /var/www
tar -xzvf leanote.bin.tar.gz
clear

function install_mongodb(){
cd /usr/local
tar -xzvf mongodb.tgz
clear
mv mongodb-linux-x86_64-3.0.1 mongodb
echo 'export PATH=$PATH:/usr/local/mongodb/bin'>>/etc/profile
source /etc/profile
mkdir  /var/lib/mongodbData
mongod --dbpath /var/lib/mongodbData &
mongorestore -h localhost -d leanote --dir /var/www/leanote/mongodb_backup/leanote_install_data/
mongo<<EOF
show dbs #　查看数据库
use leanote # 切换到leanote
show collections # 查看表
EOF
}
install_mongodb

function optimizations_mongodb(){
mongo<<EOF 
use leanote;
db.createUser({
user: 'leanote',
pwd: 'leanote123',
roles: [{role: 'dbOwner', db: 'leanote'}]
});
db.auth("leanote", "leanote123");
EOF
mongod --dbpath /var/lib/mongodbData --auth &
sed -i 's/db.username=/db.username= leanote/' /var/www/leanote/conf/app.conf
sed -i 's/db.password=/db.password= leanote123/' /var/www/leanote/conf/app.conf
}
optimizations_mongodb

echo "leanote的配置存储在文件 conf/app.conf 中。"
echo "请务必修改app.secret一项, 在若干个随机位置处，将字符修改成一个其他的值, 否则会有安全隐患!"
echo "其它的配置可暂时保持不变, 若需要配置数据库信息, 请参照 leanote问题汇总。"
cd  /var/www/leanote/bin
bash run.sh &
echo "恭喜你, 打开浏览器输入: http://localhost:9000 体验leanote吧!"
cat /dev/null > ~/.bash_history && history -c && history -w
exit 0

function createCert(){
# create self-signed server certificate:
read -p "Enter your domain [www.example.com]: " DOMAIN
echo "Create server key..."
openssl genrsa -des3 -out $DOMAIN.key 1024
echo "Create server certificate signing request..."
SUBJECT="/C=US/ST=Mars/L=iTranswarp/O=iTranswarp/OU=iTranswarp/CN=$DOMAIN"
openssl req -new -subj $SUBJECT -key $DOMAIN.key -out $DOMAIN.csr
echo "Remove password..."
mv $DOMAIN.key $DOMAIN.origin.key
openssl rsa -in $DOMAIN.origin.key -out $DOMAIN.key
echo "Sign SSL certificate..."
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
}

function Nginx_zhuanfa(){
[ -f /etc/nginx/conf.d/default.conf ] && mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
touch /etc/nginx/conf.d/default.conf
cat <<EOF >/etc/nginx/conf.d/leanote.conf
server
    {
        listen  80;
        server_name  a.com;
        
        # 强制https
        # 如果不需要, 请注释这一行rewrite
        rewrite ^/(.*) https://jp_linode2.com/$1 permanent;
        
        location / {
            proxy_pass        http://a.com;
            proxy_set_header   Host             \$host;
            proxy_set_header   X-Real-IP        \$remote_addr;
            proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
        }
    }
    
    # https
    server
    {
        listen  443 ssl;
        server_name  a.com;
        ssl_certificate     /root/a.com.crt; # 修改路径, 到a.com.crt, 下同
        ssl_certificate_key /root/a.com.key;
        location / {
            proxy_pass        http://a.com;
            proxy_set_header   Host             \$host;
            proxy_set_header   X-Real-IP        \$remote_addr;
            proxy_set_header   X-Forwarded-For  \$proxy_add_x_forwarded_for;
        }
    }
}
EOF
}
