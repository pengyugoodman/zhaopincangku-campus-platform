package com.campus.model;

import java.sql.Timestamp;

public class Goods {
    private int goodsId, sellerId, pricePoints, viewCount, status, conditionLevel;
    private int categoryId;
    private String title, description, images, flawDesc, wechat, auditRemark, categoryName, sellerName;
    private Timestamp createTime;

    public int getGoodsId() { return goodsId; }
    public void setGoodsId(int goodsId) { this.goodsId = goodsId; }
    public int getSellerId() { return sellerId; }
    public void setSellerId(int sellerId) { this.sellerId = sellerId; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImages() { return images; }
    public void setImages(String images) { this.images = images; }
    public int getConditionLevel() { return conditionLevel; }
    public void setConditionLevel(int conditionLevel) { this.conditionLevel = conditionLevel; }
    public String getFlawDesc() { return flawDesc; }
    public void setFlawDesc(String flawDesc) { this.flawDesc = flawDesc; }
    public String getWechat() { return wechat; }
    public void setWechat(String wechat) { this.wechat = wechat; }
    public int getPricePoints() { return pricePoints; }
    public void setPricePoints(int pricePoints) { this.pricePoints = pricePoints; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    public String getAuditRemark() { return auditRemark; }
    public void setAuditRemark(String auditRemark) { this.auditRemark = auditRemark; }
    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }
    public Timestamp getCreateTime() { return createTime; }
    public void setCreateTime(Timestamp createTime) { this.createTime = createTime; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getSellerName() { return sellerName; }
    public void setSellerName(String sellerName) { this.sellerName = sellerName; }

    public String getCover() {
        String url = getFirstImageUrl();
        return url.isBlank() ? "assets/placeholder.svg" : url;
    }

    public String getFirstImageUrl() {
        if (images == null || images.isBlank()) return "";
        String s = images.replace("[", "").replace("]", "").replace("\"", "");
        int idx = s.indexOf(',');
        return idx > 0 ? s.substring(0, idx).trim() : s.trim();
    }

    public String getStatusText() {
        return switch (status) {
            case 0 -> "待审核";
            case 1 -> "已上架";
            case 2 -> "已下架";
            case 3 -> "已售出";
            default -> "未知";
        };
    }
}
