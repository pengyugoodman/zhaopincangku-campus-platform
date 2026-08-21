<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 校园二手交易平台</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/style.css">
    <style>
        body{
            background:linear-gradient(135deg,var(--primary-dark),var(--primary));
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
        }
        .login-card{
            background:#fff;
            border-radius:20px;
            box-shadow:0 20px 60px rgba(0,0,0,0.15);
            padding:40px 36px;
            width:100%;
            max-width:400px;
        }
        .login-card .login-logo{
            text-align:center;
            margin-bottom:28px;
        }
        .login-card .login-logo i{
            font-size:48px;
            color:var(--primary);
            margin-bottom:12px;
            display:block;
        }
        .login-card .login-logo h2{
            font-size:22px;
            font-weight:700;
            color:var(--text-main);
        }
        .login-card .login-logo p{
            color:var(--text-secondary);
            font-size:13px;
            margin-top:6px;
        }
        .login-card .btn-primary{
            width:100%;
            padding:12px;
            font-size:16px;
            justify-content:center;
        }
        .login-hint{
            margin-top:20px;
            padding:12px 16px;
            background:var(--primary-lighter);
            border-radius:var(--radius-btn);
            font-size:12px;
            color:var(--text-secondary);
            text-align:center;
        }
        .login-hint strong{color:var(--primary)}
        .captcha-row{
            display:flex;
            gap:10px;
            align-items:center;
        }
        .captcha-row .input{
            flex:1;
            margin:0;
            text-transform:uppercase;
        }
        .captcha-row img{
            height:40px;
            border-radius:var(--radius-btn);
            cursor:pointer;
            border:1px solid var(--border-color);
        }
        .captcha-row .captcha-refresh{
            color:var(--text-secondary);
            font-size:13px;
            white-space:nowrap;
            cursor:pointer;
        }
    </style>
</head>
<body>
<div class="login-card">
    <div class="login-logo">
        <i class="fas fa-store-alt"></i>
        <h2>校园二手交易平台</h2>
        <p>登录后开启校园二手之旅</p>
    </div>
    <% if (request.getParameter("err") != null) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%=request.getParameter("err")%></div>
    <% } %>
    <form action="<%=request.getContextPath()%>/action/login" method="post">
        <div class="form-item">
            <label><i class="fas fa-phone"></i> 账号（手机号）</label>
            <input class="input" name="phone" placeholder="请输入手机号" required>
        </div>
        <div class="form-item">
            <label><i class="fas fa-lock"></i> 密码</label>
            <input class="input" name="password" type="password" placeholder="请输入密码" required>
        </div>
        <div class="form-item">
            <label><i class="fas fa-shield-alt"></i> 验证码</label>
            <div class="captcha-row">
                <input class="input" name="captcha" placeholder="输入验证码" maxlength="4" required>
                <img id="captchaImg" src="<%=request.getContextPath()%>/captcha" onclick="this.src='<%=request.getContextPath()%>/captcha?t='+Date.now()">
            </div>
        </div>
        <button type="submit" class="btn btn-primary"><i class="fas fa-sign-in-alt"></i> 登录</button>
    </form>
    <div class="login-hint">
        测试账号：手机 <strong>13800000000</strong> / 密码 <strong>123456</strong>（管理员）<br>
        普通用户：<strong>13800000001</strong> ~ <strong>13800000010</strong> / 密码 <strong>123456</strong>
    </div>
</div>
</body>
</html>
