package com.spicybraise.controller;

import com.spicybraise.common.ApiResponse;
import com.spicybraise.domain.User;
import com.spicybraise.mapper.UserMapper;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserMapper userMapper;

    public UserController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @GetMapping("/me")
    public ApiResponse<User> me(Authentication auth) {
        Long userId = Long.valueOf(auth.getPrincipal().toString());
        User user = userMapper.selectById(userId);
        user.setPasswordHash(null);
        return ApiResponse.ok(user);
    }
}
