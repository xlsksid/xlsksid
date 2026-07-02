package com.spicybraise.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public class PlaceOrderRequest {
 @NotEmpty
 private List<OrderItem> items;
 private Long couponId;
 private Integer usePoints = 0;
 private String remark;

 public List<OrderItem> getItems() { return items; }
 public void setItems(List<OrderItem> items) { this.items = items; }
 public Long getCouponId() { return couponId; }
 public void setCouponId(Long couponId) { this.couponId = couponId; }
 public Integer getUsePoints() { return usePoints; }
 public void setUsePoints(Integer usePoints) { this.usePoints = usePoints; }
 public String getRemark() { return remark; }
 public void setRemark(String remark) { this.remark = remark; }

 public static class OrderItem {
 @NotNull
 private Long productId;
 @Min(1)
 private Integer quantity;

 public Long getProductId() { return productId; }
 public void setProductId(Long productId) { this.productId = productId; }
 public Integer getQuantity() { return quantity; }
 public void setQuantity(Integer quantity) { this.quantity = quantity; }
 }
}
