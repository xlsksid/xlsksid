package com.spicybraise.domain;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import java.time.LocalDateTime;

public abstract class BaseEntity {

 @TableField(fill = FieldFill.INSERT)
 private LocalDateTime createdAt;

 @TableField(fill = FieldFill.INSERT_UPDATE)
 private LocalDateTime updatedAt;
}
