<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,java.util.*" %>
<% pageContext.setAttribute("adminTitle", "商品管理"); %>
<%
    String tab = request.getParameter("tab");
    GoodsDao gd = new GoodsDao();
    List<Goods> list = "1".equals(tab) ? gd.listByStatus(1) : "2".equals(tab) ? gd.listByStatus(2) : gd.listByStatus(0);
    String tabParam = tab == null ? "" : tab;
%>
<%@ include file="../common/admin-head.jsp" %>
<div class="admin-page-title"><i class="fas fa-box" style="color:var(--primary)"></i> 商品管理</div>
<% if (request.getParameter("msg") != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%=request.getParameter("msg")%></div><% } %>
<div class="tabs">
    <a href="goods.jsp" class="<%=tab==null?"active":""%>"><i class="fas fa-hourglass-half"></i> 待审核</a>
    <a href="goods.jsp?tab=1" class="<%= "1".equals(tab)?"active":""%>"><i class="fas fa-check-circle"></i> 已上架</a>
    <a href="goods.jsp?tab=2" class="<%= "2".equals(tab)?"active":""%>"><i class="fas fa-times-circle"></i> 已下架</a>
</div>
<% for (Goods g : list) {
    String imgVal = g.getFirstImageUrl();
%>
<div class="card">
    <div class="flex-between">
        <div style="font-weight:600"><i class="fas fa-box" style="color:var(--primary-light)"></i> <%=g.getTitle()%> <span class="text-secondary">&middot; <i class="fas fa-user"></i> <%=g.getSellerName()%></span></div>
        <span class="tag tag-info"><% if(g.getStatus()==0){ %><i class="fas fa-hourglass-half"><% }else if(g.getStatus()==1){ %><i class="fas fa-check-circle"><% }else{ %><i class="fas fa-times-circle"><% } %></i> <%=g.getStatusText()%></span>
    </div>
    <form method="post" enctype="multipart/form-data" class="mt8">
        <input type="hidden" name="id" value="<%=g.getGoodsId()%>">
        <input type="hidden" name="tab" value="<%=tabParam%>">
        <div class="flex" style="align-items:flex-start">
            <img src="<%=com.campus.util.ImageUtil.getImageUrl(request, g.getCover())%>" style="width:88px;height:88px;object-fit:cover;border-radius:var(--radius-btn);border:1px solid var(--border-color)" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/placeholder.svg'">
            <div style="flex:1">
                <div class="form-item" style="margin-bottom:8px">
                    <label><i class="fas fa-image"></i> 上传图片</label>
                    <input class="input" name="imageFile" type="file" accept="image/*" style="margin:0">
                </div>
                <div class="form-item" style="margin-bottom:8px">
                    <label><i class="fas fa-link"></i> 或图片链接</label>
                    <input class="input" name="imageUrl" value="<%=imgVal%>" placeholder="https://..." style="margin:0">
                </div>
                <button type="submit" class="btn btn-primary btn-sm" formaction="<%=request.getContextPath()%>/action/updateGoodsImages"><i class="fas fa-save"></i> 保存图片</button>
            </div>
        </div>
        <div class="text-secondary mt8"><i class="fas fa-align-left" style="color:var(--text-secondary)"></i> <%=g.getDescription()%></div>
        <div class="price mt8"><i class="fas fa-coins"></i> <%=g.getPricePoints()%> 积分</div>
        <% if (g.getStatus() == 0) { %>
        <div class="flex mt8" style="flex-wrap:wrap;gap:8px;align-items:center">
            <button type="submit" class="btn btn-success btn-sm" formaction="<%=request.getContextPath()%>/action/auditGoods" name="result" value="pass"><i class="fas fa-check"></i> 通过</button>
            <input class="input" name="remark" placeholder="驳回原因" style="margin:0;width:200px">
            <button type="submit" class="btn btn-danger btn-sm" formaction="<%=request.getContextPath()%>/action/auditGoods" name="result" value="reject"><i class="fas fa-times"></i> 驳回</button>
        </div>
        <% } else if (g.getStatus() == 1) { %>
        <a class="btn btn-warning btn-sm mt8" href="<%=request.getContextPath()%>/action/offShelf?id=<%=g.getGoodsId()%>&redirect=/admin/goods.jsp?tab=1"><i class="fas fa-arrow-down"></i> 强制下架</a>
        <% } else if (g.getStatus() == 2) { %>
        <a class="btn btn-success btn-sm mt8" href="<%=request.getContextPath()%>/action/onShelf?id=<%=g.getGoodsId()%>&redirect=/admin/goods.jsp?tab=2"><i class="fas fa-arrow-up"></i> 重新上架</a>
        <% } %>
    </form>
</div>
<% } %>
<%@ include file="../common/admin-foot.jsp" %>
