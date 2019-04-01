## React 是怎么工作的呢



首先`import ReactDOM from 'react-dom';`引入了ReactDOM, 然后 `ReactDOM.render(<App />, document.getElementById('root'));`能够吧<App/>这个组件渲染到ID为root的DOM节点上。然后现在只需要在HTML中引入包含这段代码的文件然后执行这个函数就能够对页面进行重新渲染了。

但是我们在jsx文件中首先引入的是`import React from 'react'；`这个React在整个文件中其实都没有被调用，其实这个只是jsx文件给的语法糖而已，我们在使用组件的时候就是使用到React。比如下面的例子：
```
<div className="sidebar" /> hello word<div>
//会被编译为
React.createElement(
  'div',
  {className: 'sidebar'},
  'hello word'
)
```
在这里如果是内置组件，则名字是小写，如div，这个时候传给`React.createElement`函数的将是`'div'`字符串，但是如果是自定义的组件，组件名应该是以大写字母开始，然后这个时候编译的时候则不是传入的字符串，而是组件名。如下：
```
<MyButton color="blue" shadowSize={2}>
  Click Me
</MyButton>
//编译为
React.createElement(
  MyButton,
  {color: 'blue', shadowSize: 2},
  'Click Me'
)
```
## Contex
Contex 跨越组件传递参数。其创建方式：`const ThemeContext = React.createContext(defaultValue);` defaultValue可以是任何类型，字符串，对象都可以。是默认值。也可以用`const {Provider, Consumer} = React.createContext(defaultValue);`看看就知道，这个函数返回了两个对象`Provider和Consumer`。可以通过ThemeContext.Provider来访问。具体用法如下：
```
<ThemedContext.Provider value={this.data}>
                    <ThemeButton onChange={this.handleChange}/>
</ThemedContext.Provider>
```
Provider 通过value往下传递数据。这个value最好是状态来保存，然后传递一个回调函数，回调函数修改Provider组件的状态时候，重新渲染，从而改变value向下传递的值。注意`一定要重新渲染Value往下传递的值才会更新。光是Value改变但是没有重新渲染，Consumer是不会拿到新的值的`
```
function ThemeButton(props) {
    return (
        <ThemedContext.Consumer>
            {theme => (
                <input
                    {...props}
                    style={{backgroundColor: theme.background}}
                    value={theme.background.dark}
                />

            )}
        </ThemedContext.Consumer>
    );
}
```
Consumer一定要在Provider里面。在Consumer里面要用一个函数来接收这个传递过来的值。然后在函数之中可以使用，同时函数返回一个新节点。
## react类组件的constructor构造函数

在`React`中`constructor`表示函数的的构造函数，这是ES6对类的默认方法，该方法是类中必须有的，如果没有显示定义，则会默认添加空的`constructor( )`方法。
```
class Point {
}

// 相当于
class Point {
  constructor() {}
}
```
在class方法中，继承使用 extends 关键字来实现。子类必须在`constructor( )调用 super( )`方法，否则新建实例时会报错，`因为子类没有自己的this对象，而是继承父类的this对象`，然后对其进行加工，如果不调用super方法；子类就得不到this对象。
## react的this.setState(arg1, arg2) 方法
此方法用于修改react中的状态，`函数接受两个参数，aeg1可以是对象或者是函数，arg2是函数，在state改变之后执行，是一个回掉函数，arg2可以为空`。比如:
```
this.setState({ isAuthenticated: true});
this.setState({ isAuthenticated: true},()=>{});
```
### arg1为函数的时候的用法
首先在什么时候用，`当你需要使用当前state或者是props去计算下一个状态的时候，你需要使用函数式。`使用的时候，这个函数会接收到两个参数，第一个是当前的state值，第二个是当前的props，这个函数应该返回一个对象，这个对象代表想要对this.state的更改，换句话说，之前你想给this.setState传递什么对象参数，在这种函数里就返回什么对象，不过，计算这个对象的方法有些改变，不再依赖于this.state，而是依赖于输入参数state。比如：
```
this.setState((preState, props) => {
                    return {isAuthenticated: props.isAuthen}
                });

this.setState((preState, props) => ({
                    isAuthenticated: !preState.isAuthenticated
                }));
```
两种写法，后面一种使用了箭头函数可以省略return语句的写法。
### 为什么有这两种方法。
调用setState，组件的state并不会立即改变，setState只是把要修改的状态放入一个队列中，React会优化真正的执行时机，并且React会出于性能原因，可能会将多次setState的状态修改合并成一次状态修改。所以不要依赖当前的State，计算下个State。 
例如：
```
function incrementMultiple() {
  this.setState({count: this.state.count + 1});
  this.setState({count: this.state.count + 1});
  this.setState({count: this.state.count + 1});
}
```
直观上来看，当上面的incrementMultiple函数被调用时，组件状态的count值被增加了3次，每次增加1，那最后count被增加了3，但是，实际上的结果只给state增加了1。

原因并不复杂，就是因为调用this.setState时，并没有立即更改this.state，所以this.setState只是在反复设置同一个值而已，上面的code等同下面这样。
```
function incrementMultiple() {
  const currentCount = this.state.count;
  this.setState({count: currentCount + 1});
  this.setState({count: currentCount + 1});
  this.setState({count: currentCount + 1});
}
```
currentCount就是一个快照结果，重复地给count设置同一个值，不要说重复3次，哪怕重复一万次，得到的结果也只是增加1而已。

那么如果想要结果是3怎么做呢？这时就需要第二种写法：
```
_bsetIncrementMultiple = () => {
        this.setState(prevState => ({
            count: prevState.count + 1
        }));
        this.setState(prevState => ({
            count: prevState.count + 1
        }));
        this.setState(prevState => ({
            count: prevState.count + 1
        }));
    }
```
这样，每一次改变count的时候，都是prevState.count + 1，pervState是前一个状态，每次setState之后，前一个状态都会改变，那么这时候，结果就是想要的3了。如果需要立即setState 那么传入一个函数来执行setState是最好的选择.

## React 必须被声明
由于 JSX 编译后会调用 `React.createElement` 方法，所以在你的 JSX 代码中必须首先声明 React 变量。即在JSX文件头部`import React from 'react'`;必须有。

组件的名字必须大写，这是因为由于 JSX 当元素类型以小写字母开头时，它表示一个内置的组件，如 <div> 或 <span>，并将字符串 ‘div’ 或 ‘span’ 传 递给 `React.createElement`。 以大写字母开头的类型，如 <Foo /> 编译为 `React.createElement(Foo)`，并它正对应于你在 JavaScript 文件中定义或导入的组件。
### 条件渲染
这在根据条件来确定是否渲染React元素时非常有用。以下的JSX只会在showHeader为true时渲染<Header />组件。
```
<div>
  {showHeader && <Header />}
  <Content />
</div>
```
这里需要主要`只有showHeader = false 才是条件渲染，如果showHeader = 0,这种，后边的header组件还是会渲染的。`
## Refs
在React中组件并不是真实的 DOM 节点，而是存在于内存之中的一种数据结构，叫做虚拟 DOM （virtual

DOM）。只有当它插入文档以后，才会变成真实的 DOM 。根据 React 的设计，所有的 DOM 变动，都先

在虚拟 DOM 上发生，然后再将实际发生变动的部分，反映在真实 DOM上，这种算法叫做 DOM diff ，它

可以极大提高网页的性能表现。

如果我们想在虚拟DOM时（此时DOM还没有转化为真是DOM），取到某一个元素，此时不能通过

JS的getElementByXXX这种形式。这个时候就需要用到Refs

`首先每一个组件或者是html元素都有ref属性，这个属性接受一个函数或者是一个ref的引用，如果接受的是函数则这个函数呢会在这个组件被挂载的时候在componentDidMount()函数中执行，如果是传递的ref的引用，则会在上面的函数中将引用ref的current属性设置为当前的DOM节点（如果用则HTML元素上）或者是组件的实例（用在组件上）。`下面说明如果是使用ref应用,使用React.createRef()来创建ref引用。
```
class CustomTextInput extends React.Component {
  constructor(props) {
    super(props);
    // 创建 ref 存储 textInput DOM 元素
    this.textInput = React.createRef();
    this.focusTextInput = this.focusTextInput.bind(this);
  }

  focusTextInput() {
    // 直接使用原生 API 使 text 输入框获得焦点
    // 注意：通过 "current" 取得 DOM 节点
    this.textInput.current.focus();
  }

  render() {
    // 告诉 React 我们想把 <input> ref 关联到构造器里创建的 `textInput` 上
    return (
      <div>
        <input
          type="text"
          ref={this.textInput} />

          
        <input
          type="button"
          value="Focus the text input"
          onClick={this.focusTextInput}
        />
      </div>
    );
  }
}
```
`下面的例子是使用回调函数。`
```
class Input extends Component {
    constructor(props){
        super(props);
       this.focus = this.focus.bind(this)
    }
    focus(){
        this.textInput.focus();
    }
    
    render(){
        return (
            <div>
                <input ref={(input) => { this.textInput = input }} />//input参数表示DOM本身
                <button  onClick={this.focus}>让input获取焦点</button>
            </div>
        )
    }
}
```

## 箭头函数

关于挂载时的 setInterval 中调用 tick() 的方式 ()=>this.tick()：

1、()=>this.tick()

()=>this.tick() 是 ES6 中声明函数的一种方式，叫做箭头函数表达式，引入箭头函数有两个方面的作用`：更简短的函数并且不绑定 this。`

var f = ([参数]) => 表达式（单一）
// 等价于以下写法
var f = function([参数]){
   return 表达式;
}
箭头函数的基本语法如下：

(参数1, 参数2, …, 参数N) => { 函数声明 }
(参数1, 参数2, …, 参数N) => 表达式（单一）
//相当于：(参数1, 参数2, …, 参数N) =>{ return 表达式; }

`// 当只有一个参数时，圆括号是可选的：
(单一参数) => {函数声明}
单一参数 => {函数声明}`

// 没有参数的函数应该写成一对圆括号。
() => {函数声明}
根据以上概念，尝试将 setInterval 中调用 tick() 的方式改为通常声明方式：

```
this.timerID = setInterval(function(){
    return this.tick();
  },1000
);
但是会报错，tick() 不是一个方法。

2、this.tick()

this.tick() 中的 this 指代的是 function，而不是我们想要的指代所在的组件类 Clock，所以我们要想办法让 this 能被正常指代。这里我们采用围魏救赵的办法:

let that = this;
this.timerID = setInterval(function () {
  return that.tick();
},1000);
```
在闭包函数的外部先用 that 引用组件 Clock 中挂载组件方法 componentDidMount() 中 this 的值，然后在 setInterval 中闭包函数中使用that，that 无法找到声明，就会根据作用域链去上级（上次层）中继承 that，也就是我们引用的组件类 Clock 中的 this。

到此为止，将 () => this.tick()等价代换为了我们熟悉的形式。
## 组件
`函数组件`
```
function ActionLink() {
  function handleClick(e) {
    e.preventDefault();
    console.log('链接被点击');
  }
 
  return (
    <a href="#" onClick={handleClick}>
      点我
    </a>
  );
}
```
函数组件其中HTML标签在return语句中，其他地方可以写逻辑，在使用的时候还是和其他组件一样的，但是这里将从上级组件传进来的属性都封装到props这个对象中，使用this.props.propName去访问。其中组件中的一些函数就直接在函数里面定义函数。

`类组件`
```
class Welcome extends React.Component {
  render() {
    return <h1>Hello World!</h1>;
  }
}
```
类组件，就很常见了，其中组件中的HTML内容写在类的一个`特殊函数render(){return()}}函数里`，return里的内容就是HTML标签。
## prop的类型验证
Props 验证使用 propTypes，它可以保证我们的应用组件被正确使用，React.PropTypes 提供很多验证器 (validator) 来验证传入数据是否有效。当向 props 传入无效数据时，JavaScript 控制台会抛出警告。

```
var title = "菜鸟教程";
// var title = 123;
class MyTitle extends React.Component {
  render() {
    return (
      <h1>Hello, {this.props.title}</h1>
    );
  }
}
 
MyTitle.propTypes = {
  title: PropTypes.string
};
```
## react 中的this
你必须谨慎对待 JSX 回调函数中的 this，类的方法默认是不会绑定 this 的。`如果你忘记绑定 this.handleClick 并把它传入 onClick, 当你调用这个函数的时候 this 的值会是 undefined。`

这并不是 React 的特殊行为；它是函数如何在 JavaScript 中运行的一部分。通常情况下，如果你没有在方法后面添加 () ，例如 onClick={this.handleClick}，你应该为这个方法绑定 this。

一种是在构造函数中为函数绑定this,`这个绑定this的意思是，当在子组件中调用这个函数的时候，这个函数里面的this还是指向的父组件，如果不绑定，则在子组件中调用的时候，这个this。undefined。然而在父组
件中的任何函数内的this都是指向的这个父组件本身。所以，只有在函数中使用到了this，才需要绑定this，如果函数内部没有使用到this，其实是不用绑定this。`
```
 constructor(props) {
    super(props);
    this.state = {isToggleOn: true};
 
    // 这边绑定是必要的，这样 `this` 才能在回调函数中使用
    this.handleClick = this.handleClick.bind(this);
  }
  ```
  `如果使用 bind 让你很烦，这里有两种方式可以解决。如果你正在使用实验性的属性初始化器语法，你可以使用属性初始化器来正确的绑定回调函数：`
  ```
  class LoggingButton extends React.Component {
  // 这个语法确保了 `this` 绑定在  handleClick 中
  // 这里只是一个测试
  handleClick = () => {
    console.log('this is:', this);
  }
 
  render() {
    return (
      <button onClick={this.handleClick}>
        Click me
      </button>
    );
  }
}
```
如果你没有使用属性初始化器语法，你可以在回调函数中使用 箭头函数：
```
class LoggingButton extends React.Component {
  handleClick() {
    console.log('this is:', this);
  }
 
  render() {
    //  这个语法确保了 `this` 绑定在  handleClick 中
    return (
      <button onClick={(e) => this.handleClick(e)}>
        Click me
      </button>
    );
  }
}
```
## 向事件处理程序传递参数
```
<button onClick={(e) => this.deleteRow(id, e)}>Delete Row</button>
<button onClick={this.deleteRow.bind(this, id)}>Delete Row</button>
```
上面两个例子中，参数 e 作为 React 事件对象将会被作为第二个参数进行传递。通过箭头函数的方式，事件对象必须显式的进行传递，`但是通过 bind 的方式，事件对象以及更多的参数将会被隐式的进行传递。`
```
 preventPop(name, e){    //事件对象e要放在最后
        e.preventDefault();
        alert(name);
    }
    
    render(){
        return (
            <div>
                <p>hello</p>
                {/* 通过 bind() 方法传递参数。 */}
                <a href="https://reactjs.org" onClick={this.preventPop.bind(this,this.state.name)}>Click</a>
            </div>
        );
    }
```

`需要通过 bind 方法来绑定参数，第一个参数指向 this,第二个参数开始才是事件函数接收到的参数:`
```
<button onClick={this.handleClick.bind(this, props0, props1, ...}></button>
 
handleClick(porps0, props1, ..., event) {
    // your code here
}
```

## 警告:

```组件名称必须以大写字母开头。```

例如，<div /> 表示一个DOM标签，但 <Welcome /> 表示一个组件，并且在使用该组件时你必须定义或引入它。

## 组件（函数组件，类组件）

使用函数组件的时候函数名需要大小，而函数的形参就是props，在使用属性时，直接使用props.name即可。

使用类组件的时候需要使用class声明，然后继承 React.Conmpnent类。这个时候才能使用状态和钩子函数。使用this.props.name来访问传入组件内的属性，使用this.state.stateName访问属性，this.setState({state: newState,})了更新状态。

## 生命周期钩子

```
componentDidMount(){

}

componentWillUnmount(){

}
componentDidUpdate(){

}
componentWillUpdate(){

}
```
这两个函数称为生命周期钩子，当组件输出到DOM之后会执行componentDidMount()函数，当组件生成的DOM被移除之后会执行componentWillmount()函数。

## state
组件的构造函数是唯一能够初始化state的地方。

setState(arg1,arg2) 括号内的arg1可传入两种参数，一种是对象，一种是函数. arg2为更改state之后的回调方法,arg2可为空.
### 对象式的setState用法
```
this.setState({ isAuthenticated: true});
this.setState({ isAuthenticated: true},()=>{});

this.setState({isAuthenticated: true}, () => console.log(this.state.isAuthenticated + '.'));
            
```
### 函数式的setState用法
这个函数会接收到两个参数，第一个是当前的state值，第二个是当前的props，这个函数应该返回一个对象，这个对象代表想要对this.state的更改，换句话说，之前你想给this.setState传递什么对象参数，在这种函数里就返回什么对象，不过，计算这个对象的方法有些改变，不再依赖于this.state，而是依赖于输入参数state。 
这个函数格式是固定的，必须第一个参数是state的前一个状态，第二个参数是属性对象props，这两个对象setState会自动传递到函数中去
```
this.setState((preState, props) => {return {isAuthenticated: props.isAuthen}});

this.setState((preState, props) => ({isAuthenticated: !preState.isAuthenticated}));
```
### 使用场景
调用setState，组件的state并不会立即改变，setState只是把要修改的状态放入一个队列中，React会优化真正的执行时机，并且React会出于性能原因，可能会将多次setState的状态修改合并成一次状态修改。所以不要依赖当前的State，计算下个State。

如果需要立即setState 那么传入一个函数来执行setState是最好的选择，它会立即更新状态。`其实就是如果你更新状态的时候需要用到之前的状态就应该使用函数式更新。`

## JSX 
本质上来讲，JSX 只是为 `React.createElement(component, props, ...children)` 方法提供的语法糖。比如下面的代码
```
<MyButton color="blue" shadowSize={2}>
  Click Me
</MyButton>
```
编译之后
```
React.createElement(
  MyButton,
  {color: 'blue', shadowSize: 2},
  'Click Me'
)
```
如果没有子代，你还可以使用自闭合标签
```
<div className="sidebar" />
```
编译之后
```
React.createElement(
  'div',
  {className: 'sidebar'},
  null
)
```
#



# react数据请求
使用fetch
```
 fetch("http://127.0.0.1:8080/getUser",{
     method:'post', 
     mode:'cors',
     body: JSON.stringify({"name":'test'}), 
     headers: new Headers({'Content-Type': 'application/json;charset=UTF-8'})}).then((response) => response.json())
     .then((res) => console.log(res))
     .then((res) => userdata.push(res));
```
当然你使用`get`请求方式的时候，没有向后端传送数据，这个时候就没什么，但是如果使用`post`方法，这个时候就需要注意后端传送数据的形式，上面的例子是使用了`body:JSON.stringfy(数据对象)`，这个是post+json字符串的形式，这个时候headers这个`Content-Type`参数就很重要。

`但是这个参数也不是非要写`

`非文件上传时`，无关你发送的数据格式是application/x-www-form-urlencoded或者application/json格式数据，你不设置请求头，fetch会给你默认加上一个Content-type = text/xml类型的请求头，有些第三方JAX可以自己识别发送的数据，并自己转换，但feth绝对不会，所以这个时候就要写明对应的`Content-Type`在请求的header中。这样后端才能解析你的数据，不然会报错415。

文件上传请求时（包括图片），因为不知道那个boundary的定义方式，所以就如建议的一样，我们不设置Content-type。这个时候这样后端才能解析你的数据，不然会报错415。这个boundary是什么呢。在传输文件的时候，文件会被拆分。就是发http请求规定的数据交换规则.类似于：A发送请求给B，并告诉B，我给你送来了三个快递（但为了好搬运，我将它捆成了一个包裹），包裹拆分的规则在快递单上有说明，于是B就按A说的规则，进行包裹拆分。

## 文件上传
```
<input type="file" onChange={this.handleChange}>
```
文件上传可以使用上面这一个组件。在handleChange函数中可以通过`事件对象event`来获得上传的文件对象。e.target获得该input对象，e.target.files得到上传的文件对象，该对象是一个数组，可以通过下标来访问上传的多个文件对象。其中每个对象可以获得如下信息。

   file.name//获取本地文件系统的文件名。

　　file.size//文件的字节大小。

　　file.type//字符串类型,文件的MIME类型。

　　file.lastModifiedDate//文件的最后修改时间。(只使用于Chrome浏览器)

在读取文件信息的时候需要使用FileReader对象，通过var reader = new FileReader()获得，该对象是异步读取文件信息，其中FileReader有一下几种读取文件数据的方法

1）.readAsText(file,encoding);以纯文本的形式读取文件，将读取到的文件保存到result属性。encoding参数用于指定编码类型，是可选的。

2）.readAsDataURL(file);读取文件并将文件数据以URL形式保存到result属性中。（读取图像文件常用方法）

3）.readAsBinaryString(file);读取文件并将一个字符串保存在result属性中，字符串中的每个字符表示一字节。

4）.readAsArrayBuffer(file);读取文件并将一个包含文件内容的ArrayBuffer保存在result属性中。

FileReader提供了几个事件：
           .onloadstart 上传开始

           .onprogress 上传中
           
           .onload  上传结束
           
           .onloadend 上传完毕

举例如下
```
<input type='file' accept='text/plain' onchange='openFile(event)'><br>
<img id='output'>
<script>
  var openFile = function(event) {
    var input = event.target;  //拿到input对象

    var reader = new FileReader(); //创建FileReader
    reader.onload = function(){    // 绑定`读取结束之后`的处理函数其实file已经上传完了，只是需要FileReader来读取其中的数据而已
      var text = reader.result;   // 读取到的结果保存在reader.result中
      console.log(reader.result.substring(0, 200));
    };
    reader.readAsText(input.files[0]); //读取文件 。`因为是异步读取，绑定处理事件之后才开始读取文件
  };
</script>
```
### 向后端发送文件
#### FormData
https://developer.mozilla.org/zh-CN/docs/Web/API/FormData

XMLHttpRequest Level 2添加了一个新的接口FormData.利用FormData对象,我们可以通过JavaScript用一些键值对来模拟一系列表单控件,我们还可以使用XMLHttpRequest的send()方法来异步的提交这个"表单".比起普通的ajax,使用FormData的最大优点就是我们可以异步上传一个二进制文件.
构造函数：
```
new FormData (form? : HTMLFormElement);
```
方法：append()
```
FormData.append(name, value, filename)
```
name是键。value是值。filename(可选) 指定文件的文件名,当value参数被指定为一个Blob对象或者一个File对象时,该文件名会被发送到服务器上,对于Blob对象来说,这个值默认为"blob". 其他方法看出处。
#### 发送文件
代码如下：
```
const formData = new FormData();
formData.append('file', files[0]);
fetch("http://127.0.0.1:8080/loadfile",{
      method :"POST",
      mode: 'cors',// 跨域访问
      body: formData
      }).then((res)=> res.json()).then((res) => console.log(res));
```
在向后段发送文件的额时候，header里面的`content-type`是multipart/form-data。这个时候不需要我们自己来设置，因为我们没办法知道这个boundary，这样会导致服务器出现`the request was rejected because no multipart boundary was found`错误。


## 从后端获取的数据处理
### 后端返回了一个对象
用fetch来获取数据，如果响应正常返回，我们首先看到的是一个response对象，其中包括返回的一堆原始字节，这些字节需要在收到后，需要我们通过调用方法将其转换为相应格式的数据，比如JSON，BLOB或者TEXT等等。比如，我们通过下面的请求，是无法读取到网页内容的：
```
fetch('https://www.baidu.com/').then(res => console.log(res))
```
打印出来的仅仅是一个原始的response对象而已，从中看不到任何的返回内容。而为了能够读取到返回的内容，我们需要在收到response对象后，立即将其转换为我们想要的格式，比如TEXT：
```
fetch("url",{}).then((res)=> res.text()).then((res)=> console.log(res))
```
如果后段返回的是一个对象那么需要进行反序列化：
```
fetch("url",{}).then((res)=> res.json()).then((res) => console.log(res))
```
## 数据MD5加密
添加依赖
```
yarn add js-md5
```
使用方法：
```
import md5 from 'js-md5';
md5("需要加密的数据");
```
## react生命周期勾子函数
```
componentWillMount ：在渲染前调用,在客户端也在服务端。

componentDidMount：在第一次渲染后调用，只在客户端。之后组件已经生成了对应的DOM结构，可以通过this.getDOMNode()来进行访问。

componentWillReceiveProps：在组件接收到一个新的prop时被调用。这个方法在初始化render时不会被调用。

shouldComponentUpdate：返回一个布尔值。在组件接收到新的props或者state时被调用。在初始化时或者使用forceUpdate时不被调用，可以在你确认不需要更新组件时使用。

componentWillUpdate：在组件接收到新的props或者state但还没有render时被调用。在初始化时不会被调用。

componentDidUpdate：在组件完成更新后立即调用。在初始化时不会被调用。

componentWillUnmount：在组件从 DOM 中移除的时候立刻被调用。
```

## 一个状态的值是中包含了另外一个状态，如A：<ttt s=P{B}>， AB是状态那么被包含的状态更新了，如果B更新了 A不会刷新重新渲染。

## material UI DatePicker
在使用这个组件的时候安装依赖的时候需要注意一点：
```
"date-fns": "next",
```
这个依赖，在package.json里面版本是next。