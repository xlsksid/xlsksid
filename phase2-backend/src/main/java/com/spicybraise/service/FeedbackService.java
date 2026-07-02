package com.spicybraise.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.spicybraise.common.BusinessException;
import com.spicybraise.domain.Feedback;
import com.spicybraise.domain.Order;
import com.spicybraise.mapper.FeedbackMapper;
import com.spicybraise.mapper.OrderMapper;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class FeedbackService {

    private final FeedbackMapper feedbackMapper;
    private final OrderMapper orderMapper;

    public FeedbackService(FeedbackMapper feedbackMapper, OrderMapper orderMapper) {
        this.feedbackMapper = feedbackMapper;
        this.orderMapper = orderMapper;
    }

    public Feedback submit(Long userId, Feedback feedback) {
        Order order = orderMapper.selectById(feedback.getOrderId());
        if (order == null || !order.getUserId().equals(userId)) {
            throw new BusinessException("Order not found or not yours");
        }
        if (!"completed".equals(order.getStatus())) {
            throw new BusinessException("Can only review completed orders");
        }
        feedback.setUserId(userId);
        feedbackMapper.insert(feedback);
        return feedback;
    }

    public List<Feedback> listByProduct(Long productId) {
        return feedbackMapper.selectList(new LambdaQueryWrapper<Feedback>()
                .eq(Feedback::getProductId, productId)
                .eq(Feedback::getIsDeleted, false)
                .orderByDesc(Feedback::getCreatedAt));
    }
}
