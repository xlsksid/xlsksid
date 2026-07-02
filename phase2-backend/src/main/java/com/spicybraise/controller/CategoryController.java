package com.spicybraise.controller;

import com.spicybraise.common.ApiResponse;
import com.spicybraise.domain.Category;
import com.spicybraise.service.CategoryService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping
    public ApiResponse<List<Category>> list() {
        return ApiResponse.ok(categoryService.listAll());
    }

    @GetMapping("/{id}")
    public ApiResponse<Category> get(@PathVariable Integer id) {
        return ApiResponse.ok(categoryService.getById(id));
    }

    @PostMapping
    public ApiResponse<Category> create(@RequestBody Category category) {
        return ApiResponse.ok(categoryService.create(category));
    }

    @PutMapping("/{id}")
    public ApiResponse<Category> update(@PathVariable Integer id, @RequestBody Category category) {
        return ApiResponse.ok(categoryService.update(id, category));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Integer id) {
        categoryService.delete(id);
        return ApiResponse.ok(null);
    }
}
