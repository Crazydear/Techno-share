假如要给shell脚本设置快捷运行方式即不用进入到shell脚本当前目录，就可以在任何目录运行shell脚本。方法有很多种，我就介绍下常用的两种方法。 
1、修改profile文件

sudo vi /etc/profile
1
在文件最底部添加（例如我想要配置idea的快捷启动方式，这样就不用进入到目录运行./idea.sh启动了）

export PATH=/home/twilight/work/idea-IU-182.3684.101/bin:$PATH
1
这就有点像配置window的环境变量一样，:$PATH中的冒号就类似window环境变量的分号分割其他的变量，$PATH就是获取原来的PATH环境变量。 
保存退出。注销或者重启即可生效。 
如果使用命令

source /etc/profile
1
会立即生效，但只在当前终端生效。在/etc/profile添加的环境变量会对所有用户生效。

2、修改.bashrc文件

vi ~/.bashrc
1
~就代表当前用户目录了，.代表这个文件是隐藏文件。.bashrc该文件存储的是专属于个人bash shell的信息，当登录时以及每次打开一个新的shell时，执行这个文件。在这个文件里可以自定义用户专属的个人信息。 
同理在文件末尾加上

export PATH=/home/twilight/work/idea-IU-182.3684.101/bin:$PATH
1
修改.bashrc文件不需要注销或者重启，重新开启一个控制台即可生效，因为每次打开一个新的shell时，都会执行这个文件。在~/.bashrc添加的环境变量只对当前用户有效。
--------------------- 
作者：Twilight.c 
来源：CSDN 
原文：https://blog.csdn.net/xlxfyzsfdblj/article/details/81504674 
版权声明：本文为博主原创文章，转载请附上博文链接！
