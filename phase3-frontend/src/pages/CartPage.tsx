import { useNavigate } from 'react-router-dom';
import { Card, Table, Button, InputNumber, Popconfirm, Empty, Typography } from 'antd';
import { DeleteOutlined, ShoppingCartOutlined } from '@ant-design/icons';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '@/store';
import { removeFromCart, updateQuantity, clearCart } from '@/store/cartSlice';

export default function CartPage() {
  const items = useSelector((s: RootState) => s.cart.items);
  const dispatch = useDispatch();
  const navigate = useNavigate();

  if (items.length === 0) {
    return (
      <Card>
        <Empty description="购物车是空的">
          <Button type="primary" onClick={() => navigate('/')}>去逛逛</Button>
        </Empty>
      </Card>
    );
  }

  const total = items.reduce((sum, i) => sum + i.price * i.quantity, 0);

  const columns = [
    { title: '商品', dataIndex: 'name', key: 'name' },
    { title: '单价', dataIndex: 'price', key: 'price', render: (v: number) => `¥${v}` },
    {
      title: '数量', dataIndex: 'quantity', key: 'quantity',
      render: (_: number, record: { productId: number; quantity: number }) => (
        <InputNumber min={1} value={record.quantity}
          onChange={v => v && dispatch(updateQuantity({ productId: record.productId, quantity: v }))} />
      ),
    },
    {
      title: '小计', key: 'subtotal',
      render: (_: unknown, r: { price: number; quantity: number }) => `¥${(r.price * r.quantity).toFixed(2)}`,
    },
    {
      title: '操作', key: 'action',
      render: (_: unknown, r: { productId: number }) => (
        <Popconfirm title="确定移除?" onConfirm={() => dispatch(removeFromCart(r.productId))}>
          <Button danger icon={<DeleteOutlined />} size="small" />
        </Popconfirm>
      ),
    },
  ];

  return (
    <Card title="购物车" extra={<Button onClick={() => dispatch(clearCart())}>清空购物车</Button>}>
      <Table dataSource={items} columns={columns} rowKey="productId" pagination={false} />
      <div style={{ textAlign: 'right', marginTop: 24 }}>
        <Typography.Title level={3}>合计: ¥{total.toFixed(2)}</Typography.Title>
        <Button type="primary" size="large" icon={<ShoppingCartOutlined />}
                style={{ background: '#e65100', borderColor: '#e65100' }}
                onClick={() => navigate('/checkout')}>
          去结算
        </Button>
      </div>
    </Card>
  );
}
