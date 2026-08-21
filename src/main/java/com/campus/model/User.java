package com.campus.model;

public class User {
    private int userId;
    private String studentId, realName, nickname, phone, password, avatar;
    private int creditScore, pointsBalance, verifyStatus, role, status;

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
    public int getCreditScore() { return creditScore; }
    public void setCreditScore(int creditScore) { this.creditScore = creditScore; }
    public int getPointsBalance() { return pointsBalance; }
    public void setPointsBalance(int pointsBalance) { this.pointsBalance = pointsBalance; }
    public int getVerifyStatus() { return verifyStatus; }
    public void setVerifyStatus(int verifyStatus) { this.verifyStatus = verifyStatus; }
    public int getRole() { return role; }
    public void setRole(int role) { this.role = role; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public String getVerifyText() {
        return switch (verifyStatus) {
            case 1 -> "审核中";
            case 2 -> "已认证";
            case 3 -> "已驳回";
            default -> "未认证";
        };
    }
}
