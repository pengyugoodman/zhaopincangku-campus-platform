<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.ActivityDao" %>
<% int pendingCount = 0; try { pendingCount = new ActivityDao().listPending().size(); } catch (Exception ignored) {} %>
<aside class="admin-sidebar">
    <div class="admin-brand"><i class="fas fa-store-alt"></i> <em>校园二手</em> 管理</div>
    <nav class="admin-menu">
        <a href="<%=ctx%>/admin/index.jsp" class="admin-menu-item <%=uri.contains("/admin/index.jsp")?"active":""%>">
            <i class="fas fa-tachometer-alt"></i>
            <span>仪表盘</span>
        </a>
        <a href="<%=ctx%>/admin/goods.jsp" class="admin-menu-item <%=uri.contains("/admin/goods.jsp")?"active":""%>">
            <i class="fas fa-box"></i>
            <span>商品管理</span>
        </a>
        <a href="<%=ctx%>/admin/activities.jsp" class="admin-menu-item <%=uri.contains("/admin/activities.jsp")?"active":""%>">
            <i class="fas fa-star"></i>
            <span>活动管理</span>
            <% if (pendingCount > 0) { %><span class="badge" style="background:var(--color-danger);color:#fff;font-size:11px;padding:1px 7px;border-radius:10px;margin-left:4px"><%=pendingCount%></span><% } %>
        </a>
        <a href="<%=ctx%>/admin/users.jsp" class="admin-menu-item <%=uri.contains("/admin/users.jsp")?"active":""%>">
            <i class="fas fa-users"></i>
            <span>用户管理</span>
        </a>
        <a href="<%=ctx%>/admin/orders.jsp" class="admin-menu-item <%=uri.contains("/admin/orders.jsp")?"active":""%>">
            <i class="fas fa-shopping-bag"></i>
            <span>订单管理</span>
        </a>
        <a href="<%=ctx%>/admin/points.jsp" class="admin-menu-item <%=uri.contains("/admin/points.jsp")?"active":""%>">
            <i class="fas fa-chart-line"></i>
            <span>积分审计</span>
        </a>
        <a href="<%=ctx%>/admin/config.jsp" class="admin-menu-item <%=uri.contains("/admin/config.jsp")?"active":""%>">
            <i class="fas fa-cog"></i>
            <span>系统配置</span>
        </a>
    </nav>
    <div class="admin-sidebar-foot">
        <a href="<%=ctx%>/client/home.jsp"><i class="fas fa-arrow-left"></i> 返回前台</a>
    </div>
</aside>
