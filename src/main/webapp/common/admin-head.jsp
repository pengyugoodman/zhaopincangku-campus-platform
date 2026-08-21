<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String uri = request.getRequestURI();
    String title = (String) pageContext.getAttribute("adminTitle");
    if (title == null) title = "管理后台";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%=title%> - 校园二手管理</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/style.css">
</head>
<body class="admin-body">
<div class="admin-layout">
<%@ include file="admin-sidebar.jsp" %>
<main class="admin-main">
<div class="admin-topbar">
    <i class="fas fa-user-shield"></i> 管理员
    <a href="<%=ctx%>/action/logout"><i class="fas fa-sign-out-alt"></i> 退出</a>
</div>
