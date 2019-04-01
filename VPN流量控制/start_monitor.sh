#启动服务并记录进程id到文件  
PORT=$1
#开启对应端口流量统计  
sudo iptables -A INPUT -p tcp --dport $PORT
sudo iptables -A OUTPUT -p tcp --sport $PORT
