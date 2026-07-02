package com.spicybraise.config;

import com.spicybraise.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

 private final JwtAuthenticationFilter jwtFilter;

 public SecurityConfig(JwtAuthenticationFilter jwtFilter) {
 this.jwtFilter = jwtFilter;
 }

 @Bean
 public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
 http
 .cors(cors -> cors.configurationSource(corsConfig()))
 .csrf(csrf -> csrf.disable())
 .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
 .authorizeHttpRequests(auth -> auth
 .requestMatchers("/api/auth/**").permitAll()
 .requestMatchers(HttpMethod.GET, "/api/products/**", "/api/categories/**").permitAll()
 .requestMatchers(HttpMethod.POST, "/api/products/**", "/api/categories/**")
 .hasAnyRole("ADMIN", "STAFF")
 .requestMatchers(HttpMethod.PUT, "/api/products/**", "/api/categories/**")
 .hasAnyRole("ADMIN", "STAFF")
 .requestMatchers(HttpMethod.DELETE, "/api/products/**", "/api/categories/**")
 .hasRole("ADMIN")
 .requestMatchers("/api/orders/**").authenticated()
 .requestMatchers(HttpMethod.GET, "/api/coupons/templates/**").permitAll()
 .requestMatchers("/api/coupons/templates/**").hasAnyRole("ADMIN", "STAFF")
 .requestMatchers("/api/admin/users/**").hasRole("ADMIN")
 .requestMatchers(HttpMethod.DELETE, "/api/admin/feedback/**").hasRole("ADMIN")
 .requestMatchers("/api/admin/**").hasAnyRole("ADMIN", "STAFF")
 .anyRequest().authenticated()
 )
 .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
 return http.build();
 }

 @Bean
 public PasswordEncoder passwordEncoder() {
 return new BCryptPasswordEncoder();
 }

 @Bean
 public AuthenticationManager authenticationManager(AuthenticationConfiguration config)
 throws Exception {
 return config.getAuthenticationManager();
 }

 @Bean
 public CorsConfigurationSource corsConfig() {
 CorsConfiguration cfg = new CorsConfiguration();
 cfg.setAllowedOrigins(List.of("http://localhost:3000", "http://localhost:5173"));
 cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
 cfg.setAllowedHeaders(List.of("*"));
 cfg.setAllowCredentials(true);
 UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
 source.registerCorsConfiguration("/**", cfg);
 return source;
 }
}
