package com.spicybraise.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.spicybraise.domain.Feedback;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface FeedbackMapper extends BaseMapper<Feedback> {
}
