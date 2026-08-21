package com.campus.util;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public final class RedirectUtil {
    private RedirectUtil() {}

    public static void send(HttpServletResponse resp, String url) throws IOException {
        resp.sendRedirect(url);
    }

    public static void send(HttpServletResponse resp, String ctx, String path) throws IOException {
        resp.sendRedirect(ctx + path);
    }

    public static void withMsg(HttpServletResponse resp, String ctx, String path, String msg) throws IOException {
        resp.sendRedirect(ctx + path + paramSep(path) + "msg=" + encode(msg));
    }

    public static void withErr(HttpServletResponse resp, String ctx, String path, String err) throws IOException {
        resp.sendRedirect(ctx + path + paramSep(path) + "err=" + encode(err));
    }

    private static String paramSep(String path) {
        return path.contains("?") ? "&" : "?";
    }

    private static String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
