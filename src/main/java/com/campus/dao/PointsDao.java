package com.campus.dao;

import com.campus.dao.UserDao;
import com.campus.model.PointsLog;
import com.campus.util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class PointsDao {

    public void addIncome(Connection c, int userId, int amount, int source, Integer sourceId, String desc) throws SQLException {
        UserDao ud = new UserDao();
        ud.adjustPoints(c, userId, amount);
        int balance = getBalance(c, userId);
        String sql = "INSERT INTO points_log(userId,type,amount,source,sourceId,description,balanceAfter) VALUES(?,1,?,?,?,?,?)";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId); ps.setInt(2, amount); ps.setInt(3, source);
            if (sourceId != null) ps.setInt(4, sourceId); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, desc); ps.setInt(6, balance); ps.executeUpdate();
        }
    }

    public void addExpense(Connection c, int userId, int amount, int source, Integer sourceId, String desc) throws SQLException {
        UserDao ud = new UserDao();
        ud.adjustPoints(c, userId, -amount);
        int balance = getBalance(c, userId);
        String sql = "INSERT INTO points_log(userId,type,amount,source,sourceId,description,balanceAfter) VALUES(?,2,?,?,?,?,?)";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId); ps.setInt(2, amount); ps.setInt(3, source);
            if (sourceId != null) ps.setInt(4, sourceId); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, desc); ps.setInt(6, balance); ps.executeUpdate();
        }
    }

    public List<PointsLog> listByUser(int userId) throws SQLException {
        String sql = "SELECT * FROM points_log WHERE userId=? ORDER BY createTime DESC LIMIT 50";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            List<PointsLog> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    public List<PointsLog> listAll() throws SQLException {
        String sql = "SELECT p.*,u.studentId FROM points_log p JOIN users u ON p.userId=u.userId ORDER BY p.createTime DESC LIMIT 100";
        try (Connection c = DBUtil.getConn(); ResultSet rs = c.createStatement().executeQuery(sql)) {
            List<PointsLog> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    public int totalIssued() throws SQLException {
        try (Connection c = DBUtil.getConn();
             ResultSet rs = c.createStatement().executeQuery("SELECT IFNULL(SUM(amount),0) FROM points_log WHERE type=1")) {
            rs.next(); return rs.getInt(1);
        }
    }

    public boolean signedToday(int userId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("SELECT 1 FROM sign_in_records WHERE userId=? AND signDate=CURDATE()")) {
            ps.setInt(1, userId); return ps.executeQuery().next();
        }
    }

    public int signIn(int userId) throws SQLException {
        ConfigDao cd = new ConfigDao();
        int base = cd.getInt("sign_base_points", 2);
        int bonus = cd.getInt("sign_streak_bonus", 5);
        try (Connection c = DBUtil.getConn()) {
            if (signedToday(userId)) return 0;
            c.setAutoCommit(false);
            int streak = 1;
            try (PreparedStatement ps = c.prepareStatement("SELECT streakDays FROM sign_in_records WHERE userId=? AND signDate=DATE_SUB(CURDATE(),INTERVAL 1 DAY)")) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) streak = rs.getInt(1) + 1;
            }
            int earned = base;
            if (streak > 0 && streak % 7 == 0) earned += bonus;
            try (PreparedStatement ps = c.prepareStatement("INSERT INTO sign_in_records(userId,signDate,pointsEarned,streakDays) VALUES(?,CURDATE(),?,?)")) {
                ps.setInt(1, userId); ps.setInt(2, earned); ps.setInt(3, streak); ps.executeUpdate();
            }
            addIncome(c, userId, earned, 4, null, "每日签到(连续" + streak + "天)");
            c.commit();
            return earned;
        }
    }

    public int todaySignCount() throws SQLException {
        try (Connection c = DBUtil.getConn();
             ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM sign_in_records WHERE signDate=CURDATE()")) {
            rs.next(); return rs.getInt(1);
        }
    }

    public int getStreak(int userId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps1 = c.prepareStatement("SELECT streakDays FROM sign_in_records WHERE userId=? AND signDate=CURDATE()")) {
            ps1.setInt(1, userId);
            ResultSet rs = ps1.executeQuery();
            if (rs.next()) return rs.getInt(1);
        }
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps2 = c.prepareStatement("SELECT streakDays FROM sign_in_records WHERE userId=? AND signDate=DATE_SUB(CURDATE(),INTERVAL 1 DAY)")) {
            ps2.setInt(1, userId);
            ResultSet rs = ps2.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private int getBalance(Connection c, int userId) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("SELECT pointsBalance FROM users WHERE userId=?")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            rs.next(); return rs.getInt(1);
        }
    }

    private PointsLog map(ResultSet rs) throws SQLException {
        PointsLog p = new PointsLog();
        p.setLogId(rs.getLong("logId"));
        p.setUserId(rs.getInt("userId"));
        p.setType(rs.getInt("type"));
        p.setAmount(rs.getInt("amount"));
        p.setSource(rs.getInt("source"));
        int sid = rs.getInt("sourceId");
        p.setSourceId(rs.wasNull() ? null : sid);
        p.setDescription(rs.getString("description"));
        p.setBalanceAfter(rs.getInt("balanceAfter"));
        p.setCreateTime(rs.getTimestamp("createTime"));
        return p;
    }
}
