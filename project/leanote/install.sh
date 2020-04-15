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
