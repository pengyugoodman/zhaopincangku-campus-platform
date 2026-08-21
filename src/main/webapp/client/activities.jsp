<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,java.util.*" %>
<%
    ActivityDao ad = new ActivityDao();
    List<Activity> list = ad.listActive();
    User u = com.campus.util.SessionUtil.getUser(request);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>活动中心 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
    <% if (request.getParameter("err") != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=request.getParameter("err")%></div><% } %>
    <div class="card-title"><i class="fas fa-calendar-alt" style="color:var(--primary)"></i> 活动列表</div>
    <% java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis()); %>
    <% for (Activity a : list) {
        boolean upcoming = a.getStartTime() != null && a.getStartTime().after(now);
        boolean ended = a.getEndTime() != null && a.getEndTime().before(now);
        int partStatus = ad.getParticipationStatus(u.getUserId(), a.getActivityId());
    %>
    <div class="card flex-between">
        <div class="flex" style="align-items:flex-start;gap:14px">
            <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, a.getCover())%>" style="width:72px;height:72px;object-fit:cover;border-radius:var(--radius-btn);border:1px solid var(--border-color)" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
            <div>
                <div style="font-size:16px;font-weight:700"><%=a.getTitle()%></div>
                <div class="text-secondary mt8"><i class="fas fa-align-left" style="color:var(--text-secondary)"></i> <%=a.getDescription()%></div>
                <div class="mt8">
                    <% if (upcoming) { %>
                    <span class="tag tag-info"><i class="fas fa-hourglass-half"></i> 即将开始</span>
                    <% } else if (ended) { %>
                    <span class="tag tag-danger"><i class="fas fa-flag-checkered"></i> 已结束</span>
                    <% } else { %>
                    <span class="tag tag-success"><i class="fas fa-play-circle"></i> 进行中</span>
                    <% } %>
                    <span class="tag tag-warning"><i class="fas fa-coins"></i> 奖励 <%=a.getPointsReward()%> 积分</span>
                    <span class="tag tag-info"><i class="fas fa-users"></i> <%=a.getCurrentParticipants()%> 人参与</span>
                    <span class="tag tag-success"><i class="fas fa-clock"></i> <%=a.getStartTime()%></span>
                </div>
            </div>
        </div>
        <div style="display:flex;flex-direction:column;gap:8px;align-items:flex-end">
            <% if (partStatus == 2) { %>
            <span class="tag tag-success" style="white-space:nowrap"><i class="fas fa-check-circle"></i> 已完成</span>
            <% } else if (partStatus == 1) { %>
            <span class="tag tag-warning" style="white-space:nowrap"><i class="fas fa-hourglass-half"></i> 待审核</span>
            <% } else if (partStatus == 0) { %>
            <span class="tag tag-info" style="white-space:nowrap"><i class="fas fa-user-check"></i> 已报名</span>
            <form action="<%=request.getContextPath()%>/action/cancelActivity" method="post" style="display:inline">
                <input type="hidden" name="id" value="<%=a.getActivityId()%>">
                <button class="btn btn-outline" style="font-size:12px;padding:4px 12px"><i class="fas fa-times"></i> 取消报名</button>
            </form>
            <% } else if (upcoming) { %>
            <span class="tag tag-info" style="white-space:nowrap"><i class="fas fa-lock"></i> 未到报名时间</span>
            <% } else if (ended) { %>
            <span class="tag tag-danger" style="white-space:nowrap"><i class="fas fa-lock"></i> 活动已结束</span>
            <% } else { %>
            <form action="<%=request.getContextPath()%>/action/joinActivity" method="post" style="display:inline">
                <input type="hidden" name="id" value="<%=a.getActivityId()%>">
                <button class="btn btn-primary"><i class="fas fa-hand-paper"></i> 立即报名</button>
            </form>
            <% } %>
            <a class="btn btn-outline" style="font-size:12px;padding:4px 12px" href="activity-detail.jsp?id=<%=a.getActivityId()%>"><i class="fas fa-eye"></i> 详情</a>
        </div>
    </div>
    <% } %>
    <% if (list.isEmpty()) { %><div class="card text-secondary" style="text-align:center;padding:40px"><i class="fas fa-calendar-times" style="font-size:48px;color:var(--text-light);display:block;margin-bottom:12px"></i>暂无活动</div><% } %>
</div>
</body>
</html>
