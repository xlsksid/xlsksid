package com.spicybraise.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.spicybraise.common.BusinessException;
import com.spicybraise.domain.Payment;
import com.spicybraise.domain.Order;
import com.spicybraise.mapper.PaymentMapper;
import com.spicybraise.mapper.OrderMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

@Service
public class PaymentService {

    private final PaymentMapper paymentMapper;
    private final OrderMapper orderMapper;

    public PaymentService(PaymentMapper paymentMapper, OrderMapper orderMapper) {
        this.paymentMapper = paymentMapper;
        this.orderMapper = orderMapper;
    }

    @Transactional
    public Payment simulatePay(Long orderId, Long userId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException(404, "订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权操作此订单");
        }
        if (!"pending".equals(order.getStatus())) {
            throw new BusinessException("该订单已支付或已取消，无需重复支付");
        }

        Payment payment = paymentMapper.selectOne(new LambdaQueryWrapper<Payment>()
                .eq(Payment::getOrderId, orderId));

        if (payment == null) {
            throw new BusinessException(404, "未找到支付记录");
        }
        if (!"pending".equals(payment.getPaymentStatus())) {
            throw new BusinessException("该订单已支付，无需重复操作");
        }

        payment.setPaymentStatus("success");
        payment.setTransactionId("SIM_" + System.currentTimeMillis());
        payment.setPaidAt(LocalDateTime.now());
        paymentMapper.updateById(payment);

        order.setStatus("confirmed");
        orderMapper.updateById(order);

        return payment;
    }
}
