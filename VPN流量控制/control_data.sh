#定时检测 流量超出则停止服务,比如限制每天流量100M  
MAX=100000
SLEEP_TIME=20 #每20秒检测流量一次  
while true   
do
  for PORTM in {9001..9002}
  do
    value_string=`sudo iptables -n -v -L OUTPUT -t filter -x |grep -i "spt:$PORTM"|awk -F' ' '{print $2}'`
    if [[ $? = 0 ]] ;then
     if [[ $value_string -gt $MAX ]] ;then
       # kill -9 `cat $PID_FILE`  
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