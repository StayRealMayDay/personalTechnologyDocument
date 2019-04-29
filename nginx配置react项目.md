# nginx 部署静态react项目

```
yarn run build
```

记得在packa.json里添加 "homepage": "."字段，这样在build之后的项目访问html才能访问到项目资源

然后将build文件夹里面的东西拷贝到服务器上面

在服务区上/etc/nginx下有一个nginx.conf配置文件，这个配置文件是整体配置nginx服务器的，在其中 可以include 其他的配置文件如

```
include /etc/nginx/vhost/*.conf;
```

就把vhost下的所有.conf配置文件引入进来，其中vhost下的每一个配置文件可以配置一个站点如bingo.conf

```
server {
   listen      5000; #监听端口
   server_name  localhost;#域名
   root /root/bingo;#站点的根目录
   location / {
      try_files $uri @fallback;
   }
   location @fallback {
     rewrite .* /index.html break;
   }
   error_page   500 502 503 504  /50x.html;
   location = /50x.html {
     root   html;
   }
}
```

这样配置好之后启动nginx服务区即可. #在shell中是注释的意思

# CentOS7部署Nginx

## 准备工作
Nginx的安装依赖于以下三个包，意思就是在安装Nginx之前首先必须安装一下的三个包，注意安装顺序如下：

　　1 SSL功能需要openssl库，直接通过yum安装: #yum install openssl

　　2 gzip模块需要zlib库，直接通过yum安装: #yum install zlib

　　3 rewrite模块需要pcre库，直接通过yum安装: #yum install pcre
## 安装Nginx依赖项和Nginx
   1 使用yum安装nginx需要包括Nginx的库，安装Nginx的库

　　　　#rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

　　2 使用下面命令安装nginx

　　　　#yum install nginx

　　3 启动Nginx
      #systemctl start nginx.service


# 403 forbidden问题
这是由于nginx需要一个启动用户，在/etc/nginx/nginx.conf里面。 
```
usr root;
```
即可解决
