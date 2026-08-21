<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.model.*,com.campus.util.SessionUtil" %>
<%
    User u = SessionUtil.getUser(request);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>个人中心 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
    <div class="card" style="text-align:center">
        <div style="width:72px;height:72px;border-radius:50%;background:var(--primary-lighter);margin:0 auto 12px;display:flex;align-items:center;justify-content:center"><i class="fas fa-user-circle" style="font-size:40px;color:var(--primary)"></i></div>
        <div style="font-size:18px;font-weight:700"><%=u.getNickname()%></div>
        <div class="text-secondary mt8"><i class="fas fa-id-card"></i> <%=u.getStudentId()%></div>
        <div class="mt8"><span class="tag tag-<%=u.getVerifyStatus()==2?"success":"warning"%>"><i class="fas fa-<%=u.getVerifyStatus()==2?"check-circle":"clock"%>"></i> <%=u.getVerifyText()%></span></div>
        <div class="points-badge mt16"><i class="fas fa-coins"></i> <%=u.getPointsBalance()%> 积分</div>
    </div>
    <div class="card">
        <a href="orders.jsp" style="display:flex;align-items:center;justify-content:space-between;padding:12px 0;border-bottom:1px solid var(--border-color);color:var(--text-main);font-weight:600"><span><i class="fas fa-clipboard-list" style="color:var(--primary);margin-right:8px"></i> 我的买入</span> <i class="fas fa-chevron-right" style="color:var(--text-light)"></i></a>
        <a href="seller-orders.jsp" style="display:flex;align-items:center;justify-content:space-between;padding:12px 0;border-bottom:1px solid var(--border-color);color:var(--text-main);font-weight:600"><span><i class="fas fa-handshake" style="color:var(--primary);margin-right:8px"></i> 我的卖出</span> <i class="fas fa-chevron-right" style="color:var(--text-light)"></i></a>
        <a href="my-goods.jsp" style="display:flex;align-items:center;justify-content:space-between;padding:12px 0;border-bottom:1px solid var(--border-color);color:var(--text-main);font-weight:600"><span><i class="fas fa-box" style="color:var(--primary);margin-right:8px"></i> 我的发布</span> <i class="fas fa-chevron-right" style="color:var(--text-light)"></i></a>
        <a href="points.jsp" style="display:flex;align-items:center;justify-content:space-between;padding:12px 0;border-bottom:1px solid var(--border-color);color:var(--text-main);font-weight:600"><span><i class="fas fa-coins" style="color:var(--primary);margin-right:8px"></i> 积分明细</span> <i class="fas fa-chevron-right" style="color:var(--text-light)"></i></a>
        <a href="favorites.jsp" style="display:flex;align-items:center;justify-content:space-between;padding:12px 0;color:var(--text-main);font-weight:600"><span><i class="fas fa-heart" style="color:var(--primary);margin-right:8px"></i> 我的收藏</span> <i class="fas fa-chevron-right" style="color:var(--text-light)"></i></a>
    </div>
    <% if (u.getVerifyStatus() != 2) { %>
    <div class="card">
        <div class="card-title"><i class="fas fa-id-card" style="color:var(--primary)"></i> 校园认证</div>
        <form action="<%=request.getContextPath()%>/action/verify" method="post">
            <div class="form-item"><label><i class="fas fa-id-card"></i> 学号</label><input class="input" name="studentId" placeholder="请输入学号" required></div>
            <div class="form-item"><label><i class="fas fa-user"></i> 姓名</label><input class="input" name="realName" placeholder="请输入真实姓名" required></div>
            <div class="form-item"><label><i class="fas fa-image"></i> 校园卡照片URL</label><input class="input" name="cardPhoto" placeholder="https://example.com/card.jpg" required></div>
            <button class="btn btn-primary"><i class="fas fa-upload"></i> 提交认证</button>
        </form>
    </div>
    <% } %>
</div>
</body>
</html>
