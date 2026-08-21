<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    ActivityDao ad = new ActivityDao();
    Activity a = ad.findById(id);
    User u = SessionUtil.getFreshUser(request);
    int partStatus = ad.getParticipationStatus(u.getUserId(), id);
    java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
    boolean notStarted = a.getStartTime() != null && a.getStartTime().after(now);
    boolean ended = a.getEndTime() != null && a.getEndTime().before(now);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title><%=a.getTitle()%> - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
    <% if (request.getParameter("err") != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=request.getParameter("err")%></div><% } %>
    <div class="card">
        <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, a.getCover())%>" style="width:100%;max-height:240px;object-fit:cover;border-radius:var(--radius-card);margin-bottom:16px" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
        <div class="card-title"><i class="fas fa-star" style="color:var(--primary)"></i> <%=a.getTitle()%></div>
        <p style="line-height:1.8"><i class="fas fa-align-left" style="color:var(--primary)"></i> <%=a.getDescription()%></p>
        <p class="mt8"><span class="tag tag-warning"><i class="fas fa-coins"></i> 奖励 <%=a.getPointsReward()%> 积分</span></p>
        <p class="text-secondary mt8"><i class="fas fa-clock"></i> 时间：<%=a.getStartTime()%> ~ <%=a.getEndTime()%></p>
        <div class="mt16">
            <% if (partStatus == 2) { %>
            <span class="tag tag-success"><i class="fas fa-check-circle"></i> 已完成，积分已领取</span>
            <% } else if (partStatus == 1) { %>
            <span class="tag tag-warning"><i class="fas fa-hourglass-half"></i> 已提交完成申请，等待管理员审核</span>
            <% } else if (partStatus == 0) { %>
            <span class="tag tag-info"><i class="fas fa-user-check"></i> 已报名</span>
            <% if (!ended) { %>
            <form action="<%=request.getContextPath()%>/action/completeActivity" method="post" style="display:inline;margin-left:8px">
                <input type="hidden" name="id" value="<%=id%>">
                <button class="btn btn-primary"><i class="fas fa-paper-plane"></i> 提交完成申请</button>
            </form>
            <form action="<%=request.getContextPath()%>/action/cancelActivity" method="post" style="display:inline;margin-left:8px">
                <input type="hidden" name="id" value="<%=id%>">
                <button class="btn btn-outline"><i class="fas fa-times"></i> 取消报名</button>
            </form>
            <% } %>
            <% } else if (notStarted) { %>
            <span class="tag tag-info"><i class="fas fa-hourglass-start"></i> 活动尚未开始，暂不可报名</span>
            <% } else if (ended) { %>
            <span class="tag tag-danger"><i class="fas fa-flag-checkered"></i> 活动已结束</span>
            <% } else { %>
            <form action="<%=request.getContextPath()%>/action/joinActivity" method="post" style="display:inline">
                <input type="hidden" name="id" value="<%=id%>">
                <button class="btn btn-primary"><i class="fas fa-hand-paper"></i> 立即参与</button>
            </form>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>
