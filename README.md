# 校园二手积分商城 Demo

基于 JSP + Servlet + MySQL，适配 **Tomcat 10.1**（Jakarta EE）。

## 快速启动

### 1. 导入数据库

```sql
-- 先执行建库和基础数据脚本
source chs.sql;

-- 再执行扩展表
source fix_missing_tables.sql;
```

### 2. 修改数据库连接

编辑 `src/main/resources/db.properties`：

```properties
db.url=jdbc:mysql://localhost:3306/campus_second_hand?...
db.username=root
db.password=你的密码
```

### 3. 启动项目

在项目根目录执行（需要 JDK 17，并将 `JAVA_HOME` 指向 JDK 安装目录）：

```bat
.\mvnw.cmd package
.\mvnw.cmd compile exec:java
```

嵌入式 Tomcat 会监听 8080 端口，访问：http://localhost:8080/

也可以将 `target/campus.war` 部署到外部 Tomcat 10.1 的 `webapps/` 目录，此时访问：http://localhost:8080/campus/login.jsp


## 测试账号

| 角色 | 手机号 | 验证码    |
|------|--------|--------|
| 普通用户 | 13800000001 ~ 13800000010 | 123456 |
| 管理员 | 13800000000 | 123456 |

## 功能说明

### 用户端
- 首页商品浏览、分类、搜索
- 每日签到赚积分
- 参与活动完成任务领积分
- 积分购买商品（购物车结算）
- 发布闲置（需认证）
- 订单管理、积分明细、收藏

### 管理端
- 仪表盘统计
- 商品审核 / 上下架
- 活动创建 / 开关
- 用户认证审核、封禁、积分调整
- 订单纠纷处理
- 积分流水、系统配置

## 技术栈

- Tomcat 10.1 / Jakarta Servlet 6.0
- JSP + JSTL
- MySQL 8.0
- Maven WAR 打包
