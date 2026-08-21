package com.campus.model;

import java.sql.Timestamp;

public class PointsLog {
    private long logId;
    private int userId, type, amount, source, balanceAfter;
    private Integer sourceId;
    private String description;
    private Timestamp createTime;

    public long getLogId() { return logId; }
    public void setLogId(long logId) { this.logId = logId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getType() { return type; }
    public void setType(int type) { this.type = type; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    public int getSource() { return source; }
    public void setSource(int source) { this.source = source; }
    public Integer getSourceId() { return sourceId; }
    public void setSourceId(Integer sourceId) { this.sourceId = sourceId; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getBalanceAfter() { return balanceAfter; }
    public void setBalanceAfter(int balanceAfter) { this.balanceAfter = balanceAfter; }
    public Timestamp getCreateTime() { return createTime; }
    public void setCreateTime(Timestamp createTime) { this.createTime = createTime; }

    public String getSourceText() {
        return switch (source) {
            case 1 -> "发布商品";
            case 2 -> "交易";
            case 3 -> "公益活动";
            case 4 -> "连续登录";
            case 5 -> "邀请好友";
            case 6 -> "兑换商品";
            case 7 -> "管理员调整";
            default -> "其他";
        };
    }
}
