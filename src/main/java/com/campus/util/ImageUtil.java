package com.campus.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

public final class ImageUtil {
    private ImageUtil() {}

    private static final String[] ALLOWED_EXTS = {"jpg", "jpeg", "png", "gif", "webp"};

    public static String toImagesJson(String imageUrl) {
        if (imageUrl == null || imageUrl.isBlank()) return "[]";
        String url = imageUrl.trim();
        if (url.startsWith("[")) return url;
        return "[\"" + url.replace("\\", "\\\\").replace("\"", "\\\"") + "\"]";
    }

    /**
     * 生成最终用于页面显示的图片 URL。
     * 外部完整 URL 直接返回；本地相对路径前补 contextPath；空值返回本地占位图。
     */
    public static String getImageUrl(HttpServletRequest req, String cover) {
        if (cover == null || cover.isBlank()) {
            return req.getContextPath() + "/assets/placeholder.svg";
        }
        String c = cover.trim();
        if (c.startsWith("http://") || c.startsWith("https://")) return c;
        if (c.startsWith("/")) return req.getContextPath() + c;
        return req.getContextPath() + "/" + c;
    }

    public static String getExt(String filename) {
        if (filename == null || !filename.contains(".")) return "";
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
    }

    public static boolean allowedImage(String ext) {
        for (String e : ALLOWED_EXTS) if (e.equals(ext)) return true;
        return false;
    }

    /**
     * 保存上传的图片到 webapp/subDir，返回相对于 context root 的路径（如 uploads/goods/xxx.jpg）。
     * 如果用户没有上传文件则返回 null。
     */
    public static String saveUpload(Part part, String realRoot, String subDir) throws IOException {
        if (part == null) return null;
        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.isBlank()) return null;
        String ext = getExt(submitted);
        if (!allowedImage(ext)) return null;
        String filename = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + ext;
        Path dir = Paths.get(realRoot, subDir.split("/"));
        if (!Files.exists(dir)) Files.createDirectories(dir);
        Path target = dir.resolve(filename);
        try (var in = part.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
        return subDir + "/" + filename;
    }
}
