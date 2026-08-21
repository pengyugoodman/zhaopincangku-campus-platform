<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,java.util.*" %>
<% pageContext.setAttribute("adminTitle", "用户管理"); %>
<%
    UserDao ud = new UserDao();
    String kw = request.getParameter("kw");
    List<User> users = ud.listAll(kw);
    List<String[]> pending = ud.pendingVerify();
%>
<%@ include file="../common/admin-head.jsp" %>
<div class="admin-page-title"><i class="fas fa-users" style="color:var(--primary)"></i> 用户管理</div>
<% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
<% if (!pending.isEmpty()) { %>
<div class="card">
    <div class="card-title"><i class="fas fa-user-clock" style="color:var(--color-warning)"></i> 待认证审核</div>
    <% for (String[] v : pending) { %>
    <div class="card" style="background:var(--bg-body);box-shadow:none">
        <div style="font-weight:600"><%=v[1]%> &middot; <%=v[2]%> &middot; <%=v[3]%></div>
        <div class="text-secondary mt8"><%=v[5]%></div>
        <% if (v[4] != null && !v[4].isEmpty()) { %>
        <div class="mt8"><a href="<%=v[4]%>" target="_blank"><img src="<%=v[4]%>" alt="校园卡照片" style="max-width:200px;max-height:150px;border-radius:var(--radius-btn);border:1px solid var(--border-color)" onerror="this.style.display='none'"></a></div>
        <% } %>
        <div class="mt8 flex">
            <form action="<%=request.getContextPath()%>/action/auditUser" method="post">
                <input type="hidden" name="id" value="<%=v[0]%>"><input type="hidden" name="result" value="pass">
                <button class="btn btn-success btn-sm"><i class="fas fa-check"></i> 通过</button>
            </form>
            <form action="<%=request.getContextPath()%>/action/auditUser" method="post" class="flex">
                <input type="hidden" name="id" value="<%=v[0]%>"><input type="hidden" name="result" value="reject">
                <input class="input" name="remark" placeholder="驳回原因" style="margin:0;width:160px">
                <button class="btn btn-danger btn-sm"><i class="fas fa-times"></i> 驳回</button>
            </form>
        </div>
    </div>
    <% } %>
</div>
<% } %>
<form class="flex mb16" method="get">
    <input class="input" name="kw" placeholder="搜索学号/姓名/手机" value="<%=kw!=null?kw:""%>" style="margin:0">
    <button class="btn btn-primary"><i class="fas fa-search"></i> 搜索</button>
</form>
<table class="table card">
    <tr><th><i class="fas fa-user"></i> 昵称</th><th><i class="fas fa-id-card"></i> 学号</th><th><i class="fas fa-phone"></i> 手机</th><th><i class="fas fa-coins"></i> 积分</th><th><i class="fas fa-shield-alt"></i> 认证</th><th><i class="fas fa-cog"></i> 操作</th></tr>
    <% for (User u : users) { %>
    <tr>
        <td style="font-weight:600"><i class="fas fa-user-circle" style="color:var(--primary-light)"></i> <%=u.getNickname()%></td>
        <td><i class="fas fa-id-card" style="color:var(--text-secondary)"></i> <%=u.getStudentId()%></td>
        <td><i class="fas fa-phone" style="color:var(--text-secondary)"></i> <%=u.getPhone()%></td>
        <td style="color:var(--color-warning);font-weight:700"><i class="fas fa-coins"></i> <%=u.getPointsBalance()%></td>
        <td><span class="tag tag-<%=u.getVerifyStatus()==2?"success":"warning"%>"><% if(u.getVerifyStatus()==2){ %><i class="fas fa-check-circle"><% }else{ %><i class="fas fa-clock"><% } %></i> <%=u.getVerifyText()%></span></td>
        <td>
            <% if (u.getStatus() == 1) { %>
            <a class="btn btn-danger btn-sm" href="<%=request.getContextPath()%>/action/banUser?id=<%=u.getUserId()%>"><i class="fas fa-ban"></i> 封禁</a>
            <% } else { %>
            <a class="btn btn-success btn-sm" href="<%=request.getContextPath()%>/action/unbanUser?id=<%=u.getUserId()%>"><i class="fas fa-unlock"></i> 解封</a>
            <% } %>
            <form action="<%=request.getContextPath()%>/action/adjustPoints" method="post" style="display:inline-flex;gap:4px;margin-top:4px">
                <input type="hidden" name="userId" value="<%=u.getUserId()%>">
                <input class="input" name="amount" type="number" placeholder="±积分" style="margin:0;width:80px">
                <input class="input" name="reason" placeholder="原因" style="margin:0;width:100px">
                <button class="btn btn-warning btn-sm"><i class="fas fa-edit"></i> 调整</button>
            </form>
        </td>
    </tr>
    <% } %>
</table>
<%@ include file="../common/admin-foot.jsp" %>
