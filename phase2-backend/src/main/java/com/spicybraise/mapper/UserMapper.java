package com.spicybraise.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.spicybraise.domain.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}
