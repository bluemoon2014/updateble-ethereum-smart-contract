# updateble-ethereum-smart-contract

## 介绍

这个是一个nodejs脚本，可以生成一个可升级的以太坊智能合约，目前智能合约的方法限于单纯的为表中的数据进行增删改查。

## 使用

1.首先安装nodejs 环境，安装一个最新的LTS版本就可以。  
2.赋予脚本权限 chmod 755 generatorM.js  
3.node generatorM.js   
4成功会输出一个枪和you are doing great 的图案。  

## 细节

文件的目录结构不能变化，temptate开头的智能合约是为脚本提供模板代码的，不可删除改名。  
init_table.json 是一个配置文件 里面包含了表对象，表对象里包含了字段名和字段名对应的注释和表名。  
要生成自己的合约名 请改动 脚本中22行的 fileName  

```
//智能合约文件名
var fileName = "Material";
```
### 关于智能合约

合约外部是传入用|分隔的参数，内部会分隔这个字符串，所以参数的顺序需要提前订好。  
合约返回的值是一个不进行嵌套的json字符串。  

### 关于可以升级

升级的部分有兴趣可以看solidity相关知识，这里提一下简单的描述。  
基本上是manager.sol 起到存储的作用，impl.sol 是代理者。  
调用manager的impl方法，会走一个匿名函数，然后通过delegate call的方式去调用impl函数修改manager的数据。  
以后只要升级impl合约就可以了。  
合约部署后记得调用manager 的 update方法 参数是新升级合约的地址。  
升级方案是借鉴Arachnid的方案.他头像可以说明这个单词有多不好的意思...  

## 改进

未来应该可以支持命令行参数功能。
未来应该更详细的说明升级原理。
