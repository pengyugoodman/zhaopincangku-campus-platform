<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,java.util.*" %>
<% pageContext.setAttribute("adminTitle", "活动管理"); %>
<%
    ActivityDao adao = new ActivityDao();
    List<Activity> list = adao.listAll();
    List<Object[]> pending = adao.listPending();
%>
<%@ include file="../common/admin-head.jsp" %>
<div class="admin-page-title"><i class="fas fa-star" style="color:var(--primary)"></i> 活动管理</div>
<% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
<% if (!pending.isEmpty()) { %>
<div class="card">
    <div class="card-title"><i class="fas fa-clipboard-check" style="color:var(--color-warning)"></i> 待审核的活动完成申请 (<%=pending.size()%>)</div>
    <table class="table">
        <tr><th><i class="fas fa-user"></i> 用户</th><th><i class="fas fa-bullhorn"></i> 活动</th><th><i class="fas fa-coins"></i> 奖励积分</th><th><i class="fas fa-sign-in-alt"></i> 报名时间</th><th><i class="fas fa-paper-plane"></i> 提交时间</th><th><i class="fas fa-cog"></i> 操作</th></tr>
        <% for (Object[] p : pending) { %>
        <tr>
            <td><i class="fas fa-user-circle" style="color:var(--primary)"></i> <%=p[2]%> <span class="text-secondary">(<%=p[3]%>)</span></td>
            <td><i class="fas fa-bullhorn" style="color:var(--primary-light)"></i> <%=p[5]%></td>
            <td><i class="fas fa-coins" style="color:var(--color-warning)"></i> <%=p[6]%></td>
            <td><%=p[7]%></td>
            <td><%=p[8]%></td>
            <td>
                <form action="<%=request.getContextPath()%>/action/approveActivity" method="post" style="display:inline">
                    <input type="hidden" name="id" value="<%=p[0]%>">
                    <input type="hidden" name="points" value="<%=p[6]%>">
                    <button class="btn btn-success btn-sm"><i class="fas fa-check"></i> 通过</button>
                </form>
                <form action="<%=request.getContextPath()%>/action/rejectActivity" method="post" style="display:inline">
                    <input type="hidden" name="id" value="<%=p[0]%>">
                    <button class="btn btn-danger btn-sm"><i class="fas fa-times"></i> 驳回</button>
                </form>
            </td>
        </tr>
        <% } %>
    </table>
</div>
<% } %>
<div class="card">
    <div class="card-title"><i class="fas fa-plus-circle" style="color:var(--primary)"></i> 创建活动</div>
    <form action="<%=request.getContextPath()%>/action/createActivity" method="post" enctype="multipart/form-data">
        <div class="form-item"><label><i class="fas fa-heading"></i> 标题</label><input class="input" name="title" placeholder="活动标题" required></div>
        <div class="form-item"><label><i class="fas fa-image"></i> 上传封面图</label><input class="input" name="coverFile" type="file" accept="image/*"></div>
        <div class="form-item"><label><i class="fas fa-link"></i> 或填写封面链接</label><input class="input" name="coverImage" placeholder="https://..."></div>
        <div class="form-item"><label><i class="fas fa-align-left"></i> 规则描述</label><textarea class="input" name="description" rows="3" placeholder="活动规则描述" required></textarea></div>
        <div class="form-item"><label><i class="fas fa-coins"></i> 奖励积分</label><input class="input" name="pointsReward" type="number" placeholder="奖励积分数" required></div>
        <div class="form-item"><label><i class="fas fa-users"></i> 最大人数（留空不限）</label><input class="input" name="maxParticipants" type="number"></div>
        <div class="form-item"><label><i class="fas fa-clock"></i> 开始时间</label><input class="input" name="startTime" id="actStartTime" type="datetime-local" min="<%=java.time.LocalDateTime.now().withSecond(0).withNano(0).toString()%>" required></div>
        <div class="form-item"><label><i class="fas fa-clock"></i> 结束时间</label><input class="input" name="endTime" id="actEndTime" type="datetime-local" min="<%=java.time.LocalDateTime.now().withSecond(0).withNano(0).toString()%>" required></div>
        <button class="btn btn-primary"><i class="fas fa-plus"></i> 创建</button>
    </form>
    <script>
    (function(){
        var s=document.getElementById('actStartTime'),e=document.getElementById('actEndTime');
        if(s&&e){s.addEventListener('change',function(){e.min=s.value;});}
    })();
    </script>
</div>
<% java.sql.Timestamp nowTs = new java.sql.Timestamp(System.currentTimeMillis()); %>
<% for (Activity a : list) {
    String coverVal = a.getCoverImage() == null ? "" : a.getCoverImage();
    boolean upcoming = a.getStartTime() != null && a.getStartTime().after(nowTs);
    boolean expired = a.getEndTime() != null && a.getEndTime().before(nowTs);
%>
<div class="card">
    <div class="flex-between">
        <div style="font-weight:600"><i class="fas fa-bullhorn" style="color:var(--primary-light)"></i> <%=a.getTitle()%> <span class="tag tag-info"><%=a.getStatusText()%></span></div>
        <div>
            <% if (a.getStatus() != 1) { %>
            <form action="<%=request.getContextPath()%>/action/toggleActivity" method="post" style="display:inline">
                <input type="hidden" name="id" value="<%=a.getActivityId()%>"><input type="hidden" name="status" value="1">
                <button class="btn btn-success btn-sm"><i class="fas fa-play"></i> 开启</button>
            </form>
            <% } else { %>
            <form action="<%=request.getContextPath()%>/action/toggleActivity" method="post" style="display:inline">
                <input type="hidden" name="id" value="<%=a.getActivityId()%>"><input type="hidden" name="status" value="3">
                <button class="btn btn-danger btn-sm"><i class="fas fa-stop"></i> 关闭</button>
            </form>
            <% } %>
        </div>
    </div>
    <div class="flex mt8" style="align-items:flex-start">
        <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, a.getCover())%>" style="width:88px;height:88px;object-fit:cover;border-radius:var(--radius-btn);border:1px solid var(--border-color)" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
        <form action="<%=request.getContextPath()%>/action/updateActivityCover" method="post" enctype="multipart/form-data" style="flex:1">
            <input type="hidden" name="id" value="<%=a.getActivityId()%>">
            <div class="form-item" style="margin-bottom:8px">
                <label><i class="fas fa-image"></i> 上传新封面</label>
                <input class="input" name="coverFile" type="file" accept="image/*" style="margin:0">
            </div>
            <div class="form-item" style="margin-bottom:8px">
                <label><i class="fas fa-link"></i> 或封面链接</label>
                <input class="input" name="coverImage" value="<%=coverVal%>" placeholder="https://..." style="margin:0">
            </div>
            <button class="btn btn-primary btn-sm"><i class="fas fa-save"></i> 保存封面</button>
        </form>
    </div>
    <div class="text-secondary mt8"><i class="fas fa-align-left" style="color:var(--text-secondary)"></i> <%=a.getDescription()%></div>
    <div class="mt8"><i class="fas fa-coins" style="color:var(--color-warning)"></i> 奖励 <%=a.getPointsReward()%> 分 &middot; <i class="fas fa-users" style="color:var(--primary)"></i> <%=a.getCurrentParticipants()%> 人参与 &middot; <i class="fas fa-clock" style="color:var(--text-secondary)"></i> <%=a.getStartTime()%> ~ <%=a.getEndTime()%>
    <% if (upcoming) { %><span class="tag tag-info" style="margin-left:8px"><i class="fas fa-hourglass-half"></i> 即将开始</span><% } else if (expired) { %><span class="tag tag-danger" style="margin-left:8px"><i class="fas fa-flag-checkered"></i> 已结束</span><% } else { %><span class="tag tag-success" style="margin-left:8px"><i class="fas fa-play-circle"></i> 进行中</span><% } %>
    </div>
</div>
<% } %>
<%@ include file="../common/admin-foot.jsp" %>
