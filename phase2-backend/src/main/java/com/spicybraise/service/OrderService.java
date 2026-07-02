package com.spicybraise.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.spicybraise.common.BusinessException;
import com.spicybraise.domain.*;
import com.spicybraise.dto.request.PlaceOrderRequest;
import com.spicybraise.dto.response.OrderResponse;
import com.spicybraise.mapper.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@Service
public class OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    private final OrderMapper orderMapper;
    private final OrderDetailMapper orderDetailMapper;
    private final ProductMapper productMapper;
    private final PaymentMapper paymentMapper;
    private final UserMapper userMapper;
    private final UserCouponMapper userCouponMapper;
    private final CouponTemplateMapper couponTemplateMapper;
    private final PointsRecordMapper pointsRecordMapper;

    public OrderService(OrderMapper orderMapper, OrderDetailMapper orderDetailMapper,
            ProductMapper productMapper, PaymentMapper paymentMapper, UserMapper userMapper,
            UserCouponMapper userCouponMapper, CouponTemplateMapper couponTemplateMapper,
            PointsRecordMapper pointsRecordMapper) {
        this.orderMapper = orderMapper;
        this.orderDetailMapper = orderDetailMapper;
        this.productMapper = productMapper;
        this.paymentMapper = paymentMapper;
        this.userMapper = userMapper;
        this.userCouponMapper = userCouponMapper;
        this.couponTemplateMapper = couponTemplateMapper;
        this.pointsRecordMapper = pointsRecordMapper;
    }

    @Transactional(rollbackFor = Exception.class)
    @Retryable(retryFor = BusinessException.class, maxAttempts = 3,
               backoff = @Backoff(delay = 200, multiplier = 2))
    public OrderResponse placeOrder(Long userId, PlaceOrderRequest req) {
        LocalDateTime now = LocalDateTime.now();
        BigDecimal totalAmount = BigDecimal.ZERO;

        // 1. 库存校验 + 扣减
        for (PlaceOrderRequest.OrderItem item : req.getItems()) {
            Product product = productMapper.selectById(item.getProductId());
            if (product == null || Boolean.TRUE.equals(product.getIsDeleted())
                    || !Boolean.TRUE.equals(product.getIsAvailable())) {
                throw new BusinessException("商品不存在或已下架: " + item.getProductId());
            }
            if (product.getStock() < item.getQuantity()) {
                throw new BusinessException("库存不足 [" + product.getName()
                    + "]: 剩余 " + product.getStock() + "，需要 " + item.getQuantity());
            }
            int rows = productMapper.deductStock(item.getProductId(), item.getQuantity());
            if (rows == 0) {
                throw new BusinessException("库存扣减失败: " + item.getProductId());
            }
            totalAmount = totalAmount.add(
                    product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
        }

        // 2. 优惠券校验
        BigDecimal discountAmount = BigDecimal.ZERO;
        Long lockedCouponId = null;
        if (req.getCouponId() != null) {
            UserCoupon uc = userCouponMapper.selectById(req.getCouponId());
            if (uc == null || !uc.getUserId().equals(userId)) {
                throw new BusinessException("优惠券不存在或不属于您");
            }
            if (!"unused".equals(uc.getStatus())) {
                throw new BusinessException("优惠券已使用或已过期");
            }
            if (now.isBefore(uc.getValidFrom()) || now.isAfter(uc.getValidTo())) {
                throw new BusinessException("优惠券不在有效期内");
            }
            CouponTemplate ct = couponTemplateMapper.selectById(uc.getCouponTemplateId());
            if (totalAmount.compareTo(ct.getMinOrderAmount()) < 0) {
                throw new BusinessException("未达到最低消费 ¥" + ct.getMinOrderAmount());
            }
            if ("discount".equals(ct.getType())) {
                discountAmount = totalAmount.multiply(BigDecimal.ONE.subtract(ct.getDiscountRate()));
            } else if ("reduction".equals(ct.getType())) {
                discountAmount = ct.getReductionAmount();
            }
            int locked = userCouponMapper.lockCoupon(uc.getId(), userId);
            if (locked == 0) {
                throw new BusinessException("优惠券锁定失败，请重试");
            }
            lockedCouponId = uc.getId();
        }

        // 3. 积分抵扣
        int usePoints = req.getUsePoints() != null ? req.getUsePoints() : 0;
        BigDecimal pointsAmount = BigDecimal.ZERO;
        if (usePoints > 0) {
            User user = userMapper.selectById(userId);
            if (usePoints > user.getPoints()) {
                throw new BusinessException("积分不足: 可用 " + user.getPoints() + " 分");
            }
            // 会员等级积分汇率: 铜100:1 / 银120:1 / 金150:1 / 铂200:1
            int pointsRate = getPointsRate(user.getMembershipLevel());
            pointsAmount = BigDecimal.valueOf(usePoints).divide(BigDecimal.valueOf(pointsRate), 2, java.math.RoundingMode.FLOOR);
            BigDecimal maxDiscount = totalAmount.subtract(discountAmount);
            if (pointsAmount.compareTo(maxDiscount) > 0) {
                pointsAmount = maxDiscount;
                usePoints = pointsAmount.multiply(BigDecimal.valueOf(pointsRate)).setScale(0, java.math.RoundingMode.UP).intValue();
            }
            user.setPoints(user.getPoints() - usePoints);
            userMapper.updateById(user);

            PointsRecord pr = new PointsRecord();
            pr.setUserId(userId);
            pr.setPoints(-usePoints);
            pr.setType("spend");
            pr.setDescription("下单抵扣 " + usePoints + " 分 = " + pointsAmount + " 元");
            pr.setCreatedAt(now);
            pointsRecordMapper.insert(pr);
        }

        // 4. 计算实付
        BigDecimal actualAmount = totalAmount.subtract(discountAmount).subtract(pointsAmount);
        if (actualAmount.compareTo(BigDecimal.ZERO) < 0) actualAmount = BigDecimal.ZERO;

        String orderNo = String.format("%s%06d",
                now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")),
                new Random().nextInt(1000000));

        // 5. 创建订单
        Order order = new Order();
        order.setUserId(userId);
        order.setOrderNo(orderNo);
        order.setTotalAmount(totalAmount);
        order.setDiscountAmount(discountAmount);
        order.setPointsDeducted(usePoints);
        order.setPointsAmount(pointsAmount);
        order.setActualAmount(actualAmount);
        order.setStatus("pending");
        order.setRemark(req.getRemark());
        orderMapper.insert(order);

        // 6. 订单明细
        for (PlaceOrderRequest.OrderItem item : req.getItems()) {
            Product product = productMapper.selectById(item.getProductId());
            OrderDetail detail = new OrderDetail();
            detail.setOrderId(order.getId());
            detail.setProductId(item.getProductId());
            detail.setQuantity(item.getQuantity());
            detail.setUnitPrice(product.getPrice());
            detail.setSubtotal(product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            detail.setCreatedAt(now);
            orderDetailMapper.insert(detail);
        }

        // 7. 支付记录
        Payment payment = new Payment();
        payment.setOrderId(order.getId());
        payment.setUserId(userId);
        payment.setAmount(actualAmount);
        payment.setPaymentMethod(actualAmount.compareTo(BigDecimal.ZERO) == 0 ? "points" : "wechat");
        payment.setPaymentStatus("pending");
        paymentMapper.insert(payment);

        // 8. 关联优惠券
        if (lockedCouponId != null) {
            UserCoupon uc = new UserCoupon();
            uc.setId(lockedCouponId);
            uc.setUsedOrderId(order.getId());
            userCouponMapper.updateById(uc);
        }

        // 赠送积分 (消费额1%) + 自动升级会员等级
        int earnedPoints = actualAmount.intValue();
        if (earnedPoints > 0) {
            User user = userMapper.selectById(userId);
            String oldLevel = user.getMembershipLevel();
            user.setPoints(user.getPoints() + earnedPoints);
            user.setMembershipLevel(calcLevel(user.getPoints()));
            String newLevel = user.getMembershipLevel();
            userMapper.updateById(user);

            PointsRecord pr = new PointsRecord();
            pr.setUserId(userId);
            pr.setPoints(earnedPoints);
            pr.setType("earn");
            pr.setDescription("订单 #" + orderNo + " 赠送积分");
            pr.setOrderId(order.getId());
            pr.setCreatedAt(now);
            pointsRecordMapper.insert(pr);

            if (!oldLevel.equals(newLevel)) {
                PointsRecord up = new PointsRecord();
                up.setUserId(userId);
                up.setPoints(0);
                up.setType("earn");
                up.setDescription("🎉 恭喜升级为" + getLevelName(newLevel) + "！");
                up.setCreatedAt(now);
                pointsRecordMapper.insert(up);
            }
        }

        log.info("订单已创建: id={}, orderNo={}, total={}, discount={}, points={}, actual={}",
                order.getId(), orderNo, totalAmount, discountAmount, pointsAmount, actualAmount);

        return new OrderResponse(order.getId(), orderNo, totalAmount,
                discountAmount, usePoints, pointsAmount, actualAmount, "pending");
    }

    private int getPointsRate(String level) {
        switch (level != null ? level : "bronze") {
            case "platinum": return 70;
            case "gold":     return 80;
            case "silver":   return 90;
            default:         return 100;
        }
    }

    private String calcLevel(int points) {
        if (points >= 5000) return "platinum";
        if (points >= 2000) return "gold";
        if (points >= 500)  return "silver";
        return "bronze";
    }

    private String getLevelName(String level) {
        switch (level != null ? level : "bronze") {
            case "platinum": return "铂金";
            case "gold":     return "金牌";
            case "silver":   return "银牌";
            default:         return "铜牌";
        }
    }
}
