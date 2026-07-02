package com.spicybraise.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.spicybraise.domain.UserCoupon;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import java.util.List;

@Mapper
public interface UserCouponMapper extends BaseMapper<UserCoupon> {

 /** */
 @Update("UPDATE user_coupon SET status = 'used', used_at = SYSUTCDATETIME() " +
 "WHERE id = #{id} AND user_id = #{userId} AND status = 'unused'")
 int lockCoupon(@Param("id") Long id, @Param("userId") Long userId);

 @Select("SELECT uc.*, ct.name AS templateName, ct.type, ct.discount_rate AS discountRate, ct.reduction_amount AS reductionAmount, ct.min_order_amount AS minOrderAmount FROM user_coupon uc LEFT JOIN coupon_template ct ON uc.coupon_template_id = ct.id WHERE uc.user_id = #{userId} ORDER BY uc.created_at DESC")
 List<UserCoupon> selectByUserWithName(@Param("userId") Long userId);
}
