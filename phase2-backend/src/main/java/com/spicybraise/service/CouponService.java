package com.spicybraise.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.spicybraise.common.BusinessException;
import com.spicybraise.domain.CouponTemplate;
import com.spicybraise.domain.UserCoupon;
import com.spicybraise.mapper.CouponTemplateMapper;
import com.spicybraise.mapper.UserCouponMapper;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class CouponService {

    private final CouponTemplateMapper couponTemplateMapper;
    private final UserCouponMapper userCouponMapper;

    public CouponService(CouponTemplateMapper couponTemplateMapper, UserCouponMapper userCouponMapper) {
        this.couponTemplateMapper = couponTemplateMapper;
        this.userCouponMapper = userCouponMapper;
    }

    public List<CouponTemplate> listActiveTemplates() {
        return couponTemplateMapper.selectList(new LambdaQueryWrapper<CouponTemplate>()
                .eq(CouponTemplate::getIsActive, true));
    }

    public UserCoupon claimCoupon(Long userId, Integer templateId) {
        CouponTemplate ct = couponTemplateMapper.selectById(templateId);
        if (ct == null || !Boolean.TRUE.equals(ct.getIsActive())) {
            throw new BusinessException("Coupon template not available");
        }
        if (ct.getTotalQuantity() > 0 && ct.getIssuedCount() >= ct.getTotalQuantity()) {
            throw new BusinessException("Coupon fully claimed");
        }

        Long count = userCouponMapper.selectCount(new LambdaQueryWrapper<UserCoupon>()
                .eq(UserCoupon::getUserId, userId)
                .eq(UserCoupon::getCouponTemplateId, templateId)
                .eq(UserCoupon::getStatus, "unused"));
        if (count > 0) {
            throw new BusinessException("You already have this coupon");
        }

        LocalDateTime now = LocalDateTime.now();
        UserCoupon uc = new UserCoupon();
        uc.setUserId(userId);
        uc.setCouponTemplateId(templateId);
        uc.setStatus("unused");
        uc.setValidFrom(now);
        uc.setValidTo(now.plusDays(ct.getValidDays()));
        uc.setCreatedAt(now);
        userCouponMapper.insert(uc);

        ct.setIssuedCount(ct.getIssuedCount() + 1);
        couponTemplateMapper.updateById(ct);

        return uc;
    }

    public List<UserCoupon> listUserCoupons(Long userId) {
        return userCouponMapper.selectByUserWithName(userId);
    }
}
