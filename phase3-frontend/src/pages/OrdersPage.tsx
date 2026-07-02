import { useEffect, useState } from 'react';
import { Card, Table, Tag } from 'antd';
import { listMyOrders } from '@/api/orderApi';
import type { Order } from '@/types';

const statusLabels: Record<string, string> = {
  pending: '待支付', confirmed: '已确认', preparing: '制作中',
  delivering: '配送中', completed: '已完成', cancelled: '已取消', refunded: '已退款',
};
const statusColors: Record<string, string> = {
  pending: 'default', confirmed: 'blue', preparing: 'processing',
  delivering: 'orange', completed: 'green', cancelled: 'red', refunded: 'volcano',
};

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    listMyOrders().then(setOrders).finally(() => setLoading(false));
  }, []);

  const columns = [
    { title: '订单号', dataIndex: 'orderNo', key: 'orderNo', ellipsis: true },
    { title: '总额', dataIndex: 'totalAmount', key: 'total', render: (v: number) => `¥${v}` },
    { title: '优惠', dataIndex: 'discountAmount', key: 'discount', render: (v: number) => `-¥${v}` },
    { title: '实付', dataIndex: 'actualAmount', key: 'actual', render: (v: number) => `¥${v}` },
    {
      title: '状态', dataIndex: 'status', key: 'status',
      render: (s: string) => <Tag color={statusColors[s]}>{statusLabels[s] || s}</Tag>,
    },
    { title: '时间', dataIndex: 'createdAt', key: 'time', render: (v: string) => new Date(v).toLocaleString() },
  ];

  return (
    <Card title="我的订单">
      <Table dataSource={orders} columns={columns} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />
    </Card>
  );
}
