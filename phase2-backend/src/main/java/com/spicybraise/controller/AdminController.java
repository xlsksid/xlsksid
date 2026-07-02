package com.spicybraise.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.spicybraise.common.ApiResponse;
import com.spicybraise.common.BusinessException;
import com.spicybraise.domain.*;
import com.spicybraise.mapper.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final OrderMapper orderMapper;
    private final UserMapper userMapper;
    private final FeedbackMapper feedbackMapper;
    private final UserCouponMapper userCouponMapper;
    private final CouponTemplateMapper couponTemplateMapper;

    public AdminController(OrderMapper orderMapper, UserMapper userMapper,
            FeedbackMapper feedbackMapper, UserCouponMapper userCouponMapper,
            CouponTemplateMapper couponTemplateMapper) {
        this.orderMapper = orderMapper;
        this.userMapper = userMapper;
        this.feedbackMapper = feedbackMapper;
        this.userCouponMapper = userCouponMapper;
        this.couponTemplateMapper = couponTemplateMapper;
    }

    // ========== 订单管理 ==========
    @GetMapping("/orders")
    public ApiResponse<List<Order>> listAllOrders() {
        return ApiResponse.ok(orderMapper.selectList(
            new LambdaQueryWrapper<Order>().eq(Order::getIsDeleted, false)
                .orderByDesc(Order::getCreatedAt)));
    }

    @PutMapping("/orders/{id}/status")
    public ApiResponse<Order> updateOrderStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Order order = orderMapper.selectById(id);
        if (order == null) throw new BusinessException(404, "订单不存在");
        String status = body.get("status");
        if (status == null || status.isEmpty()) throw new BusinessException("状态不能为空");
        order.setStatus(status);
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);
        return ApiResponse.ok(order);
    }

    // ========== 用户管理 ==========
    @GetMapping("/users")
    public ApiResponse<List<User>> listUsers() {
        List<User> users = userMapper.selectList(
            new LambdaQueryWrapper<User>().eq(User::getIsDeleted, false));
        users.forEach(u -> u.setPasswordHash(null));
        return ApiResponse.ok(users);
    }

    @PutMapping("/users/{id}/toggle")
    public ApiResponse<User> toggleUser(@PathVariable Long id) {
        User user = userMapper.selectById(id);
        if (user == null) throw new BusinessException(404, "用户不存在");
        user.setIsDeleted(!Boolean.TRUE.equals(user.getIsDeleted()));
        userMapper.updateById(user);
        user.setPasswordHash(null);
        return ApiResponse.ok(user);
    }

    // ========== 发券 ==========
    @PostMapping("/coupons/grant")
    @Transactional
    public ApiResponse<UserCoupon> grantCoupon(@RequestBody Map<String, Object> body) {
        Long userId = Long.valueOf(body.get("userId").toString());
        Integer templateId = Integer.valueOf(body.get("templateId").toString());

        User user = userMapper.selectById(userId);
        if (user == null) throw new BusinessException("用户不存在");
        CouponTemplate ct = couponTemplateMapper.selectById(templateId);
        if (ct == null) throw new BusinessException("优惠券模板不存在");

        UserCoupon uc = new UserCoupon();
        uc.setUserId(userId);
        uc.setCouponTemplateId(templateId);
        uc.setStatus("unused");
        uc.setValidFrom(LocalDateTime.now());
        uc.setValidTo(LocalDateTime.now().plusDays(ct.getValidDays()));
        uc.setCreatedAt(LocalDateTime.now());
        userCouponMapper.insert(uc);

        ct.setIssuedCount(ct.getIssuedCount() + 1);
        couponTemplateMapper.updateById(ct);

        return ApiResponse.ok(uc);
    }

    // ========== 评价管理 ==========
    @GetMapping("/feedback")
    public ApiResponse<List<Feedback>> listAllFeedback() {
        return ApiResponse.ok(feedbackMapper.selectList(
            new LambdaQueryWrapper<Feedback>().eq(Feedback::getIsDeleted, false)
                .orderByDesc(Feedback::getCreatedAt)));
    }

    @DeleteMapping("/feedback/{id}")
    public ApiResponse<Void> deleteFeedback(@PathVariable Long id) {
        Feedback fb = feedbackMapper.selectById(id);
        if (fb == null) throw new BusinessException(404, "评价不存在");
        fb.setIsDeleted(true);
        feedbackMapper.updateById(fb);
        return ApiResponse.ok(null);
    }
}
