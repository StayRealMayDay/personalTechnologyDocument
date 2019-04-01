
1.order 
2. suborder  get x-uid
2. build order  用了 goods数据 传入goods   加密 getsign 平接url  h5aip啥的  然后post  拼接了头。 如果cookies 有set cookies时需要更新token.  post 返回json数据 订单信息  加密数据
3.createorder里面  fun.createorder拼接数据。 url 拼接 然后post
## Token
这个token在访问私密链接的时候才会返回token，用在哪里呢，这个token在创建订单是必须要，因为在创建订单的时候，发送请求的api中需要带上sign值，这个sign值需要商品ItemID信息，skuID信息，cookie信息，用md5加密的到，这个token在访问私密链接返回cookie中，过一段时间会过期，过期之后需要带着cookie去访问私密链接，更新token。只要session不过期，cookie就可以用，token过期照样可以访问这个私密链接来更新cookie。

## 数字加密 sign
```
getSign(cookies, itemId, sku, cb) {
        //网络取md5
        if (/_m_h5_tk=([\w]+)_[\d]+;/.test(cookies)) {
            var token = /_m_h5_tk=([\w]+)_[\d]+;/.exec(cookies)[1];
            var time = new Date().getTime()
            // superagent.post("http://tool.chinaz.com/tools/md5.aspx")
            //     .send(`q=${token}%26${time}%2612574478%26%7B%22itemId%22%3A${itemId}%2C%22quantity%22%3A1%2C%22buyNow%22%3Atrue%2C%22skuId%22%3A${sku}%2C%22serviceId%22%3Anull%2C%22exParams%22%3A%22%7B%5C%22buyFrom%5C%22%3A%5C%22tmall_h5_detail%5C%22%7D%22%7D&ende=0&md5type=1`)
            //     .end((error, result) => {
            //         var sign = /WrapHid"\sid="MD5Result">([\w]+)<\/tex/.exec(result.text)[1];
            //         console.log(sign)
            //         cb(null, {sign: sign, time: time})
            //     })

            let data=`${token}&${time}&12574478&{"itemId":${itemId},"quantity":1,"buyNow":true,"skuId":${sku},"serviceId":null,"exParams":"{\\"buyFrom\\":\\"tmall_h5_detail\\"}"}`

            let sign = md5(data);

            cb(null, {sign: sign, time: time})
            // let data = `q=${token}%26${time}%2612574478%26%7B%22itemId%22%3A${itemId}%2C%22quantity%22%3A1%2C%22buyNow%22%3Atrue%2C%22skuId%22%3A${sku}%2C%22serviceId%22%3Anull%2C%22exParams%22%3A%22%7B%5C%22buyFrom%5C%22%3A%5C%22tmall_h5_detail%5C%22%7D%22%7D&ende=0&md5type=1`
            // let sign = md5(data);
            // cb(null,{sign: sign, time: time});
        } else {
            cb("错误cookie", null)
        }
        //q=sd115s4d41fwewe%26156231254789%2612574478%26%7B%22itemId%22%3A5311592491%2C%22quantity%22%3A1%2C%22buyNow%22%3Atrue%2C%22skuId%22%3A321461781%2C%22serviceId%22%3Anull%2C%22exParams%22%3A%22%7B%5C%22buyFrom%5C%22%3A%5C%22tmall_h5_detail%5C%22%7D%22%7D&ende=0&md5type=1
    },
```

每一次发送请求的时候都需要计算一下数字加密，就是用md5加密，但是这个数据要有特定的组织格式。就是`data`这个变量的组织格式。其中注销的部分是使用网络去计算加密的结果，我们改成了使用本地去加密。
.send部分。
```
// superagent.post("http://tool.chinaz.com/tools/md5.aspx")
            //     .send(`q=${token}%26${time}%2612574478%26%7B%22itemId%22%3A${itemId}%2C%22quantity%22%3A1%2C%22buyNow%22%3Atrue%2C%22skuId%22%3A${sku}%2C%22serviceId%22%3Anull%2C%22exParams%22%3A%22%7B%5C%22buyFrom%5C%22%3A%5C%22tmall_h5_detail%5C%22%7D%22%7D&ende=0&md5type=1`)
```
这个部分中的`.send`里面的数据是网站接口的形式，其中q=以及中间存在的一些数字都是转译的结果。比如`%26`就表示`&`符号。


## get realPay
```
Object {api: "mtop.trade.buildorder.h5", data: Object, ret: Array(1), v: "3.0"}
api:"mtop.trade.buildorder.h5"
data:Object
    data:Object
    endpoint:Object
    hierarchy:Object
        baseType:Array(5)
        component:Array(20)
        root:"confirmOrder_1"
        structure:Object
            confirmOrder_1:Array(9)
            item_3ac79089ac173ed26f1a7960fc249d8c:Array(3)
            order_cf40c4f59f8a19d13c3f01a5a161dbe0:Array(9)
            0:"orderInfo_cf40c4f59f8a19d13c3f01a5a161dbe0"
            1:"item_3ac79089ac173ed26f1a7960fc249d8c"
            2:"deliveryMethod_cf40c4f59f8a19d13c3f01a5a161dbe0"
            3:"invoice_cf40c4f59f8a19d13c3f01a5a161dbe0@1"
            ......
```
在拿realPay的时候返回的数据，在sructure中的order_...后面的部分应该是加密过的。如果没有加密就是一个无效的数据，出现无效数据有可能是你要拍的商品没有货了。在goods的BuildOrder里面获取realPay然后在goods的createOrder里面使用realPay。在goods的createOrder中使用了fun中的createOrder对realPay的数据进行了拼接，然后使用fun的getSign进行了数字验证的计算，然后发起了一个订单请求。