<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil,java.util.*" %>
<%
    User u = SessionUtil.getUser(request);
    List<PointsLog> logs = new PointsDao().listByUser(u.getUserId());
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>积分明细 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <a href="profile.jsp" class="page-back"><i class="fas fa-arrow-left"></i> 返回</a>
    <div class="card-title"><i class="fas fa-coins" style="color:var(--primary)"></i> 积分明细</div>
    <table class="table card">
        <tr><th><i class="fas fa-clock"></i> 时间</th><th><i class="fas fa-exchange-alt"></i> 类型</th><th><i class="fas fa-tag"></i> 来源</th><th><i class="fas fa-coins"></i> 数量</th><th><i class="fas fa-wallet"></i> 余额</th></tr>
        <% for (PointsLog p : logs) { %>
        <tr>
            <td><i class="fas fa-clock" style="color:var(--text-secondary)"></i> <%=p.getCreateTime()%></td>
            <td><% if(p.getType()==1){ %><span class="tag tag-success"><i class="fas fa-arrow-down"></i> 收入</span><% }else{ %><span class="tag tag-danger"><i class="fas fa-arrow-up"></i> 支出</span><% } %></td>
            <td><i class="fas fa-tag" style="color:var(--text-secondary)"></i> <%=p.getSourceText()%> <%=p.getDescription()!=null?p.getDescription():""%></td>
            <td style="color:<%=p.getType()==1?"var(--color-success)":"var(--color-danger)"%>;font-weight:700"><%=p.getType()==1?"+":"-"%><%=p.getAmount()%></td>
            <td><i class="fas fa-wallet" style="color:var(--text-secondary)"></i> <%=p.getBalanceAfter()%></td>
        </tr>
        <% } %>
    </table>
</div>
</body>
</html>
