package com.spicybraise.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Base64;
import java.util.Date;

@Component
public class JwtTokenProvider {

 private final SecretKey key;
 private final long expirationMs;

 public JwtTokenProvider(
 @Value("${app.jwt.secret}") String secret,
 @Value("${app.jwt.expiration-ms}") long expirationMs) {
 this.key = Keys.hmacShaKeyFor(Base64.getDecoder().decode(secret));
 this.expirationMs = expirationMs;
 }

 public String generateToken(Long userId, String username, String role) {
 Date now = new Date();
 return Jwts.builder()
 .subject(userId.toString())
 .claim("username", username)
 .claim("role", role)
 .issuedAt(now)
 .expiration(new Date(now.getTime() + expirationMs))
 .signWith(key)
 .compact();
 }

 public Claims validateToken(String token) {
 return Jwts.parser()
 .verifyWith(key)
 .build()
 .parseSignedClaims(token)
 .getPayload();
 }

 public Long getUserId(Claims claims) {
 return Long.valueOf(claims.getSubject());
 }

 public String getRole(Claims claims) {
 return claims.get("role", String.class);
 }
}
