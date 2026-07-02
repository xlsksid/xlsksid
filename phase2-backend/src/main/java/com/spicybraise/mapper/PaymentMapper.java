package com.spicybraise.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.spicybraise.domain.Payment;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PaymentMapper extends BaseMapper<Payment> {
}
