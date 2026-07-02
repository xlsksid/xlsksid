package com.spicybraise.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.spicybraise.common.BusinessException;
import com.spicybraise.domain.Category;
import com.spicybraise.mapper.CategoryMapper;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class CategoryService {

 private final CategoryMapper categoryMapper;

 public CategoryService(CategoryMapper categoryMapper) {
 this.categoryMapper = categoryMapper;
 }

 public List<Category> listAll() {
 return categoryMapper.selectList(new LambdaQueryWrapper<Category>()
 .eq(Category::getIsDeleted, false)
 .orderByAsc(Category::getSortOrder));
 }

 public Category getById(Integer id) {
 Category c = categoryMapper.selectById(id);
 if (c == null || Boolean.TRUE.equals(c.getIsDeleted())) {
 throw new BusinessException(404, "Category not found");
 }
 return c;
 }

 public Category create(Category category) {
 categoryMapper.insert(category);
 return category;
 }

 public Category update(Integer id, Category category) {
 getById(id);
 category.setId(id);
 categoryMapper.updateById(category);
 return categoryMapper.selectById(id);
 }

 public void delete(Integer id) {
 getById(id);
 categoryMapper.deleteById(id);
 }
}
