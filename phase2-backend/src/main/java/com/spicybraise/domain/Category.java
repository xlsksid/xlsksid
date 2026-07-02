package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@TableName("categories")
public class Category {

 @TableId(type = IdType.AUTO)
 private Integer id;
 private String name;
 private String description;
 private Integer sortOrder;
 private String imageUrl;
 @TableLogic
 private Boolean isDeleted;
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;

 public Integer getId() { return id; }
 public void setId(Integer id) { this.id = id; }
 public String getName() { return name; }
 public void setName(String name) { this.name = name; }
 public String getDescription() { return description; }
 public void setDescription(String description) { this.description = description; }
 public Integer getSortOrder() { return sortOrder; }
 public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
 public String getImageUrl() { return imageUrl; }
 public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
 public Boolean getIsDeleted() { return isDeleted; }
 public void setIsDeleted(Boolean isDeleted) { this.isDeleted = isDeleted; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public LocalDateTime getUpdatedAt() { return updatedAt; }
 public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
