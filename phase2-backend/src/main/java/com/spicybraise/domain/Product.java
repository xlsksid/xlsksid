package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("products")
public class Product {

 @TableId(type = IdType.AUTO)
 private Long id;
 private String name;
 private String description;
 private BigDecimal price;
 private BigDecimal costPrice;
 private Integer stock;
 private String unit;
 private String imageUrl;
 private Integer categoryId;
 private Integer spiciness;
 private Boolean isAvailable;
 @TableLogic
 private Boolean isDeleted;
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;

 public Long getId() { return id; }
 public void setId(Long id) { this.id = id; }
 public String getName() { return name; }
 public void setName(String name) { this.name = name; }
 public String getDescription() { return description; }
 public void setDescription(String description) { this.description = description; }
 public BigDecimal getPrice() { return price; }
 public void setPrice(BigDecimal price) { this.price = price; }
 public BigDecimal getCostPrice() { return costPrice; }
 public void setCostPrice(BigDecimal costPrice) { this.costPrice = costPrice; }
 public Integer getStock() { return stock; }
 public void setStock(Integer stock) { this.stock = stock; }
 public String getUnit() { return unit; }
 public void setUnit(String unit) { this.unit = unit; }
 public String getImageUrl() { return imageUrl; }
 public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
 public Integer getCategoryId() { return categoryId; }
 public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }
 public Integer getSpiciness() { return spiciness; }
 public void setSpiciness(Integer spiciness) { this.spiciness = spiciness; }
 public Boolean getIsAvailable() { return isAvailable; }
 public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }
 public Boolean getIsDeleted() { return isDeleted; }
 public void setIsDeleted(Boolean isDeleted) { this.isDeleted = isDeleted; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public LocalDateTime getUpdatedAt() { return updatedAt; }
 public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
