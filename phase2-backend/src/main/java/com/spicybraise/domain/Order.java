package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("orders")
public class Order {

 @TableId(type = IdType.AUTO)
 private Long id;
 private Long userId;
 private String orderNo;
 private BigDecimal totalAmount;
 private BigDecimal discountAmount;
 private Integer pointsDeducted;
 private BigDecimal pointsAmount;
 private BigDecimal actualAmount;
 private String status;
 private String remark;
 @TableLogic
 private Boolean isDeleted;
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;

 public Long getId() { return id; }
 public void setId(Long id) { this.id = id; }
 public Long getUserId() { return userId; }
 public void setUserId(Long userId) { this.userId = userId; }
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
 public String getRemark() { return remark; }
 public void setRemark(String remark) { this.remark = remark; }
 public Boolean getIsDeleted() { return isDeleted; }
 public void setIsDeleted(Boolean isDeleted) { this.isDeleted = isDeleted; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public LocalDateTime getUpdatedAt() { return updatedAt; }
 public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
