package com.campus.dao;

import com.campus.model.Activity;
import com.campus.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ActivityDao {

    public List<Activity> listActive() throws SQLException {
        String sql = "SELECT * FROM activities WHERE status=1 AND endTime>=NOW() ORDER BY startTime DESC";
        return query(sql);
    }

    public List<Activity> listAll() throws SQLException {
        return query("SELECT * FROM activities ORDER BY createTime DESC");
    }

    public Activity findById(int id) throws SQLException {
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement("SELECT * FROM activities WHERE activityId=?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        }
    }

    public void create(Activity a) throws SQLException {
        String sql = "INSERT INTO activities(title,coverImage,description,pointsReward,maxParticipants,startTime,endTime,status) VALUES(?,?,?,?,?,?,?,1)";
        try (Connection c = DBUtil.getConn(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getCoverImage());
            ps.setString(3, a.getDescription());
            ps.setInt(4, a.getPointsReward());
            if (a.getMaxParticipants() > 0) ps.setInt(5, a.getMaxParticipants()); else ps.setNull(5, Types.INTEGER);
            ps.setTimestamp(6, a.getStartTime()); ps.setTimestamp(7, a.getEndTime());
            ps.executeUpdate();
        }
    }

    public void updateCoverImage(int id, String coverImage) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("UPDATE activities SET coverImage=? WHERE activityId=?")) {
            ps.setString(1, coverImage); ps.setInt(2, id); ps.executeUpdate();
        }
    }

    public void updateStatus(int id, int status) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("UPDATE activities SET status=? WHERE activityId=?")) {
            ps.setInt(1, status); ps.setInt(2, id); ps.executeUpdate();
        }
    }

    public boolean hasJoined(int userId, int activityId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("SELECT 1 FROM activity_participation WHERE userId=? AND activityId=?")) {
            ps.setInt(1, userId); ps.setInt(2, activityId);
            return ps.executeQuery().next();
        }
    }

    public void join(int userId, int activityId) throws SQLException {
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement("INSERT INTO activity_participation(userId,activityId,status) VALUES(?,?,0)")) {
                ps.setInt(1, userId); ps.setInt(2, activityId); ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement("UPDATE activities SET currentParticipants=currentParticipants+1 WHERE activityId=?")) {
                ps.setInt(1, activityId); ps.executeUpdate();
            }
            c.commit();
        }
    }

    public boolean cancelJoin(int userId, int activityId) throws SQLException {
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement("DELETE FROM activity_participation WHERE userId=? AND activityId=? AND status < 2")) {
                ps.setInt(1, userId); ps.setInt(2, activityId);
                if (ps.executeUpdate() == 0) { c.rollback(); return false; }
            }
            try (PreparedStatement ps = c.prepareStatement("UPDATE activities SET currentParticipants=GREATEST(currentParticipants-1, 0) WHERE activityId=?")) {
                ps.setInt(1, activityId); ps.executeUpdate();
            }
            c.commit();
            return true;
        }
    }

    public boolean complete(int userId, int activityId, int points) throws SQLException {
        PointsDao pd = new PointsDao();
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE activity_participation SET status=2,pointsEarned=?,completeTime=NOW() WHERE userId=? AND activityId=? AND status<2")) {
                ps.setInt(1, points); ps.setInt(2, userId); ps.setInt(3, activityId);
                if (ps.executeUpdate() == 0) { c.rollback(); return false; }
            }
            pd.addIncome(c, userId, points, 3, activityId, "完成活动奖励");
            c.commit();
            return true;
        }
    }

    /** 用户提交完成申请，状态从0(已报名)变为1(待审核)，不发积分 */
    public boolean submitComplete(int userId, int activityId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE activity_participation SET status=1, completeTime=NOW() WHERE userId=? AND activityId=? AND status=0")) {
            ps.setInt(1, userId); ps.setInt(2, activityId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 管理员审核通过，状态从1(待审核)变为2(已完成)，发放积分 */
    public boolean approveParticipation(int participationId, int points) throws SQLException {
        PointsDao pd = new PointsDao();
        try (Connection c = DBUtil.getConn()) {
            c.setAutoCommit(false);
            int userId = 0, activityId = 0;
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT userId, activityId FROM activity_participation WHERE participationId=? AND status=1")) {
                ps.setInt(1, participationId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) { c.rollback(); return false; }
                userId = rs.getInt(1);
                activityId = rs.getInt(2);
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE activity_participation SET status=2, pointsEarned=? WHERE participationId=? AND status=1")) {
                ps.setInt(1, points); ps.setInt(2, participationId);
                if (ps.executeUpdate() == 0) { c.rollback(); return false; }
            }
            pd.addIncome(c, userId, points, 3, activityId, "完成活动奖励(管理员审核通过)");
            c.commit();
            return true;
        }
    }

    /** 管理员驳回，状态从1(待审核)退回0(已报名)，可重新提交 */
    public boolean rejectParticipation(int participationId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE activity_participation SET status=0, completeTime=NULL WHERE participationId=? AND status=1")) {
            ps.setInt(1, participationId);
            return ps.executeUpdate() > 0;
        }
    }

    /** 查询所有待审核的活动参与记录，返回 Object[]: {participationId, userId, nickname, phone, activityId, title, pointsReward, joinTime, completeTime} */
    public List<Object[]> listPending() throws SQLException {
        String sql = "SELECT p.participationId, p.userId, u.nickname, u.phone, p.activityId, a.title, a.pointsReward, p.joinTime, p.completeTime " +
                     "FROM activity_participation p " +
                     "JOIN users u ON p.userId = u.userId " +
                     "JOIN activities a ON p.activityId = a.activityId " +
                     "WHERE p.status = 1 ORDER BY p.completeTime DESC";
        List<Object[]> list = new ArrayList<>();
        try (Connection c = DBUtil.getConn(); ResultSet rs = c.createStatement().executeQuery(sql)) {
            while (rs.next()) {
                list.add(new Object[]{
                    rs.getInt(1), rs.getInt(2), rs.getString(3), rs.getString(4),
                    rs.getInt(5), rs.getString(6), rs.getInt(7), rs.getTimestamp(8), rs.getTimestamp(9)
                });
            }
        }
        return list;
    }

    public int getParticipationStatus(int userId, int activityId) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("SELECT status FROM activity_participation WHERE userId=? AND activityId=?")) {
            ps.setInt(1, userId); ps.setInt(2, activityId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    private List<Activity> query(String sql) throws SQLException {
        try (Connection c = DBUtil.getConn(); ResultSet rs = c.createStatement().executeQuery(sql)) {
            List<Activity> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    private Activity map(ResultSet rs) throws SQLException {
        Activity a = new Activity();
        a.setActivityId(rs.getInt("activityId"));
        a.setTitle(rs.getString("title"));
        a.setDescription(rs.getString("description"));
        try { a.setCoverImage(rs.getString("coverImage")); } catch (SQLException ignored) {}
        a.setPointsReward(rs.getInt("pointsReward"));
        a.setMaxParticipants(rs.getInt("maxParticipants"));
        a.setCurrentParticipants(rs.getInt("currentParticipants"));
        a.setStartTime(rs.getTimestamp("startTime"));
        a.setEndTime(rs.getTimestamp("endTime"));
        a.setStatus(rs.getInt("status"));
        return a;
    }
}
