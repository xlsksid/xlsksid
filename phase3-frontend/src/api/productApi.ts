import api from './axios';
import type { Product, Category } from '@/types';

export async function listProducts(categoryId?: number): Promise<Product[]> {
  const params = categoryId ? { categoryId } : {};
  const res = await api.get('/products', { params });
  return res.data.data;
}

export async function getProduct(id: number): Promise<Product> {
  const res = await api.get(`/products/${id}`);
  return res.data.data;
}

export async function createProduct(data: Partial<Product>): Promise<Product> {
  const res = await api.post('/products', data);
  return res.data.data;
}

export async function updateProduct(id: number, data: Partial<Product>): Promise<Product> {
  const res = await api.put(`/products/${id}`, data);
  return res.data.data;
}

export async function deleteProduct(id: number) {
  await api.delete(`/products/${id}`);
}

export async function listCategories(): Promise<Category[]> {
  const res = await api.get('/categories');
  return res.data.data;
}
