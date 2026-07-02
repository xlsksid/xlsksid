import { useEffect, useState } from 'react';
import { Card, Table } from 'antd';
import { listCategories } from '@/api/productApi';
import type { Category } from '@/types';

export default function CategoryManagePage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    listCategories().then(setCategories).finally(() => setLoading(false));
  }, []);

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '名称', dataIndex: 'name' },
    { title: '描述', dataIndex: 'description' },
    { title: '排序', dataIndex: 'sortOrder' },
  ];

  return (
    <Card title="分类管理">
      <Table dataSource={categories} columns={columns} rowKey="id" loading={loading} pagination={false} />
    </Card>
  );
}
