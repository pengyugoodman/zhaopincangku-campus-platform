<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil,java.util.*" %>
<%
    User u = SessionUtil.getFreshUser(request);
    String tab = request.getParameter("tab");
    Integer status = tab == null || tab.isEmpty() ? null : Integer.parseInt(tab);
    List<Order> orders = new OrderDao().listByBuyer(u.getUserId(), status);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>我的订单 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
    <div class="card text-secondary" style="font-size:13px"><i class="fas fa-info-circle" style="color:var(--primary)"></i> 流程：下单扣积分 &rarr; 待收货（面交） &rarr; 确认收货 &rarr; 积分转给卖家</div>
    <div class="tabs">
        <a href="orders.jsp" class="<%=tab==null?"active":""%>"><i class="fas fa-list"></i> 全部</a>
        <a href="orders.jsp?tab=1" class="<%= "1".equals(tab)?"active":""%>"><i class="fas fa-truck"></i> 待收货</a>
        <a href="orders.jsp?tab=2" class="<%= "2".equals(tab)?"active":""%>"><i class="fas fa-check-circle"></i> 已完成</a>
        <a href="orders.jsp?tab=3" class="<%= "3".equals(tab)?"active":""%>"><i class="fas fa-times-circle"></i> 已取消</a>
    </div>
    <% for (Order o : orders) { %>
    <div class="card">
        <div class="flex-between">
            <span style="font-weight:600"><i class="fas fa-receipt" style="color:var(--primary-light)"></i> <%=o.getOrderSn()%></span>
            <span class="tag tag-info"><% if(o.getStatus()==0){ %><i class="fas fa-clock"><% }else if(o.getStatus()==1){ %><i class="fas fa-truck"><% }else if(o.getStatus()==2){ %><i class="fas fa-check-circle"><% }else{ %><i class="fas fa-times-circle"><% } %></i> <%=o.getStatusText()%></span>
        </div>
        <div class="mt8" style="font-size:15px;font-weight:600"><i class="fas fa-box" style="color:var(--primary-light)"></i> <%=o.getGoodsTitle()%></div>
        <div class="price mt8"><i class="fas fa-coins"></i> <%=o.getPointsCost()%> 积分</div>
        <% if (o.getPickupCode() != null) { %><div class="text-secondary mt8"><i class="fas fa-key"></i> 取货码：<strong style="color:var(--primary)"><%=o.getPickupCode()%></strong></div><% } %>
        <% if (o.getAddress() != null && !o.getAddress().isBlank()) { %><div class="text-secondary"><i class="fas fa-map-marker-alt"></i> 面交地址：<%=o.getAddress()%></div><% } %>
        <% if (o.getStatus() == 1) { %>
        <div class="alert alert-success mt8" style="margin-bottom:0"><i class="fas fa-info-circle"></i> 请与卖家面交后，点击下方「确认收货」</div>
        <% } %>
        <div class="mt8 flex">
            <% if (o.getStatus() == 1) { %>
            <form action="<%=request.getContextPath()%>/action/receive" method="post">
                <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
                <button class="btn btn-success btn-sm"><i class="fas fa-check-circle"></i> 确认收货</button>
            </form>
            <% } %>
            <% if (o.getStatus() <= 1) { %>
            <form action="<%=request.getContextPath()%>/action/cancelOrder" method="post">
                <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
                <button class="btn btn-danger btn-sm"><i class="fas fa-times-circle"></i> 取消订单</button>
            </form>
            <% } %>
        </div>
    </div>
    <% } %>
    <% if (orders.isEmpty()) { %><div class="card text-secondary" style="text-align:center;padding:40px"><i class="fas fa-clipboard-list" style="font-size:48px;color:var(--text-light);display:block;margin-bottom:12px"></i>暂无订单，去<a href="home.jsp">首页</a>逛逛</div><% } %>
</div>
</body>
</html>
