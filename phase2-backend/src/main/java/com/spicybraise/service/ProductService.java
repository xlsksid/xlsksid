package com.spicybraise.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.spicybraise.common.BusinessException;
import com.spicybraise.domain.Product;
import com.spicybraise.mapper.ProductMapper;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ProductService {

 private final ProductMapper productMapper;

 public ProductService(ProductMapper productMapper) {
 this.productMapper = productMapper;
 }

 public List<Product> listAvailable() {
 return productMapper.selectList(new LambdaQueryWrapper<Product>()
 .eq(Product::getIsDeleted, false)
 .eq(Product::getIsAvailable, true)
 .orderByAsc(Product::getCategoryId));
 }

 public List<Product> listByCategory(Integer categoryId) {
 return productMapper.selectList(new LambdaQueryWrapper<Product>()
 .eq(Product::getIsDeleted, false)
 .eq(Product::getIsAvailable, true)
 .eq(Product::getCategoryId, categoryId));
 }

 public Product getById(Long id) {
 Product p = productMapper.selectById(id);
 if (p == null || Boolean.TRUE.equals(p.getIsDeleted())) {
 throw new BusinessException(404, "Product not found");
 }
 return p;
 }

 public Product create(Product product) {
 productMapper.insert(product);
 return product;
 }

 public Product update(Long id, Product product) {
 getById(id);
 product.setId(id);
 productMapper.updateById(product);
 return productMapper.selectById(id);
 }

 public void delete(Long id) {
 getById(id);
 productMapper.deleteById(id);
 }
}
