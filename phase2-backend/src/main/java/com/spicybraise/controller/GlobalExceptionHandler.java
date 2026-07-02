package com.spicybraise.controller;

import com.spicybraise.common.ApiResponse;
import com.spicybraise.common.BusinessException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

 private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

 @ExceptionHandler(BusinessException.class)
 @ResponseStatus(HttpStatus.BAD_REQUEST)
 public ApiResponse<Void> handleBusiness(BusinessException e) {
 log.warn("Business error: {}", e.getMessage());
 return ApiResponse.fail(e.getCode(), e.getMessage());
 }

 @ExceptionHandler(MethodArgumentNotValidException.class)
 @ResponseStatus(HttpStatus.BAD_REQUEST)
 public ApiResponse<Void> handleValidation(MethodArgumentNotValidException e) {
 String msg = e.getBindingResult().getFieldErrors().stream()
 .map(f -> f.getField() + ": " + f.getDefaultMessage())
 .reduce((a, b) -> a + "; " + b)
 .orElse("Validation failed");
 return ApiResponse.fail(400, msg);
 }

 @ExceptionHandler(Exception.class)
 @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
 public ApiResponse<Void> handleOther(Exception e) {
 log.error("Unexpected error", e);
 return ApiResponse.error("Internal server error: " + e.getMessage());
 }
}
