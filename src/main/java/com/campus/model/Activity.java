package com.campus.model;

import java.sql.Timestamp;

public class Activity {
    private int activityId, pointsReward, maxParticipants, currentParticipants, status;
    private String title, description, coverImage;
    private Timestamp startTime, endTime;

    public int getActivityId() { return activityId; }
    public void setActivityId(int activityId) { this.activityId = activityId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }
    public int getPointsReward() { return pointsReward; }
    public void setPointsReward(int pointsReward) { this.pointsReward = pointsReward; }
    public int getMaxParticipants() { return maxParticipants; }
    public void setMaxParticipants(int maxParticipants) { this.maxParticipants = maxParticipants; }
    public int getCurrentParticipants() { return currentParticipants; }
    public void setCurrentParticipants(int currentParticipants) { this.currentParticipants = currentParticipants; }
    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }
    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public String getStatusText() {
        return switch (status) {
            case 0 -> "草稿";
            case 1 -> "进行中";
            case 2 -> "已结束";
            case 3 -> "已取消";
            default -> "未知";
        };
    }

    public String getCover() {
        return coverImage == null || coverImage.isBlank()
                ? "assets/placeholder.svg" : coverImage.trim();
    }
}
