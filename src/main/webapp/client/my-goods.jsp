<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil,java.util.*" %>
<%
    User u = SessionUtil.getUser(request);
    List<Goods> list = new GoodsDao().listBySeller(u.getUserId());
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>我的发布 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
    <div class="flex-between mb16">
        <div class="card-title" style="margin:0;border:0;padding:0"><i class="fas fa-box" style="color:var(--primary)"></i> 我的发布</div>
        <a class="btn btn-primary btn-sm" href="publish.jsp"><i class="fas fa-plus"></i> 发布</a>
    </div>
    <% for (Goods g : list) { %>
    <div class="card flex-between">
        <div class="flex">
            <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, g.getCover())%>" style="width:60px;height:60px;object-fit:cover;border-radius:var(--radius-btn)" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
            <div>
                <div style="font-weight:600"><i class="fas fa-box" style="color:var(--primary-light)"></i> <%=g.getTitle()%></div>
                <div class="price mt8"><i class="fas fa-coins"></i> <%=g.getPricePoints()%> 积分</div>
                <span class="tag tag-info mt8"><i class="fas fa-info-circle"></i> <%=g.getStatusText()%></span>
            </div>
        </div>
        <div>
            <% if (g.getStatus() == 1) { %>
            <a class="btn btn-warning btn-sm" href="<%=request.getContextPath()%>/action/offShelf?id=<%=g.getGoodsId()%>"><i class="fas fa-arrow-down"></i> 下架</a>
            <% } else if (g.getStatus() == 2) { %>
            <a class="btn btn-success btn-sm" href="<%=request.getContextPath()%>/action/onShelf?id=<%=g.getGoodsId()%>"><i class="fas fa-arrow-up"></i> 上架</a>
            <% } %>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>
