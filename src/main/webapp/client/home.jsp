<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,java.util.*" %>
<%
    User u = com.campus.util.SessionUtil.getUser(request);
    GoodsDao gd = new GoodsDao();
    String cat = request.getParameter("cat");
    String kw = request.getParameter("kw");
    Integer catId = (cat == null || cat.isEmpty()) ? null : Integer.parseInt(cat);
    List<Goods> goods = gd.listOnSale(catId, kw);
    List<String[]> cats = gd.categories();
    PointsDao pd = new PointsDao();
    boolean signed = pd.signedToday(u.getUserId());
    int streak = pd.getStreak(u.getUserId());
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>首页 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
    <div class="card flex-between">
        <div>
            <div style="font-size:16px;font-weight:600"><i class="fas fa-user-circle" style="color:var(--primary)"></i> 你好，<%=u.getNickname()%></div>
            <div class="points-badge mt8"><i class="fas fa-coins"></i> <%=u.getPointsBalance()%> 积分</div>
            <div class="text-secondary mt8"><i class="fas fa-fire" style="color:var(--color-warning)"></i> 连续签到 <%=streak%> 天</div>
        </div>
        <div>
            <% if (!signed) { %>
            <form action="<%=request.getContextPath()%>/action/signin" method="post" style="display:inline">
                <button class="btn btn-warning"><i class="fas fa-calendar-check"></i> 每日签到</button>
            </form>
            <% } else { %>
            <span class="tag tag-success"><i class="fas fa-check"></i> 今日已签到</span>
            <% } %>
        </div>
    </div>
    <div class="quick-nav">
        <a href="<%=request.getContextPath()%>/client/activities.jsp"><i class="fas fa-calendar-alt"></i>活动中心</a>
        <a href="<%=request.getContextPath()%>/client/publish.jsp"><i class="fas fa-plus-circle"></i>发布闲置</a>
        <a href="<%=request.getContextPath()%>/client/points.jsp"><i class="fas fa-coins"></i>积分明细</a>
        <a href="<%=request.getContextPath()%>/client/favorites.jsp"><i class="fas fa-heart"></i>我的收藏</a>
    </div>
    <form class="flex mb16" method="get">
        <input class="input" name="kw" placeholder="搜索商品..." value="<%=kw!=null?kw:""%>" style="margin:0">
        <button class="btn btn-primary"><i class="fas fa-search"></i> 搜索</button>
    </form>
    <div class="tabs">
        <a href="home.jsp" class="<%=cat==null?"active":""%>"><i class="fas fa-th"></i> 全部</a>
        <% for (String[] c : cats) { %>
        <a href="home.jsp?cat=<%=c[0]%>" class="<%=cat!=null&&cat.equals(c[0])?"active":""%>"><%=c[1]%></a>
        <% } %>
    </div>
    <div class="grid">
        <% for (Goods g : goods) { %>
        <a href="goods-detail.jsp?id=<%=g.getGoodsId()%>" class="goods-card">
            <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, g.getCover())%>" alt="" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
            <div class="info">
                <div style="font-weight:600"><i class="fas fa-box" style="color:var(--primary-light)"></i> <%=g.getTitle()%></div>
                <div class="price mt8"><i class="fas fa-coins"></i> <%=g.getPricePoints()%> 积分</div>
                <div class="text-secondary mt8"><i class="fas fa-tag"></i> <%=g.getCategoryName()%></div>
            </div>
        </a>
        <% } %>
    </div>
    <% if (goods.isEmpty()) { %><div class="card text-secondary" style="text-align:center;padding:40px"><i class="fas fa-inbox" style="font-size:48px;color:var(--text-light);display:block;margin-bottom:12px"></i>暂无商品</div><% } %>
</div>
</body>
</html>
