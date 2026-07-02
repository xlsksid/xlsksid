package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@TableName("points_record")
public class PointsRecord {

 @TableId(type = IdType.AUTO)
 private Long id;
 private Long userId;
 private Integer points;
 private String type;
 private String description;
 private Long orderId;
 private LocalDateTime createdAt;

 public Long getId() { return id; }
 public void setId(Long id) { this.id = id; }
 public Long getUserId() { return userId; }
 public void setUserId(Long userId) { this.userId = userId; }
 public Integer getPoints() { return points; }
 public void setPoints(Integer points) { this.points = points; }
 public String getType() { return type; }
 public void setType(String type) { this.type = type; }
 public String getDescription() { return description; }
 public void setDescription(String description) { this.description = description; }
 public Long getOrderId() { return orderId; }
 public void setOrderId(Long orderId) { this.orderId = orderId; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
