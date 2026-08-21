<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campus.dao.*,com.campus.model.*,com.campus.util.SessionUtil,java.util.*" %>
<%
    User u = SessionUtil.getUser(request);
    List<Goods> myGoods = new GoodsDao().listBySeller(u.getUserId());
    List<String[]> cats = new GoodsDao().categories();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>发布闲置 - 校园二手交易平台</title></head>
<body>
<%@ include file="../common/header.jsp" %>
<div class="wrap">
    <% if (request.getParameter("err") != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=request.getParameter("err")%></div><% } %>
    <div class="card">
        <div class="card-title"><i class="fas fa-plus-circle" style="color:var(--primary)"></i> 发布闲置</div>
        <% if (u.getVerifyStatus() != 2) { %>
        <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> 未认证用户不能发布，请先<a href="profile.jsp">提交认证</a></div>
        <% } else { %>
        <form action="<%=request.getContextPath()%>/action/publish" method="post" enctype="multipart/form-data">
            <div class="form-item"><label><i class="fas fa-heading"></i> 标题（20字内）</label><input class="input" name="title" maxlength="20" placeholder="请输入商品标题" required></div>
            <div class="form-item"><label><i class="fas fa-align-left"></i> 描述</label><textarea class="input" name="description" rows="4" maxlength="200" placeholder="详细描述商品状况" required></textarea></div>
            <div class="form-item"><label><i class="fas fa-tag"></i> 分类</label>
                <select class="select" name="categoryId" required>
                    <% for (String[] c : cats) { %><option value="<%=c[0]%>"><%=c[1]%></option><% } %>
                </select>
            </div>
            <div class="form-item"><label><i class="fas fa-coins"></i> 积分价格</label><input class="input" name="pricePoints" type="number" min="1" placeholder="请输入积分价格" required></div>
            <div class="form-item"><label><i class="fas fa-star"></i> 新旧程度</label>
                <select class="select" name="conditionLevel">
                    <option value="0">全新</option><option value="1">几乎全新</option><option value="2">轻微使用</option><option value="3">明显磨损</option>
                </select>
            </div>
            <div class="form-item"><label><i class="fas fa-image"></i> 上传封面图</label><input class="input" name="imageFile" type="file" accept="image/*"></div>
            <div class="form-item"><label><i class="fas fa-link"></i> 或填写图片链接</label><input class="input" name="imageUrl" placeholder="https://example.com/photo.jpg"></div>
            <button class="btn btn-primary"><i class="fas fa-paper-plane"></i> 提交审核</button>
        </form>
        <% } %>
    </div>
</div>
</body>
</html>
