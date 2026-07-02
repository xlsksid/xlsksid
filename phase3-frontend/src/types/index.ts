export interface User {
  id: number;
  username: string;
  role: 'admin' | 'staff' | 'customer';
  email?: string;
  phone?: string;
  points: number;
  balance: number;
}

export interface Category {
  id: number;
  name: string;
  description?: string;
  sortOrder: number;
  imageUrl?: string;
}

export interface Product {
  id: number;
  name: string;
  description?: string;
  price: number;
  costPrice: number;
  stock: number;
  unit: string;
  imageUrl?: string;
  categoryId: number;
  spiciness: number;
  isAvailable: boolean;
}

export interface OrderItem {
  productId: number;
  quantity: number;
}

export interface Order {
  id: number;
  orderNo: string;
  totalAmount: number;
  discountAmount: number;
  pointsDeducted: number;
  pointsAmount: number;
  actualAmount: number;
  status: string;
  remark?: string;
  createdAt: string;
}

export interface CouponTemplate {
  id: number;
  name: string;
  type: 'discount' | 'reduction';
  discountRate?: number;
  reductionAmount?: number;
  minOrderAmount: number;
  validDays: number;
}

export interface UserCoupon {
  id: number;
  couponTemplateId: number;
  templateName?: string;
  type?: string;
  discountRate?: number;
  reductionAmount?: number;
  minOrderAmount?: number;
  status: 'unused' | 'used' | 'expired';
  validFrom: string;
  validTo: string;
  usedAt?: string;
}

export interface PointsRecord {
  id: number;
  points: number;
  type: 'earn' | 'spend';
  description: string;
  createdAt: string;
}

export interface Feedback {
  id: number;
  userId: number;
  productId: number;
  orderId: number;
  rating: number;
  comment?: string;
  createdAt: string;
}
