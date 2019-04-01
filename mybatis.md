## 传统Mybatis 提供的API

是创建一个和数据库打交道的SqlSession对象，然后根据Statement Id 和参数来操作数据库，这种方式固然很简单和实用，但是它不符合面向对象语言的概念和面向接口编程的编程习惯。由于面向接口的编程是面向对象的大趋势，MyBatis 为了适应这一趋势，增加了第二种使用MyBatis 支持接口（Interface）调用方式。

## 使用Mapper接口
MyBatis 将配置文件中的每一个<mapper> 节点抽象为一个 Mapper 接口：
这个接口中声明的方法和<mapper> 节点中的<select|update|delete|insert> 节点项对应，即<select|update|delete|insert> 节点的id值为Mapper 接口中的方法名称，parameterType 值表示Mapper 对应方法的入参类型，而resultMap 值则对应了Mapper 接口表示的返回值类型或者返回结果集的元素类型。
根据MyBatis 的配置规范配置好后，通过SqlSession.getMapper(XXXMapper.class)方法，MyBatis 会根据相应的接口声明的方法信息，通过动态代理机制生成一个Mapper 实例，我们使用Mapper接口的某一个方法时，MyBatis会根据这个方法的方法名和参数类型，确定Statement Id，底层还是通过SqlSession.select("statementId",parameterObject);或者SqlSession.update("statementId",parameterObject); 等等来实现对数据库的操作，MyBatis引用Mapper 接口这种调用方式，纯粹是为了满足面向接口编程的需要。（其实还有一个原因是在于，面向接口的编程，使得用户在接口上可以使用注解来配置SQL语句，这样就可以脱离XML配置文件，实现“0配置”）。

作者：猿码道
链接：https://www.jianshu.com/p/ec40a82cae28
來源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。

## SqlSession工作过程分析
### 1 开启一个数据库访问会话---创建SqlSession对象
```
SqlSession sqlSession = factory.openSession(); 
```
### 2 为SqlSession传递一个配置的Sql语句的Statement Id和参数，然后返回结果
```
List<Employee> result = sqlSession.selectList("com.louis.mybatis.dao.EmployeesMapper.selectByMinSalary",params);
```
上述的"com.louis.mybatis.dao.EmployeesMapper.selectByMinSalary"，是配置在EmployeesMapper.xml 的Statement ID，params是传递的查询参数。


让我们来看一下sqlSession.selectList()方法的定义：
```
public <E> List<E> selectList(String statement, Object parameter) {  
    return this.selectList(statement, parameter, RowBounds.DEFAULT);  
}  
 
public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {  
    try {  
        //1.根据Statement Id，在mybatis 配置对象Configuration中查找和配置文件相对应的MappedStatement      
        MappedStatement ms = configuration.getMappedStatement(statement);  
        //2. 将查询任务委托给MyBatis 的执行器 Executor  
        List<E> result = executor.query(ms, wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);  
        return result;  
    } catch (Exception e) {  
        throw ExceptionFactory.wrapException("Error querying database.  Cause: " + e, e);  
    } finally {  
        ErrorContext.instance().reset();  
    }  
} 
```
MyBatis在初始化的时候，会将MyBatis的配置信息全部加载到内存中，使用org.apache.ibatis.session.Configuration实例来维护。使用者可以使用sqlSession.getConfiguration()方法来获取。MyBatis的配置文件中配置信息的组织格式和内存中对象的组织格式几乎完全对应的。

```
<select id="selectByMinSalary" resultMap="BaseResultMap" parameterType="java.util.Map" >  
   select   
       EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, SALARY  
   from LOUIS.EMPLOYEES  
   <if test="min_salary != null">  
       where SALARY < #{min_salary,jdbcType=DECIMAL}  
   </if>  
</select>
```
加载到内存中会生成一个对应的MappedStatement对象，然后会以key="com.louis.mybatis.dao.EmployeesMapper.selectByMinSalary" ，value为MappedStatement对象的形式维护到Configuration的一个Map中。当以后需要使用的时候，只需要通过Id值来获取就可以了。

`从上述的代码中我们可以看到SqlSession的职能是：SqlSession根据Statement ID, 在mybatis配置对象Configuration中获取到对应的MappedStatement对象，然后调用mybatis执行器来执行具体的操作。`

## MyBatis初始化机制
任何框架的初始化，无非是加载自己运行时所需要的配置信息。MyBatis的配置信息,MyBatis采用了一个非常直白和简单的方式---使用 org.apache.ibatis.session.Configuration对象作为一个所有配置信息的容器，Configuration对象的组织结构和XML配置文件的组织结构几乎完全一样（当然，Configuration对象的功能并不限于此，它还负责创建一些MyBatis内部使用的对象
### 基于XML配置文件创建Configuration对象
现在就从使用MyBatis的简单例子入手，深入分析一下MyBatis是怎样完成初始化的，都初始化了什么。看以下代码：
```
String resource = "mybatis-config.xml";  
InputStream inputStream = Resources.getResourceAsStream(resource);  
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);  
SqlSession sqlSession = sqlSessionFactory.openSession();  
List list = sqlSession.selectList("com.foo.bean.BlogMapper.queryAllBlogInfo");
```
上述代码的功能是根据配置文件mybatis-config.xml  配置文件，创建SqlSessionFactory对象，然后产生SqlSession，执行SQL语句。而mybatis的初始化就发生在第三句：SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream); 现在就让我们看看第三句到底发生了什么。

`调用SqlSessionFactoryBuilder对象的build(inputStream)方法；

SqlSessionFactoryBuilder会根据输入流inputStream等信息创建XMLConfigBuilder对象;

SqlSessionFactoryBuilder调用XMLConfigBuilder对象的parse()方法；

XMLConfigBuilder对象返回Configuration对象；

SqlSessionFactoryBuilder根据Configuration对象创建一个DefaultSessionFactory对象；

SqlSessionFactoryBuilder返回 DefaultSessionFactory对象给Client，供Client使用。
`
上述的初始化过程中，涉及到了以下几个对象：
`
SqlSessionFactoryBuilder ：SqlSessionFactory的构造器，用于创建SqlSessionFactory，采用了Builder设计模式

Configuration ：该对象是mybatis-config.xml文件中所有mybatis配置信息

SqlSessionFactory：SqlSession工厂类，以工厂形式创建SqlSession对象，采用了Factory工厂设计模式

XMLConfigBuilder ：负责将mybatis-config.xml配置文件解析成Configuration对象，共

SqlSessonFactoryBuilder使用，创建SqlSessionFactory
`



### resultMap-Collection
1.Collection用于一对多或者是多对一的时候，其中在数据库中外键是在多的那一方

2.在Java的实体类中，主表及一表中用一个list<class>来储存多表中的元组。

3.查询的xml中的select语句中，需要使用连接语句，left\right (outer) join on a.id = b.a_id 这里需要注意在写查询语句的时候select 后的属性之间需要用“ , ”隔开，然而在最后一个属性的后面不需要","。或者直接使用表关联也可以， FROM TABLEA A, TABLEB B

4.<id colume="columeName" jdbcType="记得要全部大写"> `这个标签中的columeName 在collection中的要与resultMap中的id标签中的columeName不相同`，这个标签的作用就是让mybatis将columeName这一列用以区分返回的数据集，如果两条数据的ID标签columeName这一列的值相同，则mybatis认为是相同的数据则会覆盖前面值相同的那一列，而在一对多查询的时候会返回一些列主表id相同，从表id不同的数据，这个时候如果主表和从表的id名字相同，则mybatis无法区分，`mybatis是通过查询的colume名字来进行反射的`，当id名字相同的时候，而返回的数据中有大量的主表id相同的数据，则会进行覆盖，最后只会得到一个从表的数据，一对多，多的部分被覆盖了。
```
<resultMap id="getRoleModel" type="POJO.RoleModel">
            <id column="id" property="id" jdbcType="INTEGER"/>
        <result column="role_name" property="name"/>
        <result column="is_active" property="isActive"/>
        <result column="last_update_time" property="lastUpdateTime"/>
        <collection property="menus" ofType="POJO.MenuModel">
            <id column="m_id" property="id" jdbcType="INTEGER"/>
            <result column="m_value" property="value"/>
            <result column="m_display_value" property="displayValue"/>
            <result column="m_url" property="url"/>
            <result column="m_category" property="category"/>
            <result column="m_description" property="description"/>
            <result column="m_is_active" property="isActive"/>
            <result column="m_last_update_time" property="lastUpdateTime"/>
        </collection>
    </resultMap>
```
`<id column="id" property="id" jdbcType="INTEGER"/>`和`<id column="m_id" property="id" jdbcType="INTEGER"/>`的column的值不一样。


### resultMap-association

1. association用于一对一关联，这个时候外键在哪个表中已经不重要了，因为在做表连接的时候得到的数据是一样的，最重要的是要写好resultMap的映射关系，其中< association property="对应的实体类中的属性名" javeTypy="要写全路径，类名，或者别名，之前定义好的。">




### Mybatis and spring
在mybatis和spring集成的时候，第一个坑，关于mybatis，mapper.xml其中的namespace要与mapper.java的路径一致，这样才能将mapper.java中的方法与mapper.xml中的sql语句对应。

第二个坑，与spring集成之后，不需要实例化sqlsession了，只需要@Autowired mappler.java实例即可，但是这需要你在mappler.java上面加上@Mapper或者是在启动类Application.java上加@MapperScan("com.test...")

第三个坑，与spring集成之后，不需要在配置环境即mybaits 的environment，只需要在application.properties文件中指定mybatis-config.xml的路径和所有mapper.xml的路径。不然会报错无法创建bean。

第四个坑，没有集成spring的时候，每一次插入了但是数据库里面没有，是需要sqlsession.commit()才有。

### IDEA完美解决 Could not autowire. No beans of 'xxx' type found.报错
#### 1
在mapper文件上加@Repository注解，这是从spring2.0新增的一个注解，用于简化 Spring 的开发，实现数据访问
#### 2
在mapper文件上加@Component注解，把普通pojo实例化到spring容器中，相当于配置文件中的<bean id="" class=""/>