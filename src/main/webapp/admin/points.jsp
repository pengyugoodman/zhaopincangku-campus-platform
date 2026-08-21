<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,java.util.*" %>
<% pageContext.setAttribute("adminTitle", "积分审计"); %>
<% List<PointsLog> logs = new PointsDao().listAll(); %>
<%@ include file="../common/admin-head.jsp" %>
<div class="admin-page-title"><i class="fas fa-chart-line" style="color:var(--primary)"></i> 积分审计</div>
<table class="table card">
    <tr><th><i class="fas fa-clock"></i> 时间</th><th><i class="fas fa-user"></i> 用户ID</th><th><i class="fas fa-exchange-alt"></i> 类型</th><th><i class="fas fa-tag"></i> 来源</th><th><i class="fas fa-coins"></i> 数量</th><th><i class="fas fa-wallet"></i> 余额</th><th><i class="fas fa-comment"></i> 描述</th></tr>
    <% for (PointsLog p : logs) { %>
    <tr>
        <td><i class="fas fa-clock" style="color:var(--text-secondary)"></i> <%=p.getCreateTime()%></td>
        <td><i class="fas fa-user" style="color:var(--text-secondary)"></i> <%=p.getUserId()%></td>
        <td><% if(p.getType()==1){ %><span class="tag tag-success"><i class="fas fa-arrow-down"></i> 收入</span><% }else{ %><span class="tag tag-danger"><i class="fas fa-arrow-up"></i> 支出</span><% } %></td>
        <td><i class="fas fa-tag" style="color:var(--text-secondary)"></i> <%=p.getSourceText()%></td>
        <td style="color:<%=p.getType()==1?"var(--color-success)":"var(--color-danger)"%>;font-weight:700"><%=p.getType()==1?"+":"-"%><%=p.getAmount()%></td>
        <td><i class="fas fa-wallet" style="color:var(--text-secondary)"></i> <%=p.getBalanceAfter()%></td>
        <td><i class="fas fa-comment" style="color:var(--text-secondary)"></i> <%=p.getDescription()%></td>
    </tr>
    <% } %>
</table>
<%@ include file="../common/admin-foot.jsp" %>
