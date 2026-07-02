package com.spicybraise.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.spicybraise.domain.OrderDetail;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderDetailMapper extends BaseMapper<OrderDetail> {
}
