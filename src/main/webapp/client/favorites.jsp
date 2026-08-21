<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil,java.util.*" %>
<%
    User u = SessionUtil.getUser(request);
    List<Goods> favs = new CartDao().listFavorites(u.getUserId());
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>我的收藏 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <div class="card-title"><i class="fas fa-heart" style="color:var(--primary)"></i> 我的收藏</div>
    <div class="grid">
        <% for (Goods g : favs) { %>
        <a href="goods-detail.jsp?id=<%=g.getGoodsId()%>" class="goods-card">
            <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, g.getCover())%>" alt="" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
            <div class="info"><div style="font-weight:600"><i class="fas fa-box" style="color:var(--primary-light)"></i> <%=g.getTitle()%></div><div class="price mt8"><i class="fas fa-coins"></i> <%=g.getPricePoints()%> 积分</div></div>
        </a>
        <% } %>
    </div>
    <% if (favs.isEmpty()) { %><div class="card text-secondary" style="text-align:center;padding:40px"><i class="fas fa-heart" style="font-size:48px;color:var(--text-light);display:block;margin-bottom:12px"></i>暂无收藏</div><% } %>
</div>
</body>
</html>
