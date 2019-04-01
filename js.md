# JS中的Map
创建对象用new
```
var m = new Map(); // 空Map
m.set('Adam', 67); // 添加新的key-value
m.set('Bob', 59);
m.has('Adam'); // 是否存在key 'Adam': true
m.get('Adam'); // 67
m.delete('Adam'); // 删除key 'Adam'
m.get('Adam'); 
```
## Map 遍历
```
for (var x of m) { // 遍历Map
    alert(x[0] + '=' + x[1]);
}
```
### 更好的遍历：forEach
forEach是iterable内置的方法，它接收一个函数，每次迭代就自动回调该函数。
```
var m = new Map([[1, 'x'], [2, 'y'], [3, 'z']]);
m.forEach(function (value, key, map) {
    alert(value);
});
```
# JS中的Set
Set和Map类似，也是一组key的集合，但不存储value。由于key不能重复，所以，在Set中，没有重复的key。

要创建一个Set，需要提供一个Array作为输入，或者直接创建一个空Set：
```
var s1 = new Set(); // 空Set
var s2 = new Set([1, 2, 3]); // 含1, 2, 3
```
重复元素在Set中自动被过滤：
```
var s = new Set([1, 2, 3, 3, '3']);
s; // Set {1, 2, 3, "3"}
```
通过add(key)方法可以添加元素到Set中，可以重复添加，但不会有效果,痛殴delete(key)删除元素。
```
s.add(4);
s; // Set {1, 2, 3, 4}
s.add(4);
s; // 仍然是 Set {1, 2, 3, 4}
s.add(4);
s; // Set {1, 2, 3, 4}
s.delete(4);
s; // 是 Set {1, 2, 3, }
```
##  遍历
```
var s = new Set();
for (var x of s) { // 遍历Set
    alert(x);
}
```
### 遍历 forEach
Set与Array类似，但Set没有索引，因此回调函数的前两个参数都是元素本身：
```
var s = new Set(['A', 'B', 'C']);
s.forEach(function (element, sameElement, set) {
    alert(element);
});
```
# JS中的数组遍历也可以用forEach
```
var a = ['A', 'B', 'C'];
a.forEach(function (element, index, array) {
    // element: 指向当前元素的值
    // index: 指向当前索引
    // array: 指向Array对象本身
    alert(element);
});
```
## Date
创建用
```
let date = new Date("时间格式");
```
参数也可以用，这样就会创建当前时间
### Date -> 时间戳
```
var timestamp1 = (new Date()).valueOf();
// 结果：1535374762785，通过valueOf()函数返回指定对象的原始值获得准确的时间戳值；
var timestamp2 = new Date().getTime();
// 结果：1535374762785，通过原型方法直接获得当前时间的毫秒值，准确；
var timetamp3 = Number(new Date()) ;
//结果：1535374762785，将时间转化为一个number类型的数值，即时间戳；
```