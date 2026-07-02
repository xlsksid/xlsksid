import api from './axios';
import type { CouponTemplate, UserCoupon } from '@/types';

export async function listTemplates(): Promise<CouponTemplate[]> {
  const res = await api.get('/coupons/templates');
  return res.data.data;
}

export async function claimCoupon(templateId: number): Promise<UserCoupon> {
  const res = await api.post(`/coupons/claim/${templateId}`);
  return res.data.data;
}

export async function listMyCoupons(): Promise<UserCoupon[]> {
  const res = await api.get('/coupons/my');
  return res.data.data;
}
