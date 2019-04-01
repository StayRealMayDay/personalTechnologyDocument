## 参考地址
https://teddysun.com/342.html

### 安装Python版ShadowSocks
在root权限下运行如下命令
```
wget --no-check-certificate -O shadowsocks.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks.sh
chmod +x shadowsocks.sh
./shadowsocks.sh 2>&1 | tee shadowsocks.log
```
### 卸载方法
```
./shadowsocks.sh uninstall
```
### 单用户配置说明
配置文件路径`/etc/shadowsocks.json`
```
{
    "server":"0.0.0.0",
    "server_port":your_server_port,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"your_password",
    "timeout":300,
    "method":"chacha20,
    "fast_open": false
}
```
### 多用户多端口配置说明
配置文件路径`/etc/shadowsocks.json`
```
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
         "8989":"password",
         "9001":"password",
         "9002":"password",
         "9003":"password",
         "9004":"password", 
         "9000":"password",
         "9001":"password",
         "9005":"password",
         "9006":"password",
         "9007":"password"
    },
    "timeout":300,
    "method":"chacha20",
    "fast_open": false
}
```
### 使用命令
```
启动：/etc/init.d/shadowsocks start
停止：/etc/init.d/shadowsocks stop
重启：/etc/init.d/shadowsocks restart
状态：/etc/init.d/shadowsocks status
```
### 一键更换内核 安装锐速 ubuntu16.04  14。04可用
直接运行脚本
```
wget xiaofd.github.io/ruisu.sh && bash ruisu.sh
```
安装完会自动重启 正常现象 重启后就安装好了锐速，可以使用`ps aux | grep appex`来检测是否运行。

如果锐速没有自动安装可以使用`/appex/appexinstall.sh`来安装


### 1.依次输入如下命令
```
# apt-get update                              // 更新源中包列表
# apt-get install python-pip                  // 安装pip
# pip install --upgrade pip                   // 更新pip
# apt-get install git                         // 安装git
# pip install git+https://github.com/shadowsocks/shadowsocks.git@master   // 安装SS
```

### 2.安装chacha20加密：
```
# apt-get install build-essential
# wget https://github.com/jedisct1/libsodium/releases/download/1.0.8/libsodium-1.0.8.tar.gz
# tar xf libsodium-1.0.8.tar.gz && cd libsodium-1.0.8
# ./configure && make -j2
# make install
# ldconfig
```
### 3.服务器端Shadowsocks配置
```
# touch /etc/shadowsocks.json          // 创建SS配置文件
# echo '{"server":"服务器IP", "server_port":8388, "local_address": "127.0.0.1", "local_port":1080, "password":"yourpassword", "timeout":300, "method":"chacha20", "fast_open": false }' > /etc/shadowsocks.json        // 追加配置
```
### 4.服务器端的启动与停止
```
# ssserver -c /etc/shadowsocks.json -d start   //后台开启
# ssserver -c /etc/shadowsocks.json -d stop    //后台停止（一般不用停止）
```
### 输入pip命令报错：from pip import main ImportError: cannot import name 'main'
```
sudo vim /usr/bin/pip3  没有pip3就是pip
```
```
原文：from pip import main 
修改后：from pip._internal import main
```

### Linux 端口打开雨关闭
```
//关闭$PORT端口
sudo iptables -A INPUT -p tcp --dport $PORT -j DROP
sudo iptables -A OUTPUT -p tcp --dport $PORT -j DROP
//打开端口
sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport $PORT -j ACCEPT
//INPUT 表示端口接受数据
//OUTPUT表示端口发送数据
```
其中$PORT是取变量$PORT的值

### iptables 就是ip表就是一个防火墙
iptables就是一个防火墙，通过添加规则来使得接收或者丢弃哪些包，具体请看：
https://www.cnblogs.com/EasonJim/p/6851007.html
```
iptables -L -n --line-number
```
这个命令可以看到表里面的规则。INPUT表FORWARD表和OUTPUT表，当我们关闭一个端口，再打开的时候，只是在表里添加里规则，打开的时候要先把之前关闭的规则去掉才可以。
```
iptables -D OUTPUT 1
iptables -D INPUT 1
```
1表示的是规则的号码。`而我们每次添加规则的时候都是添加在后面的，所以当我们要开启被关闭的端口的时候，直接去删掉关闭的端口的规则就好了
### 开启监控
```
#启动服务并记录进程id到文件  
PORT=$1
#开启对应端口流量统计  
sudo iptables -A INPUT -p tcp --dport $PORT
sudo iptables -A OUTPUT -p tcp --sport $PORT
```
这里一个是INPUT，一个是OUTPUT，代表进入服务器和出入服务，后面的dport表示包的目的端口，sport表示源端口，我们要监控，INPUT就是进入服务器的sport目的端口。和出服务器的源端口的数据流量。
### 流量控制
```
#定时检测 流量超出则停止服务,比如限制每天流量100M  
MAX=100000
SLEEP_TIME=20 #每20秒检测流量一次  
while true   
do
  for PORTM in {9001..9002}
  do
    # 这里多了一个OUTPUT因为我们监控的只是下行流量所以只看output了
    value_string=`sudo iptables -n -v -L OUTPUT -t filter -x |grep -i "spt:$PORTM"|awk -F' ' '{print $2}'`
    if [[ $? = 0 ]] ;then
     if [[ $value_string -gt $MAX ]] ;then
       # kill -9 `cat $PID_FILE`  
       #添加防火墙规则关闭端口
        sudo iptables -A INPUT -p tcp --dport $PORTM -j DROP
        sudo iptables -A OUTPUT -p tcp --sport $PORTM -j DROP
        #关闭流量统计  
        sudo iptables -D OUTPUT -p tcp --sport $PORTM
        sudo iptables -D INPUT -p tcp --dport $PORTM
        break
      fi
    fi
  done
  sleep $SLEEP_TIME
done
```
### 打开端口
```
PORT=$1

#sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
#sudo iptables -A OUTPUT -p tcp --sport $PORT -j ACCEPT
#iptables -D OUTPUT $RULENUMBER
#iptables -D INPUT $RULENUMBER
#先删除之前关闭端口的规则
sudo iptables -D OUTPUT -p tcp --sport $PORT -j DROP
sudo iptables -D INPUT -p tcp --dport $PORT -j DROP
#然后打开端口 —A就是add 添加在已有的规则的后面，-I就是插入 需要一个位置参数
sudo iptables -A INPUT -p tcp --dport $PORT
sudo iptables -A OUTPUT -p tcp --sport $PORT
```