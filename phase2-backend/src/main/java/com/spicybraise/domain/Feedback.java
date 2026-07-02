package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@TableName("feedback")
public class Feedback {

 @TableId(type = IdType.AUTO)
 private Long id;
 private Long userId;
 private Long productId;
 private Long orderId;
 private Integer rating;
 private String comment;
 @TableLogic
 private Boolean isDeleted;
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;

 public Long getId() { return id; }
 public void setId(Long id) { this.id = id; }
 public Long getUserId() { return userId; }
 public void setUserId(Long userId) { this.userId = userId; }
 public Long getProductId() { return productId; }
 public void setProductId(Long productId) { this.productId = productId; }
 public Long getOrderId() { return orderId; }
 public void setOrderId(Long orderId) { this.orderId = orderId; }
 public Integer getRating() { return rating; }
 public void setRating(Integer rating) { this.rating = rating; }
 public String getComment() { return comment; }
 public void setComment(String comment) { this.comment = comment; }
 public Boolean getIsDeleted() { return isDeleted; }
 public void setIsDeleted(Boolean isDeleted) { this.isDeleted = isDeleted; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public LocalDateTime getUpdatedAt() { return updatedAt; }
 public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
