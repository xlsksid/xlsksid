import api from './axios';
import type { Feedback } from '@/types';

export async function submitFeedback(data: {
  productId: number; orderId: number; rating: number; comment?: string;
}): Promise<Feedback> {
  const res = await api.post('/feedback', data);
  return res.data.data;
}

export async function listProductReviews(productId: number): Promise<Feedback[]> {
  const res = await api.get(`/feedback/product/${productId}`);
  return res.data.data;
}
