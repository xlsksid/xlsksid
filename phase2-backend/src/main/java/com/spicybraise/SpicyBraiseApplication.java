package com.spicybraise;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.retry.annotation.EnableRetry;

@SpringBootApplication
@MapperScan("com.spicybraise.mapper")
@EnableRetry
public class SpicyBraiseApplication {

 public static void main(String[] args) {
 SpringApplication.run(SpicyBraiseApplication.class, args);
 }
}
