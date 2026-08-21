package com.campus.dao;

import com.campus.util.DBUtil;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class ConfigDao {

    public int getInt(String key, int def) throws SQLException {
        String v = get(key);
        return v == null ? def : Integer.parseInt(v);
    }

    public String get(String key) throws SQLException {
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement("SELECT configValue FROM system_config WHERE configKey=?")) {
            ps.setString(1, key);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getString(1) : null;
        }
    }

    public Map<String, String> all() throws SQLException {
        Map<String, String> m = new HashMap<>();
        try (Connection c = DBUtil.getConn(); ResultSet rs = c.createStatement().executeQuery("SELECT configKey,configValue FROM system_config")) {
            while (rs.next()) m.put(rs.getString(1), rs.getString(2));
        }
        return m;
    }

    public void save(String key, String value) throws SQLException {
        String sql = "INSERT INTO system_config(configKey,configValue) VALUES(?,?) " +
                     "ON DUPLICATE KEY UPDATE configValue=VALUES(configValue)";
        try (Connection c = DBUtil.getConn();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, key); ps.setString(2, value); ps.executeUpdate();
        }
    }
}
