package com.spicybraise.dto.response;

import java.math.BigDecimal;

public class OrderResponse {
 private Long orderId;
 private String orderNo;
 private BigDecimal totalAmount;
 private BigDecimal discountAmount;
 private Integer pointsDeducted;
 private BigDecimal pointsAmount;
 private BigDecimal actualAmount;
 private String status;

 public OrderResponse() {}
 public OrderResponse(Long orderId, String orderNo, BigDecimal totalAmount,
 BigDecimal discountAmount, Integer pointsDeducted, BigDecimal pointsAmount,
 BigDecimal actualAmount, String status) {
 this.orderId = orderId; this.orderNo = orderNo; this.totalAmount = totalAmount;
 this.discountAmount = discountAmount; this.pointsDeducted = pointsDeducted;
 this.pointsAmount = pointsAmount; this.actualAmount = actualAmount; this.status = status;
 }

 public Long getOrderId() { return orderId; }
 public void setOrderId(Long orderId) { this.orderId = orderId; }
 public String getOrderNo() { return orderNo; }
 public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
 public BigDecimal getTotalAmount() { return totalAmount; }
 public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
 public BigDecimal getDiscountAmount() { return discountAmount; }
 public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
 public Integer getPointsDeducted() { return pointsDeducted; }
 public void setPointsDeducted(Integer pointsDeducted) { this.pointsDeducted = pointsDeducted; }
 public BigDecimal getPointsAmount() { return pointsAmount; }
 public void setPointsAmount(BigDecimal pointsAmount) { this.pointsAmount = pointsAmount; }
 public BigDecimal getActualAmount() { return actualAmount; }
 public void setActualAmount(BigDecimal actualAmount) { this.actualAmount = actualAmount; }
 public String getStatus() { return status; }
 public void setStatus(String status) { this.status = status; }
}
