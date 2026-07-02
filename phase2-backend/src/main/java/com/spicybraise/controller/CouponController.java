package com.spicybraise.controller;

import com.spicybraise.common.ApiResponse;
import com.spicybraise.domain.CouponTemplate;
import com.spicybraise.domain.UserCoupon;
import com.spicybraise.service.CouponService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/coupons")
public class CouponController {

    private final CouponService couponService;

    public CouponController(CouponService couponService) {
        this.couponService = couponService;
    }

    @GetMapping("/templates")
    public ApiResponse<List<CouponTemplate>> listTemplates() {
        return ApiResponse.ok(couponService.listActiveTemplates());
    }

    @PostMapping("/claim/{templateId}")
    public ApiResponse<UserCoupon> claim(
            Authentication auth, @PathVariable Integer templateId) {
        Long userId = Long.valueOf(auth.getPrincipal().toString());
        return ApiResponse.ok(couponService.claimCoupon(userId, templateId));
    }

    @GetMapping("/my")
    public ApiResponse<List<UserCoupon>> myCoupons(Authentication auth) {
        Long userId = Long.valueOf(auth.getPrincipal().toString());
        return ApiResponse.ok(couponService.listUserCoupons(userId));
    }
}
