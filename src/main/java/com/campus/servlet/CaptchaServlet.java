package com.campus.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Random;
import javax.imageio.ImageIO;

@WebServlet("/captcha")
public class CaptchaServlet extends HttpServlet {
    private static final int WIDTH = 120;
    private static final int HEIGHT = 40;
    private static final int CODE_COUNT = 4;
    private static final String CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final Random RANDOM = new Random();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();

        // 背景
        g.setColor(new Color(240, 244, 249));
        g.fillRect(0, 0, WIDTH, HEIGHT);

        // 边框
        g.setColor(new Color(43, 108, 176));
        g.drawRect(0, 0, WIDTH - 1, HEIGHT - 1);

        // 生成验证码
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < CODE_COUNT; i++) {
            String ch = String.valueOf(CHARS.charAt(RANDOM.nextInt(CHARS.length())));
            code.append(ch);
            g.setFont(new Font("Arial", Font.BOLD | Font.ITALIC, 22 + RANDOM.nextInt(6)));
            g.setColor(new Color(20 + RANDOM.nextInt(80), 40 + RANDOM.nextInt(100), 120 + RANDOM.nextInt(80)));
            int x = 18 + i * 26;
            int y = 28 + RANDOM.nextInt(6);
            g.drawString(ch, x, y);
        }

        // 干扰线
        for (int i = 0; i < 6; i++) {
            g.setColor(new Color(150 + RANDOM.nextInt(80), 150 + RANDOM.nextInt(80), 180 + RANDOM.nextInt(60)));
            g.drawLine(RANDOM.nextInt(WIDTH), RANDOM.nextInt(HEIGHT), RANDOM.nextInt(WIDTH), RANDOM.nextInt(HEIGHT));
        }

        // 噪点
        for (int i = 0; i < 30; i++) {
            g.setColor(new Color(100 + RANDOM.nextInt(120), 100 + RANDOM.nextInt(120), 150 + RANDOM.nextInt(80)));
            g.fillRect(RANDOM.nextInt(WIDTH), RANDOM.nextInt(HEIGHT), 1, 1);
        }

        g.dispose();

        // 存入 session
        req.getSession().setAttribute("captcha", code.toString());

        // 输出图片
        resp.setContentType("image/png");
        resp.setHeader("Pragma", "no-cache");
        resp.setHeader("Cache-Control", "no-cache");
        resp.setDateHeader("Expires", 0);
        ImageIO.write(image, "png", resp.getOutputStream());
    }
}
