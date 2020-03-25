#!/bin/bash
# (c) Carsten Rieger IT-Services (Ubuntu 18.04) 14.03.2020
# Leanote
### START ###
cd /usr/local/src
mkdir leanote
cd leanote
wget https://sourceforge.net/projects/leanote-bin/files/2.6.1/leanote-linux-amd64-v2.6.1.bin.tar.gz
tar -xzvf leanote-darwin-amd64.v2.6.1.bin.tar.gz

### install mongodb ###
cd ..
mkdir mongodb
cd mongodb
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.1.tgz
tar -xzvf mongodb-linux-x86_64-3.0.1.tgz
cd /etc
echo "export PATH=$PATH:/usr/local/src/mongodb/mongodb-linux-x86_64-3.0.1/bin" | profile
source /etc/profile

mkdir /usr/local/src/data
mongod --dbpath /usr/local/src/data
mongorestore -h localhost -d leanote --dir /usr/local/src/leanote/mongodb_backup/leanote_install_data/
nohup mongo &

mongo

echo "show dbs #　查看数据库"
echo "use leanote # 切换到leanote"
echo "show collections # 查看表"

echo "https://github.com/leanote/leanote/wiki/QA#%E5%A6%82%E4%BD%95%E7%BB%91%E5%AE%9A%E5%9F%9F%E5%90%8D"
cd /usr/local/src/leanote/bin
bash run.sh



