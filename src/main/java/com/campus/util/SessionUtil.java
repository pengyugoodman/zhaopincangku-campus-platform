package com.campus.util;

import com.campus.dao.UserDao;
import com.campus.model.User;
import jakarta.servlet.http.HttpServletRequest;

public final class SessionUtil {
    public static final String USER_KEY = "loginUser";

    private SessionUtil() {}

    public static User getUser(HttpServletRequest req) {
        jakarta.servlet.http.HttpSession s = req.getSession(false);
        return s == null ? null : (User) s.getAttribute(USER_KEY);
    }

    public static User getFreshUser(HttpServletRequest req) throws Exception {
        User u = getUser(req);
        if (u == null) return null;
        User fresh = new UserDao().findById(u.getUserId());
        if (fresh != null) setUser(req, fresh);
        return fresh;
    }

    public static void setUser(HttpServletRequest req, User user) {
        req.getSession(true).setAttribute(USER_KEY, user);
    }

    public static void logout(HttpServletRequest req) {
        jakarta.servlet.http.HttpSession s = req.getSession(false);
        if (s != null) s.invalidate();
    }

    public static boolean isAdmin(User u) {
        return u != null && u.getRole() == 1;
    }

    public static boolean isVerified(User u) {
        return u != null && u.getVerifyStatus() == 2;
    }
}
