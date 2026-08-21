package com.campus.filter;

import com.campus.model.User;
import com.campus.util.SessionUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter(urlPatterns = {"/client/*", "/admin/*", "/action/*"})
public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req;
        HttpServletResponse w = (HttpServletResponse) resp;
        String uri = r.getRequestURI();
        User u = SessionUtil.getUser(r);

        if (uri.contains("/admin/") && (u == null || u.getRole() != 1)) {
            w.sendRedirect(r.getContextPath() + "/login.jsp");
            return;
        }
        if ((uri.contains("/client/") || uri.contains("/action/")) && u == null
                && !uri.contains("/action/login")) {
            w.sendRedirect(r.getContextPath() + "/login.jsp");
            return;
        }
        chain.doFilter(req, resp);
    }
}
