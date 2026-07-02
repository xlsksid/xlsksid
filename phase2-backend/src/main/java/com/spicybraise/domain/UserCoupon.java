package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@TableName("user_coupon")
public class UserCoupon {

 @TableId(type = IdType.AUTO)
 private Long id;
 private Long userId;
 private Integer couponTemplateId;
 private String status;
 private Long usedOrderId;
 private LocalDateTime validFrom;
 private LocalDateTime validTo;
 private LocalDateTime usedAt;
 private LocalDateTime createdAt;

 @TableField(exist = false)
 private String templateName;
 @TableField(exist = false)
 private String type;
 @TableField(exist = false)
 private java.math.BigDecimal discountRate;
 @TableField(exist = false)
 private java.math.BigDecimal reductionAmount;
 @TableField(exist = false)
 private java.math.BigDecimal minOrderAmount;

 public Long getId() { return id; }
 public void setId(Long id) { this.id = id; }
 public Long getUserId() { return userId; }
 public void setUserId(Long userId) { this.userId = userId; }
 public Integer getCouponTemplateId() { return couponTemplateId; }
 public void setCouponTemplateId(Integer couponTemplateId) { this.couponTemplateId = couponTemplateId; }
 public String getStatus() { return status; }
 public void setStatus(String status) { this.status = status; }
 public Long getUsedOrderId() { return usedOrderId; }
 public void setUsedOrderId(Long usedOrderId) { this.usedOrderId = usedOrderId; }
 public LocalDateTime getValidFrom() { return validFrom; }
 public void setValidFrom(LocalDateTime validFrom) { this.validFrom = validFrom; }
 public LocalDateTime getValidTo() { return validTo; }
 public void setValidTo(LocalDateTime validTo) { this.validTo = validTo; }
 public LocalDateTime getUsedAt() { return usedAt; }
 public void setUsedAt(LocalDateTime usedAt) { this.usedAt = usedAt; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public String getTemplateName() { return templateName; }
 public void setTemplateName(String templateName) { this.templateName = templateName; }
 public String getType() { return type; }
 public void setType(String type) { this.type = type; }
 public java.math.BigDecimal getDiscountRate() { return discountRate; }
 public void setDiscountRate(java.math.BigDecimal discountRate) { this.discountRate = discountRate; }
 public java.math.BigDecimal getReductionAmount() { return reductionAmount; }
 public void setReductionAmount(java.math.BigDecimal reductionAmount) { this.reductionAmount = reductionAmount; }
 public java.math.BigDecimal getMinOrderAmount() { return minOrderAmount; }
 public void setMinOrderAmount(java.math.BigDecimal minOrderAmount) { this.minOrderAmount = minOrderAmount; }
}
