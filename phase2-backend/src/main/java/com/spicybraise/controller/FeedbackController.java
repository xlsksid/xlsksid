package com.spicybraise.controller;

import com.spicybraise.common.ApiResponse;
import com.spicybraise.domain.Feedback;
import com.spicybraise.service.FeedbackService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/feedback")
public class FeedbackController {

    private final FeedbackService feedbackService;

    public FeedbackController(FeedbackService feedbackService) {
        this.feedbackService = feedbackService;
    }

    @PostMapping
    public ApiResponse<Feedback> submit(Authentication auth, @RequestBody Feedback feedback) {
        Long userId = Long.valueOf(auth.getPrincipal().toString());
        return ApiResponse.ok(feedbackService.submit(userId, feedback));
    }

    @GetMapping("/product/{productId}")
    public ApiResponse<List<Feedback>> listByProduct(@PathVariable Long productId) {
        return ApiResponse.ok(feedbackService.listByProduct(productId));
    }
}
