<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.model.User,com.campus.util.SessionUtil" %>
<%
    User loginUser = SessionUtil.getUser(request);
    String ctx = request.getContextPath();
    boolean isAdmin = loginUser != null && loginUser.getRole() == 1;
%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<link rel="stylesheet" href="<%=ctx%>/assets/style.css">
<header class="navbar">
    <div class="logo">
        <i class="fas fa-store-alt"></i>
        <span>校园二手交易平台</span>
    </div>
    <nav class="nav-links">
        <% if (loginUser != null && !isAdmin) { %>
            <a href="<%=ctx%>/client/home.jsp"><i class="fas fa-home"></i><span>首页</span></a>
            <a href="<%=ctx%>/client/activities.jsp"><i class="fas fa-calendar-alt"></i><span>活动</span></a>
            <a href="<%=ctx%>/client/cart.jsp"><i class="fas fa-shopping-cart"></i><span>购物车</span></a>
            <a href="<%=ctx%>/client/orders.jsp"><i class="fas fa-clipboard-list"></i><span>买入</span></a>
            <a href="<%=ctx%>/client/seller-orders.jsp"><i class="fas fa-handshake"></i><span>卖出</span></a>
            <a href="<%=ctx%>/client/profile.jsp"><i class="fas fa-user-circle"></i><span>我的</span></a>
            <span class="points-badge"><i class="fas fa-coins"></i> <%=loginUser.getPointsBalance()%></span>
        <% } else if (isAdmin) { %>
            <a href="<%=ctx%>/admin/index.jsp"><i class="fas fa-tachometer-alt"></i><span>仪表盘</span></a>
            <a href="<%=ctx%>/admin/goods.jsp"><i class="fas fa-box"></i><span>商品</span></a>
            <a href="<%=ctx%>/admin/activities.jsp"><i class="fas fa-star"></i><span>活动</span></a>
            <a href="<%=ctx%>/admin/users.jsp"><i class="fas fa-users"></i><span>用户</span></a>
            <a href="<%=ctx%>/admin/orders.jsp"><i class="fas fa-shopping-bag"></i><span>订单</span></a>
            <a href="<%=ctx%>/admin/points.jsp"><i class="fas fa-chart-line"></i><span>积分</span></a>
            <a href="<%=ctx%>/admin/config.jsp"><i class="fas fa-cog"></i><span>配置</span></a>
        <% } %>
        <% if (loginUser != null) { %>
            <a href="<%=ctx%>/action/logout"><i class="fas fa-sign-out-alt"></i><span>退出</span></a>
        <% } %>
    </nav>
</header>
