import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Form, Input, Select, Button, Radio, Typography, Divider, message, Spin } from 'antd';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '@/store';
import { clearCart } from '@/store/cartSlice';
import { placeOrder, simulatePay } from '@/api/orderApi';
import { listMyCoupons } from '@/api/couponApi';
import type { UserCoupon } from '@/types';

export default function CheckoutPage() {
  const items = useSelector((s: RootState) => s.cart.items);
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [coupons, setCoupons] = useState<UserCoupon[]>([]);
  const [loading, setLoading] = useState(false);
  const [orderPlaced, setOrderPlaced] = useState<{ id: number; no: string; amount: number } | null>(null);
  const [form] = Form.useForm();

  useEffect(() => {
    if (items.length === 0) navigate('/cart');
    else listMyCoupons().then(setCoupons).catch(() => {});
  }, []);

  const totalBefore = items.reduce((s, i) => s + i.price * i.quantity, 0);
  const watchCoupon = Form.useWatch('couponId', form);
  const watchPoints = Form.useWatch('usePoints', form) || 0;

  const selectedCoupon = coupons.find(c => c.id === watchCoupon);
  let discount = 0;
  if (selectedCoupon) {
    discount = selectedCoupon.type === 'discount'
      ? totalBefore * (1 - (selectedCoupon.discountRate || 1))
      : (selectedCoupon.reductionAmount || 0);
  }
  const pointsDiscount = watchPoints / 100;
  const actual = Math.max(0, totalBefore - discount - pointsDiscount);

  const handlePlaceOrder = async () => {
    setLoading(true);
    try {
      const order = await placeOrder(
        items.map(i => ({ productId: i.productId, quantity: i.quantity })),
        watchCoupon || null, watchPoints, form.getFieldValue('remark')
      );
      setOrderPlaced({ id: order.orderId, no: order.orderNo, amount: order.actualAmount });
      message.success('下单成功!');
    } catch { /* handled */ }
    finally { setLoading(false); }
  };

  const handlePay = async () => {
    if (!orderPlaced) return;
    setLoading(true);
    try {
      await simulatePay(orderPlaced.id);
      message.success('支付成功!');
      dispatch(clearCart());
      navigate('/orders');
    } catch { /* handled */ }
    finally { setLoading(false); }
  };

  if (orderPlaced) {
    return (
      <Card title="订单已确认" style={{ maxWidth: 500, margin: '0 auto' }}>
        <Typography.Text>订单号: <strong>{orderPlaced.no}</strong></Typography.Text><br />
        <Typography.Text>应付金额: <strong>¥{orderPlaced.amount.toFixed(2)}</strong></Typography.Text>
        <Divider />
        <Button type="primary" block size="large" loading={loading}
                style={{ background: '#e65100', borderColor: '#e65100' }}
                onClick={handlePay}>
          模拟支付
        </Button>
      </Card>
    );
  }

  return (
    <Card title="结算" style={{ maxWidth: 600, margin: '0 auto' }}>
      <Spin spinning={loading}>
        {items.map(i => (
          <div key={i.productId} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
            <span>{i.name} x {i.quantity}</span>
            <span>¥{(i.price * i.quantity).toFixed(2)}</span>
          </div>
        ))}
        <Divider />
        <Typography.Text>小计: ¥{totalBefore.toFixed(2)}</Typography.Text>

        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item name="couponId" label="优惠券">
            <Select allowClear placeholder="选择优惠券" options={coupons
              .filter(c => c.status === 'unused' && totalBefore >= (c.minOrderAmount || 0))
              .map(c => ({
                value: c.id,
                label: `${c.templateName || '优惠券#' + c.id} (-¥${discount})`,
              }))}
            />
          </Form.Item>
          <Form.Item name="usePoints" label="使用积分 (100分 = ¥1)">
            <Radio.Group>
              {[0, 100, 200, 500].map(v => (
                <Radio.Button key={v} value={v}>{v > 0 ? `${v}分` : '不用'}</Radio.Button>
              ))}
            </Radio.Group>
          </Form.Item>
          <Form.Item name="remark" label="备注">
            <Input.TextArea rows={2} placeholder="加辣、不要香菜..." />
          </Form.Item>
        </Form>

        <Typography.Title level={4} style={{ color: '#e65100' }}>
          应付: ¥{actual.toFixed(2)}
          {discount > 0 && <span style={{ fontSize: 14, color: '#52c41a' }}> (已省 ¥{discount.toFixed(2)})</span>}
        </Typography.Title>

        <Button type="primary" block size="large" onClick={handlePlaceOrder}
                style={{ background: '#e65100', borderColor: '#e65100' }}>
          提交订单
        </Button>
      </Spin>
    </Card>
  );
}
