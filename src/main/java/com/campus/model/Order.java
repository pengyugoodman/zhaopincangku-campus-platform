package com.campus.model;

import java.sql.Timestamp;

public class Order {
    private int orderId, buyerId, goodsId, pointsCost, status, deliveryMethod;
    private String orderSn, pickupCode, address, buyerRemark, goodsTitle, buyerName, sellerName;
    private Timestamp createTime, confirmTime;

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public String getOrderSn() { return orderSn; }
    public void setOrderSn(String orderSn) { this.orderSn = orderSn; }
    public int getBuyerId() { return buyerId; }
    public void setBuyerId(int buyerId) { this.buyerId = buyerId; }
    public int getGoodsId() { return goodsId; }
    public void setGoodsId(int goodsId) { this.goodsId = goodsId; }
    public int getPointsCost() { return pointsCost; }
    public void setPointsCost(int pointsCost) { this.pointsCost = pointsCost; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    public String getPickupCode() { return pickupCode; }
    public void setPickupCode(String pickupCode) { this.pickupCode = pickupCode; }
    public int getDeliveryMethod() { return deliveryMethod; }
    public void setDeliveryMethod(int deliveryMethod) { this.deliveryMethod = deliveryMethod; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getBuyerRemark() { return buyerRemark; }
    public void setBuyerRemark(String buyerRemark) { this.buyerRemark = buyerRemark; }
    public Timestamp getCreateTime() { return createTime; }
    public void setCreateTime(Timestamp createTime) { this.createTime = createTime; }
    public Timestamp getConfirmTime() { return confirmTime; }
    public void setConfirmTime(Timestamp confirmTime) { this.confirmTime = confirmTime; }
    public String getGoodsTitle() { return goodsTitle; }
    public void setGoodsTitle(String goodsTitle) { this.goodsTitle = goodsTitle; }
    public String getBuyerName() { return buyerName; }
    public void setBuyerName(String buyerName) { this.buyerName = buyerName; }
    public String getSellerName() { return sellerName; }
    public void setSellerName(String sellerName) { this.sellerName = sellerName; }

    public String getStatusText() {
        return switch (status) {
            case 0 -> "待确认";
            case 1 -> "待收货";
            case 2 -> "已完成";
            case 3 -> "已取消";
            default -> "未知";
        };
    }
}
