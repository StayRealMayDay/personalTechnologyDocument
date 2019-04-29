# redux
应用中所有的 state 都以一个对象树的形式储存在一个单一的 store 中。 惟一改变 state 的办法是触发 action，一个描述发生什么的对象。 为了描述 action 如何改变 state 树，你需要编写 reducers。

`reducer 就是一个纯函数，用来改变状态而已。每一个reducer可以看作是react的状态里面的键key，而这个reducer接受的状态就是react状态里面对应的键的值。另外一个参数就是action。返回更新之后的状态。`

## 三大原则
### 单一数据源
整个应用的 state 被储存在一棵 object tree 中，并且这个 object tree 只存在于唯一一个 store 中。
```
console.log(store.getState())

/* 输出
{
  visibilityFilter: 'SHOW_ALL',
  todos: [
    {
      text: 'Consider using Redux',
      completed: true,
    },
    {
      text: 'Keep all state in a single tree',
      completed: false
    }
  ]
}
*／
```
### State 是只读的
唯一改变 state 的方法就是触发 action，action 是一个用于描述已发生事件的普通对象。
```
store.dispatch({
  type: 'COMPLETE_TODO',
  index: 1
})

store.dispatch({
  type: 'SET_VISIBILITY_FILTER',
  filter: 'SHOW_COMPLETED'
})
```
### 使用纯函数来执行修改
为了描述 action 如何改变 state tree ，你需要编写 reducers。Reducer 只是一些纯函数，它接收先前的 state 和 action，并返回新的 state。
```
function visibilityFilter(state = 'SHOW_ALL', action) {
  switch (action.type) {
    case 'SET_VISIBILITY_FILTER':
      return action.filter
    default:
      return state
  }
}

function todos(state = [], action) {
  switch (action.type) {
    case 'ADD_TODO':
      return [
        ...state,
        {
          text: action.text,
          completed: false
        }
      ]
    case 'COMPLETE_TODO':
      return state.map((todo, index) => {
        if (index === action.index) {
          return Object.assign({}, todo, {
            completed: true
          })
        }
        return todo
      })
    default:
      return state
  }
}

import { combineReducers, createStore } from 'redux'
let reducer = combineReducers({ visibilityFilter, todos })
let store = createStore(reducer)
```

## reducer修改状态
### 不要修改 state
使用 Object.assign() 新建了一个副本。不能这样使用 Object.assign(state, { visibilityFilter: action.filter })，因为它会改变第一个参数的值。你必须把第一个参数设置为空对象。你也可以开启对ES7提案对象展开运算符的支持, 从而使用 { ...state, ...newState } 达到相同的目的。

### 在 default 情况下返回旧的 state。遇到未知的 action 时，一定要返回旧的 state。
```
function todoApp(state = initialState, action) {
  switch (action.type) {
    case SET_VISIBILITY_FILTER:
      return Object.assign({}, state, {
        visibilityFilter: action.filter
      })
    case ADD_TODO:
      return Object.assign({}, state, {
        todos: [
          ...state.todos,
          {
            text: action.text,
            completed: false
          }
        ]
      })
    default:
      return state
  }
}
```

## 注意每个 reducer 只负责管理全局 state 中它负责的一部分。每个 reducer 的 state 参数都不同，分别对应它管理的那部分 state 数据。
现在看起来好多了！随着应用的膨胀，我们还可以将拆分后的 reducer 放到不同的文件中, 以保持其独立性并用于专门处理不同的数据域。

最后，Redux 提供了 combineReducers() 工具类来合并不同的reducer，这样就能消灭一些样板代码了。有了它，可以这样重构 todoApp：
```
import { combineReducers } from 'redux'

const todoApp = combineReducers({
  visibilityFilter,
  todos
})

export default todoApp
```
注意上面的写法和下面完全等价：
```
export default function todoApp(state = {}, action) {
  return {
    visibilityFilter: visibilityFilter(state.visibilityFilter, action),
    todos: todos(state.todos, action)
  }
}
```
全局state有两个状态，一个是visibilityFilter，另外一个是todos。然后分别用两个reducer来处理这两个状态。这两个reducer的名字和对应其处理的状态名字相同。然后通过combineReducers()将这两个reducers合并起来。
你也可以给它们设置不同的 key，或者调用不同的函数。下面两种合成 reducer 方法完全等价：
```
const reducer = combineReducers({
  a: doSomethingWithA,
  b: processB,
  c: c
})
```
```
function reducer(state = {}, action) {
  return {
    a: doSomethingWithA(state.a, action),
    b: processB(state.b, action),
    c: c(state.c, action)
  }
}
```
combineReducers() 所做的只是生成一个函数，这个函数来调用你的一系列 reducer，每个 reducer 根据它们的 key 来筛选出 state 中的一部分数据并处理，然后这个生成的函数再将所有 reducer 的结果合并成一个大的对象。

combineReducers 接收一个对象，可以把所有顶级的 reducer 放到一个独立的文件中，通过 export 暴露出每个 reducer 函数，然后使用 import * as reducers 得到一个以它们名字作为 key 的 object：
```
import { combineReducers } from 'redux'
import * as reducers from './reducers'

const todoApp = combineReducers(reducers)
```
## Store
Store 就是把它们联系到一起的对象。Store 有以下职责：

维持应用的 state；

提供 getState() 方法获取 state；

提供 dispatch(action) 方法更新 state；

通过 subscribe(listener) 注册监听器;

通过 subscribe(listener) 返回的函数注销监听器。
### 创建store
```
import { createStore } from 'redux'
import todoApp from './reducers'
let store = createStore(todoApp, window.STATE_FROM_SERVER)
console.log(store.getState())

// 每次 state 更新时，打印日志
// 注意 subscribe() 返回一个函数用来注销监听器
const unsubscribe = store.subscribe(() =>
  console.log(store.getState())
)
```
createStore() 的第二个参数是可选的, 用于设置 state 初始状态。这对开发同构应用时非常有用，服务器端 redux 应用的 state 结构可以与客户端保持一致, 那么客户端可以将从网络接收到的服务端 state 直接用于本地数据初始化。

注册监听器之后，每一次更新store的state就是执行监听器这个函数。

## 数据流
### Redux 应用中数据的生命周期遵循下面 4 个步骤：
#### 1.调用 store.dispatch(action)
Action 就是一个描述“发生了什么”的普通对象。比如：
```
{ type: 'LIKE_ARTICLE', articleId: 42 }
{ type: 'FETCH_USER_SUCCESS', response: { id: 3, name: 'Mary' } }
{ type: 'ADD_TODO', text: 'Read the Redux docs.' }
```
你可以在任何地方调用 store.dispatch(action)，包括组件中、XHR 回调中、甚至定时器中。
#### 2.Redux store 调用传入的 reducer 函数
Store 会把两个参数传入 reducer： 当前的 state 树和 action。
例如，在这个 todo 应用中，根 reducer 可能接收这样的数据：
```
 // 当前应用的 state（todos 列表和选中的过滤器）
 let previousState = {
   visibleTodoFilter: 'SHOW_ALL',
   todos: [
     {
       text: 'Read the docs.',
       complete: false
     }
   ]
 }

 // 将要执行的 action（添加一个 todo）
 let action = {
   type: 'ADD_TODO',
   text: 'Understand the flow.'
 }

 // reducer 返回处理后的应用状态
 let nextState = todoApp(previousState, action)
 ```
 #### 3.根 reducer 应该把多个子 reducer 输出合并成一个单一的 state 树
 根 reducer 的结构完全由你决定。Redux 原生提供combineReducers()辅助函数，来把根 reducer 拆分成多个函数，用于分别处理 state 树的一个分支。

下面演示 combineReducers() 如何使用。假如你有两个 reducer：一个是 todo 列表，另一个是当前选择的过滤器设置：

```
let todoApp = combineReducers({
   todos,
   visibleTodoFilter
 })
 ```
 当你触发 action 后，combineReducers 返回的 todoApp 会负责调用两个 reducer：
 ```
let nextTodos = todos(state.todos, action)
let nextVisibleTodoFilter = visibleTodoFilter(state.visibleTodoFilter, action)
 ```
 然后会把两个结果集合并成一个 state 树：
 ```
  return {
   todos: nextTodos,
   visibleTodoFilter: nextVisibleTodoFilter
 }
 ```
 #### 4.Redux store 保存了根 reducer 返回的完整 state 树
 这个新的树就是应用的下一个 state！所有订阅 store.subscribe(listener) 的监听器都将被调用；监听器里可以调用 store.getState() 获得当前 state。

现在，可以应用新的 state 来更新 UI。如果你使用了 React Redux 这类的绑定库，这时就应该调用 component.setState(newState) 来更新。

## 搭配 React
### 安装 React Redux
```
npm install --save react-redux
//或者
yarn add react-redux
```
官方文档讲解了什么容器组件和展示组件，太复杂，总的来说，就是把展示组件，绑定了store中的状态之后就变成了容器组件。从技术上说可以有两种方法绑定。`一个是通过store.subscribe() 来编写容器组件。另外一个就是使用connect()函数。`
### store.subscribe() 来编写容器组件
1.首先可以通过props把store对象传给每一个组件

2.在每一个组件中通过store.subscribe(()=> store.getState())函数。该函数接受一个函数作为其参数，在内部函数可以访问store的对象，然后可以更新组件的对象以此来管理组件。
### connect()函数

connect(fun1, fun2)(component)。connect()函数绑定一个组件同时将该组件转化为了容器组件，store中的状态通过props传递给了component(组件)。但是其中传递了哪些state呢。那就要看func1了。
#### func1函数
func1这个函数来指定如何把当前 Redux store state 映射到展示组件的props中。用下面这个例子讲解：
```
import * as React from "react";
import {Snackbar} from "material-ui";
import {connect} from "react-redux";
import {oMQ} from "../redux/messages";

const MessageSnackbar = ({dispatch, open, message}) => (
    <Snackbar open={open} message={message && `[${message.type}]: ${message.message}`} autoHideDuration={6000}
              onClose={() => dispatch(oMQ())}/>
);
const selector = state => ({
    open: state.messages.length > 0,
    message: state.messages[0]
});
export default connect(selector)(MessageSnackbar);
```
在这个例子中这个fuc1就是这个selector函数，该函数接收一个参数，该参数是store的state。然后返回一个对象，该对象会作为后面绑定的组件的props的一部分传进去。在selector函数中可以访问store的state。还可以在该函数内做一些计算操作。然后返回一个对象，该对象就会以props的形式传入组件中。

在组件中可以通过this.props.open来访问这个传入的open参数。当然也可以在组件定义的时候通过解构赋值拿到参数。当然也可以拿到dispatch函数。
#### func2函数
该函数一般不用，因为我们可以直接在组件里面拿到store.dispath()函数，

func2方法接收 dispatch() 方法并返回期望注入到展示组件的 props 中的回调方法。
```
const func2 = dispatch => {
  return {
    onTodoClick: id => {
      dispatch(toggleTodo(id))
    }
  }
}
```
#### 如何向组件传入store。
通过connect()函数可以将store的state和组件绑定，但是store是如何传入到组件当中的呢。因为connect()是import from 'react-redux'。但是store是创建自`import { createStore } from 'redux'`。所以connect是拿不到store的，所以需要通过其他方法传入。

`<provider>组件`
```
render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)
```
在最外层在组件使用一个`<provider>组件`就可以将store传入其所有的子组件中。
### 关于组件的wityStyle(styles)用法
`wityStyle(styles)`要放在connect的前面才可以如下
```
export default withStyles(styles)(connect(selector)(Login));
```
否则会报**Can not call a class as function**错误

### reduxDevTool用法
使用这个插件需要在创建store的时候使用中间件才可以如果是使用saga中间件则需要如下创建store
```
import saga from "redux-saga";
const sagas = saga();
const store = createStore(reducer, compose(
    applyMiddleware(sagas),
    window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()));

export default store;
```
如果是使用thunk中间件
```
import thunk from 'redux-thunk'
const middleware = [thunk];
const store = createStore(reducer, compose(
    applyMiddleware(...middleware),
    window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()));

export default store;

```
## Action
这里呢将action分成了两类，**一类action就是操作store中的状态的，只能对状态进行改变，没有网络请求啊啥的。另外一类是异步action，可以进行网络请求。**

### 同步action
说白了同步action就是一个对象，其中包含了一个type，表示操作类型，还有payload操作需要的数据。然后可以用一个函数来生成这样的一个对象，这个函数就叫action创建函数。

### 异步action
同步 action 创建函数和网络请求结合起来呢。形成异步action。标准的做法是使用 Redux Thunk 中间件。要引入 redux-thunk 这个专门的库才能使用。我们 后面 会介绍 middleware 大体上是如何工作的；目前，你只需要知道一个要点：通过使用指定的 middleware，**action 创建函数除了返回 action 对象外还可以返回函数。这时，这个 action 创建函数就成为了 thunk。**

**当 action 创建函数返回函数时，这个函数会被 Redux Thunk middleware 执行**。这个函数并不需要保持纯净；它还可以带有副作用，**包括执行异步 API 请求。这个函数还可以 dispatch action，就像 dispatch 前面定义的同步 action 一样。**
```
action.js
```
```
import fetch from 'cross-fetch'

export const REQUEST_POSTS = 'REQUEST_POSTS'
function requestPosts(subreddit) {
  return {
    type: REQUEST_POSTS,
    subreddit
  }
}

export const RECEIVE_POSTS = 'RECEIVE_POSTS'
function receivePosts(subreddit, json) {
  return {
    type: RECEIVE_POSTS,
    subreddit,
    posts: json.data.children.map(child => child.data),
    receivedAt: Date.now()
  }
}

 export const INVALIDATE_SUBREDDIT = ‘INVALIDATE_SUBREDDIT’
 export function invalidateSubreddit(subreddit) {
   return {
     type: INVALIDATE_SUBREDDIT,
     subreddit
   }
 }
//上面三个是同步action


///这里是使用方法用store.diapathch就可以了。

// 来看一下我们写的第一个 thunk action 创建函数！
// 虽然内部操作不同，你可以像其它 action 创建函数 一样使用它：
// store.dispatch(fetchPosts('reactjs'))

export function fetchPosts(subreddit) {

  // Thunk middleware 知道如何处理函数。
  // 这里把 dispatch 方法通过参数的形式传给函数，
  // 以此来让它自己也能 dispatch action。

  return function (dispatch，getState) {  //这里是action创建函数内部返回的函数会被middleware识别然后将dispatch 函数传进来，在这个函数之中可以进行dispatch操作。
  //当然这里还可以接收另外一个getState()函数可以访问到Store里面的状态。

    // 首次 dispatch：更新应用的 state 来通知
    // API 请求发起了。

    dispatch(requestPosts(subreddit))

    // thunk middleware 调用的函数可以有返回值，
    // 它会被当作 dispatch 方法的返回值传递。

    // 这个案例中，我们返回一个等待处理的 promise。
    // 这并不是 redux middleware 所必须的，但这对于我们而言很方便。

    return fetch(`http://www.subreddit.com/r/${subreddit}.json`)
      .then(
        response => response.json(),
        // 不要使用 catch，因为会捕获
        // 在 dispatch 和渲染中出现的任何错误，
        // 导致 'Unexpected batch number' 错误。
        // https://github.com/facebook/react/issues/6895
         error => console.log('An error occurred.', error)
      )
      .then(json =>
        // 可以多次 dispatch！
        // 这里，使用 API 请求结果来更新应用的 state。

        dispatch(receivePosts(subreddit, json))
      )
  }
}

```
我们是如何在 dispatch 机制中引入 Redux Thunk middleware 的呢？我们使用了 applyMiddleware()，如下：在创建store的时候添加中间件。
```
index.js
```
```
import thunkMiddleware from 'redux-thunk'
import { createLogger } from 'redux-logger'
import { createStore, applyMiddleware } from 'redux'
import { selectSubreddit, fetchPosts } from './actions'
import rootReducer from './reducers'

const loggerMiddleware = createLogger()

const store = createStore(
  rootReducer,
  applyMiddleware(
    thunkMiddleware, // 允许我们 dispatch() 函数
    loggerMiddleware // 一个很便捷的 middleware，用来打印 action 日志
  )
)

store.dispatch(selectSubreddit('reactjs'))
store
  .dispatch(fetchPosts('reactjs'))
  .then(() => console.log(store.getState())
)
```
### 服务端渲染须知

**异步 action 创建函数对于做服务端渲染非常方便。你可以创建一个 store，dispatch 一个异步 action 创建函数，这个 action 创建函数又 dispatch 另一个异步 action 创建函数来为应用的一整块请求数据，同时在 Promise 完成和结束时才 render 界面。然后在 render 前，store 里就已经存在了需要用的 state。好比可以在最外层组件使用componentWillAmount函数里面请求数据**

## Middleware
Redux middleware 被用于解决不同的问题，它提供的是位于 action 被发起之后，到达 reducer 之前的扩展点。 你可以利用 Redux middleware 来进行日志记录、创建崩溃报告、调用异步接口或者路由等等。

### 例子 记录日志

我们想记录在dispatch之前发生了什么，之后发生了什么，当然我们可以手动记录
#### 手动记录
```
let action = addTodo('Use Redux')

console.log('dispatching', action)
store.dispatch(action)
console.log('next state', store.getState())
```
就是在dispatch前后记录需要的信息。但是这样很麻烦，所以可以封装成一个函数。

#### 封装dispatch
把上面的操作封装起来
```
function dispatchAndLog(store, action) {
  console.log('dispatching', action)
  store.dispatch(action)
  console.log('next state', store.getState())
}
```
但是这样的话，每次就需要从外部引入这个函数，所以我们可以选择将其隐藏起来，直接替换store.dispatch方法。
#### Monkeypatching Dispatch

```
function patchStoreToAddLogging(store) {
  let next = store.dispatch
  store.dispatch = function dispatchAndLog(action) {
  console.log('dispatching', action)
  let result = next(action)
  console.log('next state', store.getState())
  return result
}
}
```
我们将原来的dispatch方法保存到next中，然后封装一个新的方法`dispatchAndLog`，在新的方法中记录我们所要记录的东西，同时又使用next来发动原来的dispatch方法，然后将这个封装的`dispatchAndLog`方法赋值给store.dispatch。这样就话就相当于修改了原来的store.dispatch方法为我们增加了新的功能，

但是这种方法只能为每一个功能单独实现且单独绑定，当我们要切换功能的时候就需要重新绑定store.dispatch方法。另外一个缺点就是比如你实现了多个动能，分别用不同的函数来实现了，但是你想要结合这些功能的时候，你需要另外写一个新的函数来将这几个功能合并成一个函数，再绑定store.dispatch. 这样很不方便。所以有了下面这个。**这个时候你已经开始明白什么是中间件了**

#### 隐藏 Monkeypatching
为了解决上面的问题，其实只需要简单的改变一下，我们在这个patchStoreToAddLogging函数中返回一个函数。本来在这个函数中是需要修改store.dispatch函数的。就是要给store.dispatch绑定一个新的函数，我们这里将这个函数返回。
```
function logger(store) {
  let next = store.dispatch

  // 我们之前的做法:
  // store.dispatch = function dispatchAndLog(action) {

  return function dispatchAndLog(action) {
    console.log('dispatching', action)
    let result = next(action)
    console.log('next state', store.getState())
    return result
  }
}
```
这样的话，虽然在这个函数中我们没有将新的函数于store.dispatch绑定，但是我们返回了这个需要绑定的store.dispatch函数，我们在外部进行绑定就好，但是这样实现之后我们就可以将多个功能串起来，就是将多个中间件串起来。看如下代码。就是applyMiddlewareByMonkeypatching函数。
```
function applyMiddlewareByMonkeypatching(store, middlewares) {
  middlewares = middlewares.slice()
  middlewares.reverse()

  // 在每一个 middleware 中变换 dispatch 方法。
  middlewares.forEach(middleware =>
    store.dispatch = middleware(store)
  )
}
```
在这段代码中如下代码：
```
middlewares.forEach(middleware =>
    store.dispatch = middleware(store)
  )
```
当一个middleware进来的时候会将原来的store.dispatch函数保存到next变量中，然后封装功能，然后返回一个新的函数，绑定到store.dispatch中，然后下一个middleware进来的时候会将上一个修改过的store.dispatch函数保存到next变量中，然后加上功能之后返回一个新的函数，这样两个middleware就串起来了然后绑定到store.dispatch中。

为什么我们要替换原来的 dispatch 呢？当然，这样我们就可以在后面直接调用它，但是还有另一个原因：就是每一个 middleware 都可以操作（或者直接调用）前一个 middleware 包装过的 store.dispatch。

将 middleware 串连起来的必要性是显而易见的。

如果 applyMiddlewareByMonkeypatching 方法中没有在第一个 middleware 执行时立即替换掉 store.dispatch，那么 store.dispatch 将会一直指向原始的 dispatch 方法。也就是说，第二个 middleware 依旧会作用在原始的 dispatch 方法。

#### 移除 Monkeypatching
但是，还有另一种方式来实现这种链式调用的效果。可以让 middleware 以方法参数的形式接收一个 next() 方法，而不是通过 store 的实例去获取。
```
unction logger(store) {
  return function wrapDispatchToAddLogging(next) {
    return function dispatchAndLog(action) {
      console.log('dispatching', action)
      let result = next(action)
      console.log('next state', store.getState())
      return result
    }
  }
}
```
使用箭头函数:
```
const logger = store => next => action => {
  console.log('dispatching', action)
  let result = next(action)
  console.log('next state', store.getState())
  return result
}

const crashReporter = store => next => action => {
  try {
    return next(action)
  } catch (err) {
    console.error('Caught an exception!', err)
    Raven.captureException(err, {
      extra: {
        action,
        state: store.getState()
      }
    })
    throw err
  }
}
```
当然在使用的时候需要改变一下，因为多封装了一层函数。
```
let dispatch = store.dispatch
  middlewares.forEach(middleware =>
    dispatch = middleware(store)(dispatch)
  )
```
#### 最终的使用
```
import { createStore, combineReducers, applyMiddleware } from 'redux'

let todoApp = combineReducers(reducers)
let store = createStore(
  todoApp,
  // applyMiddleware() 告诉 createStore() 如何处理中间件
  applyMiddleware(logger, crashReporter)
)
```
就是这样！现在任何被发送到 store 的 action 都会经过 logger 和 crashReporter：

```
// 将经过 logger 和 crashReporter 两个 middleware！
store.dispatch(addTodo('Use Redux'))
```
## React-Router

最新的V4版本已经不用**React-Router**了,具体看网址 https://github.com/ReactTraining/react-router/blob/25776d4dc89b8fb2f575884749766355992116b5/packages/react-router/docs/guides/migrating.md#the-router 。改用了**React-Router-Dom**。首先要添加依赖
```
yarn add react-router-dom
或者
npm install react-router-dom --save
```
### 在使用V3版本的时候如下使用：
```
import routes from './routes'
<Router history={browserHistory} routes={routes} />
// or
<Router history={browserHistory}>
  <Route path='/' component={App}>
    // ...
  </Route>
</Router>
```
你可以使用Router组件的 routes属性传递这个路由信息，也可以配置直接将Route作为Router的孩子传递进去。

这个broserHistory是创建一些历史信息，用来回跳，保存一些会话信息。

### V4版本
```
<BrowserRouter>
  <div>
  <Route path='/' component={Table} />
    <Route path='/about' component={About} />
    <Route path='/contact' component={Contact} />
  </div>
</BrowserRouter>
```
首先不用手动添加history。V4提供了`<BrowserRouter>，<HashRouter>和<MemoryRouter>` 他们能自动给你创建历史记录。但是这里你需要注意的一点是这三个Router都只能接收一个child元素。

这里有一个点就是path。如果一个url能匹配上多个path，那么那多个path的组件都会被渲染。如上面这个Router,如果访问页面的url是`/about`。那么`Table`和`About`两个组件都会被渲染。
但是组件`<Route>`组件有一个exact属性。这样会使得只有完全匹配的时候才会渲染。比如：
```
<BrowserRouter>
  <div>
  <Route exact path='/' component={Table} />
    <Route path='/about' component={About} />
    <Route path='/contact' component={Contact} />
  </div>
</BrowserRouter>
``` 
这样在访问/about的时候Table组件就不会渲染了
在配置好路由之后当然还需连接啊，我们不可能一直通过地址栏输入url来访问把，所以按照传统的就是需要配置一些`<a>`标签，但是在react中有一个专门的组件做连接`<Link>`

### <Link>
用法如下：
```
import { Link } from 'react-router-dom';
 render(){
        const a = [1, 2, 3, 4];
        return (
            <div>
                {a.map((v,index) => (<p key={index}>{v}</p>))}
               <p> <Link to={"Login"} style={{textDecoration:'none'}}>Login</Link></p>
            </div>
        )
    }
```
只需要在需要做连接的地方使用`<Link to={'path'}>需要连接的东西比如文字什么的<Link>`，做了连接的文字呢会有下划线，想要去掉下划线呢就加一个Style就可以了`style={{textDecoration:'none'}}

## promise
### 介绍

Promise，他是一个对象，是用来处理异步操作的，可以让我们写异步调用的时候写起来更加优雅，更加美观便于阅读。顾名思义为承诺、许诺的意思，意思是使用了Promise之后他肯定会给我们答复，无论成功或者失败都会给我们一个答复，所以我们就不用担心他跑了哈哈。所以，Promise有三种状态：pending（进行中），resolved（完成），rejected（失败）。只有异步返回的结果可以改变其状态。所以，promise的过程一般只有两种：pending->resolved或者pending->rejected。

promise对象还有一个比较常用的then方法，用来执行回调函数，then方法接受两个参数，第一个是成功的resolved的回调，另一个是失败rejected的回调，第二个失败的回调参数可选。并且then方法里也可以返回promise对象，这样就可以链式调用了。

### 理解
 看用法
 ```
 var Pro = new Promise(function (resolve, reject){...}).then(func1, func2)
 ```
在new 一个Promise的时候需要传入一个函数function(resolve, reject)。这个函数需要接收两个参数，这两个参数是Promise传给它的，一个是resolve另外一个是reject。这也是两个函数，只要这两个函数任何一个执行了Promise就会认为函数执行结束。resolve执行Promise就认为是成功执行，则接下来会执行.then(func1,func2)中func1，这个是Promise认为执行成功的回调函数，func2是失败的回调函数，就是在function(resolve, reject)中如果执行了reject。那么就会执行func2。

例子中常常使用Promise来模拟异步请求
```
const delay = (ms) => new Promise(res => setTimeout(res, ms));
```
delay 这个函数接收一个ms的参数，然后返回一个Promise 当调用delay(1000)的时候，会返回一个Promise，这个Promise会执行res => setTimeout(res, ms),这个res就是resolve，这里面是一个定时器，过了1000秒之后执行resolve。Promise认为执行完毕。

Promise的出现是为了解决js中的无限回调问题。
现在一半用法如下
```
function delay(ms) {  
  return new Promise((resolve, reject) => {
    setTimeout(resolve, ms);
  });
}

console.log(1)
delay(300).then(() => console.log(2))
console.log(3)
```
在delay()函数中使用setTimeout()来模拟一个异步操作，再用promise封装一下，使得可以使用promise的then()方法来在异步操作完成之后，执行特定的代码。
现在promise的使用已经很普遍，javascript标准中的fetch()函数也是支持promise的回调机制，以方便开发者更容易的处理网络请求的异步返回。

### promise + yield 
```
function* baum() {
  yield delay(300).then(() => console.log(1))
  yield console.log(2)
  yield delay(300).then(() => console.log(3))
  yield console.log(4)
}

const b = baum()
b.next()
b.next()
b.next()
b.next()
```
函数baum()结构表达的意思是，有一些同步的操作，然后会发出异步的请求（比如网络请求），异步请求结束后，再执行后面的代码。但是因为delay()函数的异步使得1和3的输出延迟了，并没有达到预期效果。
可是令人十分费解的是，在saga中，这样的程序结构，是会按照顺序执行的效果呈现出来，即输出是1,2,3,4，所以一定是saga在对诸如baum()这样的generator进行了一层包裹，使得里面的同步操作可以等待上一个异步promise函数执行完成后再被触发。

具体解答看连接 https://www.jianshu.com/p/c1b8b89c4905

## Saga 中间件

首先需要安装依赖
```
yarn add redux-saga
```
将其结合在redux中，即在dispatch之后到收到结果之前。
```
import { createStore, applyMiddleware } from 'redux'
import createSagaMiddleware from 'redux-saga'
import rootSaga from "./saga";

const sagaMiddleware = createSagaMiddleware();
const store = createStore(reducer, applyMiddleware(sagaMiddleware));

sagaMiddleware.run(rootSaga)
```

首先使用createSagaMiddleware创建一个saga中间件。然后使用applyMiddleware应用到redux中，然后使用sagaMiddleware.run(rootSaga) 去运行一个rootSaga,在这个rootSaga中会监听相应的dispatch然后作出相应的操作。

### sagas

每一个sagas就是一个generator生成器。 其实就是一个function* 带了一个星号的函数，在这个函数中可以使用yield。然后还可以进行一些列异步操作。例如
```
import { takeEvery } from 'redux-saga/effects'

// FETCH_USERS
function* fetchUsers(action) { ... }

// CREATE_USER
function* createUser(action) { ... }

// use them in parallel
export default function* rootSaga() {
  yield takeEvery('FETCH_USERS', fetchUsers)
  yield takeEvery('CREATE_USER', createUser)
}
```
## 部署注意点
在添加redux之后，在部署的时候需要把开发工具去去掉。
```
const store = createStore(reducer, compose(applyMiddleware(sagas),window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()));
```
这里变成
```
const store = createStore(reducer, compose(applyMiddleware(sagas)));
```