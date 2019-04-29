# Node
 node.js就是js + googleV8引擎的web服务器项目，就是js开发后端服务器。

 ## 模块
 hello.js文件，这个hello.js文件就是一个模块，模块的名字就是文件名（去掉.js后缀），所以hello.js文件就是名为hello的模块。
 ```
 'use strict';
var s = 'Hello';
function greet(name) {
    console.log(s + ', ' + name + '!');
}
module.exports = greet;
 ```
函数greet()是我们在hello模块中定义的，你可能注意到最后一行是一个奇怪的赋值语句，它的意思是，把函数greet作为模块的输出暴露出去，这样其他模块就可以使用greet函数了。

问题是其他模块怎么使用hello模块的这个greet函数呢？我们再编写一个main.js文件，调用hello模块的greet函数：
```
'use strict';

// 引入hello模块:
var greet = require('./hello');

var s = 'Michael';

greet(s); // Hello, Michael!
```
注意到引入hello模块用Node提供的require函数：

引入的模块作为变量保存在greet变量中，那greet变量到底是什么东西？其实变量greet就是在hello.js中我们用module.exports = greet;输出的greet函数。所以，main.js就成功地引用了hello.js模块中定义的greet()函数，接下来就可以直接使用它了。

在使用require()引入模块的时候，请注意模块的相对路径。因为main.js和hello.js位于同一个目录，所以我们用了当前目录.：
```
var greet = require('./hello'); // 不要忘了写相对目录!
```
如果只写模块名：
```
var greet = require('hello');
```
则Node会依次在内置模块、全局模块和当前模块下查找hello.js，你很可能会得到一个错误：

当使用module.exports = 暴露函数的时候，直接写函数名字就好，当然还可以暴露一个对象，对象里面是多个函数

```
module.exports = {
    foo: function(){}.
    doo: function(){}
}
```


## fs 文件读取模块

###  异步读取文件
#### 文本文件
```
var fs = require('fs');

fs.readFile('sample.txt', 'utf-8', function (err, data) {
    if (err) {
        console.log(err);
    } else {
        console.log(data);
    }
});
```
请注意，sample.txt文件必须在当前目录下，且文件编码为utf-8。

异步读取时，传入的回调函数接收两个参数，当正常读取时，err参数为null，data参数为读取到的String。当读取发生错误时，err参数代表一个错误对象，data为undefined。这也是Node.js标准的回调函数：第一个参数代表错误信息，第二个参数代表结果。后面我们还会经常编写这种回调函数。

由于err是否为null就是判断是否出错的标志，所以通常的判断逻辑总是：
```
if (err) {
    // 出错了
} else {
    // 正常
}
```
如果我们要读取的文件不是文本文件，而是二进制文件，怎么办？
#### 二进制文件，如图片
下面的例子演示了如何读取一个图片文件：
```
var fs = require('fs');

fs.readFile('sample.png', function (err, data) {
    if (err) {
        console.log(err);
    } else {
        console.log(data);
        console.log(data.length + ' bytes');
    }
});
```

当读取二进制文件时，不传入文件编码时，回调函数的data参数将返回一个Buffer对象。在Node.js中，Buffer对象就是一个包含零个或任意个字节的数组（注意和Array不同）。

Buffer对象可以和String作转换，例如，把一个Buffer对象转换成String：
```
var text = data.toString('utf-8');
console.log(text);
```
或者把一个String转换成Buffer：
```
var buf = Buffer.from(text, 'utf-8');
console.log(buf);
```
### 同步读文件
除了标准的异步读取模式外，fs也提供相应的同步读取函数。同步读取的函数和异步函数相比，多了一个Sync后缀，并且不接收回调函数，函数直接返回结果。

用fs模块同步读取一个文本文件的代码如下
```
var fs = require('fs');

var data = fs.readFileSync('sample.txt', 'utf-8');
console.log(data);
```
如果同步读取文件发生错误，则需要用try...catch捕获该错误：
```
try {
    var data = fs.readFileSync('sample.txt', 'utf-8');
    console.log(data);
} catch (err) {
    // 出错了
}
```
### 写文件
将数据写入文件是通过fs.writeFile()实现的：
```
var fs = require('fs');

var data = 'Hello, Node.js';
fs.writeFile('output.txt', data, function (err) {
    if (err) {
        console.log(err);
    } else {
        console.log('ok.');
    }
});
```

writeFile()的参数依次为文件名、数据和回调函数。如果传入的数据是String，默认按UTF-8编码写入文本文件，如果传入的参数是Buffer，则写入的是二进制文件。回调函数由于只关心成功与否，因此只需要一个err参数。

和readFile()类似，writeFile()也有一个同步方法，叫writeFileSync()：
```
var fs = require('fs');

var data = 'Hello, Node.js';
fs.writeFileSync('output.txt', data);

```
### stat 获取文件信息

如果我们要获取文件大小，创建时间等信息，可以使用fs.stat()，它返回一个Stat对象，能告诉我们文件或目录的详细信息：
```
var fs = require('fs');

fs.stat('sample.txt', function (err, stat) {
    if (err) {
        console.log(err);
    } else {
        // 是否是文件:
        console.log('isFile: ' + stat.isFile());
        // 是否是目录:
        console.log('isDirectory: ' + stat.isDirectory());
        if (stat.isFile()) {
            // 文件大小:
            console.log('size: ' + stat.size);
            // 创建时间, Date对象:
            console.log('birth time: ' + stat.birthtime);
            // 修改时间, Date对象:
            console.log('modified time: ' + stat.mtime);
        }
    }
});
```

## stream 流操作
在Node.js中，流也是一个对象，我们只需要响应流的事件就可以了：data事件表示流的数据已经可以读取了，end事件表示这个流已经到末尾了，没有数据可以读取了，error事件表示出错了。

下面是一个从文件流读取文本内容的示例：
```
var fs = require('fs');

// 打开一个流:
var rs = fs.createReadStream('sample.txt', 'utf-8');

rs.on('data', function (chunk) {
    console.log('DATA:')
    console.log(chunk);
});

rs.on('end', function () {
    console.log('END');
});

rs.on('error', function (err) {
    console.log('ERROR: ' + err);
});

```
要注意，data事件可能会有多次，每次传递的chunk是流的一部分数据。

要以流的形式写入文件，只需要不断调用write()方法，最后以end()结束：
```
var fs = require('fs');

var ws1 = fs.createWriteStream('output1.txt', 'utf-8');
ws1.write('使用Stream写入文本数据...\n');
ws1.write('END.');
ws1.end();

var ws2 = fs.createWriteStream('output2.txt');
ws2.write(new Buffer('使用Stream写入二进制数据...\n', 'utf-8'));
ws2.write(new Buffer('END.', 'utf-8'));
ws2.end();
```
### pipe
就像可以把两个水管串成一个更长的水管一样，两个流也可以串起来。一个Readable流和一个Writable流串起来后，所有的数据自动从Readable流进入Writable流，这种操作叫pipe。

在Node.js中，Readable流有一个pipe()方法，就是用来干这件事的。

让我们用pipe()把一个文件流和另一个文件流串起来，这样源文件的所有数据就自动写入到目标文件里了，所以，这实际上是一个复制文件的程序：
```
var fs = require('fs');

var rs = fs.createReadStream('sample.txt');
var ws = fs.createWriteStream('copied.txt');

rs.pipe(ws);
```
**stream的操作都是异步操作，所以如果我们需要读取完成之后再做其他操作应该写在所有的stream操作的回调函数之中，如：**
#### 读取数据之后做操作
```
rs.on("end", function(xxx){});
```
诸如此类：
```
var p = new Promise( (resolve, reject)=> {
    $.get('text.php', (res)=> {
        resolve(res);    // 请注意resolve的位置在get内。
    });
});
p.then((value)=> {
    console.log(value);
})
```
或者是这样:
```
var fs = require('fs');

var ws1 = fs.createWriteStream('noname.js', 'utf-8');
ws1.write("HelloWorld asdwqf123456\n");
ws1.write("2017 08 30 17:09:11\n",function(){
    fs.readFile("noname.js", "utf-8", function(err, data){
        if (err){
            console.log(err);
        }else{
            console.log(data);
        }
    })
});
ws1.write("End\n");
ws1.end();
```

## process
process 对象是一个全局变量，它提供当前 Node.js 进程的有关信息，以及控制当前 Node.js 进程。 因为是全局变量，所以无需使用 require()。

process.argv 属性返回一个数组，这个数组包含了启动Node.js进程时的命令行参数。第一个元素为process.execPath。如果需要获取argv[0]的值请参见node文档的 process.argv0。第二个元素为当前执行的JavaScript文件路径。剩余的元素为其他命令行参数。
```
//process-args.js文件有以下代码:
process.argv.forEach((val, index) => {
  console.log(`${index}: ${val}`);
});
```
运行以下命令，启动进程：
```
$ node process-args.js one two=three four
```
将输出：
```
0: /usr/local/bin/node
1: /Users/mjr/work/node/process-args.js
2: one
3: two=three
4: four
```

## path

处理本地文件目录需要使用Node.js提供的path模块，它可以方便地构造目录：
```
var path = require('path');

// 解析当前目录:
var workDir = path.resolve('.'); // '/Users/michael'

// 组合完整的文件路径:当前目录+'pub'+'index.html':
var filePath = path.join(workDir, 'pub', 'index.html');
// '/Users/michael/pub/index.html'
```
## url
解析URL需要用到Node.js提供的url模块，它使用起来非常简单，通过parse()将一个字符串解析为一个Url对象：
```
'use strict';

var url = require('url');

console.log(url.parse('http://user:pass@host.com:8080/path/to/file?query=string#hash'));

```
解析的结果如下：
```
Url {
  protocol: 'http:',
  slashes: true,
  auth: 'user:pass',
  host: 'host.com:8080',
  port: '8080',
  hostname: 'host.com',
  hash: '#hash',
  search: '?query=string',
  query: 'query=string',
  pathname: '/path/to/file',
  path: '/path/to/file?query=string',
  href: 'http://user:pass@host.com:8080/path/to/file?query=string#hash' }

```

## 获取post请求数据
首先给服务器绑定响应事件：
```
//2.创建服务器
var app = http.createServer();

//3.添加响应事件
app.on('request', function (req, res) {})
```
通过判断url路径和请求方式来判断是否是表单提交
```
if (req.url === '/heroAdd' && req.method === 'POST') 
```
创建一个变量来接收数据，给request请求注册一个接收数据data的事件。
```
 var data = '';
如果表单数据量越多，则发送的次数越多，如果比较少，可能一次就发过来了
所以接收表单数据的时候，需要通过监听 req 对象的 data 事件来取数据
也就是说，每当收到一段表单提交过来的数据，req 的 data 事件就会被触发一次，同时通过回调函数可以拿到该 段 的数据
//2.注册data事件接收数据（每当收到一段表单提交的数据，该方法会执行一次）
req.on('data', function (chunk) {
    // chunk 默认是一个二进制数据，和 data 拼接会自动 toString
    data += chunk;
});
```

给req请求注册完成接收数据end事件（所有数据接收完成会执行一次该方法）
```
req.on('end', function () {
    
    //（1）.对url进行解码（url会对中文进行编码）
    data = decodeURI(data);
    console.log(data);
    // 如果是get请求可以用上面的模块。
    /**post请求参数不能使用url模块解析，因为他不是一个url，而是一个请求体对象 */

    //（2）.使用querystring对url进行反序列化（解析url将&和=拆分成键值对），得到一个对象
    //querystring是nodejs内置的一个专用于处理url的模块，API只有四个，详情见nodejs官方文档
    var dataObject = querystring.parse(data);
    console.log(dataObject);
});

```

## nodejs 跨域访问
设置请求头
```
   response.setHeader('Access-Control-Allow-Origin',"*");
```
这个是设置返回的数据能够被浏览器接收，意思就是所有的访问我都可以处理。
### Request header field content-type is not allowed by Access-Control-Allow-Headers in preflight respon
错误原因：
在正式跨域的请求前，浏览器会根据需要，发起一个“PreFlight”（也就是Option请求），用来让服务端返回允许的方法（如get、post），被跨域访问的Origin（来源，或者域），还有是否需要Credentials(认证信息）

如果跨域的请求是Simple Request（简单请求 ），则不会触发“PreFlight”。Mozilla对于简单请求的要求是： 
以下三项必须都成立： 
1. 只能是Get、Head、Post方法 
2. 除了浏览器自己在Http头上加的信息（如Connection、User-Agent），开发者只能加这几个：Accept、Accept-Language、Content-Type、。。。。 
3. Content-Type只能取这几个值： 
application/x-www-form-urlencoded 
multipart/form-data 
text/plain

解决方法,在返回的response头中加入如下数据。
```
response.setHeader('Access-Control-Allow-Headers','Content-Type');
```
虽然这样能解决报错问题，但是前端会发送两次请求，第一次的请求是一个option请求，所以后端必须做相应的处理。
```
server.on("request", function (request, response) {

    response.setHeader("Access-Control-Allow-Origin", "*");

    response.setHeader("Access-Control-Allow-Headers", "X-Requested-With,Content-Type");
    response.setHeader("Content-Type", "application/json");
    if (request.url === "/Login" && request.method === 'POST') {
        var data = "";
        request.on('data', function (chunk) {
            data += chunk;
        });
        request.on('end', function () {
            console.log(data)
            console.log("this is data" + typeof data)
            data = JSON.parse(data);
            response.end('{"name":"renhaoran", "password":"renhaoran001"}');
        })
    }else{
    response.end()
    }

})
```
## __dirame和./的区别
Node.js 中，__dirname 总是指向被执行 js 文件的绝对路径，所以当你在 /d1/d2/myscript.js 文件中写了 __dirname， 它的值就是 /d1/d2 。

相反，./ 会返回你执行 node 命令的路径，
假设有如下目录结构：
```
/dir1
  /dir2
    pathtest.js
```
然后在 pathtest.js 中，有如下代码:
```
var path = require("path");
console.log(". = %s", path.resolve("."));
console.log("__dirname = %s", path.resolve(__dirname));
```
然后在 pathtest.js 中，有如下代码:
```
cd /dir1/dir2
node pathtest.js
```
将会得到
```
. = /dir1/dir2
__dirname = /dir1/dir2
```
. 是你的当前工作目录，在这个例子中就是 /dir1/dir2 ，__dirname 是 pathtest.js 的文件路径，在这个例子中就是 /dir1/dir2 。

然而，如果我们的工作目录是 /dir1
```
cd /dir1
node dir2/pathtest.js
```
将会得到
```
. = /dir1
__dirname = /dir1/dir2
```
## crypto
crypto模块的目的是为了提供通用的加密和哈希算法。用纯JavaScript代码实现这些功能不是不可能，但速度会非常慢。Nodejs用C/C++实现这些算法后，通过cypto这个模块暴露为JavaScript接口，这样用起来方便，运行速度也快,
### MD5和SHA1
MD5是一种常用的哈希算法，用于给任意数据一个“签名”。这个签名通常用一个十六进制的字符串表示：
```
//引入模块
const crypto = require('crypto');
//创建实例，参数是加密方法
const hash = crypto.createHash('md5');

// 可任意多次调用update()添加数据，两次添加数据会简单的拼接起来，下面两个update和
//hash.update('Hello, world!' + 'Hello, nodejs!');一样。
hash.update('Hello, world!');
hash.update('Hello, nodejs!');
//digest是加密并返回加密后的数据，'hex'表示以16进制显示。
console.log(hash.digest('hex')); // 7e1977739c748beac0c0fd14fd26a544
```
如果要计算SHA1，只需要把'md5'改成'sha1'，就可以得到SHA1的结果1f32b9c9932c02227819a4151feed43e131aca40。

还可以使用更安全的sha256和sha512。

**这个digest()调用之后会清除数据所以不能重复调用。**
## Hmac
Hmac算法也是一种哈希算法，它可以利用MD5或SHA1等哈希算法。不同的是，Hmac还需要一个密钥：
```
const crypto = require('crypto');

const hmac = crypto.createHmac('sha256', 'secret-key');

hmac.update('Hello, world!');
hmac.update('Hello, nodejs!');

console.log(hmac.digest('hex')); // 80f7e22570...
```
只要密钥发生了变化，那么同样的输入数据也会得到不同的签名，因此，可以把Hmac理解为用随机数“增强”的哈希算法。
## AES
AES是一种常用的对称加密算法，加解密都用同一个密钥。crypto模块提供了AES支持，但是需要自己封装好函数，便于使用：
```
const crypto = require('crypto');

function aesEncrypt(data, key) {
    const cipher = crypto.createCipher('aes192', key);
    var crypted = cipher.update(data, 'utf8', 'hex');
    crypted += cipher.final('hex');
    return crypted;
}

function aesDecrypt(encrypted, key) {
    const decipher = crypto.createDecipher('aes192', key);
    var decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
}

var data = 'Hello, this is a secret message!';
var key = 'Password!';
var encrypted = aesEncrypt(data, key);
var decrypted = aesDecrypt(encrypted, key);

console.log('Plain text: ' + data);
console.log('Encrypted text: ' + encrypted);
console.log('Decrypted text: ' + decrypted);
```
运行结果如下：
```
Plain text: Hello, this is a secret message!
Encrypted text: 8a944d97bdabc157a5b7a40cb180e7...
Decrypted text: Hello, this is a secret message!
```
可以看出，加密后的字符串通过解密又得到了原始内容。

注意到AES有很多不同的算法，如aes192，aes-128-ecb，aes-256-cbc等，AES除了密钥外还可以指定IV（Initial Vector），不同的系统只要IV不同，用相同的密钥加密相同的数据得到的加密结果也是不同的。加密结果通常有两种表示方法：hex和base64，这些功能Nodejs全部都支持，但是在应用中要注意，如果加解密双方一方用Nodejs，另一方用Java、PHP等其它语言，需要仔细测试。如果无法正确解密，要确认双方是否遵循同样的AES算法，字符串密钥和IV是否相同，加密后的数据是否统一为hex或base64格式。

**不同的加密算法是不一样的，这里加密的时候最后用的是final，同时在update数据的时候也会返回加密的block，所以我们需要将返回的block保存下来。并且拼接起来才能的到完整的加密数据，**
## Diffie-Hellman
DH算法是一种密钥交换协议，它可以让双方在不泄漏密钥的情况下协商出一个密钥来。DH算法基于数学原理，比如小明和小红想要协商一个密钥，可以这么做：

小明先选一个素数和一个底数，例如，素数p=23，底数g=5（底数可以任选），再选择一个秘密整数a=6，计算A=g^a mod p=8，然后大声告诉小红：p=23，g=5，A=8；

小红收到小明发来的p，g，A后，也选一个秘密整数b=15，然后计算B=g^b mod p=19，并大声告诉小明：B=19；

小明自己计算出s=B^a mod p=2，小红也自己计算出s=A^b mod p=2，因此，最终协商的密钥s为2。

在这个过程中，密钥2并不是小明告诉小红的，也不是小红告诉小明的，而是双方协商计算出来的。第三方只能知道p=23，g=5，A=8，B=19，由于不知道双方选的秘密整数a=6和b=15，因此无法计算出密钥2。

用crypto模块实现DH算法如下：
```
const crypto = require('crypto');

// xiaoming's keys:
var ming = crypto.createDiffieHellman(512);
var ming_keys = ming.generateKeys();

var prime = ming.getPrime();
var generator = ming.getGenerator();

console.log('Prime: ' + prime.toString('hex'));
console.log('Generator: ' + generator.toString('hex'));

// xiaohong's keys:
var hong = crypto.createDiffieHellman(prime, generator);
var hong_keys = hong.generateKeys();

// exchange and generate secret:
var ming_secret = ming.computeSecret(hong_keys);
var hong_secret = hong.computeSecret(ming_keys);

// print secret:
console.log('Secret of Xiao Ming: ' + ming_secret.toString('hex'));
console.log('Secret of Xiao Hong: ' + hong_secret.toString('hex'));
```
运行后，可以得到如下输出：
```
$ node dh.js 
Prime: a8224c...deead3
Generator: 02
Secret of Xiao Ming: 695308...d519be
Secret of Xiao Hong: 695308...d519be
```
注意每次输出都不一样，因为素数的选择是随机的。



## Async/await
有一种特殊的语法可以更舒适地与promise协同工作，它叫做async/await，它是非常的容易理解和使用。
### Async functions
让我们先从async关键字说起，它被放置在一个函数前面。就像下面这样：
```
async function f() {
    return 1
}
```
函数前面的async一词意味着一个简单的事情：这个函数总是返回一个promise，如果代码中有return <非promise>语句，JavaScript会自动把返回的这个value值包装成promise的resolved值。他和下面的写法是一样，
```
async function f() {
    return Promise.resolve(1)
}
f().then(alert) // 1
```
所以，async确保了函数返回一个promise，即使其中包含非promise。够简单了吧？但是不仅仅只是如此，还有另一个关键词await，只能在async函数里使用，同样，它也很cool。
### Await
语法如下：
```
// 只能在async函数内部使用
let value = await promise
```
关键词await可以让JavaScript进行等待，直到一个promise执行并返回它的结果，JavaScript才会继续往下执行。

以下是一个promise在1s之后resolve的例子：
```
async function f() {
    let promise = new Promise((resolve, reject) => {
        setTimeout(() => resolve('done!'), 1000)
    })
    let result = await promise // 直到promise返回一个resolve值（*）
    alert(result) // 'done!' 
}
f()
```
函数执行到（*）行会‘暂停’，当promise处理完成后重新恢复运行， resolve的值成了最终的result，所以上面的代码会在1s后输出'done!'

我们强调一下：await字面上使得JavaScript等待，直到promise处理完成，
然后将结果继续下去。这并不会花费任何的cpu资源，因为引擎能够同时做其他工作：执行其他脚本，处理事件等等。

这只是一个更优雅的得到promise值的语句，它比promise更加容易阅读和书写。

**不能在常规函数里使用await**

如果我们试图在非async函数里使用await，就会出现一个语法错误：
```
function f() {
   let promise = Promise.resolve(1)
   let result = await promise // syntax error
}
```
如果我们忘记了在函数之前放置async，我们就会得到这样一个错误。如上所述，await只能在async函数中工作。

让我们来看promise链式操作一章中提到的showAvatar()例子，并用async/await重写它。
#### promise 的链式操作
```
new Promise(function(resolve, reject) {

  setTimeout(() => resolve(1), 1000); // (*)

}).then(function(result) { // (**)

  alert(result); // 1
  return result * 2;

}).then(function(result) { // (***)

  alert(result); // 2
  return result * 2;

}).then(function(result) {

  alert(result); // 4
  return result * 2;

});
```
Here the flow is:

1. The initial promise resolves in 1 second (*),

2. Then the .then handler is called (**).

3. The value that it returns is passed to the next .then handler (***)

4. …and so on.

对下面这个例子进行重写
```
// Make a request for user.json
fetch('/article/promise-chaining/user.json')
  // Load it as json
  .then(response => response.json())
  // Make a request to github
  .then(user => fetch(`https://api.github.com/users/${user.name}`))
  // Load the response as json
  .then(response => response.json())
  // Show the avatar image (githubUser.avatar_url) for 3 seconds (maybe animate it)
  .then(githubUser => {
    let img = document.createElement('img');
    img.src = githubUser.avatar_url;
    img.className = "promise-avatar-example";
    document.body.append(img);

    setTimeout(() => img.remove(), 3000); // (*)
  });
```
重写的结果如下：
```
async function showAvatar() {
    // read our JSON
    let response = await fetch('/article/promise-chaining/user.json')
    let user = await response.json()
    
    // read github user
    let githubResponse = await fetch(`https://api.github.com/users/${user.name}`)
    let githubUser = await githubResponse.json()
    
    // 展示头像
    let img = document.createElement('img')
    img.src = githubUser.avatar_url
    img.className = 'promise-avatar-example'
    documenmt.body.append(img)
    
    // 等待3s
    await new Promise((resolve, reject) => {
        setTimeout(resolve, 3000)
    })
    
    img.remove()
    
    return githubUser
}
showAvatar()
```
### 错误处理

如果一个promise正常resolve，那么await返回这个结果，但是在reject的情况下会抛出一个错误，就好像在那一行有一个throw语句一样。
```
async function f() {
    await Promise.reject(new Error('whoops!'))
}
```
和下面一样
```
async function f() {
    throw new Error('Whoops!')
}   
```
在真实的使用场景中，promise在reject抛出错误之前可能需要一段时间，所以await将会等待，然后才抛出一个错误。
我们可以使用try-catch语句捕获错误，就像在正常抛出中处理异常一样：
```
async function f() {
    try {
        let response = await fetch('http://no-such-url');
        let user = await response.json();
    } catch (err) {
        alet(err) // TypeError: failed to fetch
    }
}
f()
```
如果我们不使用try-catch，然后async函数f()的调用产生的promise变成reject状态的话，我们可以添加.catch去处理它：
```
async function f() {
    let response = await fetch('http://no-such-url')
}
// f()变成了一个rejected的promise
f().catch(alert) // TypeError: failed to fetch
```
### 总结
放在一个函数前的async有两个作用：

1.使函数总是返回一个promise

2.允许在这其中使用await

promise前面的await关键字能够使JavaScript等待，直到promise处理结束。然后：

1.如果它是一个错误，异常就产生了，就像在那个地方调用了throw error一样。

2.否则，它会返回一个结果，我们可以将它分配给一个值

他们一起提供了一个很好的框架来编写易于读写的异步代码。

有了async/await，我们很少需要写promise.then/catch，但是我们仍然不应该忘记它们是基于promise的，因为有些时候（例如在最外面的范围内）我们不得不使用这些方法。Promise.all也是一个非常棒的东西，它能够同时等待很多任务。


## express-session
相关链接：

https://www.cnblogs.com/xiashan17/p/5897282.html

https://cloud.tencent.com/developer/news/198738

具体来说，再使用express-session中间件之后，可以在其中设置`saveUninitialized : true`这样一个选项， 在这样设置之后只要去访问这个服务器就会生成一个session，当然前提是还没生成的情况，如果已经生成了就不会再生成了，生成一个session之后呢，在服务器的返回头上会多一个Set_Cookie字段，这个字段其实是sessionID加密之后的数据，浏览器保存这个cookie在下次访问的时候，带上这个cookie，服务器就会拿到这个sessionID然后找到之前生成的session，session还可以记录一些信息，然后通过sessionID找到该session然后拿到该信息，比如登录确认啥的。

rolling:true字段呢是来重新更新过期时间的。等等

**session的过程**

https://blog.csdn.net/nw_ningwang/article/details/78500761
## fetch默认不自带cookie
需要自带cookie需要设置一个字段,在fetch请求时
```
credentials：
```
credentials有三个值可以配置， 默认是:‘omit’， 即忽略cookie ‘same-origin’： 同域名下请求会发送cookie。 'include‘：是否同域名都会发送cookie

在默认带上cookie之后，比如选择了'include'后台的跨域访问路径需要修改。
```
res.header("Access-Control-Allow-Origin", "htt://localhost:3000");   //这里要写具体请求地址
res.header(" Access-Control-Allow-Credentials", true);
```
如果地址写 "*"会报错。 在这样设置之后Chrome还是无法使用document.cookie来看cookie，我也不知道怎么回事。

## express获取post请求参数

```
const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const app = express();


app.use(bodyParser.urlencoded({extended: true}));
//这两个只会有一个起作用，建议都写上
app.use(bodyParser.json());
```

## 请求URL编码问题
js有三个函数,
```
escape（69个）：*/@+-._0-9a-zA-Z
encodeURI（82个）：!#$&'()*+,/:;=?@-._~0-9a-zA-Z
encodeURIComponent（71个）：!'()*-._~0-9a-zA-Z
```
函数后面的字符为安全字符，即不会对这些字符进行编码。在进行网络请求的时候，请求模块在发送请求的时候会自动把url进行编码，然后再请求，这个可以Wireshark抓包来看，有的网站制定了编码方式，即使你的链接是对的，但是你请求的时候编码方式不对，也是拿不到数据的。

## https
HTTPS 就是在原来的http上加了一层，要么是SSL，安全套接曾，或者TLS，传输层安全，其原理是结合对称加密和非对称加密，首先使用非对称加密来传输对称加密的密钥，之后使用对称加密来进行数据传输，非对称加密的时候，可以通过三个随机数来生成一个密钥，这个是在建立安全链接的时候，即握手的时候产生的。随机数是在客户端和服务器自己产生的，所以中间人是不知道的，这样就导致中间人无法解密加密信息。

其实最核心的是，客户端是用服务器的公钥加密，中间人没有服务器的私钥，所以没法解密获取对称加密的方法和密钥，所以无法中间人劫持，唯一的方法是伪造证书，使得客户端能够相信中间人的证书，这样的话你在截获第一个握手的时候开始，就获取第一个返回的数据，解析之后换成自己的证书，这样就能和客户端，以及服务器分别商量对称加密的算法和密钥，这样一来就能截获客户端的数据了。
具体的流程是：
1. 客户端请求

2. 服务器返回数据，将公钥用证书加密。

3. 客户端看证书是否信任，信任则用其对应的公钥解密， 获取服务公钥，

4. 用服务器公钥加密数据，设置对称传输的密钥和方法

5.使用密钥回复 ，传输数据。