package com.campus.util;

import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

public final class DBUtil {
    private static String url, username, password;

    static {
        try (InputStream in = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties p = new Properties();
            p.load(in);
            url = p.getProperty("db.url");
            username = p.getProperty("db.username");
            password = p.getProperty("db.password");
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            throw new RuntimeException("数据库配置加载失败", e);
        }
    }

    private DBUtil() {}

    public static Connection getConn() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }

    public static void close(AutoCloseable... rs) {
        for (AutoCloseable r : rs) {
            if (r != null) {
                try { r.close(); } catch (Exception ignored) {}
            }
        }
    }
}
