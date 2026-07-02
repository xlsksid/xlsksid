import { useEffect, useState } from 'react';
import { Card, Tabs, Table, Button, Modal, Form, Input, InputNumber, Select, Switch, Tag, message, Popconfirm, Space, Typography } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, SendOutlined } from '@ant-design/icons';
import { listProducts, createProduct, updateProduct, deleteProduct, listCategories } from '@/api/productApi';
import type { Product, Category } from '@/types';
import api from '@/api/axios';

const statusLabels: Record<string, string> = {
  pending: '待支付', confirmed: '已确认', preparing: '制作中', delivering: '配送中', completed: '已完成', cancelled: '已取消', refunded: '已退款'
};
const statusColors: Record<string, string> = {
  pending: 'default', confirmed: 'blue', preparing: 'processing', delivering: 'orange', completed: 'green', cancelled: 'red', refunded: 'volcano'
};

export default function AdminPage() {
  return (
    <Card title="后台管理" style={{ borderRadius: 16 }}>
      <Tabs defaultActiveKey="products" items={[
        { key: 'products', label: '商品管理', children: <ProductTab /> },
        { key: 'orders', label: '订单管理', children: <OrderTab /> },
        { key: 'users', label: '用户管理', children: <UserTab /> },
        { key: 'feedback', label: '评价管理', children: <FeedbackTab /> },
        { key: 'coupons', label: '发券管理', children: <CouponTab /> },
      ]} />
    </Card>
  );
}

// ========== 商品管理 Tab ==========
function ProductTab() {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);
  const [form] = Form.useForm();

  const load = async () => {
    setLoading(true);
    const [p, c] = await Promise.all([listProducts(), listCategories()]);
    setProducts(p); setCategories(c); setLoading(false);
  };
  useEffect(() => { load(); }, []);

  const openCreate = () => { setEditing(null); form.resetFields(); setModalOpen(true); };
  const openEdit = (p: Product) => { setEditing(p); form.setFieldsValue(p); setModalOpen(true); };
  const handleSave = async () => {
    const values = await form.validateFields();
    editing ? (await updateProduct(editing.id, values), message.success('已更新')) : (await createProduct(values), message.success('已创建'));
    setModalOpen(false); load();
  };
  const handleDelete = async (id: number) => { await deleteProduct(id); message.success('已删除'); load(); };

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 50 },
    { title: '名称', dataIndex: 'name' },
    { title: '单价', dataIndex: 'price', render: (v: number) => `¥${v}` },
    { title: '库存', dataIndex: 'stock' },
    { title: '辣度', dataIndex: 'spiciness', render: (v: number) => '🌶'.repeat(v) },
    { title: '上架', dataIndex: 'isAvailable', render: (v: boolean) => v ? '✅' : '❌' },
    { title: '操作', render: (_: unknown, r: Product) => (
        <Space>
          <Button icon={<EditOutlined />} size="small" onClick={() => openEdit(r)}>编辑</Button>
          <Popconfirm title="确定删除?" onConfirm={() => handleDelete(r.id)}>
            <Button icon={<DeleteOutlined />} size="small" danger>删除</Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Button type="primary" icon={<PlusOutlined />} onClick={openCreate} style={{ background: '#e65100', borderColor: '#e65100', marginBottom: 16 }}>新增商品</Button>
      <Table dataSource={products} columns={columns} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />
      <Modal title={editing ? '编辑商品' : '新增商品'} open={modalOpen} onOk={handleSave} onCancel={() => setModalOpen(false)}>
        <Form form={form} layout="vertical">
          <Form.Item name="name" label="名称" rules={[{ required: true }]}><Input /></Form.Item>
          <Form.Item name="price" label="单价" rules={[{ required: true }]}><InputNumber min={0} precision={2} style={{ width: '100%' }} /></Form.Item>
          <Form.Item name="stock" label="库存" rules={[{ required: true }]}><InputNumber min={0} style={{ width: '100%' }} /></Form.Item>
          <Form.Item name="unit" label="单位" initialValue="份"><Input /></Form.Item>
          <Form.Item name="categoryId" label="分类" rules={[{ required: true }]}><Select options={categories.map(c => ({ value: c.id, label: c.name }))} /></Form.Item>
          <Form.Item name="spiciness" label="辣度(1-5)" initialValue={1}><InputNumber min={1} max={5} style={{ width: '100%' }} /></Form.Item>
          <Form.Item name="isAvailable" label="上架" valuePropName="checked" initialValue={true}><Switch /></Form.Item>
        </Form>
      </Modal>
    </div>
  );
}

// ========== 订单管理 Tab ==========
function OrderTab() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const load = async () => {
    setLoading(true);
    try { const res = await api.get('/admin/orders'); setOrders(res.data.data || []); } catch {}
    setLoading(false);
  };
  useEffect(() => { load(); }, []);

  const updateStatus = async (id: number, status: string) => {
    try { await api.put(`/admin/orders/${id}/status`, { status }); message.success('状态已更新'); load(); } catch {}
  };

  const columns = [
    { title: '订单号', dataIndex: 'orderNo', ellipsis: true },
    { title: '用户ID', dataIndex: 'userId', width: 70 },
    { title: '总额', dataIndex: 'totalAmount', render: (v: number) => `¥${v}` },
    { title: '实付', dataIndex: 'actualAmount', render: (v: number) => `¥${v}` },
    { title: '状态', dataIndex: 'status', render: (s: string) => <Tag color={statusColors[s]}>{statusLabels[s]}</Tag> },
    { title: '操作', render: (_: unknown, r: any) => (
        <Select size="small" value={r.status} style={{ width: 120 }} onChange={(v) => updateStatus(r.id, v)}
          options={Object.entries(statusLabels).map(([k, v]) => ({ value: k, label: v }))} />
      ),
    },
  ];
  return <Table dataSource={orders} columns={columns} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />;
}

// ========== 用户管理 Tab ==========
function UserTab() {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const load = async () => {
    setLoading(true);
    try { const res = await api.get('/admin/users'); setUsers(res.data.data || []); } catch {}
    setLoading(false);
  };
  useEffect(() => { load(); }, []);

  const toggleUser = async (id: number) => {
    try { await api.put(`/admin/users/${id}/toggle`); message.success('已切换'); load(); } catch {}
  };

  const levelIcons: Record<string, string> = { platinum: '💎', gold: '🥇', silver: '🥈', bronze: '🥉' };

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 50 },
    { title: '用户名', dataIndex: 'username' },
    { title: '角色', dataIndex: 'role', render: (v: string) => <Tag>{v}</Tag> },
    { title: '积分', dataIndex: 'points' },
    { title: '会员', dataIndex: 'membershipLevel', render: (v: string) => levelIcons[v] + ' ' + v },
    { title: '状态', dataIndex: 'isDeleted', render: (v: boolean) => v ? <Tag color="red">已禁用</Tag> : <Tag color="green">正常</Tag> },
    { title: '操作', render: (_: unknown, r: any) => (
        <Popconfirm title="切换用户状态?" onConfirm={() => toggleUser(r.id)}>
          <Button size="small" danger={!r.isDeleted}>{r.isDeleted ? '启用' : '禁用'}</Button>
        </Popconfirm>
      ),
    },
  ];
  return <Table dataSource={users} columns={columns} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />;
}

// ========== 评价管理 Tab ==========
function FeedbackTab() {
  const [list, setList] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const load = async () => {
    setLoading(true);
    try { const res = await api.get('/admin/feedback'); setList(res.data.data || []); } catch {}
    setLoading(false);
  };
  useEffect(() => { load(); }, []);

  const handleDelete = async (id: number) => {
    try { await api.delete(`/admin/feedback/${id}`); message.success('已删除'); load(); } catch {}
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 50 },
    { title: '用户ID', dataIndex: 'userId', width: 70 },
    { title: '商品ID', dataIndex: 'productId', width: 70 },
    { title: '评分', dataIndex: 'rating', render: (v: number) => '⭐'.repeat(v) },
    { title: '内容', dataIndex: 'comment', ellipsis: true },
    { title: '操作', render: (_: unknown, r: any) => (
        <Popconfirm title="确定删除?" onConfirm={() => handleDelete(r.id)}>
          <Button icon={<DeleteOutlined />} size="small" danger />
        </Popconfirm>
      ),
    },
  ];
  return <Table dataSource={list} columns={columns} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />;
}

// ========== 发券管理 Tab ==========
function CouponTab() {
  const [users, setUsers] = useState<any[]>([]);
  const [templates, setTemplates] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    api.get('/admin/users').then(r => setUsers(r.data.data || [])).catch(() => {});
    api.get('/coupons/templates').then(r => setTemplates(r.data.data || [])).catch(() => {});
  }, []);

  const grantCoupon = async (values: any) => {
    setLoading(true);
    try { await api.post('/admin/coupons/grant', values); message.success('发券成功!'); } catch {}
    setLoading(false);
  };

  return (
    <div>
      <Typography.Title level={5}>给指定用户发券</Typography.Title>
      <Form layout="inline" onFinish={grantCoupon}>
        <Form.Item name="userId" label="用户" rules={[{ required: true }]}>
          <Select placeholder="选择用户" style={{ width: 200 }} showSearch
            filterOption={(input, option) => (option?.label as string || '').includes(input)}
            options={users.filter(u => u.role === 'customer').map(u => ({ value: u.id, label: `${u.username}(ID:${u.id})` }))} />
        </Form.Item>
        <Form.Item name="templateId" label="优惠券" rules={[{ required: true }]}>
          <Select placeholder="选择券模板" style={{ width: 250 }}
            options={templates.map((t: any) => ({ value: t.id, label: `${t.name} (${t.type === 'discount' ? ((1-t.discountRate)*100).toFixed(0)+'%' : '¥'+t.reductionAmount})` }))} />
        </Form.Item>
        <Form.Item>
          <Button type="primary" htmlType="submit" icon={<SendOutlined />} loading={loading} style={{ background: '#e65100', borderColor: '#e65100' }}>发券</Button>
        </Form.Item>
      </Form>
    </div>
  );
}
