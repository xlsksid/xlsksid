package com.spicybraise.controller;

import com.spicybraise.common.ApiResponse;
import com.spicybraise.domain.Order;
import com.spicybraise.dto.request.PlaceOrderRequest;
import com.spicybraise.dto.response.OrderResponse;
import com.spicybraise.mapper.OrderMapper;
import com.spicybraise.service.OrderService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;
    private final OrderMapper orderMapper;

    public OrderController(OrderService orderService, OrderMapper orderMapper) {
        this.orderService = orderService;
        this.orderMapper = orderMapper;
    }

    @PostMapping
    public ApiResponse<OrderResponse> placeOrder(
            Authentication auth,
            @Valid @RequestBody PlaceOrderRequest req) {
        Long userId = Long.valueOf(auth.getPrincipal().toString());
        return ApiResponse.ok(orderService.placeOrder(userId, req));
    }

    @GetMapping
    public ApiResponse<List<Order>> listMyOrders(Authentication auth) {
        Long userId = Long.valueOf(auth.getPrincipal().toString());
        List<Order> orders = orderMapper.selectList(
                new LambdaQueryWrapper<Order>()
                        .eq(Order::getUserId, userId)
                        .eq(Order::getIsDeleted, false)
                        .orderByDesc(Order::getCreatedAt));
        return ApiResponse.ok(orders);
    }

    @GetMapping("/{id}")
    public ApiResponse<Order> getOrder(@PathVariable Long id, Authentication auth) {
        Order order = orderMapper.selectById(id);
        if (order == null) {
            return ApiResponse.fail(404, "Order not found");
        }
        return ApiResponse.ok(order);
    }
}
