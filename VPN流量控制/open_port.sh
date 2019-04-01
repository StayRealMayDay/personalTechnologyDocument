RULENUMBER=$1

#添加打开端口的规则
#sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
#sudo iptables -A OUTPUT -p tcp --sport $PORT -j ACCEPT


# 删除规则
iptables -D OUTPUT $RULENUMBER
iptables -D INPUT $RULENUMBER