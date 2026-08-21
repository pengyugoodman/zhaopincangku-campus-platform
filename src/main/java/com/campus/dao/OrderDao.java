package com.campus.dao;

import com.campus.model.Order;
import com.campus.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class OrderDao {
    private static final AtomicInteger SEQ = new AtomicInteger(0);

    public List<Order> listByBuyer(int buyerId, Integer status) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT o.*,g.title goodsTitle FROM orders o JOIN goods g ON o.goodsId=g.goodsId WHERE o.buyerId=?");
        if (status != null) sb.append(" AND o.status=?");
        sb.append(" ORDER BY o.createTime DESC");
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sb.toString())) {
            ps.setInt(1, buyerId);
            if (status != null) ps.setInt(2, status);
            return mapList(ps.executeQuery());
        }
    }

    public List<Order> listBySeller(int sellerId, Integer status) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT o.*,g.title goodsTitle,ub.nickname buyerName FROM orders o " +
            "JOIN goods g ON o.goodsId=g.goodsId JOIN users ub ON o.buyerId=ub.userId WHERE g.sellerId=?");
        if (status != null) sb.append(" AND o.status=?");
        sb.append(" ORDER BY o.createTime DESC");
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sb.toString())) {
            ps.setInt(1, sellerId);
            if (status != null) ps.setInt(2, status);
            ResultSet rs = ps.executeQuery();
            List<Order> list = new ArrayList<>();
            while (rs.next()) {
                Order o = map(rs);
                o.setGoodsTitle(rs.getString("goodsTitle"));
                o.setBuyerName(rs.getString("buyerName"));
                list.add(o);
            }
            return list;
        }
    }

    public List<Order> listAll(Integer status) throws SQLException {
        String sql = "SELECT o.*,g.title goodsTitle,ub.nickname buyerName,us.nickname sellerName FROM orders o " +
                     "JOIN goods g ON o.goodsId=g.goodsId JOIN users ub ON o.buyerId=ub.userId JOIN users us ON g.sellerId=us.userId";
        if (status != null) sql += " WHERE o.status=?";
        sql += " ORDER BY o.createTime DESC";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            if (status != null) ps.setInt(1, status);
            ResultSet rs = ps.executeQuery();
            List<Order> list = new ArrayList<>();
            while (rs.next()) {
                Order o = map(rs);
                o.setGoodsTitle(rs.getString("goodsTitle"));
                o.setBuyerName(rs.getString("buyerName"));
                o.setSellerName(rs.getString("sellerName"));
                list.add(o);
            }
            return list;
        }
    }

    public int createOrder(Connection c, int buyerId, int goodsId, int points, String remark, String address) throws SQLException {
        String sn = "ORD" + System.currentTimeMillis() + SEQ.incrementAndGet();
        String code = "P" + (100000 + (int) (Math.random() * 899999));
        String sql = "INSERT INTO orders(orderSn,buyerId,goodsId,pointsCost,status,pickupCode,deliveryMethod,address,buyerRemark) VALUES(?,?,?,?,0,?,1,?,?)";
        int orderId;
        try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, sn); ps.setInt(2, buyerId); ps.setInt(3, goodsId);
            ps.setInt(4, points); ps.setString(5, code); ps.setString(6, address); ps.setString(7, remark);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                orderId = keys.getInt(1);
            }
        }
        try (PreparedStatement ps = c.prepareStatement("UPDATE goods SET status=3 WHERE goodsId=?")) {
            ps.setInt(1, goodsId); ps.executeUpdate();
        }
        return orderId;
    }

    public void sellerConfirm(Connection c, int orderId) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("UPDATE orders SET status=1 WHERE orderId=? AND status=0")) {
            ps.setInt(1, orderId); ps.executeUpdate();
        }
    }

    public void sellerConfirm(int orderId, int sellerId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement(
                 "UPDATE orders o JOIN goods g ON o.goodsId=g.goodsId SET o.status=1 WHERE o.orderId=? AND g.sellerId=? AND o.status=0")) {
            ps.setInt(1, orderId); ps.setInt(2, sellerId); ps.executeUpdate();
        }
    }

    public void confirmReceive(int orderId, int buyerId) throws SQLException {
        PointsDao pd = new PointsDao();
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            int sellerId = 0, points = 0;
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT o.pointsCost,g.sellerId FROM orders o JOIN goods g ON o.goodsId=g.goodsId WHERE o.orderId=? AND o.buyerId=? AND o.status=1")) {
                ps.setInt(1, orderId); ps.setInt(2, buyerId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) { c.rollback(); return; }
                points = rs.getInt(1); sellerId = rs.getInt(2);
            }
            try (PreparedStatement ps = c.prepareStatement("UPDATE orders SET status=2,confirmTime=NOW() WHERE orderId=?")) {
                ps.setInt(1, orderId); ps.executeUpdate();
            }
            pd.addIncome(c, sellerId, points, 2, orderId, "交易收入");
            c.commit();
        }
    }

    public void cancel(int orderId) throws SQLException {
        PointsDao pd = new PointsDao();
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            int buyerId = 0, points = 0, goodsId = 0;
            try (PreparedStatement ps = c.prepareStatement("SELECT buyerId,pointsCost,goodsId FROM orders WHERE orderId=? AND status IN (0,1)")) {
                ps.setInt(1, orderId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) { c.rollback(); return; }
                buyerId = rs.getInt(1); points = rs.getInt(2); goodsId = rs.getInt(3);
            }
            try (PreparedStatement ps = c.prepareStatement("UPDATE orders SET status=3,cancelTime=NOW() WHERE orderId=?")) {
                ps.setInt(1, orderId); ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement("UPDATE goods SET status=1 WHERE goodsId=?")) {
                ps.setInt(1, goodsId); ps.executeUpdate();
            }
            pd.addIncome(c, buyerId, points, 2, orderId, "订单取消退还");
            c.commit();
        }
    }

    public int countMonth() throws SQLException {
        try (Connection c = DBUtil.getConn();
             ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM orders WHERE MONTH(createTime)=MONTH(NOW()) AND status=2")) {
            rs.next(); return rs.getInt(1);
        }
    }

    private List<Order> mapList(ResultSet rs) throws SQLException {
        List<Order> list = new ArrayList<>();
        while (rs.next()) list.add(map(rs));
        return list;
    }

    private Order map(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("orderId"));
        o.setOrderSn(rs.getString("orderSn"));
        o.setBuyerId(rs.getInt("buyerId"));
        o.setGoodsId(rs.getInt("goodsId"));
        o.setPointsCost(rs.getInt("pointsCost"));
        o.setStatus(rs.getInt("status"));
        o.setPickupCode(rs.getString("pickupCode"));
        o.setDeliveryMethod(rs.getInt("deliveryMethod"));
        o.setAddress(rs.getString("address"));
        o.setBuyerRemark(rs.getString("buyerRemark"));
        o.setCreateTime(rs.getTimestamp("createTime"));
        o.setConfirmTime(rs.getTimestamp("confirmTime"));
        try { o.setGoodsTitle(rs.getString("goodsTitle")); } catch (SQLException ignored) {}
        try { o.setBuyerName(rs.getString("buyerName")); } catch (SQLException ignored) {}
        return o;
    }
}
