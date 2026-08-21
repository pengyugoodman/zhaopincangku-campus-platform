<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil,java.util.*" %>
<%
    User u = SessionUtil.getFreshUser(request);
    List<Order> orders = new OrderDao().listBySeller(u.getUserId(), null);
    List<Order> pending = orders.stream().filter(o -> o.getStatus() == 0).toList();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>售卖订单 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
    <div class="card-title"><i class="fas fa-handshake" style="color:var(--primary)"></i> 我卖出的订单</div>
    <% if (pending.isEmpty() && orders.isEmpty()) { %>
    <div class="card text-secondary" style="text-align:center;padding:40px"><i class="fas fa-handshake" style="font-size:48px;color:var(--text-light);display:block;margin-bottom:12px"></i>暂无售卖订单</div>
    <% } %>
    <% for (Order o : orders) { %>
    <div class="card">
        <div class="flex-between">
            <span style="font-weight:600"><i class="fas fa-receipt" style="color:var(--primary-light)"></i> <%=o.getOrderSn()%></span>
            <span class="tag tag-info"><% if(o.getStatus()==0){ %><i class="fas fa-clock"><% }else if(o.getStatus()==1){ %><i class="fas fa-truck"><% }else if(o.getStatus()==2){ %><i class="fas fa-check-circle"><% }else{ %><i class="fas fa-times-circle"><% } %></i> <%=o.getStatusText()%></span>
        </div>
        <div class="mt8" style="font-size:15px;font-weight:600"><i class="fas fa-box" style="color:var(--primary-light)"></i> <%=o.getGoodsTitle()%></div>
        <div class="text-secondary mt8"><i class="fas fa-user"></i> 买家：<%=o.getBuyerName()%> &middot; <i class="fas fa-coins"></i> <%=o.getPointsCost()%> 积分</div>
        <% if (o.getBuyerRemark() != null) { %><div class="text-secondary"><i class="fas fa-comment"></i> 备注：<%=o.getBuyerRemark()%></div><% } %>
        <% if (o.getStatus() == 0) { %>
        <form action="<%=request.getContextPath()%>/action/sellerConfirm" method="post" class="mt8">
            <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
            <button class="btn btn-primary btn-sm"><i class="fas fa-check"></i> 确认发货/约定面交</button>
        </form>
        <% } else if (o.getStatus() == 1) { %>
        <div class="text-secondary mt8"><i class="fas fa-clock"></i> 等待买家确认收货</div>
        <% } else if (o.getStatus() == 2) { %>
        <div class="mt8"><span class="tag tag-success"><i class="fas fa-check-circle"></i> 已完成，积分已到账</span></div>
        <% } %>
    </div>
    <% } %>
</div>
</body>
</html>
