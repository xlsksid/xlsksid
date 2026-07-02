package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("coupon_template")
public class CouponTemplate {

 @TableId(type = IdType.AUTO)
 private Integer id;
 private String name;
 private String type;
 private BigDecimal discountRate;
 private BigDecimal reductionAmount;
 private BigDecimal minOrderAmount;
 private Integer validDays;
 private Integer totalQuantity;
 private Integer issuedCount;
 private Boolean isActive;
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;

 public Integer getId() { return id; }
 public void setId(Integer id) { this.id = id; }
 public String getName() { return name; }
 public void setName(String name) { this.name = name; }
 public String getType() { return type; }
 public void setType(String type) { this.type = type; }
 public BigDecimal getDiscountRate() { return discountRate; }
 public void setDiscountRate(BigDecimal discountRate) { this.discountRate = discountRate; }
 public BigDecimal getReductionAmount() { return reductionAmount; }
 public void setReductionAmount(BigDecimal reductionAmount) { this.reductionAmount = reductionAmount; }
 public BigDecimal getMinOrderAmount() { return minOrderAmount; }
 public void setMinOrderAmount(BigDecimal minOrderAmount) { this.minOrderAmount = minOrderAmount; }
 public Integer getValidDays() { return validDays; }
 public void setValidDays(Integer validDays) { this.validDays = validDays; }
 public Integer getTotalQuantity() { return totalQuantity; }
 public void setTotalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; }
 public Integer getIssuedCount() { return issuedCount; }
 public void setIssuedCount(Integer issuedCount) { this.issuedCount = issuedCount; }
 public Boolean getIsActive() { return isActive; }
 public void setIsActive(Boolean isActive) { this.isActive = isActive; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public LocalDateTime getUpdatedAt() { return updatedAt; }
 public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
