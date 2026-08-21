package com.campus.dao;

import com.campus.model.User;
import com.campus.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    public User findByPhone(String phone) throws SQLException {
        String sql = "SELECT * FROM users WHERE phone=? AND status=1";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, phone);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        }
    }

    public User findById(int id) throws SQLException {
        String sql = "SELECT * FROM users WHERE userId=?";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        }
    }

    public List<User> listAll(String keyword) throws SQLException {
        String sql = "SELECT * FROM users WHERE role=0";
        if (keyword != null && !keyword.isBlank()) sql += " AND (studentId LIKE ? OR realName LIKE ? OR phone LIKE ?)";
        sql += " ORDER BY userId DESC";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            if (keyword != null && !keyword.isBlank()) {
                String k = "%" + keyword.trim() + "%";
                ps.setString(1, k); ps.setString(2, k); ps.setString(3, k);
            }
            ResultSet rs = ps.executeQuery();
            List<User> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    public void updateStatus(int userId, int status) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("UPDATE users SET status=? WHERE userId=?")) {
            ps.setInt(1, status); ps.setInt(2, userId); ps.executeUpdate();
        }
    }

    public void updateVerify(int userId, int verifyStatus) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("UPDATE users SET verifyStatus=? WHERE userId=?")) {
            ps.setInt(1, verifyStatus); ps.setInt(2, userId); ps.executeUpdate();
        }
    }

    public void adjustPoints(Connection c, int userId, int delta) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("UPDATE users SET pointsBalance=pointsBalance+? WHERE userId=?")) {
            ps.setInt(1, delta); ps.setInt(2, userId); ps.executeUpdate();
        }
    }

    public int countAll() throws SQLException {
        try (Connection c = DBUtil.getConn();
             ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM users WHERE role=0")) {
            rs.next(); return rs.getInt(1);
        }
    }

    public void submitVerify(int userId, String studentId, String realName, String cardPhoto) throws SQLException {
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            String sql = "INSERT INTO user_verify_materials(userId,studentId,realName,cardPhoto,status,submitTime) " +
                         "VALUES(?,?,?,?,1,NOW()) " +
                         "ON DUPLICATE KEY UPDATE studentId=VALUES(studentId),realName=VALUES(realName)," +
                         "cardPhoto=VALUES(cardPhoto),status=1,rejectReason=NULL,submitTime=NOW(),auditTime=NULL";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, userId); ps.setString(2, studentId); ps.setString(3, realName); ps.setString(4, cardPhoto);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement("UPDATE users SET verifyStatus=1 WHERE userId=?")) {
                ps.setInt(1, userId); ps.executeUpdate();
            }
            c.commit();
        } catch (SQLException e) {
            throw e;
        }
    }

    public void auditVerify(int verifyId, boolean pass, String reason) throws SQLException {
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            int userId = 0;
            try (PreparedStatement ps = c.prepareStatement("SELECT userId FROM user_verify_materials WHERE verifyId=?")) {
                ps.setInt(1, verifyId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) userId = rs.getInt(1);
            }
            int st = pass ? 2 : 3;
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE user_verify_materials SET status=?,rejectReason=?,auditTime=NOW() WHERE verifyId=?")) {
                ps.setInt(1, st); ps.setString(2, reason); ps.setInt(3, verifyId); ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement("UPDATE users SET verifyStatus=? WHERE userId=?")) {
                ps.setInt(1, st); ps.setInt(2, userId); ps.executeUpdate();
            }
            c.commit();
        }
    }

    public List<String[]> pendingVerify() throws SQLException {
        String sql = "SELECT v.verifyId,u.nickname,v.studentId,v.realName,v.cardPhoto,v.submitTime FROM user_verify_materials v JOIN users u ON v.userId=u.userId WHERE v.status=1 ORDER BY v.submitTime";
        try (Connection c = DBUtil.getConn(); ResultSet rs = c.createStatement().executeQuery(sql)) {
            List<String[]> list = new ArrayList<>();
            while (rs.next()) {
                list.add(new String[]{
                    String.valueOf(rs.getInt(1)), rs.getString(2), rs.getString(3),
                    rs.getString(4), rs.getString(5), rs.getString(6)
                });
            }
            return list;
        }
    }

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("userId"));
        u.setStudentId(rs.getString("studentId"));
        u.setRealName(rs.getString("realName"));
        u.setNickname(rs.getString("nickname"));
        u.setPhone(rs.getString("phone"));
        u.setPassword(rs.getString("password"));
        u.setAvatar(rs.getString("avatar"));
        u.setCreditScore(rs.getInt("creditScore"));
        u.setPointsBalance(rs.getInt("pointsBalance"));
        u.setVerifyStatus(rs.getInt("verifyStatus"));
        u.setRole(rs.getInt("role"));
        u.setStatus(rs.getInt("status"));
        return u;
    }
}
