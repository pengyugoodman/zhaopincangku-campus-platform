<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,java.util.*" %>
<% pageContext.setAttribute("adminTitle", "系统配置"); %>
<% Map<String, String> cfg = new ConfigDao().all(); %>
<%@ include file="../common/admin-head.jsp" %>
<div class="admin-page-title"><i class="fas fa-cog" style="color:var(--primary)"></i> 系统配置</div>
<% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
<div class="card">
    <form action="<%=request.getContextPath()%>/action/saveConfig" method="post">
        <div class="form-item"><label><i class="fas fa-calendar-check"></i> 签到基础积分</label><input class="input" name="sign_base_points" value="<%=cfg.getOrDefault("sign_base_points","2")%>"></div>
        <div class="form-item"><label><i class="fas fa-fire"></i> 连续7天额外奖励</label><input class="input" name="sign_streak_bonus" value="<%=cfg.getOrDefault("sign_streak_bonus","5")%>"></div>
        <div class="form-item"><label><i class="fas fa-plus-circle"></i> 发布奖励积分</label><input class="input" name="publish_reward_points" value="<%=cfg.getOrDefault("publish_reward_points","10")%>"></div>
        <div class="form-item"><label><i class="fas fa-list-ol"></i> 每日发布奖励上限</label><input class="input" name="publish_daily_limit" value="<%=cfg.getOrDefault("publish_daily_limit","3")%>"></div>
        <div class="form-item"><label><i class="fas fa-hourglass-half"></i> 订单自动取消时限(小时)</label><input class="input" name="order_cancel_hours" value="<%=cfg.getOrDefault("order_cancel_hours","48")%>"></div>
        <button class="btn btn-primary"><i class="fas fa-save"></i> 保存</button>
    </form>
</div>
<%@ include file="../common/admin-foot.jsp" %>
