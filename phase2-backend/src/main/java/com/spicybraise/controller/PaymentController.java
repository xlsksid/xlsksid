package com.spicybraise.controller;

import com.spicybraise.common.ApiResponse;
import com.spicybraise.domain.Payment;
import com.spicybraise.service.PaymentService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/pay/{orderId}")
    public ApiResponse<Payment> pay(@PathVariable Long orderId, Authentication auth) {
        Long userId = Long.valueOf(auth.getPrincipal().toString());
        return ApiResponse.ok(paymentService.simulatePay(orderId, userId));
    }
}
