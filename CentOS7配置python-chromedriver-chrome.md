# 安装Chrome
使用yum命令安装
```
yum install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
```
也可以下载到本地再安装
```
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
yum install ./google-chrome-stable_current_x86_64.rpm
```
安装必要的库
```
yum install mesa-libOSMesa-devel gnu-free-sans-fonts wqy-zenhei-fonts
```
安装的路径是：
```
\opt\google\chrome
```
在该路径下使用./google-chrome可以启动。在root用户下要加上参数--no-sandbox.
```
./google-chrome --no-sandbox
```
同时在/usr/bin/下面有一个google-chrome也可以启动这个应该是一个软连接吧我猜测的因为程序默认的启动路径是那里。

## 报错 
**The process started from chrome location /usr/bin/google-chrome is no longer running, so ChromeDriver is assuming that Chrome has crashed.
这个就是在启动的时候没有加上--no-sandbox.**这个是在使用selenium的时候报错。解决方法**
```
chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument("--no-sandbox")
```
即可

# 安装 chromedriver
先使用 google-chrome --version查询一下浏览器版本，然后到如下网址
http://npm.taobao.org/mirrors/chromedriver/ 去下载对应的chromedriver
使用unzip命令解压之后，将chrmedriver可执行文件放到/usr/local/bin下即可。

# CentOS 7下安装Python3.6.4

安装python3.6可能使用的依赖
```
yum install openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel
```
下载python包
```
wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz
```
解压
```
tar -zxvf Python-3.6.4.tgz
```
把python移到/usr/local下面
```
mv Python-3.6.4 /usr/local
```
删除旧版本的python依赖(可选，本机自带的python好像不冲突)
```
ll /usr/bin | grep python
rm -rf /usr/bin/python
```
进入python目录
```
cd /usr/local/Python-3.6.4/
```
配置
```
./configure
```
编译 make
```
make
```
编译，安装
```
make install
```
删除旧的软链接，创建新的软链接到最新的python
```
rm -rf /usr/bin/python
ln -s /usr/local/bin/python3.6 /usr/bin/python

python -V
```