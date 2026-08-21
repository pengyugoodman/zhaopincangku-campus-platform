<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*" %>
<% pageContext.setAttribute("adminTitle", "仪表盘"); %>
<%
    UserDao ud = new UserDao();
    PointsDao pd = new PointsDao();
    GoodsDao gd = new GoodsDao();
    OrderDao od = new OrderDao();
%>
<%@ include file="../common/admin-head.jsp" %>
<div class="admin-page-title"><i class="fas fa-tachometer-alt" style="color:var(--primary)"></i> 仪表盘</div>
<div class="stat-grid">
    <div class="stat-box"><div class="num"><i class="fas fa-users" style="color:var(--primary)"></i> <%=ud.countAll()%></div><div class="label">注册用户</div></div>
    <div class="stat-box"><div class="num"><i class="fas fa-calendar-check" style="color:var(--color-success)"></i> <%=pd.todaySignCount()%></div><div class="label">今日签到</div></div>
    <div class="stat-box"><div class="num"><i class="fas fa-box" style="color:var(--color-warning)"></i> <%=gd.countToday()%></div><div class="label">今日新商品</div></div>
    <div class="stat-box"><div class="num"><i class="fas fa-shopping-bag" style="color:var(--color-danger)"></i> <%=od.countMonth()%></div><div class="label">本月交易</div></div>
    <div class="stat-box"><div class="num"><i class="fas fa-coins" style="color:var(--color-warning)"></i> <%=pd.totalIssued()%></div><div class="label">累计发放积分</div></div>
</div>
<%@ include file="../common/admin-foot.jsp" %>
