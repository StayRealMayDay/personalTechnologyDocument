# spring & react


## spring
只需要返回Json数据即可，在@Controller中在每一个`@RequestMapping`的地方加上`@ResponseBody`，则该路径下的方法返回什么就是什么，不会去寻找一个对应的jsp页面返回。
## Cross-Origin Resource Sharing（跨域资源共享）
spring和react结合的时候自然会有跨域访问的问题，这里需要在两个地方进行配置，首先是后端需要允许跨域访问，在使用spring boot之后，
### 跨域访问可以通过添加如下方法解决(现在已经不用这种方法了)
```
@Configuration
public class MyWebAppConfigurer extends WebMvcConfigurerAdapter{

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**");
    }
}
```
可以在addMapping中配置我们的路径。/**代表所有路径。当然也可以修改其它属性
```
@Configuration
public class MyWebAppConfigurer extends WebMvcConfigurerAdapter{

    @Override
    public void addCorsMappings(CorsRegistry registry) {
           registry.addMapping("/api/**")
           .allowedOrigins("http://192.168.1.97")
           .allowedMethods("GET", "POST")
           .allowCredentials(false).maxAge(3600);
    }
}
```
以上两种，都是针对全局配置，如果你想做到更细致也可以使用@CrossOrigin这个注解在controller类中使用。
```
@CrossOrigin(origins = "http://192.168.1.97:8080", maxAge = 3600)
@RequestMapping("rest_index")
@RestController
public class IndexController{
```
`但是在spring 2.0之后，WebMvcConfigurerAdapter被移除了，但是有替代方案，以下WebMvcConfigurerAdapter 比较常用的重写接口`
```
/** 解决跨域问题 **/
public void addCorsMappings(CorsRegistry registry) ;
/** 添加拦截器 **/
void addInterceptors(InterceptorRegistry registry);
/** 这里配置视图解析器 **/
void configureViewResolvers(ViewResolverRegistry registry);
/** 配置内容裁决的一些选项 **/
void configureContentNegotiation(ContentNegotiationConfigurer configurer);
/** 视图跳转控制器 **/
void addViewControllers(ViewControllerRegistry registry);
/** 静态资源处理 **/
void addResourceHandlers(ResourceHandlerRegistry registry);
/** 默认静态资源处理器 **/
void configureDefaultServletHandling(DefaultServletHandlerConfigurer configurer);
```
### 新的版本解决方案目前有两种
`方案1 直接实现WebMvcConfigurer`
```
@Configuration
public class MyWebAppConfigurer  implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**");
    }
}
```
`方案2 直接继承WebMvcConfigurationSupport`
```
@Configuration
public class MyWebAppConfigurer extends WebMvcConfigurationSupport {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**");
    }
}
```
亲测两种方法都可以用。
### 最牛逼的直接用注解
在你controller里面加上`@CrossOrigin`即可
```
@RestController
@CrossOrigin
public class HelloWordController {

    @RequestMapping("/hello")
    public String HelloWord(@RequestParam String studentname){
        return studentname;
    }
    @RequestMapping("/hello/{Id}")
    public String HelloWord1(@PathVariable String Id, @RequestHeader("temp") String temp){
        return Id + "   "+temp;
    }
    @RequestMapping("loadfile")
    public User UpLoadFile(@RequestBody User user){
        return user;
    }
}
```

#

## spring Srouce Root
idea在build工程的时候，遇到maven项目使用的是pom文件里面配置的<build></build>里面的东西
而这里面如果不做特别配置，是maven默认的，编译的时候，只搬运src/main/java里面的java文件到target/classes,其他文件会被忽略，所以找不到.xml文件。要在pom文件里面加入以下代码：
```
<build>
<resources>
            <resource>
                <directory>src/main/java</directory>
                <includes>
                    <include>*/.properties</include>
                    <include>*/.xml</include>
                </includes>
                <filtering>false</filtering>
            </resource>
        </resources>
</build>
```
在spring启动的时候会读取该路径下的文件，如果有配置文件没有在该路径下则会读取不到，如:application.properties这个配置文件如果没有在该路径下则会没有数据源。
同时也可以在你`project structure中Facets下有Source Roots的，看下这里的内容，
正常是会有srcmainjava 和 srcmainresources的`，少哪个加哪个。添加的方法是`右击文件夹-> Mark directory as -> Resources Root`。修改之后对应pom文件的路径也会修改。

## spring @RequestParam @RequestBody @PathVariable 等参数绑定注解详解

handler method 参数绑定常用的注解,我们根据他们处理的Request的不同内容部分分为四类：（主要讲解常用类型）

A、处理requet uri 部分（这里指uri template中variable，不含queryString部分）的注解：   @PathVariable;

B、处理request header部分的注解：   @RequestHeader, @CookieValue;

C、处理request body部分的注解：@RequestParam,  @RequestBody;

D、处理attribute类型是注解： @SessionAttributes, @ModelAttribute;

### @PathVariable
#### value和path
value和path是都是指请求地址。@RequestMapping("/login")等价于@RequestMapping(path="/login")。
#### 占位符
```
@RequestMapping(path = "/{account}", method = RequestMethod.GET)
public String getUser(@PathVariable String account)
```
这是参数名跟占位符名字一致的情况，不一致的话就要这样写：
```
@RequestMapping(path = "/{account}/{name}", method = RequestMethod.GET)
public String getUser(@PathVariable("account") String phoneNumber,@PathVariable("name") String userName)
```
这样就把占位符绑定到参数phoneNumber上了。
如访问路径稳/user1/user2那么account的值就是user1然后name的值就是user2。
### @RequestHeader
@RequestHeader 注解，可以把Request请求header部分的值绑定到方法的参数上。
示例代码：

这是一个Request 的header部分：
```
Host                    localhost:8080
Accept                  text/html,application/xhtml+xml,application/xml;q=0.9
Accept-Language         fr,en-gb;q=0.7,en;q=0.3
Accept-Encoding         gzip,deflate
Accept-Charset          ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive              300
```
```
@RequestMapping("/displayHeaderInfo.do")
public void displayHeaderInfo(@RequestHeader("Accept-Encoding") String encoding,
                              @RequestHeader("Keep-Alive") long keepAlive)  {
  
}
```
上面的代码，把request header部分的 Accept-Encoding的值，绑定到参数encoding上了， Keep-Alive header的值绑定到参数keepAlive上。
### @CookieValue
@CookieValue 可以把Request header中关于cookie的值绑定到方法的参数上。
例如有如下Cookie值：
```
JSESSIONID=415A4AC178C59DACE0B2C9CA727CDD84
```
参数绑定的代码：
```
@RequestMapping("/displayHeaderInfo.do")
public void displayHeaderInfo(@CookieValue("JSESSIONID") String cookie)  {
 
  //...
 
}
```
即把JSESSIONID的值绑定到参数cookie上。

### @RequestParam
A） 常用来处理简单类型的绑定，通过Request.getParameter() 获取的String可直接转换为简单类型的情况（ String--> 简单类型的转换操作由ConversionService配置的转换器来完成）；因为使用request.getParameter()方式获取参数，所以可以处理get 方式中queryString的值，也可以处理post方式中 body data的值；

B）用来处理Content-Type: 为 application/x-www-form-urlencoded编码的内容，提交方式GET、POST；

C) 该注解有两个属性： value、required； value用来指定要传入值的id名称，required用来指示参数是否必须绑定；

示例代码：
```
@Controller
@RequestMapping("/pets")
@SessionAttributes("pet")
public class EditPetForm {
 
    // ...
 
    @RequestMapping(method = RequestMethod.GET)
    public String setupForm(@RequestParam("petId") int petId, ModelMap model) {
        Pet pet = this.clinic.loadPet(petId);
        model.addAttribute("pet", pet);
        return "petForm";
    }
```
### @RequestBody
该注解常用来处理Content-Type: 不是application/x-www-form-urlencoded编码的内容，例如application/json, application/xml等；

它是通过使用HandlerAdapter 配置的HttpMessageConverters来解析post data body，然后绑定到相应的bean上的。

因为配置有FormHttpMessageConverter，所以也可以用来处理 application/x-www-form-urlencoded的内容，处理完的结果放在一个MultiValueMap<String, String>里，这种情况在某些特殊需求下使用，详情查看FormHttpMessageConverter api;
示例代码：
```
@PostMapping(path = "register")
public String registerUser(@RequestBody User user) {
    return user.toString();
}
```
### @SessionAttributes
该注解用来绑定HttpSession中的attribute对象的值，便于在方法中的参数里使用。

该注解有value、types两个属性，可以通过名字和类型指定要使用的attribute 对象；

示例代码：
```
@Controller
@RequestMapping("/editPet.do")
@SessionAttributes("pet")
public class EditPetForm {
    // ...
}
```
### @ModelAttribute
该注解有两个用法，一个是用于方法上，一个是用于参数上；

用于方法上时：  通常用来在处理@RequestMapping之前，为请求绑定需要从后台查询的model；

用于参数上时： 用来通过名称对应，把相应名称的值绑定到注解的参数bean上；要绑定的值来源于：

A） @SessionAttributes 启用的attribute 对象上；

B） @ModelAttribute 用于方法上时指定的model对象；

C） 上述两种情况都没有时，new一个需要绑定的bean对象，然后把request中按名称对应的方式把值绑定到bean中。

用到方法上@ModelAttribute的示例代码：
```
@ModelAttribute
public Account addAccount(@RequestParam String number) {
    return accountManager.findAccount(number);
}
```
这种方式实际的效果就是在调用@RequestMapping的方法之前，为request对象的model里put（“account”， Account）；

用在参数上的@ModelAttribute示例代码：
```

@RequestMapping(value="/owners/{ownerId}/pets/{petId}/edit", method = RequestMethod.POST)
public String processSubmit(@ModelAttribute Pet pet) {
   
}
```
首先查询 @SessionAttributes有无绑定的Pet对象，若没有则查询@ModelAttribute方法层面上是否绑定了Pet对象，若没有则将URI template中的值按对应的名称绑定到Pet对象的各属性上。


## 文件/图片上传
例子如下。前段使用FormData模拟表单上传数据,所以拿到的是一系列键值对。
```
 @RequestMapping("/loadfile")
    public String UpLoadFile(@RequestParam MultipartFile file) throws FileNotFoundException {
        System.out.println(file.getName());//上传之后在表单中的name
        System.out.println(file.getOriginalFilename());//上传之前在本地主机上的名字
        System.out.println(file.getContentType());
        File path = new File(ResourceUtils.getURL("classpath:").getPath());// target包下面的class路径
        if(!path.exists()) path = new File("");
        File upload = new File(path.getAbsolutePath(),"static/files/");
        if(!upload.exists()) upload.mkdirs();
        System.out.println("upload url:"+upload.getAbsolutePath());
        System.out.println("path:"+path.getAbsolutePath());
        File dest = new File(upload.getAbsolutePath() + "/" + new Date().toString() + file.getOriginalFilename());// 在目标文件夹创建file文件
        try {
            file.transferTo(dest);//江数据写入目标文件
        }catch (IOException e){

        }
        return file.getName();
    }
```
### MultipartFile
MultipartFile是spring类型，代表HTML中form data方式上传的文件，包含二进制数据+文件名称
https://blog.csdn.net/sdut406/article/details/85647982
#### MultipartFile转File
我们这里记录一种方法使用transferTo:
```

File file = new File(path,"demo.txt");
MultipartFile multipartFile = getFile();
multipartFile.transferTo(file);
```
### 文件保存问题 & springboot部署之后无法获取项目目录的问题：
就是我将项目导出为jar包，然后用java -jar 运行时，项目中文件上传的功能无法正常运行，其中获取到存放文件的目录的绝对路径的值为空，文件无法上传。解决方案：
```
//获取跟目录
File path = new File(ResourceUtils.getURL("classpath:").getPath());
if(!path.exists()) path = new File("");
System.out.println("path:"+path.getAbsolutePath());

//如果上传目录为/static/images/upload/，则可以如下获取：
File upload = new File(path.getAbsolutePath(),"static/images/upload/");
if(!upload.exists()) upload.mkdirs();
System.out.println("upload url:"+upload.getAbsolutePath());
//在开发测试模式时，得到的地址为：{项目跟目录}/target/static/images/upload/
//在打包成jar正式发布时，得到的地址为：{发布jar包目录}/static/images/upload/
```
另外一个获得项目根目录的方法是：
```
String path = ClassUtils.getDefaultClassLoader().getResource("").getPath();
```
#### 另外使用以上代码需要注意，因为以jar包发布时，我们存储的路径是与jar包同级的static目录，因此我们需要在jar包目录的application.properties配置文件中设置静态资源路径，如下所示：
```
#设置静态资源路径，多个以逗号分隔
spring.resources.static-locations=classpath:static/,file:static/
```
以jar包发布springboot项目时，默认会先使用jar包跟目录下的application.properties来作为项目配置文件。

## target 文件夹
arget是用来存放项目构建后的文件和目录、jar包、war包、编译的class文件。`所以在在上面的寻找项目的根目录的时候都是找到了target/classes这个目录。`