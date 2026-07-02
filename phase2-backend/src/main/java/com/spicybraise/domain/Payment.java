package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("payments")
public class Payment {

 @TableId(type = IdType.AUTO)
 private Long id;
 private Long orderId;
 private Long userId;
 private BigDecimal amount;
 private String paymentMethod;
 private String paymentStatus;
 private String transactionId;
 private LocalDateTime paidAt;
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;

 public Long getId() { return id; }
 public void setId(Long id) { this.id = id; }
 public Long getOrderId() { return orderId; }
 public void setOrderId(Long orderId) { this.orderId = orderId; }
 public Long getUserId() { return userId; }
 public void setUserId(Long userId) { this.userId = userId; }
 public BigDecimal getAmount() { return amount; }
 public void setAmount(BigDecimal amount) { this.amount = amount; }
 public String getPaymentMethod() { return paymentMethod; }
 public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
 public String getPaymentStatus() { return paymentStatus; }
 public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
 public String getTransactionId() { return transactionId; }
 public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
 public LocalDateTime getPaidAt() { return paidAt; }
 public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public LocalDateTime getUpdatedAt() { return updatedAt; }
 public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
