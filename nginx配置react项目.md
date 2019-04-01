# nginx 部署静态react项目

```
yarn run build
```

记得在packa.json里添加 "homepage": "."字段，这样在build之后的项目访问html才能访问到项目资源

在服务区上/etc/nginx下有一个nginx.conf配置文件，这个配置文件是整体配置nginx服务器的，在其中 可以include 其他的配置文件如

```
include /etc/nginx/vhost/*.conf;
```

就把vhost下的所有.conf配置文件引入进来，其中vhost下的每一个配置文件可以配置一个站点如bingo.conf

```
server {
   listen      5000; //监听端口
   server_name  localhost;//域名
   root /root/bingo;//站点的根目录
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

这样配置好之后启动nginx服务区即可