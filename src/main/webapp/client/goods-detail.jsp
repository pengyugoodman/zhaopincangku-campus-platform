<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    User u = SessionUtil.getFreshUser(request);
    Goods g = new GoodsDao().findById(id);
    boolean fav = new CartDao().isFavorite(u.getUserId(), id);
    boolean canBuy = u.getVerifyStatus() == 2 && g.getStatus() == 1 && g.getSellerId() != u.getUserId();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title><%=g.getTitle()%> - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("err") != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=request.getParameter("err")%></div><% } %>
    <div class="card">
        <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, g.getCover())%>" style="width:100%;max-height:360px;object-fit:cover;border-radius:var(--radius-card)" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
        <h2 class="mt16" style="font-size:22px;font-weight:700"><%=g.getTitle()%></h2>
        <div class="points-badge mt8"><i class="fas fa-coins"></i> <%=g.getPricePoints()%> 积分</div>
        <p class="text-secondary mt8"><i class="fas fa-tag"></i> <%=g.getCategoryName()%> &middot; <i class="fas fa-user"></i> 卖家：<%=g.getSellerName()%></p>
        <p class="mt16" style="line-height:1.8"><i class="fas fa-align-left" style="color:var(--primary)"></i> <%=g.getDescription()%></p>
        <% if (g.getStatus() != 1) { %>
        <div class="alert alert-error mt16"><i class="fas fa-exclamation-triangle"></i> 该商品已下架或已售出</div>
        <% } else if (g.getSellerId() == u.getUserId()) { %>
        <div class="alert alert-error mt16"><i class="fas fa-info-circle"></i> 这是您发布的商品</div>
        <% } else if (u.getVerifyStatus() != 2) { %>
        <div class="alert alert-error mt16"><i class="fas fa-exclamation-circle"></i> 请先<a href="profile.jsp">完成校园认证</a>后再购买</div>
        <% } else if (u.getPointsBalance() < g.getPricePoints()) { %>
        <div class="alert alert-error mt16"><i class="fas fa-exclamation-circle"></i> 积分不足（需要<%=g.getPricePoints()%>，当前<%=u.getPointsBalance()%>），去<a href="activities.jsp">活动中心</a>赚积分</div>
        <% } %>
        <div class="mt16 flex">
            <% if (canBuy && u.getPointsBalance() >= g.getPricePoints()) { %>
            <form action="<%=request.getContextPath()%>/action/buyNow" method="post">
                <input type="hidden" name="goodsId" value="<%=id%>">
                <input type="hidden" name="remark" value="面交自提">
                <input type="hidden" name="address" value="待协商">
                <button class="btn btn-primary"><i class="fas fa-bolt"></i> 立即购买</button>
            </form>
            <form action="<%=request.getContextPath()%>/action/addCart" method="post">
                <input type="hidden" name="goodsId" value="<%=id%>">
                <button class="btn btn-success"><i class="fas fa-cart-plus"></i> 加入购物车</button>
            </form>
            <% } %>
            <form action="<%=request.getContextPath()%>/action/favorite" method="post">
                <input type="hidden" name="goodsId" value="<%=id%>">
                <button class="btn"><i class="fas fa-heart<%=fav?"":""%>"></i> <%=fav?"取消收藏":"收藏"%></button>
            </form>
        </div>
    </div>
</div>
</body>
</html>
