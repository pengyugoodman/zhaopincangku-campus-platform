package com.campus.dao;

import com.campus.model.Goods;
import com.campus.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDao {

    public List<Goods> listCart(int userId) throws SQLException {
        String sql = "SELECT g.*,c.categoryName FROM cart_items ci JOIN goods g ON ci.goodsId=g.goodsId JOIN categories c ON g.categoryId=c.categoryId WHERE ci.userId=? AND g.status=1";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            List<Goods> list = new ArrayList<>();
            while (rs.next()) {
                Goods g = new Goods();
                g.setGoodsId(rs.getInt("goodsId"));
                g.setTitle(rs.getString("title"));
                g.setImages(rs.getString("images"));
                g.setPricePoints(rs.getInt("pricePoints"));
                g.setSellerId(rs.getInt("sellerId"));
                list.add(g);
            }
            return list;
        }
    }

    public void add(int userId, int goodsId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("INSERT IGNORE INTO cart_items(userId,goodsId) VALUES(?,?)")) {
            ps.setInt(1, userId); ps.setInt(2, goodsId); ps.executeUpdate();
        }
    }

    public void remove(int userId, int goodsId) throws SQLException {
        try (Connection c = DBUtil.getConn()) {
            remove(c, userId, goodsId);
        }
    }

    public void remove(Connection c, int userId, int goodsId) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("DELETE FROM cart_items WHERE userId=? AND goodsId=?")) {
            ps.setInt(1, userId); ps.setInt(2, goodsId); ps.executeUpdate();
        }
    }

    public void toggleFavorite(int userId, int goodsId) throws SQLException {
        try (Connection c = DBUtil.getConn()) {
            try (PreparedStatement chk = c.prepareStatement("SELECT 1 FROM favorites WHERE userId=? AND goodsId=?")) {
                chk.setInt(1, userId); chk.setInt(2, goodsId);
                if (chk.executeQuery().next()) {
                    try (PreparedStatement del = c.prepareStatement("DELETE FROM favorites WHERE userId=? AND goodsId=?")) {
                        del.setInt(1, userId); del.setInt(2, goodsId); del.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ins = c.prepareStatement("INSERT INTO favorites(userId,goodsId) VALUES(?,?)")) {
                        ins.setInt(1, userId); ins.setInt(2, goodsId); ins.executeUpdate();
                    }
                }
            }
        }
    }

    public boolean isFavorite(int userId, int goodsId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("SELECT 1 FROM favorites WHERE userId=? AND goodsId=?")) {
            ps.setInt(1, userId); ps.setInt(2, goodsId); return ps.executeQuery().next();
        }
    }

    public List<Goods> listFavorites(int userId) throws SQLException {
        String sql = "SELECT g.* FROM favorites f JOIN goods g ON f.goodsId=g.goodsId WHERE f.userId=? ORDER BY f.createTime DESC";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            List<Goods> list = new ArrayList<>();
            while (rs.next()) {
                Goods g = new Goods();
                g.setGoodsId(rs.getInt("goodsId"));
                g.setTitle(rs.getString("title"));
                g.setImages(rs.getString("images"));
                g.setPricePoints(rs.getInt("pricePoints"));
                g.setStatus(rs.getInt("status"));
                list.add(g);
            }
            return list;
        }
    }
}
