package com.campus.servlet;

import com.campus.dao.*;
import com.campus.model.Activity;
import com.campus.model.Goods;
import com.campus.model.User;
import com.campus.util.ImageUtil;
import com.campus.util.RedirectUtil;
import com.campus.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;

@WebServlet("/action/*")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 20 * 1024 * 1024, fileSizeThreshold = 1024 * 1024)
public class ActionServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final GoodsDao goodsDao = new GoodsDao();
    private final ActivityDao activityDao = new ActivityDao();
    private final OrderDao orderDao = new OrderDao();
    private final PointsDao pointsDao = new PointsDao();
    private final CartDao cartDao = new CartDao();
    private final ConfigDao configDao = new ConfigDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo() == null ? "" : req.getPathInfo().substring(1);
        String ctx = req.getContextPath();
        try {
            if ("removeCart".equals(action)) {
                cartDao.remove(SessionUtil.getUser(req).getUserId(), Integer.parseInt(req.getParameter("goodsId")));
                RedirectUtil.send(resp, ctx, "/client/cart.jsp");
                return;
            }
            if ("offShelf".equals(action) || "onShelf".equals(action)) {
                int status = "offShelf".equals(action) ? 2 : 1;
                goodsDao.updateStatus(Integer.parseInt(req.getParameter("id")), status);
                String redirect = req.getParameter("redirect");
                RedirectUtil.send(resp, ctx, redirect != null ? redirect : "/client/my-goods.jsp");
                return;
            }
            if ("banUser".equals(action)) {
                userDao.updateStatus(Integer.parseInt(req.getParameter("id")), 0);
                RedirectUtil.send(resp, ctx, "/admin/users.jsp");
                return;
            }
            if ("unbanUser".equals(action)) {
                userDao.updateStatus(Integer.parseInt(req.getParameter("id")), 1);
                RedirectUtil.send(resp, ctx, "/admin/users.jsp");
                return;
            }
            if ("logout".equals(action)) {
                SessionUtil.logout(req);
                RedirectUtil.send(resp, ctx, "/login.jsp");
                return;
            }
        } catch (Exception e) {
            handleError(resp, ctx, e);
            return;
        }
        RedirectUtil.send(resp, ctx, "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo() == null ? "" : req.getPathInfo().substring(1);
        String ctx = req.getContextPath();
        try {
            switch (action) {
                case "login" -> handleLogin(req, resp, ctx);
                case "logout" -> { SessionUtil.logout(req); RedirectUtil.send(resp, ctx, "/login.jsp"); }
                case "signin" -> {
                    pointsDao.signIn(SessionUtil.getUser(req).getUserId());
                    SessionUtil.getFreshUser(req);
                    RedirectUtil.withMsg(resp, ctx, "/client/home.jsp", "签到成功");
                }
                case "joinActivity" -> {
                    int activityId = Integer.parseInt(req.getParameter("id"));
                    Activity act = activityDao.findById(activityId);
                    if (act == null) { RedirectUtil.withErr(resp, ctx, "/client/activities.jsp", "活动不存在"); break; }
                    Timestamp now = new Timestamp(System.currentTimeMillis());
                    if (act.getStartTime() != null && act.getStartTime().after(now)) {
                        RedirectUtil.withErr(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "活动尚未开始，暂不可报名");
                        break;
                    }
                    if (act.getEndTime() != null && act.getEndTime().before(now)) {
                        RedirectUtil.withErr(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "活动已结束");
                        break;
                    }
                    if (activityDao.hasJoined(SessionUtil.getUser(req).getUserId(), activityId)) {
                        RedirectUtil.withErr(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "您已经报名了该活动");
                        break;
                    }
                    // 人数上限检查（maxParticipants<=0 表示不限人数）
                    if (act.getMaxParticipants() > 0 && act.getCurrentParticipants() >= act.getMaxParticipants()) {
                        RedirectUtil.withErr(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "活动报名人数已满");
                        break;
                    }
                    activityDao.join(SessionUtil.getUser(req).getUserId(), activityId);
                    RedirectUtil.withMsg(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "报名成功");
                }
                case "cancelActivity" -> {
                    int activityId = Integer.parseInt(req.getParameter("id"));
                    if (activityDao.cancelJoin(SessionUtil.getUser(req).getUserId(), activityId)) {
                        RedirectUtil.withMsg(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "已取消报名");
                    } else {
                        RedirectUtil.withErr(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "取消失败，活动可能已完成");
                    }
                }
                case "completeActivity" -> handleCompleteActivity(req, resp, ctx);
                case "publish" -> handlePublish(req, resp, ctx);
                case "addCart" -> {
                    cartDao.add(SessionUtil.getUser(req).getUserId(), Integer.parseInt(req.getParameter("goodsId")));
                    RedirectUtil.send(resp, ctx, "/client/cart.jsp");
                }
                case "removeCart" -> {
                    cartDao.remove(SessionUtil.getUser(req).getUserId(), Integer.parseInt(req.getParameter("goodsId")));
                    RedirectUtil.send(resp, ctx, "/client/cart.jsp");
                }
                case "checkout" -> handleCheckout(req, resp, ctx);
                case "buyNow" -> handleBuyNow(req, resp, ctx);
                case "sellerConfirm" -> {
                    orderDao.sellerConfirm(Integer.parseInt(req.getParameter("orderId")), SessionUtil.getUser(req).getUserId());
                    RedirectUtil.withMsg(resp, ctx, "/client/seller-orders.jsp", "已确认，等待买家收货");
                }
                case "receive" -> {
                    orderDao.confirmReceive(Integer.parseInt(req.getParameter("orderId")), SessionUtil.getUser(req).getUserId());
                    SessionUtil.getFreshUser(req);
                    RedirectUtil.withMsg(resp, ctx, "/client/orders.jsp", "交易完成，积分已转给卖家");
                }
                case "cancelOrder" -> {
                    orderDao.cancel(Integer.parseInt(req.getParameter("orderId")));
                    SessionUtil.getFreshUser(req);
                    RedirectUtil.withMsg(resp, ctx, "/client/orders.jsp", "订单已取消，积分已退还");
                }
                case "verify" -> handleVerify(req, resp, ctx);
                case "favorite" -> {
                    cartDao.toggleFavorite(SessionUtil.getUser(req).getUserId(), Integer.parseInt(req.getParameter("goodsId")));
                    RedirectUtil.send(resp, ctx, "/client/goods-detail.jsp?id=" + req.getParameter("goodsId"));
                }
                case "offShelf" -> { goodsDao.updateStatus(Integer.parseInt(req.getParameter("id")), 2); RedirectUtil.send(resp, ctx, "/client/my-goods.jsp"); }
                case "onShelf" -> { goodsDao.updateStatus(Integer.parseInt(req.getParameter("id")), 1); RedirectUtil.send(resp, ctx, "/client/my-goods.jsp"); }
                case "auditGoods" -> handleAuditGoods(req, resp, ctx);
                case "updateGoodsImages" -> handleUpdateGoodsImages(req, resp, ctx);
                case "updateActivityCover" -> handleUpdateActivityCover(req, resp, ctx);
                case "auditUser" -> { userDao.auditVerify(Integer.parseInt(req.getParameter("id")), "pass".equals(req.getParameter("result")), req.getParameter("remark")); RedirectUtil.send(resp, ctx, "/admin/users.jsp"); }
                case "banUser" -> { userDao.updateStatus(Integer.parseInt(req.getParameter("id")), 0); RedirectUtil.send(resp, ctx, "/admin/users.jsp"); }
                case "unbanUser" -> { userDao.updateStatus(Integer.parseInt(req.getParameter("id")), 1); RedirectUtil.send(resp, ctx, "/admin/users.jsp"); }
                case "adjustPoints" -> handleAdjustPoints(req, resp, ctx);
                case "createActivity" -> handleCreateActivity(req, resp, ctx);
                case "toggleActivity" -> { activityDao.updateStatus(Integer.parseInt(req.getParameter("id")), Integer.parseInt(req.getParameter("status"))); RedirectUtil.send(resp, ctx, "/admin/activities.jsp"); }
                case "approveActivity" -> {
                    int pid = Integer.parseInt(req.getParameter("id"));
                    int points = Integer.parseInt(req.getParameter("points"));
                    activityDao.approveParticipation(pid, points);
                    RedirectUtil.withMsg(resp, ctx, "/admin/activities.jsp", "已审核通过，积分已发放");
                }
                case "rejectActivity" -> {
                    int pid = Integer.parseInt(req.getParameter("id"));
                    activityDao.rejectParticipation(pid);
                    RedirectUtil.withMsg(resp, ctx, "/admin/activities.jsp", "已驳回，用户可重新提交");
                }
                case "saveConfig" -> { for (String k : new String[]{"sign_base_points","sign_streak_bonus","publish_reward_points","publish_daily_limit","order_cancel_hours"}) configDao.save(k, req.getParameter(k)); RedirectUtil.withMsg(resp, ctx, "/admin/config.jsp", "保存成功"); }
                case "forceCancel" -> { orderDao.cancel(Integer.parseInt(req.getParameter("orderId"))); RedirectUtil.send(resp, ctx, "/admin/orders.jsp"); }
                case "forceComplete" -> { orderDao.confirmReceive(Integer.parseInt(req.getParameter("orderId")), Integer.parseInt(req.getParameter("buyerId"))); RedirectUtil.send(resp, ctx, "/admin/orders.jsp"); }
                default -> RedirectUtil.send(resp, ctx, "/login.jsp");
            }
        } catch (Exception e) {
            handleError(resp, ctx, e);
        }
    }

    private void handleCompleteActivity(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        int activityId = Integer.parseInt(req.getParameter("id"));
        boolean ok = activityDao.submitComplete(SessionUtil.getUser(req).getUserId(), activityId);
        if (ok) {
            RedirectUtil.withMsg(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "已提交完成申请，等待管理员审核");
        } else {
            RedirectUtil.withErr(resp, ctx, "/client/activity-detail.jsp?id=" + activityId, "请先参与活动");
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        // 验证码校验
        String sessionCaptcha = (String) req.getSession().getAttribute("captcha");
        String inputCaptcha = req.getParameter("captcha");
        req.getSession().removeAttribute("captcha"); // 一次性验证码
        if (sessionCaptcha == null || inputCaptcha == null || !sessionCaptcha.equalsIgnoreCase(inputCaptcha.trim())) {
            RedirectUtil.withErr(resp, ctx, "/login.jsp", "验证码错误");
            return;
        }
        String phone = req.getParameter("phone");
        String password = req.getParameter("password");
        User u = userDao.findByPhone(phone);
        if (u == null) { RedirectUtil.withErr(resp, ctx, "/login.jsp", "用户不存在"); return; }
        if (password == null || !password.equals(u.getPassword())) {
            RedirectUtil.withErr(resp, ctx, "/login.jsp", "密码错误"); return;
        }
        SessionUtil.setUser(req, u);
        RedirectUtil.send(resp, ctx, u.getRole() == 1 ? "/admin/index.jsp" : "/client/home.jsp");
    }

    private void handlePublish(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        User u = SessionUtil.getUser(req);
        if (u.getVerifyStatus() != 2) { RedirectUtil.withErr(resp, ctx, "/client/publish.jsp", "请先完成认证"); return; }
        Goods g = new Goods();
        g.setSellerId(u.getUserId());
        g.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
        g.setTitle(req.getParameter("title"));
        g.setDescription(req.getParameter("description"));
        g.setPricePoints(Integer.parseInt(req.getParameter("pricePoints")));
        g.setConditionLevel(Integer.parseInt(req.getParameter("conditionLevel")));
        String imageUrl = saveImage(req, "imageFile", "uploads/goods");
        if (imageUrl == null) imageUrl = req.getParameter("imageUrl");
        if (imageUrl == null || imageUrl.isBlank()) { RedirectUtil.withErr(resp, ctx, "/client/publish.jsp", "请上传商品图片或填写图片链接"); return; }
        g.setImages(ImageUtil.toImagesJson(imageUrl));
        goodsDao.publish(g);
        RedirectUtil.withMsg(resp, ctx, "/client/my-goods.jsp", "已提交审核");
    }

    private void handlePublishReward(int goodsId) throws Exception {
        Goods g = goodsDao.findById(goodsId);
        if (g == null) return;
        int reward = configDao.getInt("publish_reward_points", 10);
        try (Connection c = com.campus.util.DBUtil.getConn()) {
            c.setAutoCommit(false);
            pointsDao.addIncome(c, g.getSellerId(), reward, 1, goodsId, "发布商品奖励");
            c.commit();
        }
    }

    private void handleCheckout(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        User u = SessionUtil.getFreshUser(req);
        if (u.getVerifyStatus() != 2) { RedirectUtil.withErr(resp, ctx, "/client/cart.jsp", "未认证无法交易"); return; }
        String[] ids = req.getParameterValues("goodsId");
        if (ids == null || ids.length == 0) { RedirectUtil.withErr(resp, ctx, "/client/cart.jsp", "请选择商品"); return; }
        String remark = req.getParameter("remark");
        String address = req.getParameter("address");
        try (Connection c = com.campus.util.DBUtil.getConn()) {
            c.setAutoCommit(false);
            int total = 0;
            for (String id : ids) {
                Goods g = findGoodsForOrder(c, Integer.parseInt(id));
                if (g != null && g.getStatus() == 1 && g.getSellerId() != u.getUserId()) total += g.getPricePoints();
            }
            if (total == 0) {
                c.rollback();
                RedirectUtil.withErr(resp, ctx, "/client/cart.jsp", "商品已下架或不存在");
                return;
            }
            if (total > u.getPointsBalance()) {
                c.rollback();
                RedirectUtil.withErr(resp, ctx, "/client/cart.jsp", "积分不足，请先参加活动赚积分");
                return;
            }
            int ordered = 0;
            for (String id : ids) {
                Goods g = findGoodsForOrder(c, Integer.parseInt(id));
                if (g == null || g.getStatus() != 1 || g.getSellerId() == u.getUserId()) continue;
                pointsDao.addExpense(c, u.getUserId(), g.getPricePoints(), 2, g.getGoodsId(), "购买 " + g.getTitle());
                int orderId = orderDao.createOrder(c, u.getUserId(), g.getGoodsId(), g.getPricePoints(), remark, address);
                orderDao.sellerConfirm(c, orderId);
                cartDao.remove(c, u.getUserId(), g.getGoodsId());
                ordered++;
            }
            if (ordered == 0) {
                c.rollback();
                RedirectUtil.withErr(resp, ctx, "/client/cart.jsp", "无法购买自己的商品");
                return;
            }
            c.commit();
            SessionUtil.getFreshUser(req);
        }
        RedirectUtil.withMsg(resp, ctx, "/client/orders.jsp", "下单成功，请凭取货码面交后确认收货");
    }

    private void handleBuyNow(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        User u = SessionUtil.getFreshUser(req);
        if (u.getVerifyStatus() != 2) { RedirectUtil.withErr(resp, ctx, "/client/goods-detail.jsp?id=" + req.getParameter("goodsId"), "请先完成认证"); return; }
        int goodsId = Integer.parseInt(req.getParameter("goodsId"));
        String remark = req.getParameter("remark");
        String address = req.getParameter("address");
        try (Connection c = com.campus.util.DBUtil.getConn()) {
            c.setAutoCommit(false);
            Goods g = findGoodsForOrder(c, goodsId);
            if (g == null || g.getStatus() != 1) {
                c.rollback();
                RedirectUtil.withErr(resp, ctx, "/client/home.jsp", "商品已下架");
                return;
            }
            if (g.getSellerId() == u.getUserId()) {
                c.rollback();
                RedirectUtil.withErr(resp, ctx, "/client/goods-detail.jsp?id=" + goodsId, "不能购买自己的商品");
                return;
            }
            if (g.getPricePoints() > u.getPointsBalance()) {
                c.rollback();
                RedirectUtil.withErr(resp, ctx, "/client/goods-detail.jsp?id=" + goodsId, "积分不足");
                return;
            }
            pointsDao.addExpense(c, u.getUserId(), g.getPricePoints(), 2, goodsId, "购买 " + g.getTitle());
            int orderId = orderDao.createOrder(c, u.getUserId(), goodsId, g.getPricePoints(), remark, address);
            orderDao.sellerConfirm(c, orderId);
            cartDao.remove(c, u.getUserId(), goodsId);
            c.commit();
            SessionUtil.getFreshUser(req);
        }
        RedirectUtil.withMsg(resp, ctx, "/client/orders.jsp", "下单成功，请凭取货码面交后确认收货");
    }

    private Goods findGoodsForOrder(Connection c, int goodsId) throws SQLException {
        try (var ps = c.prepareStatement("SELECT goodsId,sellerId,title,pricePoints,status FROM goods WHERE goodsId=?")) {
            ps.setInt(1, goodsId);
            var rs = ps.executeQuery();
            if (!rs.next()) return null;
            Goods g = new Goods();
            g.setGoodsId(rs.getInt("goodsId"));
            g.setSellerId(rs.getInt("sellerId"));
            g.setTitle(rs.getString("title"));
            g.setPricePoints(rs.getInt("pricePoints"));
            g.setStatus(rs.getInt("status"));
            return g;
        }
    }

    private void handleVerify(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        User u = SessionUtil.getUser(req);
        userDao.submitVerify(u.getUserId(), req.getParameter("studentId"), req.getParameter("realName"), req.getParameter("cardPhoto"));
        u.setVerifyStatus(1);
        SessionUtil.setUser(req, u);
        RedirectUtil.withMsg(resp, ctx, "/client/profile.jsp", "已提交认证");
    }

    private void handleAdjustPoints(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        int userId = Integer.parseInt(req.getParameter("userId"));
        int amount = Integer.parseInt(req.getParameter("amount"));
        String reason = req.getParameter("reason");
        try (Connection c = com.campus.util.DBUtil.getConn()) {
            c.setAutoCommit(false);
            if (amount >= 0) pointsDao.addIncome(c, userId, amount, 7, null, reason);
            else pointsDao.addExpense(c, userId, -amount, 7, null, reason);
            c.commit();
        }
        RedirectUtil.withMsg(resp, ctx, "/admin/users.jsp", "调整成功");
    }

    private void handleCreateActivity(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        Activity a = new Activity();
        a.setTitle(req.getParameter("title"));
        String cover = saveImage(req, "coverFile", "uploads/activities");
        if (cover == null) cover = req.getParameter("coverImage");
        if (cover == null || cover.isBlank()) { RedirectUtil.withErr(resp, ctx, "/admin/activities.jsp", "请上传活动封面或填写封面链接"); return; }
        a.setCoverImage(cover);
        a.setDescription(req.getParameter("description"));
        a.setPointsReward(Integer.parseInt(req.getParameter("pointsReward")));
        String max = req.getParameter("maxParticipants");
        a.setMaxParticipants(max == null || max.isBlank() ? 0 : Integer.parseInt(max));
        Timestamp startTime = parseDateTimeLocal(req.getParameter("startTime"));
        Timestamp endTime = parseDateTimeLocal(req.getParameter("endTime"));
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (!startTime.after(now)) {
            RedirectUtil.withErr(resp, ctx, "/admin/activities.jsp", "活动开始时间不能早于当前时间");
            return;
        }
        if (!endTime.after(startTime)) {
            RedirectUtil.withErr(resp, ctx, "/admin/activities.jsp", "活动结束时间必须晚于开始时间");
            return;
        }
        a.setStartTime(startTime);
        a.setEndTime(endTime);
        activityDao.create(a);
        RedirectUtil.withMsg(resp, ctx, "/admin/activities.jsp", "创建成功");
    }

    private void handleAuditGoods(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String imageUrl = saveImage(req, "imageFile", "uploads/goods");
        if (imageUrl == null) imageUrl = req.getParameter("imageUrl");
        if (imageUrl != null && !imageUrl.isBlank()) goodsDao.updateImages(id, imageUrl);
        boolean pass = "pass".equals(req.getParameter("result"));
        goodsDao.audit(id, pass, req.getParameter("remark"));
        if (pass) handlePublishReward(id);
        RedirectUtil.withMsg(resp, ctx, goodsAdminUrl(req.getParameter("tab")), pass ? "审核通过" : "已驳回");
    }

    private void handleUpdateGoodsImages(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String imageUrl = saveImage(req, "imageFile", "uploads/goods");
        if (imageUrl == null) imageUrl = req.getParameter("imageUrl");
        if (imageUrl == null || imageUrl.isBlank()) { RedirectUtil.withErr(resp, ctx, goodsAdminUrl(req.getParameter("tab")), "请上传图片或填写图片链接"); return; }
        goodsDao.updateImages(id, imageUrl);
        RedirectUtil.withMsg(resp, ctx, goodsAdminUrl(req.getParameter("tab")), "图片已更新");
    }

    private void handleUpdateActivityCover(HttpServletRequest req, HttpServletResponse resp, String ctx) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String cover = saveImage(req, "coverFile", "uploads/activities");
        if (cover == null) cover = req.getParameter("coverImage");
        if (cover == null || cover.isBlank()) { RedirectUtil.withErr(resp, ctx, "/admin/activities.jsp", "请上传封面或填写封面链接"); return; }
        activityDao.updateCoverImage(id, cover);
        RedirectUtil.withMsg(resp, ctx, "/admin/activities.jsp", "封面已更新");
    }

    private String saveImage(HttpServletRequest req, String fieldName, String subDir) throws Exception {
        String realRoot = req.getServletContext().getRealPath("/");
        return ImageUtil.saveUpload(req.getPart(fieldName), realRoot, subDir);
    }

    private String goodsAdminUrl(String tab) {
        return tab == null || tab.isBlank() ? "/admin/goods.jsp" : "/admin/goods.jsp?tab=" + tab;
    }

    /** 解析 datetime-local 控件提交的值（YYYY-MM-DDTHH:MM 或 YYYY-MM-DDTHH:MM:SS），返回 Timestamp。 */
    private Timestamp parseDateTimeLocal(String value) {
        if (value == null || value.isBlank()) throw new IllegalArgumentException("时间不能为空");
        String s = value.replace("T", " ");
        // 补齐秒位：YYYY-MM-DD HH:MM -> YYYY-MM-DD HH:MM:00
        if (s.length() == 16) s += ":00";
        return Timestamp.valueOf(s);
    }

    private void handleError(HttpServletResponse resp, String ctx, Exception e) throws IOException {
        e.printStackTrace();
        RedirectUtil.withErr(resp, ctx, "/login.jsp", e.getMessage() != null ? e.getMessage() : "操作失败");
    }
}
