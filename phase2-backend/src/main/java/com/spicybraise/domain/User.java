package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("users")
public class User {

 @TableId(type = IdType.AUTO)
 private Long id;
 private String username;
 private String passwordHash;
 private String email;
 private String phone;
 private String role;
 private String avatar;
 private BigDecimal balance;
 private Integer points;
 private String membershipLevel;
 @TableLogic
 private Boolean isDeleted;
 private LocalDateTime createdAt;
 private LocalDateTime updatedAt;

 public Long getId() { return id; }
 public void setId(Long id) { this.id = id; }
 public String getUsername() { return username; }
 public void setUsername(String username) { this.username = username; }
 public String getPasswordHash() { return passwordHash; }
 public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
 public String getEmail() { return email; }
 public void setEmail(String email) { this.email = email; }
 public String getPhone() { return phone; }
 public void setPhone(String phone) { this.phone = phone; }
 public String getRole() { return role; }
 public void setRole(String role) { this.role = role; }
 public String getAvatar() { return avatar; }
 public void setAvatar(String avatar) { this.avatar = avatar; }
 public BigDecimal getBalance() { return balance; }
 public void setBalance(BigDecimal balance) { this.balance = balance; }
 public Integer getPoints() { return points; }
 public void setPoints(Integer points) { this.points = points; }
 public String getMembershipLevel() { return membershipLevel; }
 public void setMembershipLevel(String membershipLevel) { this.membershipLevel = membershipLevel; }
 public Boolean getIsDeleted() { return isDeleted; }
 public void setIsDeleted(Boolean isDeleted) { this.isDeleted = isDeleted; }
 public LocalDateTime getCreatedAt() { return createdAt; }
 public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
 public LocalDateTime getUpdatedAt() { return updatedAt; }
 public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
