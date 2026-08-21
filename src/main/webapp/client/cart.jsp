<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil,java.util.*" %>
<%
    User u = SessionUtil.getFreshUser(request);
    List<Goods> cart = new CartDao().listCart(u.getUserId());
    int total = cart.stream().mapToInt(Goods::getPricePoints).sum();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>购物车 - 校园二手交易平台</title></head>
<body class="has-bottom">
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("err") != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=request.getParameter("err")%></div><% } %>
    <div class="card-title"><i class="fas fa-shopping-cart" style="color:var(--primary)"></i> 购物车</div>
    <% if (cart.isEmpty()) { %>
    <div class="card text-secondary" style="text-align:center;padding:40px"><i class="fas fa-shopping-cart" style="font-size:48px;color:var(--text-light);display:block;margin-bottom:12px"></i>购物车是空的，去<a href="home.jsp">首页</a>逛逛吧</div>
    <% } else { %>
    <form action="<%=request.getContextPath()%>/action/checkout" method="post">
        <% for (Goods g : cart) { %>
        <div class="card flex-between">
            <div class="flex">
                <input type="checkbox" name="goodsId" value="<%=g.getGoodsId()%>" checked>
                <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, g.getCover())%>" style="width:60px;height:60px;object-fit:cover;border-radius:var(--radius-btn)" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
                <div>
                    <div style="font-weight:600"><i class="fas fa-box" style="color:var(--primary-light)"></i> <%=g.getTitle()%></div>
                    <div class="price mt8"><i class="fas fa-coins"></i> <%=g.getPricePoints()%> 积分</div>
                </div>
            </div>
            <a class="btn btn-danger btn-sm" href="<%=request.getContextPath()%>/action/removeCart?goodsId=<%=g.getGoodsId()%>"><i class="fas fa-trash"></i> 删除</a>
        </div>
        <% } %>
        <div class="card">
            <div class="form-item"><label><i class="fas fa-comment"></i> 面交备注</label><input class="input" name="remark" placeholder="约在图书馆门口"></div>
            <div class="form-item"><label><i class="fas fa-map-marker-alt"></i> 面交地址</label><input class="input" name="address" placeholder="5栋302"></div>
        </div>
        <div class="bottom-bar">
            <div>合计 <span class="points-badge"><i class="fas fa-coins"></i> <%=total%></span> / 余额 <%=u.getPointsBalance()%></div>
            <% if (total <= u.getPointsBalance() && u.getVerifyStatus() == 2) { %>
            <button type="submit" class="btn btn-primary"><i class="fas fa-check"></i> 去结算</button>
            <% } else if (u.getVerifyStatus() != 2) { %>
            <a class="btn btn-warning" href="profile.jsp"><i class="fas fa-id-card"></i> 请先完成认证</a>
            <% } else { %>
            <a class="btn btn-warning" href="activities.jsp"><i class="fas fa-coins"></i> 积分不足，去赚积分</a>
            <% } %>
        </div>
    </form>
    <% } %>
</div>
</body>
</html>
