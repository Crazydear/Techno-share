## 1.nginx 解决 connect() failed (111: Connection refused) while connecting to upstream,
比如刚装完的时候访问显示502，

也不知道什么问题，就去看了一下nginx日志  /var/log/nginx/error.log,发现了这个错误

2018/06/03 13:38:23 [error] 21332#21332: *301 connect() failed (111: Connection refused) while connecting to upstream, client: 115.159.183.71, server: 202.182.116.84, request: "GET /phpmyadmin/index.php HTTP/1.1", upstream: "fastcgi://127.0.0.1:9000", host: "202.182.116.84"
去搜了一下，这样的错误有两个解决方式

 1.php-fpm没有运行
执行如下命令查看是否启动了php-fpm，如果没有则启动你的php-fpm即可

netstat -ant | grep 9000
2.php-fpm队列满了
php-fpm.conf(/etc/php/7.0/fpm/php-fpm.conf)配置文件pm.max_children修改大一点,重启php-fpm并观察日志情况

呵呵，但是呢，姐姐岂止是普通人，这两个都看了还是不行，解决完了才发现，没想到啊，自己竟然有一个这么大的错误

来啊从配置文件开始看起吧，

3、修改配置文件

因为nginx和php有两种链接方式，一种是

fastcgi_pass 127.0.0.1:9000;

另一种是这个
fastcgi_pass unix:/run/php/php7.0-fpm.sock;


这个具体怎么用要去php fpm里面去看他的配置文件
/etc/php/7.0/fpm/pool.d/www.conf里面的Listen

如果Listen是端口就写127.0.0.1:9000;

如果是路径，nginx的配置文件也要学路径，unix:/run/php/php7.0-fpm.sock;

重新访问就好了
