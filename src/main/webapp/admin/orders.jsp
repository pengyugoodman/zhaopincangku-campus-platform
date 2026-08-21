<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,java.util.*" %>
<% pageContext.setAttribute("adminTitle", "订单管理"); %>
<%
    String tab = request.getParameter("tab");
    Integer status = tab == null || tab.isEmpty() ? null : Integer.parseInt(tab);
    List<Order> orders = new OrderDao().listAll(status);
%>
<%@ include file="../common/admin-head.jsp" %>
<div class="admin-page-title"><i class="fas fa-shopping-bag" style="color:var(--primary)"></i> 订单管理</div>
<div class="tabs">
    <a href="orders.jsp" class="<%=tab==null?"active":""%>"><i class="fas fa-list"></i> 全部</a>
    <a href="orders.jsp?tab=0" class="<%= "0".equals(tab)?"active":""%>"><i class="fas fa-clock"></i> 待确认</a>
    <a href="orders.jsp?tab=1" class="<%= "1".equals(tab)?"active":""%>"><i class="fas fa-truck"></i> 待收货</a>
    <a href="orders.jsp?tab=2" class="<%= "2".equals(tab)?"active":""%>"><i class="fas fa-check-circle"></i> 已完成</a>
    <a href="orders.jsp?tab=3" class="<%= "3".equals(tab)?"active":""%>"><i class="fas fa-times-circle"></i> 已取消</a>
</div>
<table class="table card">
    <tr><th><i class="fas fa-receipt"></i> 订单号</th><th><i class="fas fa-user"></i> 买家</th><th><i class="fas fa-user-tie"></i> 卖家</th><th><i class="fas fa-box"></i> 商品</th><th><i class="fas fa-coins"></i> 积分</th><th><i class="fas fa-info-circle"></i> 状态</th><th><i class="fas fa-cog"></i> 操作</th></tr>
    <% for (Order o : orders) { %>
    <tr>
        <td style="font-weight:600"><i class="fas fa-receipt" style="color:var(--primary-light)"></i> <%=o.getOrderSn()%></td>
        <td><i class="fas fa-user" style="color:var(--text-secondary)"></i> <%=o.getBuyerName()%></td>
        <td><i class="fas fa-user-tie" style="color:var(--text-secondary)"></i> <%=o.getSellerName()%></td>
        <td><i class="fas fa-box" style="color:var(--text-secondary)"></i> <%=o.getGoodsTitle()%></td>
        <td style="color:var(--color-warning);font-weight:700"><i class="fas fa-coins"></i> <%=o.getPointsCost()%></td>
        <td><span class="tag tag-info"><% if(o.getStatus()==0){ %><i class="fas fa-clock"><% }else if(o.getStatus()==1){ %><i class="fas fa-truck"><% }else if(o.getStatus()==2){ %><i class="fas fa-check-circle"><% }else{ %><i class="fas fa-times-circle"><% } %></i> <%=o.getStatusText()%></span></td>
        <td>
            <% if (o.getStatus() <= 1) { %>
            <form action="<%=request.getContextPath()%>/action/forceCancel" method="post" style="display:inline">
                <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
                <button class="btn btn-danger btn-sm"><i class="fas fa-ban"></i> 强制取消</button>
            </form>
            <% if (o.getStatus() == 1) { %>
            <form action="<%=request.getContextPath()%>/action/forceComplete" method="post" style="display:inline">
                <input type="hidden" name="orderId" value="<%=o.getOrderId()%>">
                <input type="hidden" name="buyerId" value="<%=o.getBuyerId()%>">
                <button class="btn btn-success btn-sm"><i class="fas fa-check"></i> 强制完成</button>
            </form>
            <% } %>
            <% } %>
        </td>
    </tr>
    <% } %>
</table>
<%@ include file="../common/admin-foot.jsp" %>
