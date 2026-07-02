package com.spicybraise.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.spicybraise.domain.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface ProductMapper extends BaseMapper<Product> {

 /** rowversion */
 @Update("UPDATE products SET stock = stock - #{qty}, updated_at = SYSUTCDATETIME() " +
 "WHERE id = #{id} AND stock >= #{qty} AND is_deleted = 0")
 int deductStock(@Param("id") Long id, @Param("qty") int qty);
}
