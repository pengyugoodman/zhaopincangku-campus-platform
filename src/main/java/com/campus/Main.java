package com.campus;

import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import java.io.File;

/**
 * 嵌入式 Tomcat 启动入口，直接运行 main 方法即可启动项目。
 * 访问地址：http://localhost:8080/
 */
public final class Main {

    private static final int PORT = 8080;
    private static final String CONTEXT_PATH = "";

    public static void main(String[] args) throws Exception {
        Tomcat tomcat = new Tomcat();
        tomcat.setPort(PORT);
        tomcat.getConnector(); // 使用默认 HTTP/1.1 连接器

        // ---- 确定路径 ----
        String baseDir = new File(System.getProperty("user.dir")).getAbsolutePath();
        File webappDir = new File(baseDir, "src/main/webapp");
        File classesDir = new File(baseDir, "target/classes");

        if (!classesDir.exists()) {
            classesDir = new File(baseDir, "target/campus/WEB-INF/classes");
            if (!classesDir.exists()) {
                System.err.println("未找到编译输出目录，请先执行 mvn compile 或 mvn package");
                System.err.println("  期望路径: " + new File(baseDir, "target/classes").getAbsolutePath());
                System.exit(1);
            }
        }

        System.out.println("webapp 目录 : " + webappDir.getAbsolutePath());
        System.out.println("classes 目录: " + classesDir.getAbsolutePath());

        // ---- 添加 Web 应用 ----
        // 说明：addWebapp 是异步的，web.xml 会在 tomcat.start() 时才被解析。
        // 因此不能靠"临时移走 web.xml"来避免重复注册 —— 正确做法是 web.xml
        // 不再重复声明已通过 @WebFilter/@WebServlet 注解注册的 Filter/Servlet。
        Context ctx = tomcat.addWebapp(CONTEXT_PATH, webappDir.getAbsolutePath());

        // 设置父 ClassLoader，确保 webapp 能访问类路径上的所有库
        ctx.setParentClassLoader(Main.class.getClassLoader());

        // ---- 告诉 Tomcat 去哪里找编译好的 class 文件 ----
        StandardRoot root = new StandardRoot(ctx);
        root.addPreResources(new DirResourceSet(root, "/WEB-INF/classes",
                classesDir.getAbsolutePath(), "/"));
        ctx.setResources(root);

        // ---- 确保上传目录存在 ----
        File uploadsDir = new File(webappDir, "uploads");
        if (!uploadsDir.exists()) {
            uploadsDir.mkdirs();
        }

        // ---- 启动 ----
        tomcat.start();
        System.out.println();
        System.out.println("============================================");
        System.out.println("  校园二手交易平台 已启动");
        System.out.println("  地址: http://localhost:" + PORT + "/");
        System.out.println("  管理端: http://localhost:" + PORT + "/admin/");
        System.out.println("============================================");
        System.out.println();

        // 阻塞主线程，等待关闭
        tomcat.getServer().await();
    }
}
