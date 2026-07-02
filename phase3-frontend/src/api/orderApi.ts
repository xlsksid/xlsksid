import api from './axios';
import type { Order, OrderItem } from '@/types';

export async function placeOrder(
  items: OrderItem[], couponId?: number | null, usePoints?: number, remark?: string
): Promise<Order> {
  const res = await api.post('/orders', { items, couponId, usePoints, remark });
  return res.data.data;
}

export async function listMyOrders(): Promise<Order[]> {
  const res = await api.get('/orders');
  return res.data.data;
}

export async function getOrder(id: number): Promise<Order> {
  const res = await api.get(`/orders/${id}`);
  return res.data.data;
}

export async function simulatePay(orderId: number) {
  const res = await api.post(`/payments/pay/${orderId}`);
  return res.data.data;
}
