import { useEffect, useState } from 'react';
import { Card, Table } from 'antd';
import { listTemplates } from '@/api/couponApi';
import type { CouponTemplate } from '@/types';

export default function CouponManagePage() {
  const [templates, setTemplates] = useState<CouponTemplate[]>([]);

  useEffect(() => { listTemplates().then(setTemplates); }, []);

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '名称', dataIndex: 'name' },
    { title: '类型', dataIndex: 'type', render: (v: string) => v === 'discount' ? '折扣券' : '满减券' },
    { title: '优惠', key: 'discount',
      render: (_: unknown, r: CouponTemplate) =>
        r.type === 'discount' ? `${((1 - (r.discountRate || 1)) * 100).toFixed(0)}%` : `-¥${r.reductionAmount}` },
    { title: '最低消费', dataIndex: 'minOrderAmount', render: (v: number) => `¥${v}` },
    { title: '有效天数', dataIndex: 'validDays' },
  ];

  return (
    <Card title="优惠券模板">
      <Table dataSource={templates} columns={columns} rowKey="id" pagination={false} />
    </Card>
  );
}
