package com.campus.dao;

import com.campus.model.Goods;
import com.campus.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GoodsDao {

    public List<Goods> listOnSale(Integer categoryId, String keyword) throws SQLException {
        StringBuilder sb = new StringBuilder(
            "SELECT g.*,c.categoryName,u.nickname sellerName FROM goods g " +
            "JOIN categories c ON g.categoryId=c.categoryId " +
            "JOIN users u ON g.sellerId=u.userId WHERE g.status=1");
        if (categoryId != null && categoryId > 0) sb.append(" AND g.categoryId=?");
        if (keyword != null && !keyword.isBlank()) sb.append(" AND g.title LIKE ?");
        sb.append(" ORDER BY g.createTime DESC");
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sb.toString())) {
            int i = 1;
            if (categoryId != null && categoryId > 0) ps.setInt(i++, categoryId);
            if (keyword != null && !keyword.isBlank()) ps.setString(i, "%" + keyword.trim() + "%");
            ResultSet rs = ps.executeQuery();
            List<Goods> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    public Goods findById(int id) throws SQLException {
        String sql = "SELECT g.*,c.categoryName,u.nickname sellerName FROM goods g " +
                     "JOIN categories c ON g.categoryId=c.categoryId JOIN users u ON g.sellerId=u.userId WHERE g.goodsId=?";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Goods g = map(rs);
                try (PreparedStatement up = c.prepareStatement("UPDATE goods SET viewCount=viewCount+1 WHERE goodsId=?")) {
                    up.setInt(1, id); up.executeUpdate();
                }
                return g;
            }
            return null;
        }
    }

    public List<Goods> listBySeller(int sellerId) throws SQLException {
        String sql = "SELECT g.*,c.categoryName FROM goods g JOIN categories c ON g.categoryId=c.categoryId WHERE sellerId=? ORDER BY createTime DESC";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            List<Goods> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    public List<Goods> listByStatus(int status) throws SQLException {
        String sql = "SELECT g.*,c.categoryName,u.nickname sellerName FROM goods g JOIN categories c ON g.categoryId=c.categoryId JOIN users u ON g.sellerId=u.userId WHERE g.status=? ORDER BY g.createTime DESC";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, status);
            ResultSet rs = ps.executeQuery();
            List<Goods> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    public void publish(Goods g) throws SQLException {
        String sql = "INSERT INTO goods(sellerId,categoryId,title,description,images,conditionLevel,pricePoints,status) VALUES(?,?,?,?,?,?,?,0)";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, g.getSellerId()); ps.setInt(2, g.getCategoryId());
            ps.setString(3, g.getTitle()); ps.setString(4, g.getDescription());
            ps.setString(5, g.getImages()); ps.setInt(6, g.getConditionLevel());
            ps.setInt(7, g.getPricePoints()); ps.executeUpdate();
        }
    }

    public void audit(int goodsId, boolean pass, String remark) throws SQLException {
        String sql = pass ? "UPDATE goods SET status=1,onTime=NOW(),auditRemark=NULL WHERE goodsId=?"
                          : "UPDATE goods SET status=2,auditRemark=? WHERE goodsId=?";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            if (pass) ps.setInt(1, goodsId);
            else { ps.setString(1, remark); ps.setInt(2, goodsId); }
            ps.executeUpdate();
        }
    }

    public void updateImages(int goodsId, String imageUrl) throws SQLException {
        String json = com.campus.util.ImageUtil.toImagesJson(imageUrl);
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("UPDATE goods SET images=? WHERE goodsId=?")) {
            ps.setString(1, json); ps.setInt(2, goodsId); ps.executeUpdate();
        }
    }

    public void updateStatus(int goodsId, int status) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("UPDATE goods SET status=? WHERE goodsId=?")) {
            ps.setInt(1, status); ps.setInt(2, goodsId); ps.executeUpdate();
        }
    }

    public int countToday() throws SQLException {
        try (Connection c = DBUtil.getConn();
             ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM goods WHERE DATE(createTime)=CURDATE()")) {
            rs.next(); return rs.getInt(1);
        }
    }

    public List<String[]> categories() throws SQLException {
        try (Connection c = DBUtil.getConn(); ResultSet rs = c.createStatement().executeQuery("SELECT categoryId,categoryName FROM categories ORDER BY sortOrder")) {
            List<String[]> list = new ArrayList<>();
            while (rs.next()) list.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2)});
            return list;
        }
    }

    private Goods map(ResultSet rs) throws SQLException {
        Goods g = new Goods();
        g.setGoodsId(rs.getInt("goodsId"));
        g.setSellerId(rs.getInt("sellerId"));
        g.setCategoryId(rs.getInt("categoryId"));
        g.setTitle(rs.getString("title"));
        g.setDescription(rs.getString("description"));
        g.setImages(rs.getString("images"));
        g.setConditionLevel(rs.getInt("conditionLevel"));
        try { g.setWechat(rs.getString("wechat")); } catch (SQLException ignored) {}
        g.setPricePoints(rs.getInt("pricePoints"));
        g.setStatus(rs.getInt("status"));
        g.setAuditRemark(rs.getString("auditRemark"));
        g.setViewCount(rs.getInt("viewCount"));
        g.setCreateTime(rs.getTimestamp("createTime"));
        try { g.setCategoryName(rs.getString("categoryName")); } catch (SQLException ignored) {}
        try { g.setSellerName(rs.getString("sellerName")); } catch (SQLException ignored) {}
        return g;
    }
}
